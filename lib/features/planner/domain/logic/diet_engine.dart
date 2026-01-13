import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';

/// [DietEngine] handles the "Hard Constraints" of the Planner and Clinical Safety.
/// 
/// **Architecture:**
/// 1. **Clinical Overlays (MedicalCondition)**: ZERO TOLERANCE.
///    - If a user has an allergy/condition, the recipe MUST be safe or have a valid variant.
///    - Safety is determined by: Tags (Positive), Ingredients (Negative), or Variants (Transformation).
/// 
/// 2. **Lifestyle Compatibility (DietLifestyle)**: Preference-based.
///    - If a user is Vegan, non-vegan recipes are hidden unless adapted.
class DietEngine {
  
  /// Checks if a [Recipe] is compatible with a List of [FamilyMember]s.
  /// Returns [true] only if the recipe is safe for EVERYONE.
  /// Checks if a [Recipe] is compatible with a List of [FamilyMember]s.
  /// Returns [true] only if the recipe is safe for EVERYONE.
  bool isRecipeCompatible(Recipe recipe, List<FamilyMember> members) {
    for (final member in members) {
      if (!_isCompatibleWithMember(recipe, member)) {
        return false;
      }
    }
    return true;
  }

  bool _isCompatibleWithMember(Recipe recipe, FamilyMember member) {
    // 1. CRITICAL: Check Medical Conditions (The "Do Not Kill" Filter)
    for (final condition in member.medicalConditions) {
      if (!isSafeForCondition(recipe, condition)) {
        // print('🚫 [CLINICAL BLOCK] "${recipe.title}" rejected for ${member.name} due to ${condition.displayName}');
        return false;
      }
    }

    // 2. LIFESTYLE: Check Primary Diet (The "Preference" Filter)
    if (!isCompatibleWithLifestyle(recipe, member.primaryDiet)) {
      // print('⚠️ [LIFESTYLE BLOCK] "${recipe.title}" incompatible with ${member.primaryDiet.displayName}');
      return false;
    }
    
    return true;
  }

  /// Calculates all compatible diets and conditions for a recipe.
  /// Used by Seeder/Indexer to populate `dietTags`.
  List<String> calculateCompatibleDiets(Recipe recipe) {
    Set<String> compatibleTags = {};

    // Check Conditions
    for (final condition in MedicalCondition.values) {
      if (isSafeForCondition(recipe, condition)) {
        compatibleTags.add(condition.key);
      }
    }

    // Check Lifestyles
    for (final lifestyle in DietLifestyle.values) {
      if (isCompatibleWithLifestyle(recipe, lifestyle)) {
        compatibleTags.add(lifestyle.key);
      }
    }

    return compatibleTags.toList();
  }

  /// Evaluates safety for a specific medical condition.
  bool isSafeForCondition(Recipe recipe, MedicalCondition condition) {
    if (_hasCompatibleVariant(recipe, condition.key)) return true; // Used .key

    // Helper to check tags (Case insensitive)
    final lowerTags = recipe.tags.map((t) => t.toLowerCase()).toList();

    switch (condition) {
      case MedicalCondition.celiac:
        // Must be explicitly Glutent-Free or Celiac safe
        if (lowerTags.any((t) => ['gluten-free', 'celiac', 'sin gluten', 'gf'].contains(t))) return true;
        // Negative Check (Strict): Wheat, Barley, Rye, Malt, Seitan, Soy Sauce, Couscous, Bulgur
        if (_ingredientsContain(recipe, [
          'wheat', 'trigo', 'barley', 'cebada', 'rye', 'centeno', 'malt', 'malta', 
          'seitan', 'bulgur', 'couscous', 'semolina', 'kamut', 'spelt', 'espelta', 
          'farro', 'durum', 'soy sauce', 'salsa de soja', 'beer', 'cerveza', 'flour', 'harina', 'bread', 'pan'
        ])) return false;
        return true; // Trust the negative filter

      case MedicalCondition.aplv:
        if (lowerTags.any((t) => ['dairy-free', 'aplv', 'sin lacteos', 'vegan'].contains(t))) return true;
        
        final aplvExceptions = ['soy milk', 'almond milk', 'coconut milk', 'oat milk', 'rice milk', 'cocoa butter', 'fruit butter', 'peanut butter', 'nut butter'];
        if (_ingredientsContain(recipe, [
          'milk', 'leche', 'cheese', 'queso', 'butter', 'mantequilla', 'cream', 'nata', 
          'yogurt', 'yogur', 'whey', 'suero', 'casein', 'caseinato', 'lactose', 'lactosa', 'ghee', 'curd'
        ], except: aplvExceptions)) return false;
        return true; 

      case MedicalCondition.eggAllergy:
        if (lowerTags.any((t) => ['egg-free', 'vegan', 'plant-based'].contains(t))) return true;
        if (_ingredientsContain(recipe, ['egg', 'huevo', 'mayonnaise', 'mayonesa', 'meringue', 'merengue', 'albumin', 'albumina'], except: ['eggplant', 'veggie'])) return false; 
        return true; 

      case MedicalCondition.soyAllergy:
        if (lowerTags.contains('soy-free')) return true;
        if (_ingredientsContain(recipe, ['soy', 'soja', 'tofu', 'tempeh', 'edamame', 'miso', 'shoyu', 'tamari'])) return false;
        return true;

      case MedicalCondition.nutAllergy:
        if (lowerTags.contains('nut-free')) return true;
        if (_ingredientsContain(recipe, ['nut', 'nuez', 'almond', 'almendra', 'peanut', 'cacahuete', 'cashew', 'anacardo', 'walnut', 'nogueira', 'pecan', 'pecana', 'hazelnut', 'avellana', 'pistachio', 'pistacho', 'macadamia'], except: ['nutmeg', 'coconut', 'butternut', 'donut'])) return false;
        return true;

      case MedicalCondition.shellfishAllergy:
        if (lowerTags.contains('shellfish-free') || lowerTags.contains('vegan')) return true;
        if (_ingredientsContain(recipe, ['shrimp', 'gamba', 'camaron', 'crab', 'cangrejo', 'lobster', 'langosta', 'shellfish', 'marisco', 'prawn', 'langostino', 'oyster', 'ostras', 'mussel', 'mejillon', 'clam', 'almeja', 'squid', 'calamar', 'octopus', 'pulpo'])) return false;
        return true;
        
      case MedicalCondition.lowFodmap:
        if (lowerTags.any((t) => t.contains('fodmap'))) return true;
        
        if (_ingredientsContain(recipe, [
          'onion', 'cebolla', 'garlic', 'ajo', 'wheat', 'trigo', 'rye', 'centeno', 'barley', 'cebada', 
          'apple', 'manzana', 'pear', 'pera', 'peach', 'melocoton', 'plum', 'ciruela', 'honey', 'miel', 
          'milk', 'leche', 'yogurt', 'yogur', 'cheese', 'queso' // Lactose is high FODMAP usually
        ], except: ['garlic oil', 'garlic-infused oil', 'green onion', 'cebolleta', 'hard cheese', 'lactose-free'])) return false;
        return true;

      case MedicalCondition.histamine:
        // SIGHI Protocol
        if (lowerTags.contains('histamine') || lowerTags.contains('low-histamine')) return true;
        // Blocks: Tomato, Spinach, Cured Meats, Aged Cheese, Citrus, Fermented
        if (_ingredientsContain(recipe, [
          'tomato', 'tomate', 'spinach', 'espinaca', 'aged', 'curado', 'parmesan', 'parmesano', 
          'cured', 'salami', 'sausage', 'embutido', 'pepperoni', 'fermented', 'fermentado', 
          'vinegar', 'vinagre', 'soy sauce', 'salsa de soja', 'alcohol', 'wine', 'vino', 'beer', 'cerveza',
          'cheese', 'queso' // Most cheese is aged. Fresh cheese might be safe but risky.
        ], except: ['apple cider vinegar', 'mozzarella', 'ricotta'])) return false;
        return true;

      case MedicalCondition.diabetes:
        if (lowerTags.contains('diabetes') || lowerTags.contains('diabetic')) return true;
        if (lowerTags.contains('keto')) return true; 
        if (_ingredientsContain(recipe, ['sugar', 'azucar', 'honey', 'miel', 'syrup', 'sirope', 'molasses', 'melaza', 'juice', 'zumo', 'nectar'])) return false;
        return true;

      case MedicalCondition.renal:
        if (lowerTags.contains('renal') || lowerTags.contains('kidney')) return true;
        // Blocks: Banana, Potato, Tomato, Avocado, Spinach, Chocolate, Bran, Nuts
        if (_ingredientsContain(recipe, [
          'banana', 'platano', 'potato', 'patata', 'papa', 'tomato', 'tomate', 
          'avocado', 'aguacate', 'spinach', 'espinaca', 'chocolate', 'cacao', 'cocoa', 
          'nut', 'nuez', 'bran', 'salvado'
        ])) return false;
        // Note: For Renal, potato is acceptable ONLY if tagged Renal or variant exists.
        // We added 'potato' to ban list. If it has variant, it returns true BEFORE this check.
        return true;
    }
  }

  /// Evaluates compatibility with a lifestyle choice.
  bool isCompatibleWithLifestyle(Recipe recipe, DietLifestyle lifestyle) {
    if (lifestyle == DietLifestyle.omnivore) return true; // Omnivore eats everything
    
    // Check for explicit variant first (e.g., Omni recipe with "Keto" swap)
    if (_hasCompatibleVariant(recipe, lifestyle.key)) return true; // Used .key

    final lowerTags = recipe.tags.map((t) => t.toLowerCase()).toList();

    switch (lifestyle) {
      case DietLifestyle.vegan:
        return lowerTags.contains('vegan') || lowerTags.contains('plant-based');
      
      case DietLifestyle.vegetarian:
        return lowerTags.contains('vegetarian') || lowerTags.contains('vegan') || lowerTags.contains('plant-based');
      
      case DietLifestyle.pescatarian:
        if (lowerTags.contains('pescatarian') || lowerTags.contains('vegetarian') || lowerTags.contains('vegan')) return true;
        // Blocks: Meat, Chicken
        if (_ingredientsContain(recipe, ['chicken', 'pollo', 'beef', 'res', 'pork', 'cerdo', 'lamb', 'cordero', 'meat', 'carne'])) return false;
        return true;

      case DietLifestyle.keto:
        return lowerTags.contains('keto') || lowerTags.contains('low-carb');

      case DietLifestyle.paleo:
        return lowerTags.contains('paleo');

      case DietLifestyle.whole30:
        return lowerTags.contains('whole30');

      case DietLifestyle.mediterranean:
        return lowerTags.contains('mediterranean');

      case DietLifestyle.highPerformance:
        return lowerTags.contains('high-protein') || lowerTags.contains('sport');

      case DietLifestyle.lowCarb:
        return lowerTags.contains('low-carb') || lowerTags.contains('keto');
        
      default:
        return true;
    }
  }

  bool _ingredientsContain(Recipe recipe, List<String> keywords, {List<String> except = const []}) {
    for (final ingredient in recipe.ingredients) {
      final lowerIng = ingredient.toLowerCase();
      
      // Check if this ingredient matches any BAD keyword
      bool matchesKeyword = false;
      for (final keyword in keywords) {
        if (lowerIng.contains(keyword.toLowerCase())) {
          matchesKeyword = true;
          break;
        }
      }

      if (matchesKeyword) {
        // If it matches a keyword, check if it is explicitly EXEMPTED (safe substitute)
        bool isExempt = false;
        for (final ex in except) {
          if (lowerIng.contains(ex.toLowerCase())) {
            isExempt = true; 
            break;
          }
        }
        
        // If it matches a BAD word and is NOT exempt, it is UNSAFE.
        if (!isExempt) {
          return true; 
        }
      }
    }
    return false;
  }

  /// Checks if a recipe has a compatible variant for a specific diet/condition.
  /// Matches against keys in `variant_logic`.
  bool _hasCompatibleVariant(Recipe recipe, String token) {
    for (final step in recipe.steps) {
      if (step.isBranchPoint && step.variantLogic != null && step.variantLogic!.isNotEmpty) {
        // Relaxed matching: "Keto" matches "Keto", "Ketogenic", etc.
        if (step.variantLogic!.keys.any((key) => key.toLowerCase().contains(token.toLowerCase()))) {
          return true;
        }
      }
    }
    return false;
  }
}
