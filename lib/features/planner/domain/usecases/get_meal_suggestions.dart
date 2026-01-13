import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/inventory/domain/repositories/i_inventory_repository.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/features/planner/domain/logic/diet_engine.dart';
import 'package:gastronomic_os/features/planner/domain/logic/scoring_engine.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:gastronomic_os/features/inventory/domain/entities/inventory_item.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';

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
    // 1. Fetch Suggestions from Server (The Chef's Brain - Coarse Filter)
    final suggestionsResult = await recipeRepository.getDashboardSuggestions(limit: 20);
    
    if (suggestionsResult.$1 != null) {
      return (suggestionsResult.$1, null);
    }
    
    final candidateRecipes = suggestionsResult.$2 ?? [];
    if (candidateRecipes.isEmpty) return (null, <RecipeSuggestion>[]);

    // 2. Fetch Context for Client-Side Enrichment (Score/Reasons/Diet)
    final inventoryFuture = inventoryRepository.getInventory();
    final familyFuture = onboardingRepository.getFamilyMembers();
    
    final contextResults = await Future.wait([inventoryFuture, familyFuture]);
    
    final inventoryResult = contextResults[0] as (Failure?, dynamic); // List<InventoryItem>?
    final familyResult = contextResults[1] as (Failure?, dynamic); // List<FamilyMember>?

    // If context fails, we can still show recipes but with 0 score, or fail?
    // Let's degrade gracefully: Default empty context.
    final inventoryList = (inventoryResult.$2 as List?)?.cast<InventoryItem>() ?? <InventoryItem>[];
    final familyList = (familyResult.$2 as List?)?.cast<FamilyMember>() ?? <FamilyMember>[];

    // 3. Enrich & Validate (Fine Filter)
    List<RecipeSuggestion> suggestions = [];

    for (final recipe in candidateRecipes) {
      // Client-Side Diet Check (Safety Net)
      if (familyList.isNotEmpty) {
          if (!_dietEngine.isRecipeCompatible(recipe, familyList)) {
            continue; 
          }
      }

      // Client-Side Scoring (Presentation Details)
      // Since the server already ranked them (mostly), this is just to generating 
      // the "Great Value" badge and reason strings accurately.
      double score = 0;
      List<String> reasons = [];
      
      if (inventoryList.isNotEmpty) {
         score = _scoringEngine.calculateScore(recipe, inventoryList);
         
         if (score > 40) reasons.add("Savior! Uses expiring items.");
         else if (score > 10) reasons.add("You have ingredients.");
      }

      suggestions.add(RecipeSuggestion(recipe: recipe, score: score, matchingReasons: reasons));
    }
    
    // Re-sort just in case local scoring logic differs slightly from server logic (e.g. detailed expiration match)
    suggestions.sort((a, b) => b.score.compareTo(a.score));

    return (null, suggestions);
  }
}
