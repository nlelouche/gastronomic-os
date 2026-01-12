import 'package:gastronomic_os/features/planner/domain/entities/meal_plan.dart';
import 'package:gastronomic_os/features/planner/domain/entities/shopping_item.dart';
import 'package:gastronomic_os/features/planner/domain/logic/ingredient_normalizer.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';

class ShoppingEngine {
  final IngredientNormalizer normalizer;

  ShoppingEngine({IngredientNormalizer? normalizer}) 
      : normalizer = normalizer ?? IngredientNormalizer();

  /// Generates a consolidated shopping list from a set of meal plans.
  List<ShoppingItem> generateList(List<MealPlan> plans) {
    // Map of "Name" -> ShoppingItem (Aggregated)
    final Map<String, ShoppingItem> consolidated = {};

    for (final plan in plans) {
      final recipe = plan.recipe;
      if (recipe == null) {
        print('🛒 ENGINE: Skipping plan ${plan.id} because recipe is null');
        continue;
      }
      
      print('🛒 ENGINE: Processing recipe "${recipe.title}" with ${recipe.ingredients.length} ingredients');

      // 1. Process Base Ingredients
      for (final raw in recipe.ingredients) {
        // print('   -> Ingredient: $raw');
        _processIngredient(raw, consolidated, isVariant: false);
      }

      // 2. Process Variants (The "Smart" part)
      // We look for variant text in steps. 
      // MVP: We assume ALL variants found in steps might be needed (Option).
      // Ideally, we'd check Family Diets here, but MealPlan implies "Cooking For Family".
      // Let's assume we list them as marked "Variant".
      for (final step in recipe.steps) {
        if (step.variantLogic != null) {
          // Parse "Use Tofu instead". 
          // variantLogic is Map<String, String> (e.g. {"vegan": "Use Tofu"})
          final variantInstructions = step.variantLogic!.values.join(' ');
          
          final keywords = ['Tofu', 'Seitan', 'Tempeh', 'Almond Milk', 'Soy Milk'];
          for (final key in keywords) {
             if (variantInstructions.contains(key)) {
                _processIngredient("1 pack $key", consolidated, isVariant: true);
             }
          }
        }
      }
    }

    return consolidated.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  void _processIngredient(String raw, Map<String, ShoppingItem> map, {required bool isVariant}) {
    final (qty, unit, name) = normalizer.normalize(raw);
    // print('      -> Normalized: "$raw" => $qty $unit $name');
    
    if (name.isEmpty) {
       print('🛒 ENGINE: WARNING - Could not extract name from "$raw"');
       return;
    }
    
    // Key is name + variant status (keep variants separate? or merge?)
    // Merge: If base recipe calls for Tofu, and Variant calls for Tofu, we need 2 Tofu.
    // So Key is just Name.
    final key = name;

    if (map.containsKey(key)) {
      final current = map[key]!;
      map[key] = current.copyWith(
        quantity: current.quantity + qty,
        // If one usage is Variant and other is Base, is the result Variant?
        // If Base needs it, it's NOT just a variant option, it's required.
        // So isVariant = current.isVariant && isVariant.
        // (If ANY usage is Base (false), then result is Base (false)).
        isVariant: current.isVariant && isVariant,
      );
    } else {
      map[key] = ShoppingItem(
        name: name,
        quantity: qty,
        unit: unit,
        isVariant: isVariant,
        originalInput: raw,
      );
    }
  }
}
