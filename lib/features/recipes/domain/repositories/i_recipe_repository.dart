import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/commit.dart';

abstract class IRecipeRepository {
  // Recipes
  Future<(Failure?, List<Recipe>?)> getRecipes();
  Future<(Failure?, Recipe?)> getRecipeDetails(String id);
  Future<(Failure?, Recipe?)> createRecipe(Recipe recipe);
  Future<(Failure?, Recipe?)> forkRecipe(String originalRecipeId, String newTitle);
  
  // Commits
  Future<(Failure?, List<Commit>?)> getCommits(String recipeId);
  Future<(Failure?, Commit?)> addCommit(Commit commit);
  
  // Advanced: Get the resolved recipe state at a specific commit (Snapshot)
  // Future<(Failure?, RecipeSnapshot?)> getRecipeSnapshot(String commitId); 
  
  // Debug/Dev
  /// Seeds the database with test recipes
  /// [filterTitle] if provided, only seeds recipes containing this string in title
  Future<void> seedDatabase({String? filterTitle});
}
