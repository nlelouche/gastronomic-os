import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/error/error_context.dart';
import 'package:gastronomic_os/core/error/exception_handler.dart';
import 'package:gastronomic_os/core/error/error_reporter.dart';
import 'package:gastronomic_os/core/util/app_logger.dart';
import 'package:gastronomic_os/features/recipes/data/datasources/recipe_cache_service.dart'; // NEW IMPORT
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
  final RecipeCacheService cacheService; // NEW

  RecipeRepositoryImpl({
    required this.remoteDataSource,
    required this.supabaseClient,
    required this.cacheService,
  });

  // Phase 3.2: My Recipes & Bookmarks Support
  @override
  Future<(Failure?, List<Recipe>?)> getMyRecipes({bool isFork = false}) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
          return (AuthFailure('User not logged in', context: ErrorContext.repository('getMyRecipes')), null);
      }
      // Fetch user's recipes (Created or Forked)
      final result = await remoteDataSource.getRecipes(
        limit: 100, // Fetch more for personal list
        authorId: userId,
        isFork: isFork,
      );
      return (null, result);
    } catch (e, s) {
      return (ExceptionHandler.handle(e, stackTrace: s, context: ErrorContext.repository('getMyRecipes')), null);
    }
  }

  @override
  Future<(Failure?, List<Recipe>?)> getSavedRecipes() async {
     try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
          return (AuthFailure('User not logged in', context: ErrorContext.repository('getSavedRecipes')), null);
      }
      final result = await remoteDataSource.getRecipes(
        limit: 100,
        onlySaved: true,
      );
      return (null, result);
    } catch (e, s) {
      return (ExceptionHandler.handle(e, stackTrace: s, context: ErrorContext.repository('getSavedRecipes')), null);
    }
  }

  @override
  Future<(Failure?, void)> toggleSaveRecipe(String recipeId) async {
    try {
      await remoteDataSource.toggleSaveRecipe(recipeId);
      return (null, null);
    } catch (e, s) {
       return (ExceptionHandler.handle(e, stackTrace: s, context: ErrorContext.repository('toggleSaveRecipe')), null);
    }
  }

  @override
  Future<(Failure?, bool)> isRecipeSaved(String recipeId) async {
    try {
      final result = await remoteDataSource.isRecipeSaved(recipeId);
      return (null, result);
    } catch (e, s) {
       return (ExceptionHandler.handle(e, stackTrace: s, context: ErrorContext.repository('isRecipeSaved')), false);
    }
  }

  @override
  Future<(Failure?, List<Recipe>?)> getRecipes({int limit = 20, int offset = 0, String? query, List<String>? excludedTags}) async {
    try {
      final result = await remoteDataSource.getRecipes(limit: limit, offset: offset, query: query, excludedTags: excludedTags);
      return (null, result);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('getRecipes', extra: {
          'limit': limit,
          'offset': offset,
          'query': query,
        }),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, List<Recipe>?)> getDashboardSuggestions({int limit = 10}) async {
    try {
      final result = await remoteDataSource.getDashboardSuggestions(limit: limit);
      return (null, result);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('getDashboardSuggestions', extra: {
          'limit': limit,
        }),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, Recipe?)> getRecipeDetails(String id) async {
    // 1. Check Cache
    final cached = cacheService.getRecipeDetails(id);
    if (cached != null) {
       AppLogger.d('📦 Returning cached details for: ${cached.title}');
       return (null, cached);
    }

    // 2. Fetch Remote
    try {
      AppLogger.d('🌍 Fetching details from remote for: $id');
      final result = await remoteDataSource.getRecipeDetails(id);
      
      // 3. Update Cache
      if (result != null) {
        cacheService.cacheRecipeDetails(result);
      }
      return (null, result);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('getRecipeDetails', extra: {
          'recipeId': id,
        }),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, Recipe?)> createRecipe(Recipe recipe) async {
    try {
      final result = await remoteDataSource.createRecipe(recipe);
      cacheService.invalidate(); // Clear cache on mutation
      return (null, result);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('createRecipe', extra: {
          'recipeName': recipe.title,
        }),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, Recipe?)> forkRecipe(String originalRecipeId, String newTitle) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return (AuthFailure(
          'User not logged in',
          context: ErrorContext.repository('forkRecipe'),
        ), null);
      }

      final result = await remoteDataSource.forkRecipe(originalRecipeId, newTitle, userId);
      cacheService.invalidate(); // Clear cache
      return (null, result);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('forkRecipe', extra: {
          'originalRecipeId': originalRecipeId,
          'newTitle': newTitle,
        }),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, List<Commit>?)> getCommits(String recipeId) async {
    try {
      final result = await remoteDataSource.getCommits(recipeId);
      return (null, result);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('getCommits', extra: {
          'recipeId': recipeId,
        }),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
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
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('addCommit', extra: {
          'recipeId': commit.recipeId,
          'message': commit.message,
        }),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }


  @override
  Future<(Failure?, void)> deleteRecipe(String id) async {
    try {
      await remoteDataSource.deleteRecipe(id);
      cacheService.invalidate(); // Clear cache
      return (null, null);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('deleteRecipe', extra: {
          'recipeId': id,
        }),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, Recipe?)> updateRecipe(Recipe recipe) async {
    try {
      final result = await remoteDataSource.updateRecipe(recipe);
      cacheService.invalidate(); // Clear cache
      return (null, result);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('updateRecipe', extra: {
          'recipeName': recipe.title,
        }),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }
}
