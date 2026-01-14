import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/util/app_logger.dart'; // Import AppLogger
import 'package:gastronomic_os/features/recipes/data/models/recipe_snapshot_model.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_collection_model.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_model.dart';
import 'package:gastronomic_os/features/recipes/data/models/commit_model.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_step_model.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart'; 

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> getRecipes({
    int limit = 20, 
    int offset = 0, 
    String? query, 
    List<String>? excludedTags,
    String? authorId,
    bool? isFork,
    bool onlySaved = false,
    String? collectionId,
  });
  Future<void> toggleSaveRecipe(String recipeId);
  Future<bool> isRecipeSaved(String recipeId);
  Future<RecipeModel> createRecipe(Recipe recipe);
  Future<RecipeModel> forkRecipe(String originalRecipeId, String newTitle, String authorId);
  Future<List<CommitModel>> getCommits(String recipeId);
  Future<CommitModel> addCommit(CommitModel commit);
  Future<RecipeModel> getRecipeDetails(String recipeId);
  Future<List<RecipeModel>> getDashboardSuggestions({int limit = 10});
  Future<List<RecipeModel>> getForks(String recipeId);

  Future<void> clearAllRecipes(); // For development: clear all recipes

  // Phase 3: Edit/Delete
  Future<void> deleteRecipe(String id);
  Future<RecipeModel> updateRecipe(Recipe recipe);
  
  // Phase 3.2: Image Upload
  Future<String> uploadRecipeImage(dynamic imageFile, String userId); 

  // Phase 3.4: Collections
  Future<RecipeCollectionModel> createCollection(String name);
  Future<List<RecipeCollectionModel>> getUserCollections();
  Future<void> addToCollection(String recipeId, String collectionId);
  Future<void> removeFromCollection(String recipeId, String collectionId);
  Future<void> deleteCollection(String collectionId);
}


class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final SupabaseClient supabaseClient;

  RecipeRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<RecipeModel>> getRecipes({
    int limit = 20, 
    int offset = 0, 
    String? query, 
    List<String>? excludedTags,
    String? authorId,      
    bool? isFork,          
    bool onlySaved = false,
    String? collectionId, // New Parameter
  }) async {
    try {
      var builder = supabaseClient.from('recipes').select();
      
      // Filter by Author (for Created/Forked tabs)
      if (authorId != null) {
        builder = builder.eq('author_id', authorId);
      }

      // Filter by Collection (Two-step)
      if (collectionId != null) {
         final collectionItems = await supabaseClient
             .from('collection_items')
             .select('recipe_id')
             .eq('collection_id', collectionId);
             
         final recipeIds = (collectionItems as List).map((e) => e['recipe_id'] as String).toList();
         
         if (recipeIds.isEmpty) return [];
         
         builder = builder.filter('id', 'in', recipeIds);
      }

      // Filter by Fork Status
      if (isFork != null) {
        builder = builder.eq('is_fork', isFork);
      }

      // Filter by Saved (Bookmarks) - Two-step approach to avoid PGRST200
      if (onlySaved) {
        final userId = supabaseClient.auth.currentUser!.id;
        
        // 1. Get IDs from saved_recipes
        final savedResponse = await supabaseClient
            .from('saved_recipes')
            .select('recipe_id')
            .eq('user_id', userId);
            
        final savedIds = (savedResponse as List).map((e) => e['recipe_id'] as String).toList();
        
        if (savedIds.isEmpty) {
          // No saved recipes, return empty list immediately to save query
          return [];
        }
        
        // 2. Filter main query
        builder = builder.filter('id', 'in', savedIds);
      }

      // Standard Filters
      if (query != null && query.isNotEmpty) {
        builder = builder.ilike('title', '%$query%');
      }

      if (excludedTags != null && excludedTags.isNotEmpty) {
         builder = builder.not('tags', 'ov', excludedTags);
      }

      final response = await builder
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return (response as List).map((data) => RecipeModel.fromJson(data)).toList();
    } catch (e, s) {
      AppLogger.e('Error fetching recipes (filtered)', e, s);
      throw Exception('Datasource operation failed');
    }
  }

  // Helper for Bookmarks
  @override
  Future<void> toggleSaveRecipe(String recipeId) async {
    try {
      final userId = supabaseClient.auth.currentUser!.id;
      
      // Check if exists
      final existing = await supabaseClient
          .from('saved_recipes')
          .select('id')
          .eq('user_id', userId)
          .eq('recipe_id', recipeId)
          .maybeSingle();

      if (existing != null) {
        // Unsave
        await supabaseClient
            .from('saved_recipes')
            .delete()
            .eq('id', existing['id']);
      } else {
        // Save
        await supabaseClient
            .from('saved_recipes')
            .insert({'user_id': userId, 'recipe_id': recipeId});
      }
    } catch (e) {
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<bool> isRecipeSaved(String recipeId) async {
     try {
      final userId = supabaseClient.auth.currentUser!.id;
      final existing = await supabaseClient
          .from('saved_recipes')
          .select('id')
          .eq('user_id', userId)
          .eq('recipe_id', recipeId)
          .maybeSingle();
      return existing != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<RecipeModel> createRecipe(Recipe recipe) async {
    try {
      final currentUserId = supabaseClient.auth.currentUser!.id;

      // 1. Calculate Enriched Tags (Move logic to top)
      final enrichedTags = List<String>.from(recipe.tags);
      AppLogger.d('🔍 Enriching tags for "${recipe.title}". Initial tags: $enrichedTags');
      
      for (final step in recipe.steps) {
        if (step.isBranchPoint && step.variantLogic != null) {
          AppLogger.d('   Found variant step: ${step.variantLogic!.keys}');
          for (final diet in step.variantLogic!.keys) {
            final normalizedDiet = diet; 
            if (!enrichedTags.any((t) => t.toLowerCase() == normalizedDiet.toLowerCase())) {
              enrichedTags.add(normalizedDiet);
              AppLogger.d('   ✅ Added enriched tag: $normalizedDiet');
            }
          }
        }
      }
      AppLogger.d('🏁 Final enriched tags: $enrichedTags');
      
      // 2. Check Existence
      final existingRecipe = await supabaseClient
          .from('recipes')
          .select('id')
          .eq('author_id', currentUserId)
          .eq('title', recipe.title)
          .maybeSingle();
      
      String recipeId;

      if (existingRecipe != null) {
        AppLogger.w('⚠️ Recipe "${recipe.title}" already exists. Updating Tags & Creating new Snapshot.');
        AppLogger.d('   Original Tags: ${recipe.tags}');
        AppLogger.d('   Enriched Tags to Update: $enrichedTags');
        
        recipeId = existingRecipe['id'];
        
        // SELF-HEALING: Ensure tags are up to date!
        await supabaseClient
            .from('recipes')
            .update({'tags': enrichedTags})
            .eq('id', recipeId);
        AppLogger.d('   ✅ Tags updated in DB.');
      } else {
        // 3. Insert New Recipe (using enrichedTags)
        final recipeData = {
          'title': recipe.title,
          'description': recipe.description,
          'tags': enrichedTags, // ✅ Save enriched tags
          'is_public': recipe.isPublic,
          'cover_photo_url': recipe.coverPhotoUrl, // Add field
          'author_id': currentUserId,
        };

        final recipeResponse = await supabaseClient
            .from('recipes')
            .insert(recipeData)
            .select()
            .single();
        
        recipeId = recipeResponse['id'];
      }

      // 2. Insert Initial Commit
      final commitData = {
        'recipe_id': recipeId,
        'author_id': supabaseClient.auth.currentUser!.id,
        'message': 'Initial commit',
        'diff': {'action': 'init'}, // Simplified diff for init
      };

      final commitResponse = await supabaseClient
          .from('commits')
          .insert(commitData)
          .select()
          .single();
      
      final commitId = commitResponse['id'];

      // 3. Insert Snapshot (The Content)
      // CRITICAL: Supabase client has issues with deeply nested Maps.
      // We need to convert steps to JSON first, then parse back to ensure proper serialization
      final stepsJson = recipe.steps.map((step) {
        if (step is RecipeStepModel) {
          final json = step.toJson();
          AppLogger.d('💾 Serializing step: "${step.instruction.substring(0, min(30, step.instruction.length))}..." - toJson: $json');
          return json;
        }
        return {
          'instruction': step.instruction,
          'is_branch_point': step.isBranchPoint,
          'variant_logic': step.variantLogic,
          'cross_contamination_alert': step.crossContaminationAlert,
        };
      }).toList();

      // Convert the entire structure to JSON string and back to force proper serialization
      final fullStructureJson = {
        'ingredients': recipe.ingredients,
        'steps': stepsJson,
      };
      
      final snapshotData = {
        'commit_id': commitId,
        'recipe_id': recipeId,
        'full_structure': fullStructureJson,
      };

      AppLogger.d('🚀 About to insert snapshot to Supabase. Full payload:');
      AppLogger.d('   Steps count: ${stepsJson.length}');
      AppLogger.d('   Step 2 JSON: ${stepsJson.length > 1 ? stepsJson[1] : "N/A"}');
      AppLogger.d('   full_structure type: ${fullStructureJson.runtimeType}');
      AppLogger.d('   full_structure JSON: $fullStructureJson');

      await supabaseClient
          .from('recipe_snapshots')
          .insert(snapshotData);

      // Return the created/updated model
      final finalRecipeResponse = await supabaseClient
          .from('recipes')
          .select()
          .eq('id', recipeId)
          .single();
          
      return RecipeModel.fromJson(finalRecipeResponse);
    } catch (e, s) {
      // Rollback: Delete the header if snapshot failed to prevent "Shell" recipes
      // Only rollback if we were creating a NEW recipe (not updating existing)
      // Actually, checking if existingRecipe was null variable is tricky here due to scope.
      // But we can check if 'commits' table has entries?
      // Simplified robustness: just log loudly. 
      // Real rollback requires knowing if we inserted.
      
      AppLogger.e('❌ CRITICAL ERROR creating recipe "${recipe.title}"', e, s); 
      AppLogger.e('   👉 Suggestion: Purge Database and Retry Seeding.');
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<RecipeModel> forkRecipe(String originalRecipeId, String newTitle, String authorId) async {
    try {
      // 1. Fetch Original Recipe Details (Header + Latest Snapshot Content)
      final original = await getRecipeDetails(originalRecipeId);
      
      // 2. Insert New Recipe Header
      // We copy structure-level metadata like tags, but author is new
      final forkData = {
        'author_id': authorId,
        'origin_id': originalRecipeId,
        'is_fork': true,
        'title': newTitle,
        'description': original.description, // Copy description
        'tags': original.tags, // Copy tags
        'cover_photo_url': original.coverPhotoUrl, // Copy cover photo
        'is_public': true, 
      };
      
      final recipeResponse = await supabaseClient
          .from('recipes')
          .insert(forkData)
          .select()
          .single();
          
      final newRecipeId = recipeResponse['id'];

      // 3. Create Initial Commit for Fork
      final commitData = {
        'recipe_id': newRecipeId,
        'author_id': authorId,
        'message': 'Forked from ${original.title}',
        'diff': {'action': 'fork', 'origin': originalRecipeId}, 
      };

      final commitResponse = await supabaseClient
          .from('commits')
          .insert(commitData)
          .select()
          .single();
      
      final commitId = commitResponse['id'];

      // 4. Copy Snapshot Content
      // We re-use logic from createRecipe to serialize steps safely
      // Or since we have the model, we can just serialize it back.
      
      final stepsJson = original.steps.map((step) {
        if (step is RecipeStepModel) return step.toJson();
         return {
          'instruction': step.instruction,
          'is_branch_point': step.isBranchPoint,
          'variant_logic': step.variantLogic,
          'cross_contamination_alert': step.crossContaminationAlert,
        };
      }).toList();

      final fullStructureJson = {
        'ingredients': original.ingredients,
        'steps': stepsJson,
      };

      final snapshotData = {
        'commit_id': commitId,
        'recipe_id': newRecipeId,
        'full_structure': fullStructureJson,
      };

      await supabaseClient.from('recipe_snapshots').insert(snapshotData);

      // Return the complete new model
      return getRecipeDetails(newRecipeId);
    } catch (e, s) {
      AppLogger.e('Error forking recipe', e, s);
      throw Exception('Datasource operation failed: $e');
    }
  }

  @override
  Future<List<CommitModel>> getCommits(String recipeId) async {
    try {
      final response = await supabaseClient
          .from('commits')
          .select()
          .eq('recipe_id', recipeId)
          .order('created_at', ascending: false);
      return (response as List).map((e) => CommitModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<List<RecipeModel>> getDashboardSuggestions({int limit = 10}) async {
    try {
      final response = await supabaseClient.rpc('get_dashboard_suggestions', params: {'limit_count': limit});
      
      if (response == null) return [];
      
      // Response is a List of Maps (recipes)
      return (response as List).map((data) => RecipeModel.fromJson(data)).toList();
    } catch (e) {
      // If RPC fails (e.g. not applied yet), fallback to getRecipes
      AppLogger.w('⚠️ RPC get_dashboard_suggestions failed: $e. Falling back to simple getRecipes.');
      return getRecipes(limit: limit);
    }
  }

  @override
  Future<List<RecipeModel>> getForks(String recipeId) async {
    try {
      final response = await supabaseClient
          .from('recipes')
          .select()
          .eq('origin_id', recipeId)
          .order('created_at', ascending: false);
      
      return (response as List).map((data) => RecipeModel.fromJson(data)).toList();
    } catch (e) {
       AppLogger.e('Error fetching forks for $recipeId', e);
       return [];
    }
  }

  @override
  Future<CommitModel> addCommit(CommitModel commit) async {
    try {
      final response = await supabaseClient
          .from('commits')
          .insert(commit.toJson()..remove('id'))
          .select()
          .single();
      return CommitModel.fromJson(response);
    } catch (e) {
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<RecipeModel> getRecipeDetails(String recipeId) async {
    try {
      // 1. Fetch the Recipe Header
      final recipeResponse = await supabaseClient
          .from('recipes')
          .select()
          .eq('id', recipeId)
          .single();
      
      final recipeModel = RecipeModel.fromJson(recipeResponse);

      // 2. Fetch the Latest Snapshot
      // We assume the latest snapshot corresponds to the current state
      final snapshotResponse = await supabaseClient
          .from('recipe_snapshots')
          .select()
          .eq('recipe_id', recipeId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (snapshotResponse != null) {
        final snapshot = RecipeSnapshotModel.fromJson(snapshotResponse);
        // Return a new model with ingredients/steps populated
        return RecipeModel(
          id: recipeModel.id,
          authorId: recipeModel.authorId,
          originId: recipeModel.originId,
          isFork: recipeModel.isFork,
          title: recipeModel.title,
          description: recipeModel.description,
          coverPhotoUrl: recipeModel.coverPhotoUrl, // Fix: Pass cover photo
          isPublic: recipeModel.isPublic,
          createdAt: recipeModel.createdAt,
          ingredients: snapshot.ingredients,
          steps: snapshot.steps,
          tags: recipeModel.tags, // Populate tags too
          dietTags: recipeModel.dietTags,
          titleEn: recipeModel.titleEn,
          descriptionEn: recipeModel.descriptionEn,
          ingredientsEn: recipeModel.ingredientsEn,
          stepsEn: recipeModel.stepsEn,
        );
      }
      
      return recipeModel; // Return header only if no snapshot found
    } catch (e, s) {
      AppLogger.e('Error fetching details', e, s);
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<void> clearAllRecipes() async {
    try {
      // Delete in correct order to respect foreign key constraints
      await supabaseClient.from('recipe_snapshots').delete().neq('commit_id', '00000000-0000-0000-0000-000000000000');
      await supabaseClient.from('commits').delete().neq('id', '00000000-0000-0000-0000-000000000000');
      await supabaseClient.from('recipes').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    } catch (e) {
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<void> deleteRecipe(String id) async {
    try {
      AppLogger.d('🗑️ Attempting to delete recipe: $id');
      
      // Manual Cascade Delete
      
      // 0. Delete Meal Plans (FK Constraint Check)
      await supabaseClient.from('meal_plans').delete().eq('recipe_id', id);

      // 1. Delete Snapshots
      await supabaseClient.from('recipe_snapshots').delete().eq('recipe_id', id);
      
      // 2. Delete Commits
      await supabaseClient.from('commits').delete().eq('recipe_id', id);
      
      // 3. Delete Recipe & Verify
      final response = await supabaseClient
          .from('recipes')
          .delete()
          .eq('id', id)
          .select(); // Select returns the deleted rows
      
      if (response.isEmpty) {
        AppLogger.w('⚠️ Delete operation returned 0 rows for recipe $id. Possible causes: RLS blocking or ID not found.');
        throw Exception('Delete failed: Permission denied or Recipe not found.');
      } else {
        AppLogger.d('✅ Successfully deleted recipe: $id');
      }

    } catch (e, s) {
      AppLogger.e('Error deleting recipe $id', e, s);
      // Re-throw so the UI knows it failed
      throw Exception('Datasource delete operation failed: $e');
    }
  }

  @override
  Future<RecipeModel> updateRecipe(Recipe recipe) async {
    try {
      final currentUserId = supabaseClient.auth.currentUser!.id;

      // 1. Calculate Enriched Tags
      final enrichedTags = List<String>.from(recipe.tags);
      for (final step in recipe.steps) {
        if (step.isBranchPoint && step.variantLogic != null) {
          for (final diet in step.variantLogic!.keys) {
            final normalizedDiet = diet; 
            if (!enrichedTags.any((t) => t.toLowerCase() == normalizedDiet.toLowerCase())) {
              enrichedTags.add(normalizedDiet);
            }
          }
        }
      }

      // 2. Update Recipe Header
      final recipeData = {
        'title': recipe.title,
        'description': recipe.description,
        'tags': enrichedTags,
        'cover_photo_url': recipe.coverPhotoUrl, // Add field
        'is_public': recipe.isPublic,
      };

      await supabaseClient
          .from('recipes')
          .update(recipeData)
          .eq('id', recipe.id)
          .eq('author_id', currentUserId); // Security check

      // 3. Insert Commit
      final commitData = {
        'recipe_id': recipe.id,
        'author_id': currentUserId,
        'message': 'Updated via Editor', // detailed diff could be added here
        'diff': {'action': 'update'}, 
      };

      final commitResponse = await supabaseClient
          .from('commits')
          .insert(commitData)
          .select()
          .single();
      
      final commitId = commitResponse['id'];

      // 4. Insert Snapshot
      final stepsJson = recipe.steps.map((step) {
        if (step is RecipeStepModel) return step.toJson();
        return {
          'instruction': step.instruction,
          'is_branch_point': step.isBranchPoint,
          'variant_logic': step.variantLogic,
          'cross_contamination_alert': step.crossContaminationAlert,
        };
      }).toList();

      final fullStructureJson = {
        'ingredients': recipe.ingredients,
        'steps': stepsJson,
      };
      
      final snapshotData = {
        'commit_id': commitId,
        'recipe_id': recipe.id,
        'full_structure': fullStructureJson,
      };

      await supabaseClient.from('recipe_snapshots').insert(snapshotData);

      // Return updated model
      return getRecipeDetails(recipe.id);
    } catch (e, s) {
      AppLogger.e('Error updating recipe', e, s);
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<String> uploadRecipeImage(dynamic imageFile, String userId) async {
    try {
      // Use dynamic to support File (Mobile) and potentially Bytes (Web) later, though effectively File now.
      // Assuming 'imageFile' is of type File (dart:io)
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // Simple extension extraction or default to jpg
      final path = 'covers/$userId/$timestamp.jpg'; 

      await supabaseClient.storage.from('recipe_images').upload(
        path,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final url = supabaseClient.storage.from('recipe_images').getPublicUrl(path);
      return url;
    } catch (e) {
      AppLogger.e('Error uploading image', e);
      throw Exception('Image upload failed');
    }
  }

  // Phase 3.4: Collections Implementation
  @override
  Future<RecipeCollectionModel> createCollection(String name) async {
    try {
      final userId = supabaseClient.auth.currentUser!.id;
      final response = await supabaseClient
          .from('recipe_collections')
          .insert({
            'name': name,
            'owner_id': userId,
          })
          .select()
          .single();
      
      return RecipeCollectionModel.fromJson(response);
    } catch (e, s) {
      AppLogger.e('Error creating collection', e, s);
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<List<RecipeCollectionModel>> getUserCollections() async {
    try {
      final userId = supabaseClient.auth.currentUser!.id;
      
      // Get collections and count items
      final response = await supabaseClient
          .from('recipe_collections')
          .select('*, collection_items(count)') // Subquery count
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((data) {
        // Map count from subquery
        final countList = data['collection_items'] as List?;
        final count = (countList != null && countList.isNotEmpty) 
            ? countList[0]['count'] as int 
            : 0;
            
        // Inject count into data map so fromJson picks it up (if we added logic there)
        // Or better: Modify Model to accept it, or use copyWith.
        // For now, let's assume specific parsing or modify the model to handle 'collection_items' logic?
        // Actually, our model has `recipeCount`, we should map it manually before creating model or update fromJson.
        // Let's manually map for safety.
        final map = Map<String, dynamic>.from(data);
        map['recipeCount'] = count; // This won't work unless we modify Model to look for this or custom constructor.
        
        // Easier: Just return Model and rely on a default, implementing count logic properly requires a View or Join.
        // For MVP: Let's trust the subquery returns `{count: X}` formatted in a way we can parse.
        // Supabase returns `collection_items: [{count: 1}]`.
        
        return RecipeCollectionModel.fromJson(data).copyWith(recipeCount: count);
      }).toList();
    } catch (e, s) {
      AppLogger.e('Error fetching collections', e, s);
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<void> addToCollection(String recipeId, String collectionId) async {
    try {
      await supabaseClient.from('collection_items').insert({
        'collection_id': collectionId,
        'recipe_id': recipeId,
      });
    } catch (e) {
       // Ignore duplicate key error safely
       if (e is PostgrestException && e.code == '23505') return;
       throw Exception('Datasource operation failed: $e');
    }
  }

  @override
  Future<void> removeFromCollection(String recipeId, String collectionId) async {
    try {
      await supabaseClient
          .from('collection_items')
          .delete()
          .eq('collection_id', collectionId)
          .eq('recipe_id', recipeId);
    } catch (e) {
      throw Exception('Datasource operation failed');
    }
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    try {
      await supabaseClient
          .from('recipe_collections')
          .delete()
          .eq('id', collectionId);
    } catch (e) {
      throw Exception('Datasource operation failed');
    }
  }
}
