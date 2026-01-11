import 'package:gastronomic_os/core/error/failures.dart';
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

  RecipeRepositoryImpl({
    required this.remoteDataSource,
    required this.supabaseClient,
  });

  @override
  Future<(Failure?, List<Recipe>?)> getRecipes() async {
    try {
      final result = await remoteDataSource.getRecipes();
      return (null, result);
    } catch (e) {
      return (const ServerFailure(), null);
    }
  }

  @override
  Future<(Failure?, Recipe?)> getRecipeDetails(String id) async {
    try {
      final result = await remoteDataSource.getRecipeDetails(id);
      return (null, result);
    } catch (e) {
      return (const ServerFailure(), null);
    }
  }

  @override
  Future<(Failure?, Recipe?)> createRecipe(Recipe recipe) async {
    try {
      final result = await remoteDataSource.createRecipe(recipe);
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
}
