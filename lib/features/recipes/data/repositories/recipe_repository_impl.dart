import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/recipes/data/datasources/recipe_seeder.dart';
import 'package:gastronomic_os/features/recipes/data/datasources/recipe_remote_datasource.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_model.dart';
import 'package:gastronomic_os/features/recipes/data/models/commit_model.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/commit.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For accessing current user ID from Supabase Auth

class RecipeRepositoryImpl implements IRecipeRepository {
  final RecipeRemoteDataSource remoteDataSource;
  final SupabaseClient supabaseClient; // To get current user

  List<Recipe>? _cachedRecipes;

  RecipeRepositoryImpl({
    required this.remoteDataSource,
    required this.supabaseClient,
  });

  @override
  Future<(Failure?, List<Recipe>?)> getRecipes() async {
    // 1. Return Cache if available
    if (_cachedRecipes != null) {
      print('📦 Returning cached recipes (${_cachedRecipes!.length})');
      return (null, _cachedRecipes);
    }

    try {
      // 2. Fetch Lightweight Headers only (Optimization Phase 3)
      // This avoids downloading heavy snapshot JSONs for the list view
      final result = await remoteDataSource.getRecipeHeaders();
      
      // 3. Update Cache
      _cachedRecipes = result;
      return (null, result);
    } catch (e) {
      return (const ServerFailure(), null);
    }
  }

  @override
  Future<(Failure?, Recipe?)> getRecipeDetails(String id) async {
    // 1. Check Cache
    if (_cachedRecipes != null) {
      try {
        final cached = _cachedRecipes!.firstWhere((r) => r.id == id);
        // Optimization: If cached recipe already has steps, assume details are loaded.
        // NOTE: This assumes a recipe without steps is "incomplete" or just a header.
        // If a valid recipe truly has no steps, this will cause a redundant fetch, which is acceptable.
        if (cached.steps.isNotEmpty) {
           print('📦 Returning cached details for: ${cached.title}');
           return (null, cached);
        }
      } catch (_) {
        // Not in cache, proceed to remote
      }
    }

    try {
      print('🌍 Fetching details from remote for: $id');
      final result = await remoteDataSource.getRecipeDetails(id);
      
      // Update Cache with full details
      if (_cachedRecipes != null) {
         final index = _cachedRecipes!.indexWhere((r) => r.id == id);
         if (index != -1) {
           _cachedRecipes![index] = result;
         } else {
           _cachedRecipes!.add(result);
         }
      }
      return (null, result);
    } catch (e) {
      return (const ServerFailure(), null);
    }
  }

  @override
  Future<(Failure?, Recipe?)> createRecipe(Recipe recipe) async {
    try {
      final result = await remoteDataSource.createRecipe(recipe);
      // Invalidate cache to force refresh list
      _cachedRecipes = null;
      return (null, result);
    } catch (e) {
      return (const ServerFailure(), null);
    }
  }

  @override
  Future<(Failure?, Recipe?)> forkRecipe(String originalRecipeId, String newTitle) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return (const ServerFailure("User not logged in"), null);

      final result = await remoteDataSource.forkRecipe(originalRecipeId, newTitle, userId);
      _cachedRecipes = null; // Invalidate cache
      return (null, result);
    } catch (e) {
      return (const ServerFailure(), null);
    }
  }

  @override
  Future<(Failure?, List<Commit>?)> getCommits(String recipeId) async {
    try {
      final result = await remoteDataSource.getCommits(recipeId);
      return (null, result);
    } catch (e) {
      return (const ServerFailure(), null);
    }
  }

  @override
  Future<(Failure?, Commit?)> addCommit(Commit commit) async {
    try {
      final model = CommitModel(
        id: commit.id,
        recipeId: commit.recipeId,
        parentCommitId: commit.parentCommitId,
        authorId: supabaseClient.auth.currentUser?.id ?? '',
        message: commit.message,
        diff: commit.diff,
        createdAt: commit.createdAt,
      );
      final result = await remoteDataSource.addCommit(model);
      return (null, result);
    } catch (e) {
      return (const ServerFailure(), null);
    }
  }

  @override
  Future<void> seedDatabase({String? filterTitle}) async {
    print('🧹 Clearing existing recipes...');
    
    // DEVELOPMENT MODE: Clear all recipes before seeding
    try {
      if (filterTitle == null) {
        // Only clear all if doing a full seed or explicitly requested
        // If seeding single recipe, we rely on upsert to not duplicate, 
        // but user requested "seed ONLY steak", implying clean slate or just adding/updating that one.
        // For debugging safety, let's NOT clear all if filtering, unless we want to isolate.
        // User asked: "seedear unicamente la receta de steak"
        // Let's assume we keep others but just ensure this one is fresh/present.
        // actually existing clearAllRecipes nukes EVERYTHING.
        // So if we key filter, we should probably NOT nuke everything.
        // But the previous implementation nuked everything.
        
        // Let's modify behavior: 
        // If filter is present -> DO NOT CLEAR, just UPSERT that specific recipe.
        // If no filter -> CLEAR ALL and SEED ALL.
         await remoteDataSource.clearAllRecipes();
         print('✅ Database cleared');
      } else {
        print('ℹ️ Single recipe seed mode - Skipping full database clear');
      }

    } catch (e) {
      print('⚠️ Error clearing database: $e');
    }

    print('🌱 Seeding recipes${filterTitle != null ? ' (Filter: $filterTitle)' : ''}...');
    final recipes = await RecipeSeeder.loadFromAssets(filterTitle: filterTitle);
    
    for (final recipe in recipes) {
      try {
        await remoteDataSource.createRecipe(recipe);
        print('✓ Seeded: ${recipe.title}');
      } catch (e) {
        print('✗ Error seeding recipe ${recipe.title}: $e');
      }
    }
    print('🎉 Seeding complete!');
    _cachedRecipes = null; // Invalidate cache
  }
}
