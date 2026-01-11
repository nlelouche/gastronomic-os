import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/inventory/domain/repositories/i_inventory_repository.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/features/planner/domain/logic/diet_engine.dart';
import 'package:gastronomic_os/features/planner/domain/logic/scoring_engine.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';

class RecipeSuggestion {
  final Recipe recipe;
  final double score;
  final List<String> matchingReasons;

  RecipeSuggestion({required this.recipe, required this.score, this.matchingReasons = const []});
}

class GetMealSuggestions {
  final IRecipeRepository recipeRepository;
  final IInventoryRepository inventoryRepository;
  final IOnboardingRepository onboardingRepository;
  
  final DietEngine _dietEngine = DietEngine();
  final ScoringEngine _scoringEngine = ScoringEngine();

  GetMealSuggestions({
    required this.recipeRepository,
    required this.inventoryRepository,
    required this.onboardingRepository,
  });

  Future<(Failure?, List<RecipeSuggestion>?)> call() async {
    // 1. Fetch Data
    // We fetch sequentially for safety, or parallel if confident.
    // Parallel is better for performance.
    
    final recipesFuture = recipeRepository.getRecipes();
    final inventoryFuture = inventoryRepository.getInventory();
    final familyFuture = onboardingRepository.getFamilyMembers();

    final results = await Future.wait([recipesFuture, inventoryFuture, familyFuture]);

    final recipesResult = results[0] as (Failure?, List<Recipe>?);
    final inventoryResult = results[1] as (Failure?, dynamic); // Dynamic cast cause List<InventoryItem>? vs List<dynamic>?
    final familyResult = results[2] as (Failure?, dynamic);

    // 2. Error Handling
    if (recipesResult.$1 != null) return (recipesResult.$1, null);
    if (inventoryResult.$1 != null) return (inventoryResult.$1, null);
    if (familyResult.$1 != null) return (familyResult.$1, null);

    final recipes = recipesResult.$2 ?? [];
    // Need to cast correctly
    final inventory = (inventoryResult.$2 as List?)?.cast<dynamic>() ?? [];
    // Convert to InventoryItem if needed? Repository returns InventoryItem.
    // Actually, let's just use typed results from the futures if we await them separately or cast carefully.
    
    // Let's re-do await separately to keep types clean.
    var rRes = await recipeRepository.getRecipes();
    if (rRes.$1 != null) return (rRes.$1, null);
    
    var iRes = await inventoryRepository.getInventory();
    if (iRes.$1 != null) return (iRes.$1, null);
    
    var fRes = await onboardingRepository.getFamilyMembers();
    if (fRes.$1 != null) return (fRes.$1, null);

    final recipeList = rRes.$2 ?? [];
    final inventoryList = iRes.$2 ?? [];
    final familyList = fRes.$2 ?? [];

    // 3. Filter & Score
    List<RecipeSuggestion> suggestions = [];

    for (final recipe in recipeList) {
      if (!_dietEngine.areRecipesCompatible(recipe, familyList)) {
        continue;
      }

      double score = _scoringEngine.calculateScore(recipe, inventoryList);
      
      List<String> reasons = [];
      if (score > 40) reasons.add("Savior! Uses expiring items.");
      else if (score > 10) reasons.add("You have ingredients.");

      suggestions.add(RecipeSuggestion(recipe: recipe, score: score, matchingReasons: reasons));
    }

    // 4. Sort
    suggestions.sort((a, b) => b.score.compareTo(a.score));

    return (null, suggestions.take(5).toList());
  }
}
