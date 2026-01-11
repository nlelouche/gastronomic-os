import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';

/// [DietEngine] handles the "Hard Constraints" of the Planner.
/// It filters out recipes that strictly violate a family member's diet or allergies.
/// 
/// **DAG Support:** Analyzes recipe steps for `variant_logic` to determine if a recipe
/// can be adapted for specific diets (e.g., a meat recipe with a Vegan variant).
class DietEngine {
  
  /// Checks if a [Recipe] is compatible with a List of [FamilyMember]s.
  /// Returns [true] only if the recipe is safe for EVERYONE.
  bool areRecipesCompatible(Recipe recipe, List<FamilyMember> members) {
    for (final member in members) {
      if (!_isCompatibleWithMember(recipe, member)) {
        return false;
      }
    }
    return true;
  }

  bool _isCompatibleWithMember(Recipe recipe, FamilyMember member) {
    // 1. Check Allergies (Hard Block)
    for (final allergy in member.allergies) {
      if (recipe.ingredients.any((ing) => ing.toLowerCase().contains(allergy.toLowerCase()))) {
        // TODO: Future enhancement - check if variant removes allergenic ingredient
        print('🚫 Recipe "${recipe.title}" rejected for ${member.name}: Allergy "$allergy" matches ingredient.');
        return false;
      }
    }

    // 2. Check Diet Compatibility
    final diet = member.diet.toLowerCase();
    
    // Omnivores accept everything
    if (diet == 'omnivore' || diet == 'omnívoro') {
      return true;
    }

    // For restrictive diets, check if recipe is compatible
    final compatible = _isDietCompatible(recipe, diet);
    if (!compatible) {
       print('🚫 Recipe "${recipe.title}" rejected for ${member.name}: Incompatible with diet "$diet". Tags: ${recipe.tags}');
    }
    return compatible;
  }

  /// Checks if a recipe is compatible with a specific diet.
  /// Uses a three-tier approach:
  /// 1. Recipe is explicitly tagged for this diet (e.g., "Vegan" tag)
  /// 2. Recipe has variant_logic that provides a compatible adaptation
  /// 3. Recipe has no conflicting ingredients (fallback for untagged recipes)
  bool _isDietCompatible(Recipe recipe, String diet) {
    final lowerTags = recipe.tags.map((t) => t.toLowerCase()).toList();

    // === VEGAN ===
    if (diet == 'vegan' || diet == 'vegano') {
      // Option 1: Explicitly tagged as vegan
      if (lowerTags.contains('vegan') || lowerTags.contains('plant-based')) {
        return true;
      }
      
      // Option 2: Has vegan variant in steps
      if (_hasCompatibleVariant(recipe, 'Vegan')) {
        return true;
      }
      
      // Strict: Reject if not explicitly vegan
      return false;
    }

    // === VEGETARIAN ===
    if (diet == 'vegetarian' || diet == 'vegetariano') {
      // Option 1: Explicit Tags
      if (lowerTags.any((t) => ['vegan', 'vegetarian', 'plant-based'].contains(t))) {
        return true;
      }
      
      // Option 2: Keyword Inference (Fix for missing tags in Tofu/Tempeh recipes)
      final title = recipe.title.toLowerCase();
      if (title.contains('tofu') || title.contains('tempeh') || title.contains('seitan')) {
         print('   ✅ Assuming Vegetarian via Title Keyword: "${recipe.title}"');
         return true; 
      }

      // Option 3: Has vegetarian OR vegan variant (vegan is vegetarian-compatible)
      if (_hasCompatibleVariant(recipe, 'Vegetarian') || _hasCompatibleVariant(recipe, 'Vegan')) {
        return true;
      }
      
      return false;
    }

    // === KETO ===
    if (diet == 'keto' || diet == 'ketogenic') {
      if (lowerTags.contains('keto') || lowerTags.contains('low-carb')) {
        return true;
      }
      if (_hasCompatibleVariant(recipe, 'Keto')) {
        return true;
      }
      return false;
    }

    // === CELIAC / GLUTEN-FREE ===
    if (diet == 'celiac' || diet == 'gluten-free' || diet == 'celiaco') {
      if (lowerTags.any((t) => ['celiac', 'gluten-free', 'sin gluten'].contains(t))) {
        return true;
      }
      if (_hasCompatibleVariant(recipe, 'Celiac') || _hasCompatibleVariant(recipe, 'Gluten-Free')) {
        return true;
      }
      return false;
    }

    // === PALEO ===
    if (diet == 'paleo') {
      if (lowerTags.contains('paleo') || lowerTags.contains('ancestral')) {
        return true;
      }
      if (_hasCompatibleVariant(recipe, 'Paleo')) {
        return true;
      }
      return false;
    }

    // === DIABETIC ===
    if (diet == 'diabetic' || diet == 'diabetes' || diet == 'diabético') {
      if (lowerTags.any((t) => ['diabetes', 'low-gi', 'diabetic'].contains(t))) {
        return true;
      }
      if (_hasCompatibleVariant(recipe, 'Diabetic') || _hasCompatibleVariant(recipe, 'Low-GI')) {
        return true;
      }
      return false;
    }

    // === RENAL ===
    if (diet == 'renal' || diet == 'kidney') {
      if (lowerTags.any((t) => ['renal', 'low-potassium', 'low-phosphorus'].contains(t))) {
        return true;
      }
      if (_hasCompatibleVariant(recipe, 'Renal')) {
        return true;
      }
      return false;
    }

    // === LOW FODMAP ===
    if (diet == 'low fodmap' || diet == 'fodmap') {
      if (lowerTags.any((t) => t.contains('fodmap'))) {
        return true;
      }
      if (_hasCompatibleVariant(recipe, 'Low FODMAP')) {
        return true;
      }
      return false;
    }

    // Default: Unknown diet, be permissive (assume omnivore-like)
    return true;
  }

  /// Checks if a recipe has a compatible variant for a specific diet.
  /// Scans all steps for branch points with variant_logic matching the target diet.
  bool _hasCompatibleVariant(Recipe recipe, String targetDiet) {
    for (final step in recipe.steps) {
      if (step.isBranchPoint && step.variantLogic != null && step.variantLogic!.isNotEmpty) {
        // Check for exact match (case-insensitive)
        if (step.variantLogic!.keys.any((key) => key.toLowerCase() == targetDiet.toLowerCase())) {
          return true;
        }
      }
    }
    return false;
  }
}
