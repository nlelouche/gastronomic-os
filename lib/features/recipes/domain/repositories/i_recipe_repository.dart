import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/commit.dart';

abstract class IRecipeRepository {
  // Recipes
  Future<(Failure?, List<Recipe>?)> getRecipes({int limit = 20, int offset = 0, String? query, List<String>? excludedTags});
  Future<(Failure?, Recipe?)> getRecipeDetails(String id);
  Future<(Failure?, List<Recipe>?)> getDashboardSuggestions({int limit = 10});
  Future<(Failure?, Recipe?)> createRecipe(Recipe recipe);
  Future<(Failure?, Recipe?)> forkRecipe(String originalRecipeId, String newTitle);
  
  // Commits
  Future<(Failure?, List<Commit>?)> getCommits(String recipeId);
  Future<(Failure?, Commit?)> addCommit(Commit commit);

  // Edit & Delete (Phase 3)
  Future<(Failure?, void)> deleteRecipe(String id);
  Future<(Failure?, Recipe?)> updateRecipe(Recipe recipe);
  
  // Advanced: Get the resolved recipe state at a specific commit (Snapshot)
  // Future<(Failure?, RecipeSnapshot?)> getRecipeSnapshot(String commitId); 
  

}
