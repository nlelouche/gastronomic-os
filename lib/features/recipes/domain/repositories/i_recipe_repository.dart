import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/commit.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_collection.dart';
import 'package:gastronomic_os/features/social/domain/entities/social_feed_item.dart';

abstract class IRecipeRepository {
  // Recipes
  Future<(Failure?, List<Recipe>?)> getRecipes({
    int limit = 20, 
    int offset = 0, 
    String? query, 
    List<String>? excludedTags,
    List<String>? pantryItems, // New: For Pantry Matching
    String? collectionId, // New: Filter by Collection
  });
  Future<(Failure?, Recipe?)> getRecipeDetails(String id);
  Future<(Failure?, List<Recipe>?)> getDashboardSuggestions({int limit = 10});
  Future<(Failure?, Recipe?)> createRecipe(Recipe recipe);
  Future<(Failure?, Recipe?)> forkRecipe(String originalRecipeId, String newTitle);
  
  // Phase 3.2: My Recipes & Bookmarks
  Future<(Failure?, List<Recipe>?)> getMyRecipes({bool isFork = false});
  Future<(Failure?, List<Recipe>?)> getSavedRecipes();
  Future<(Failure?, bool)> isRecipeSaved(String recipeId);
  Future<(Failure?, void)> toggleSaveRecipe(String recipeId);
  
  // Commits
  Future<(Failure?, List<Commit>?)> getCommits(String recipeId);
  Future<(Failure?, Commit?)> addCommit(Commit commit);

  // Edit & Delete (Phase 3)
  Future<(Failure?, void)> deleteRecipe(String id);
  Future<(Failure?, Recipe?)> updateRecipe(Recipe recipe);
  
  // Advanced: Get the resolved recipe state at a specific commit (Snapshot)
  // Future<(Failure?, RecipeSnapshot?)> getRecipeSnapshot(String commitId); 
  

  Future<(Failure?, List<Recipe>?)> getForks(String recipeId);
  Future<(Failure?, String?)> uploadRecipeImage(dynamic imageFile);

  // Collections (Phase 3.4)
  Future<(Failure?, RecipeCollection?)> createCollection(String name);
  Future<(Failure?, List<RecipeCollection>?)> getUserCollections();
  Future<(Failure?, void)> addToCollection(String recipeId, String collectionId);
  Future<(Failure?, void)> removeFromCollection(String recipeId, String collectionId);
  Future<(Failure?, void)> deleteCollection(String collectionId);
  // Social & Feed (Phase 5)
  Future<(Failure?, List<SocialFeedItem>?)> getPublicFeed({int limit = 10, int offset = 0});
  Future<(Failure?, void)> toggleLike(String recipeId);
}
