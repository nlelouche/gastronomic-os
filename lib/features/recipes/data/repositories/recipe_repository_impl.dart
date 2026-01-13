import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/util/app_logger.dart';
import 'package:gastronomic_os/features/recipes/data/datasources/recipe_seeder.dart';
import 'package:gastronomic_os/features/recipes/data/datasources/recipe_remote_datasource.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_model.dart';
import 'package:gastronomic_os/features/recipes/data/models/commit_model.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/commit.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

class RecipeRepositoryImpl implements IRecipeRepository {
  final RecipeRemoteDataSource remoteDataSource;
  final SupabaseClient supabaseClient; 

  List<Recipe>? _cachedRecipes;

  RecipeRepositoryImpl({
    required this.remoteDataSource,
    required this.supabaseClient,
  });

  @override
  Future<(Failure?, List<Recipe>?)> getRecipes({int limit = 20, int offset = 0, String? query}) async {
    try {
      final result = await remoteDataSource.getRecipes(limit: limit, offset: offset, query: query);
      return (null, result);
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching recipes', e, stackTrace);
      return (ServerFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, List<Recipe>?)> getDashboardSuggestions({int limit = 10}) async {
    try {
      final result = await remoteDataSource.getDashboardSuggestions(limit: limit);
      return (null, result);
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching dashboard suggestions', e, stackTrace);
      return (ServerFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, Recipe?)> getRecipeDetails(String id) async {
    if (_cachedRecipes != null) {
      try {
        final cached = _cachedRecipes!.firstWhere((r) => r.id == id);
        if (cached.steps.isNotEmpty) {
           AppLogger.d('📦 Returning cached details for: ${cached.title}');
           return (null, cached);
        }
      } catch (_) {
        // Not in cache
      }
    }

    try {
      AppLogger.d('🌍 Fetching details from remote for: $id');
      final result = await remoteDataSource.getRecipeDetails(id);
      
      if (_cachedRecipes != null) {
         final index = _cachedRecipes!.indexWhere((r) => r.id == id);
         if (index != -1) {
           _cachedRecipes![index] = result;
         } else {
           _cachedRecipes!.add(result);
         }
      }
      return (null, result);
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching recipe details for $id', e, stackTrace);
      return (ServerFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, Recipe?)> createRecipe(Recipe recipe) async {
    try {
      final result = await remoteDataSource.createRecipe(recipe);
      _cachedRecipes = null;
      return (null, result);
    } catch (e, stackTrace) {
      AppLogger.e('Error creating recipe', e, stackTrace);
      return (ServerFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, Recipe?)> forkRecipe(String originalRecipeId, String newTitle) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return (const ServerFailure("User not logged in"), null);

      final result = await remoteDataSource.forkRecipe(originalRecipeId, newTitle, userId);
      _cachedRecipes = null;
      return (null, result);
    } catch (e, stackTrace) {
      AppLogger.e('Error forking recipe', e, stackTrace);
      return (ServerFailure(e.toString()), null);
    }
  }

  @override
  Future<(Failure?, List<Commit>?)> getCommits(String recipeId) async {
    try {
      final result = await remoteDataSource.getCommits(recipeId);
      return (null, result);
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching commits', e, stackTrace);
      return (ServerFailure(e.toString()), null);
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
    } catch (e, stackTrace) {
      AppLogger.e('Error adding commit', e, stackTrace);
      return (ServerFailure(e.toString()), null);
    }
  }

  @override
  Future<void> seedDatabase({String? filterTitle}) async {
    AppLogger.w('🧹 Clearing existing recipes...');
    
    try {
      if (filterTitle == null) {
         await remoteDataSource.clearAllRecipes();
         AppLogger.i('✅ Database cleared');
      } else {
        AppLogger.i('ℹ️ Single recipe seed mode - Skipping full database clear');
      }

    } catch (e, stackTrace) {
      AppLogger.e('⚠️ Error clearing database', e, stackTrace);
    }

    AppLogger.i('🌱 Seeding recipes${filterTitle != null ? ' (Filter: $filterTitle)' : ''}...');
    final recipes = await RecipeSeeder.loadFromAssets(filterTitle: filterTitle);
    
    for (final recipe in recipes) {
      try {
        await remoteDataSource.createRecipe(recipe);
        AppLogger.i('✓ Seeded: ${recipe.title}');
      } catch (e) {
        AppLogger.e('✗ Error seeding recipe ${recipe.title}', e);
      }
    }
    AppLogger.i('🎉 Seeding complete!');
    _cachedRecipes = null;
  }
}
