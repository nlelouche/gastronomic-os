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
import 'package:gastronomic_os/features/recipes/domain/entities/commit.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:gastronomic_os/features/planner/domain/logic/scoring_engine.dart'; // NEW 

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
  Future<(Failure?, List<Recipe>?)> getRecipes({
    int limit = 20, 
    int offset = 0, 
    String? query, 
    List<String>? excludedTags,
    List<String>? pantryItems,
  }) async {
    try {
      // 1. Fetch from Remote (Raw List)
      final rawResult = await remoteDataSource.getRecipes(
        limit: limit, 
        offset: offset, 
        query: query, 
        excludedTags: excludedTags
      );

      var recipes = rawResult!; // Assuming non-null if no error throw

      // 2. Client-Side Processing: Pantry Match Sorting
      if (pantryItems != null && pantryItems.isNotEmpty) {
          final engine = ScoringEngine();
          
          // Enrich with Scores
          recipes = recipes.map((r) {
             final score = engine.calculateScoreSimple(r, pantryItems);
             // Ensure we don't lose the object type if possible, but copyWith returns Recipe
             return r.copyWith(matchScore: score);
          }).toList();

          // Sort by match score (Descending)
          recipes.sort((a, b) {
             return (b.matchScore ?? 0).compareTo(a.matchScore ?? 0);
          });
      }

      return (null, recipes);
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
  @override
  Future<(Failure?, List<Recipe>?)> getForks(String recipeId) async {
    try {
      // Use getRecipes but filter by 'origin_id'
      // Requires adding 'originId' parameter to RemoteDataSource.getRecipes first
      // OR we can make a new specific call. 
      // The most flexible way is to add 'originId' to getRecipes options.
      
      final result = await remoteDataSource.getRecipes(
        limit: 100,
        // Since we don't have 'originId' param yet effectively in the interface call here...
        // We will assume remoteDataSource.getRecipes can handle it via query or new param.
        // Let's check remoteDataSource signature...
        // It has (limit, offset, query, excludedTags, authorId, isFork, onlySaved)
        // We need 'originId'.
      );
      
      // WAIT, 'getRecipes' in Datasource is flexible? 
      // Let's simply implement a dedicated method in Datasource for clarity: getForks(id)
      return (null, await remoteDataSource.getForks(recipeId));
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('getForks', extra: {'originId': recipeId}),
      );
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, String?)> uploadRecipeImage(dynamic imageFile) async {
    try {
      final userId = supabaseClient.auth.currentUser!.id;
      final url = await remoteDataSource.uploadRecipeImage(imageFile, userId);
      return (null, url);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e, 
        stackTrace: stackTrace, 
        context: ErrorContext.repository('uploadRecipeImage'),
      );
      return (failure, null);
    }
  }
}
