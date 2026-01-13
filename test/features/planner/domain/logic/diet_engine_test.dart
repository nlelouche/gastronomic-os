import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/planner/domain/logic/diet_engine.dart';

void main() {
  late DietEngine dietEngine;

  setUp(() {
    dietEngine = DietEngine();
  });

  // --- Helper to create a dummy recipe ---
  Recipe createRecipe({
    required String title,
    List<String> ingredients = const [],
    List<String> tags = const [],
    Map<String, String>? variantLogic,
  }) {
    return Recipe(
      id: 'test-recipe-1',
      authorId: 'test-author', // Required
      title: title,
      description: 'Test Description',
      createdAt: DateTime.now(), // Required
      // REMOVED: imageUrl, prepTimeMinutes, servings, difficulty, caloriesPerServing (Not in Entity)
      tags: tags,
      ingredients: ingredients,
      steps: [
        RecipeStep(
          instruction: 'Cook things.',
          isBranchPoint: variantLogic != null,
          variantLogic: variantLogic,
        )
      ],
      dietTags: const [], 
    );
  }

  // --- Helper to create a family member ---
  FamilyMember createMember({
    String name = 'TestUser',
    DietLifestyle diet = DietLifestyle.omnivore,
    List<MedicalCondition> conditions = const [],
  }) {
    return FamilyMember(
      id: 'user-1',
      name: name,
      role: 'Tester',
      primaryDiet: diet,
      medicalConditions: conditions,
    );
  }

  group('Clinical Safety Guidelines (Zero Tolerance)', () {
    
    // 1. APLV (Cow's Milk Protein Allergy)
    // Rule: NO milk, cheese, yogurt, butter, cream, whey, casein.
    test('APLV should REJECT milk products and HIDDEN casein', () {
      final unsafeIngredients = [
        ['Milk'], ['Cheese'], ['Yogurt'], ['Butter'], ['Cream'],
        ['Whey Protein'], ['Caseinate'], ['Sodium Caseinate']
      ];

      for (final ing in unsafeIngredients) {
        final recipe = createRecipe(title: 'Unsafe APLV', ingredients: ing);
        final member = createMember(conditions: [MedicalCondition.aplv]);
        
        expect(
          dietEngine.isRecipeCompatible(recipe, [member]), 
          false, 
          reason: 'APLV should reject ${ing[0]}'
        );
      }
    });

    test('APLV should ACCEPT safe substitutes', () {
      final recipe = createRecipe(
        title: 'Vegan Mac', 
        ingredients: ['Soy Milk', 'Nutritional Yeast', 'Pasta']
      );
      final member = createMember(conditions: [MedicalCondition.aplv]);
      expect(dietEngine.isRecipeCompatible(recipe, [member]), true);
    });

    // 2. Celiac Disease
    // Rule: NO Wheat, Barley, Rye, Malt, Seitan, Soy Sauce (generic).
    test('Celiac should REJECT gluten sources', () {
      final unsafeIngredients = [
        ['Wheat Flour'], ['Barley'], ['Rye Bread'], ['Malt Vinegar'],
        ['Seitan'], ['Soy Sauce'], ['Couscous'], ['Bulgur']
      ];

      for (final ing in unsafeIngredients) {
        final recipe = createRecipe(title: 'Unsafe Gluten', ingredients: ing);
        final member = createMember(conditions: [MedicalCondition.celiac]);
        
        expect(
          dietEngine.isRecipeCompatible(recipe, [member]), 
          false, 
          reason: 'Celiac should reject ${ing[0]}'
        );
      }
    });

    test('Celiac should ACCEPT Gluten-Free certified items', () {
      final recipe = createRecipe(
        title: 'GF Pasta', 
        ingredients: ['Rice Flour', 'Tamari', 'Quinoa'],
        tags: ['Gluten-Free'] // Explicit tag helps
      );
      final member = createMember(conditions: [MedicalCondition.celiac]);
      expect(dietEngine.isRecipeCompatible(recipe, [member]), true);
    });

    // 3. Renal Disease
    // Rule: Limit Potassium (Banana, Potato, Tomato, Spinach) & Phosphorus.
    // NOTE: Some items are allowed IF LEACHED, but raw/standard are high risk.
    // For "Zero Tolerance" safety, we might reject high-potassium items unless explicitly tagged "Renal".
    test('Renal should REJECT high-potassium bombs unless variants exist', () {
      final unsafeIngredients = [
        ['Banana'], ['Potato'], ['Tomato Paste'], ['Spinach'], ['Avocado']
      ];

      for (final ing in unsafeIngredients) {
        final recipe = createRecipe(title: 'High Potassium', ingredients: ing);
        // Without variant logic or "Renal" tag, should fail
        final member = createMember(conditions: [MedicalCondition.renal]);
        
        expect(
          dietEngine.isRecipeCompatible(recipe, [member]), 
          false, 
          reason: 'Renal should reject ${ing[0]}'
        );
      }
    });

    test('Renal should ACCEPT high-potassium items IF a variant exists', () {
      final recipe = createRecipe(
        title: 'Potatoes', 
        ingredients: ['Potato'],
        variantLogic: {'Renal': 'Soak potatoes for 4 hours (Leaching)'}
      );
      final member = createMember(conditions: [MedicalCondition.renal]);
      
      // Should pass because a specific Renal variant is provided
      expect(dietEngine.isRecipeCompatible(recipe, [member]), true);
    });

    // 4. Low FODMAP
    // Rule: No Onion, Garlic, Honey, Wheat, Milk.
    test('Low FODMAP should REJECT high FODMAP ingredients', () {
      final unsafeIngredients = [
        ['Onion'], ['Garlic'], ['Honey'], ['Apple'], ['Wheat'], ['Milk']
      ];

      for (final ing in unsafeIngredients) {
        final recipe = createRecipe(title: 'Fodmap Bomb', ingredients: ing);
        final member = createMember(conditions: [MedicalCondition.lowFodmap]);
        
        expect(
          dietEngine.isRecipeCompatible(recipe, [member]), 
          false, 
          reason: 'Low FODMAP should reject ${ing[0]}'
        );
      }
    });

    test('Low FODMAP should ACCEPT Garlic Oil', () {
      final recipe = createRecipe(
        title: 'Safe Flavor', 
        ingredients: ['Garlic-infused Oil', 'Green Onion Tops', 'Maple Syrup']
      );
      final member = createMember(conditions: [MedicalCondition.lowFodmap]);
      expect(dietEngine.isRecipeCompatible(recipe, [member]), true);
    });

    // 5. Histamine Intolerance
    // Rule: No Tomato, Spinach, Cured Meat, Fermented, Leftovers logic (hard to test here, but check ingredients).
    test('Histamine should REJECT liberators and fermented items', () {
      final unsafeIngredients = [
        ['Tomato'], ['Spinach'], ['Parmesan'], ['Salami'], ['Soy Sauce'], ['Vinegar']
      ];

      for (final ing in unsafeIngredients) {
        final recipe = createRecipe(title: 'Histamine Bomb', ingredients: ing);
        final member = createMember(conditions: [MedicalCondition.histamine]);
        
        expect(
          dietEngine.isRecipeCompatible(recipe, [member]), 
          false, 
          reason: 'Histamine should reject ${ing[0]}'
        );
      }
    });
  });

  group('Lifestyle Compatibility', () {
    
    test('Vegan should REJECT animal products', () {
      final unsafeIngredients = [
        ['Beef'], ['Chicken'], ['Fish'], ['Egg'], ['Honey'], ['Gelatin']
      ];

      for (final ing in unsafeIngredients) {
        final recipe = createRecipe(title: 'Not Vegan', ingredients: ing);
        final member = createMember(diet: DietLifestyle.vegan);
        
        expect(
          dietEngine.isRecipeCompatible(recipe, [member]), 
          false, 
          reason: 'Vegan should reject ${ing[0]}'
        );
      }
    });

    test('Keto should REJECT sugars and starches', () {
      final unsafeIngredients = [
        ['Sugar'], ['Rice'], ['Potato'], ['Pasta'], ['Bread']
      ];

      for (final ing in unsafeIngredients) {
        final recipe = createRecipe(title: 'Carb Bomb', ingredients: ing);
        final member = createMember(diet: DietLifestyle.keto);
        
        expect(
          dietEngine.isRecipeCompatible(recipe, [member]), 
          false, 
          reason: 'Keto should reject ${ing[0]}'
        );
      }
    });

    test('Mixed Family: Omnivore + Vegan', () {
      // Recipe has Meat but offers Vegan variant
      final recipe = createRecipe(
        title: 'Tacos', 
        ingredients: ['Beef'],
        variantLogic: {'Vegan': 'Use Lentils'}
      );
      
      final dad = createMember(name: 'Dad', diet: DietLifestyle.omnivore);
      final mom = createMember(name: 'Mom', diet: DietLifestyle.vegan);

      expect(dietEngine.isRecipeCompatible(recipe, [dad, mom]), true);
    });

    test('Mixed Family: Universal Fail', () {
      // Recipe has Meat and NO Vegan variant
      final recipe = createRecipe(
        title: 'Steak', 
        ingredients: ['Beef'],
        variantLogic: {}
      );
      
      final dad = createMember(name: 'Dad', diet: DietLifestyle.omnivore);
      final mom = createMember(name: 'Mom', diet: DietLifestyle.vegan);

      expect(dietEngine.isRecipeCompatible(recipe, [dad, mom]), false);
    });
  });
}
