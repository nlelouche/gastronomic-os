import 'package:gastronomic_os/features/inventory/domain/entities/inventory_item.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';

/// [ScoringEngine] handles the "Soft Constraints" / Heuristics.
/// It assigns a score (0-100) to recipes based on how well they utilize the existing inventory.
class ScoringEngine {
  
  /// Calculates a score for a [Recipe] given the current [InventoryItem] list.
  double calculateScore(Recipe recipe, List<InventoryItem> inventory) {
    if (recipe.ingredients.isEmpty) return 0.0;

    double score = 0.0;
    int matchedIngredients = 0;
    
    // Create a map for faster lookup
    // Normalize keys to lowercase for matching
    final inventoryMap = {
      for (var item in inventory) item.name.toLowerCase(): item
    };

    for (final ingredient in recipe.ingredients) {
      final normalizedIng = ingredient.toLowerCase();
      
      // Simple string matching (In production: Fuzzy matching)
      // We look for partial matches (e.g. "Tomato" matches "Tomato Sauce"?? No, careful.)
      // Reverse: Inventory "Milk" matches Recipe "1 cup Milk".
      
      // We iterate inventory to find if any inventory item name is contained in the ingredient string
      // e.g. Ingredient: "2 onions", Inventory: "Onion". "2 onions".contains("onion") -> true.
      
      InventoryItem? matchedItem;
      for (final invItemName in inventoryMap.keys) {
        if (normalizedIng.contains(invItemName)) {
          matchedItem = inventoryMap[invItemName];
          break;
        }
      }

      if (matchedItem != null) {
        matchedIngredients++;
        score += 10.0; // Base points for having the item

        // Freshness Bonus
        if (matchedItem.expirationDate != null) {
          final daysUntilExpiry = matchedItem.expirationDate!.difference(DateTime.now()).inDays;
          if (daysUntilExpiry <= 2) {
            score += 50.0; // HUGE bonus for saving expiring food (The "Money" Goal)
          } else if (daysUntilExpiry <= 5) {
            score += 20.0;
          }
        }
      }
    }

    // Adjust score by coverage ratio
    double coverage = matchedIngredients / recipe.ingredients.length;
    score = score * (0.5 + (coverage * 0.5)); // Penalize slightly if we have to buy too many things

    return score;
  }

  /// Simplified scoring using only item names (no expiry data)
  double calculateScoreSimple(Recipe recipe, List<String> inventoryNames) {
    if (recipe.ingredients.isEmpty) return 0.0;
    
    double score = 0.0;
    int matchedIngredients = 0;
    
    final inventorySet = inventoryNames.map((e) => e.toLowerCase()).toSet();

    for (final ingredient in recipe.ingredients) {
      final normalizedIng = ingredient.toLowerCase();
      // Simple contains check
      for (final invItemName in inventorySet) {
        if (normalizedIng.contains(invItemName)) {
           matchedIngredients++;
           score += 10.0; 
           break;
        }
      }
    }
    
    double coverage = matchedIngredients / recipe.ingredients.length;
    score = score * (0.5 + (coverage * 0.5));
    return score;
  }
}
