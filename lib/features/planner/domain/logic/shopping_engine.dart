import 'package:gastronomic_os/core/logic/unit_converter.dart';
import 'package:gastronomic_os/features/inventory/domain/entities/inventory_item.dart';
import 'package:gastronomic_os/features/planner/domain/entities/meal_plan.dart';
import 'package:gastronomic_os/features/planner/domain/entities/shopping_item.dart';
import 'package:gastronomic_os/features/planner/domain/logic/ingredient_normalizer.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';

class ShoppingEngine {
  final IngredientNormalizer normalizer;
  final UnitConverter converter;

  ShoppingEngine({IngredientNormalizer? normalizer, UnitConverter? converter}) 
      : normalizer = normalizer ?? IngredientNormalizer(),
        converter = converter ?? UnitConverter();

  /// Generates a consolidated shopping list from a set of meal plans.
  List<ShoppingItem> generateList(List<MealPlan> plans, {List<InventoryItem> inventory = const []}) {
    // Map of "Name" -> ShoppingItem (Aggregated)
    final Map<String, ShoppingItem> consolidated = {};

    // 1. Host Aggregation
    for (final plan in plans) {
      final recipe = plan.recipe;
      if (recipe == null) continue;

      // Base Ingredients
      for (final raw in recipe.ingredients) {
        _processIngredient(raw, consolidated, isVariant: false);
      }

      // Process Variants
      for (final step in recipe.steps) {
        if (step.variantLogic != null) {
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

    // 2. Inventory Deduction (The "Comparator" Logic)
    if (inventory.isNotEmpty) {
      for (final stockItem in inventory) {
        // Normalize stock item name to match shopping list keys
        final (_, stockUnit, stockName) = normalizer.normalize(stockItem.name + ' ' + stockItem.unit); // Combine for safety?
        // Actually, stockItem has separated Quantity and Unit.
        // Let's rely on name matching first.
        final cleanStockName = normalizer.normalizeNameOnly(stockItem.name);
        
        if (cleanStockName.isNotEmpty && consolidated.containsKey(cleanStockName)) {
           final need = consolidated[cleanStockName]!;
           
           // Use UnitConverter for smart deduction
           final remainingNeed = converter.deduct(
             need.quantity, 
             need.unit, 
             stockItem.quantity, // Stock Qty 
             stockItem.unit,      // Stock Unit
             ingredientName: cleanStockName
           );
           
           if (remainingNeed <= 0.01) {
             // Fully stocked
             consolidated.remove(cleanStockName);
           } else {
             // Partially stocked (update quantity, keep unit of Need)
             consolidated[cleanStockName] = need.copyWith(quantity: remainingNeed);
           }
        }
      }
    }

    return consolidated.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  void _processIngredient(String raw, Map<String, ShoppingItem> map, {required bool isVariant}) {
    final (qty, unit, name) = normalizer.normalize(raw);
    
    if (name.isEmpty) return;
    
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
