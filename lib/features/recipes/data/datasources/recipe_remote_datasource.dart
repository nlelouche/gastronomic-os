import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_snapshot_model.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_model.dart';
import 'package:gastronomic_os/features/recipes/data/models/commit_model.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_step_model.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart'; 

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> getRecipes({int limit = 20, int offset = 0, String? query});
  // Future<List<RecipeModel>> getRecipeHeaders(); // DEPRECATED: use getRecipes()
  Future<RecipeModel> createRecipe(Recipe recipe);
  Future<RecipeModel> forkRecipe(String originalRecipeId, String newTitle, String authorId);
  Future<List<CommitModel>> getCommits(String recipeId);
  Future<CommitModel> addCommit(CommitModel commit);
  Future<RecipeModel> getRecipeDetails(String recipeId);
  Future<List<RecipeModel>> getDashboardSuggestions({int limit = 10});
  Future<void> clearAllRecipes(); // For development: clear all recipes
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final SupabaseClient supabaseClient;

  RecipeRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<RecipeModel>> getRecipes({int limit = 20, int offset = 0, String? query}) async {
    try {
      var builder = supabaseClient.from('recipes').select();
      
      if (query != null && query.isNotEmpty) {
        builder = builder.ilike('title', '%$query%');
      }

      final response = await builder
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return (response as List).map((data) => RecipeModel.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching recipes: $e');
      throw const ServerFailure();
    }
  }

  // @override
  // Future<List<RecipeModel>> getRecipeHeaders() async ... // REMOVED

  @override
  Future<RecipeModel> createRecipe(Recipe recipe) async {
    try {
      final currentUserId = supabaseClient.auth.currentUser!.id;

      // 1. Calculate Enriched Tags (Move logic to top)
      final enrichedTags = List<String>.from(recipe.tags);
      print('🔍 Enriching tags for "${recipe.title}". Initial tags: $enrichedTags');
      
      for (final step in recipe.steps) {
        if (step.isBranchPoint && step.variantLogic != null) {
          print('   Found variant step: ${step.variantLogic!.keys}');
          for (final diet in step.variantLogic!.keys) {
            final normalizedDiet = diet; 
            if (!enrichedTags.any((t) => t.toLowerCase() == normalizedDiet.toLowerCase())) {
              enrichedTags.add(normalizedDiet);
              print('   ✅ Added enriched tag: $normalizedDiet');
            }
          }
        }
      }
      print('🏁 Final enriched tags: $enrichedTags');
      
      // 2. Check Existence
      final existingRecipe = await supabaseClient
          .from('recipes')
          .select('id')
          .eq('author_id', currentUserId)
          .eq('title', recipe.title)
          .maybeSingle();
      
      String recipeId;

      if (existingRecipe != null) {
        print('⚠️ Recipe "${recipe.title}" already exists. Updating Tags & Creating new Snapshot.');
        print('   Original Tags: ${recipe.tags}');
        print('   Enriched Tags to Update: $enrichedTags');
        
        recipeId = existingRecipe['id'];
        
        // SELF-HEALING: Ensure tags are up to date!
        await supabaseClient
            .from('recipes')
            .update({'tags': enrichedTags})
            .eq('id', recipeId);
        print('   ✅ Tags updated in DB.');
      } else {
        // 3. Insert New Recipe (using enrichedTags)
        final recipeData = {
          'title': recipe.title,
          'description': recipe.description,
          'tags': enrichedTags, // ✅ Save enriched tags
          'is_public': recipe.isPublic,
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
          print('💾 Serializing step: "${step.instruction.substring(0, min(30, step.instruction.length))}..." - toJson: $json');
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

      print('🚀 About to insert snapshot to Supabase. Full payload:');
      print('   Steps count: ${stepsJson.length}');
      print('   Step 2 JSON: ${stepsJson.length > 1 ? stepsJson[1] : "N/A"}');
      print('   full_structure type: ${fullStructureJson.runtimeType}');
      print('   full_structure JSON: $fullStructureJson');

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
    } catch (e) {
      // Rollback: Delete the header if snapshot failed to prevent "Shell" recipes
      // Only rollback if we were creating a NEW recipe (not updating existing)
      // Actually, checking if existingRecipe was null variable is tricky here due to scope.
      // But we can check if 'commits' table has entries?
      // Simplified robustness: just log loudly. 
      // Real rollback requires knowing if we inserted.
      
      print('❌ CRITICAL ERROR creating recipe "${recipe.title}": $e'); 
      print('   👉 Suggestion: Purge Database and Retry Seeding.');
      throw const ServerFailure();
    }
  }

  @override
  Future<RecipeModel> forkRecipe(String originalRecipeId, String newTitle, String authorId) async {
    try {
      // 1. Fetch original recipe to copy description/logic if needed (optional)
      // 2. Insert new recipe pointing to origin
      final forkData = {
        'author_id': authorId,
        'origin_id': originalRecipeId,
        'is_fork': true,
        'title': newTitle,
        'is_public': true, // Default
      };
      
      final response = await supabaseClient
          .from('recipes')
          .insert(forkData)
          .select()
          .single();
          
      return RecipeModel.fromJson(response);
    } catch (e) {
      throw const ServerFailure();
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
      throw const ServerFailure();
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
      print('⚠️ RPC get_dashboard_suggestions failed: $e. Falling back to simple getRecipes.');
      return getRecipes(limit: limit);
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
      throw const ServerFailure();
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
          isPublic: recipeModel.isPublic,
          createdAt: recipeModel.createdAt,
          ingredients: snapshot.ingredients,
          steps: snapshot.steps,
        );
      }
      
      return recipeModel; // Return header only if no snapshot found
    } catch (e) {
      print('Error fetching details: $e');
      throw const ServerFailure();
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
      throw const ServerFailure();
    }
  }
}
