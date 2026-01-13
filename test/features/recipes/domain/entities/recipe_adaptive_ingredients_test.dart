import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';

void main() {
  group('Recipe.getIngredientsForProfile', () {
    late Recipe masterRecipe;

    setUp(() {
      // Simplified version of the Master Recipe for testing
      masterRecipe = Recipe(
        id: 'TEST-001',
        authorId: 'test-author',
        title: 'Test Recipe',
        createdAt: DateTime.now(),
        ingredients: [
          // Pure Base items (should ALWAYS show)
          'AOVE (Aceite de Oliva Virgen Extra) (15ml) [Base]',
          'Sal Marina (al gusto) [Base]',
          
          // Base + specific diets
          'Arroz Integral (80g) [Base, Vegan, Vegetarian, Gluten-Free]',
          'Pechuga de Pollo (150g) [Base, Paleo, Whole30, High-Performance]',
          
          // Diet-specific (no Base)
          'Arroz de Coliflor (200g) [Keto, Paleo, Low-Carb, Whole30, Diabetes]',
          'Tofu Firme (150g) [Vegan, Vegetarian]',
          
          // Universal
          'Agua (500ml)',
        ],
        steps: [
          RecipeStep(
            instruction: 'Cocer el arroz integral.',
            isBranchPoint: true,
            variantLogic: {
              'Keto': 'Preparar arroz de coliflor.',
            },
          ),
          RecipeStep(
            instruction: 'Cortar pollo en dados.',
            isBranchPoint: true,
            variantLogic: {
              'Vegan': 'Usar tofu.',
            },
          ),
        ],
      );
    });

    test('Empty profile should show Base and Universal items', () {
      final filtered = masterRecipe.getIngredientsForProfile([]);
      
      expect(filtered, contains(contains('AOVE')));
      expect(filtered, contains(contains('Sal Marina')));
      expect(filtered, contains(contains('Agua')));
      expect(filtered, contains(contains('Arroz Integral'))); // Has Base
      expect(filtered, contains(contains('Pechuga de Pollo'))); // Has Base
    });

    test('Keto profile shows Keto items + Pure Base', () {
      final filtered = masterRecipe.getIngredientsForProfile(['keto']);
      
      // Should show
      expect(filtered, contains(contains('Arroz de Coliflor')), reason: '[Keto] item');
      expect(filtered, contains(contains('AOVE')), reason: 'Pure [Base]');
      expect(filtered, contains(contains('Sal Marina')), reason: 'Pure [Base]');
      expect(filtered, contains(contains('Agua')), reason: 'Universal');
      
      // Should NOT show
      expect(filtered, isNot(contains(contains('Tofu'))), reason: '[Vegan] only');
    });

    test('Vegan profile shows Vegan items + ALL Base items', () {
      final filtered = masterRecipe.getIngredientsForProfile(['vegan']);
      
      // Should show - Vegan specific
      expect(filtered, contains(contains('Tofu')), reason: '[Vegan] item');
      expect(filtered, contains(contains('Arroz Integral')), reason: '[Base, Vegan]');
      
      // Should show - Pure Base
      expect(filtered, contains(contains('AOVE')), reason: 'Pure [Base]');
      expect(filtered, contains(contains('Sal Marina')), reason: 'Pure [Base]');
      
      // Should show - All Base items (NEW BEHAVIOR)
      expect(filtered, contains(contains('Pechuga de Pollo')), 
        reason: '[Base] items always show for consistency with recipe steps');
    });

    test('High-Performance + Keto (Master Recipe scenario)', () {
      final filtered = masterRecipe.getIngredientsForProfile(['high-performance', 'keto']);
      
      // Critical: Items needed for BOTH members
      expect(filtered, contains(contains('Pechuga de Pollo')), 
        reason: '[High-Performance] for Fercha');
      expect(filtered, contains(contains('Arroz de Coliflor')), 
        reason: '[Keto] for Mamá');
      
      // Pure Base (universal)
      expect(filtered, contains(contains('AOVE')));
      expect(filtered, contains(contains('Sal Marina')));
      
      // CRITICAL BUG TEST: This should show because Step 1 says "Cocer arroz integral" for High-Performance
      // But current logic hides it because [Base, Vegan, Vegetarian] don't match {high-performance, keto}
      expect(filtered, contains(contains('Arroz Integral')), 
        reason: 'CRITICAL: Arroz Integral has [Base] and is used in Step 1 for High-Performance users');
    });

    test('Ingredients should match what steps reference', () {
      // This is a META test: If Step 1 base instruction says "arroz integral",
      // then "Arroz Integral" MUST be in the filtered list for users who see that step
      
      final highPerfFiltered = masterRecipe.getIngredientsForProfile(['high-performance']);
      final step1 = masterRecipe.steps[0];
      
      // Step 1 base: "Cocer el arroz integral"
      // Therefore, High-Performance user MUST see Arroz Integral
      expect(step1.instruction.toLowerCase(), contains('arroz integral'));
      expect(highPerfFiltered.any((ing) => ing.toLowerCase().contains('arroz integral')), isTrue,
        reason: 'If step mentions "arroz integral", ingredient list must include it');
    });

    test('Case insensitivity of tag matching', () {
      final filtered1 = masterRecipe.getIngredientsForProfile(['KETO']);
      final filtered2 = masterRecipe.getIngredientsForProfile(['keto']);
      final filtered3 = masterRecipe.getIngredientsForProfile(['Keto']);
      
      expect(filtered1.length, equals(filtered2.length));
      expect(filtered2.length, equals(filtered3.length));
    });

    test('Multiple diet tags are OR-ed (union)', () {
      final filtered = masterRecipe.getIngredientsForProfile(['vegan', 'keto']);
      
      // Should get Vegan items
      expect(filtered, contains(contains('Tofu')));
      expect(filtered, contains(contains('Arroz Integral'))); // [Base, Vegan]
      
      // Should get Keto items
      expect(filtered, contains(contains('Arroz de Coliflor'))); // [Keto]
    });

    test('Items with Base tag should always be considered', () {
      // This test formalizes the rule: 
      // "Items with [Base] are safe defaults and should show unless explicitly replaced"
      
      final omnivoreProfile = masterRecipe.getIngredientsForProfile(['omnivore']);
      
      // All [Base] items should show for omnivore
      expect(omnivoreProfile, contains(contains('AOVE')));
      expect(omnivoreProfile, contains(contains('Sal Marina')));
      expect(omnivoreProfile, contains(contains('Arroz Integral')));
      expect(omnivoreProfile, contains(contains('Pechuga de Pollo')));
    });
  });

  group('Edge Cases', () {
    test('Recipe with no tagged ingredients shows all', () {
      final recipe = Recipe(
        id: 'TEST-002',
        authorId: 'test',
        title: 'Simple Recipe',
        createdAt: DateTime.now(),
        ingredients: [
          'Agua',
          'Sal',
          'Aceite',
        ],
        steps: [],
      );
      
      final filtered = recipe.getIngredientsForProfile(['keto', 'vegan']);
      expect(filtered.length, equals(3), reason: 'No tags = show all');
    });

    test('Recipe with empty ingredients returns empty', () {
      final recipe = Recipe(
        id: 'TEST-003',
        authorId: 'test',
        title: 'Empty',
        createdAt: DateTime.now(),
        ingredients: [],
        steps: [],
      );
      
      final filtered = recipe.getIngredientsForProfile(['vegan']);
      expect(filtered, isEmpty);
    });
  });
}
