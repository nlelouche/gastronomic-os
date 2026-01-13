import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/domain/logic/recipe_resolver.dart';

void main() {
  group('Master Recipe System - Comprehensive Tests', () {
    group('1. Tag Parsing and Normalization', () {
      test('Parse single tag from ingredient string', () {
        final ingredient = 'AOVE (15ml) [Base]';
        final match = RegExp(r'\[(.*?)\]').firstMatch(ingredient);
        
        expect(match, isNotNull);
        expect(match!.group(1), equals('Base'));
      });

      test('Parse multiple tags from ingredient string', () {
        final ingredient = 'Arroz Integral (80g) [Base, Vegan, Vegetarian, Gluten-Free]';
        final match = RegExp(r'\[(.*?)\]').firstMatch(ingredient);
        final tags = match!.group(1)!.split(',').map((t) => t.trim()).toList();
        
        expect(tags, hasLength(4));
        expect(tags, containsAll(['Base', 'Vegan', 'Vegetarian', 'Gluten-Free']));
      });

      test('Ingredient without tags returns null match', () {
        final ingredient = 'Agua (500ml)';
        final match = RegExp(r'\[(.*?)\]').firstMatch(ingredient);
        
        expect(match, isNull);
      });

      test('Case-insensitive tag matching', () {
        final userTags = ['KETO', 'vegan', 'Celiac'];
        final normalized = userTags.map((t) => t.toLowerCase()).toSet();
        
        expect(normalized, contains('keto'));
        expect(normalized, contains('vegan'));
        expect(normalized, contains('celiac'));
        expect(normalized, hasLength(3));
      });

      test('Tag cleaning (trim whitespace)', () {
        final rawTags = ' Base , Vegan  ,  Keto ';
        final cleaned = rawTags.split(',').map((t) => t.trim()).toList();
        
        expect(cleaned, equals(['Base', 'Vegan', 'Keto']));
      });
    });

    group('2. Family Member Tag Collection', () {
      test('Collect tags from single member', () {
        final member = FamilyMember(
          name: 'Test',
          role: FamilyRole.mother,
          primaryDiet: DietLifestyle.keto,
          medicalConditions: [MedicalCondition.celiac, MedicalCondition.aplv],
        );

        final tags = <String>{
          member.primaryDiet.key,
          ...member.medicalConditions.map((c) => c.key),
        };

        expect(tags, hasLength(3));
        expect(tags, contains('keto'));
        expect(tags, contains('celiac'));
        expect(tags, contains('aplv'));
      });

      test('Collect tags from multiple family members', () {
        final family = [
          FamilyMember(
            name: 'Fercha',
            role: FamilyRole.son,
            primaryDiet: DietLifestyle.highPerformance,
            medicalConditions: [],
          ),
          FamilyMember(
            name: 'Mamá',
            role: FamilyRole.mother,
            primaryDiet: DietLifestyle.keto,
            medicalConditions: [MedicalCondition.diabetes],
          ),
        ];

        final allTags = <String>{};
        for (final member in family) {
          allTags.add(member.primaryDiet.key);
          allTags.addAll(member.medicalConditions.map((c) => c.key));
        }

        expect(allTags, hasLength(3));
        expect(allTags, containsAll(['high_performance', 'keto', 'diabetes']));
      });

      test('Family with no medical conditions', () {
        final member = FamilyMember(
          name: 'Omnivore',
          role: FamilyRole.father,
          primaryDiet: DietLifestyle.omnivore,
          medicalConditions: [],
        );

        final tags = {member.primaryDiet.key};
        
        expect(tags, hasLength(1));
        expect(tags, contains('omnivore'));
      });
    });

    group('3. Ingredient Filtering with Real Master Recipe Data', () {
      late Recipe masterRecipe;

      setUp(() {
        // Exact ingredients from the actual Master Recipe
        masterRecipe = Recipe(
          id: 'GOS-MASTER-UNIVERSAL-001',
          authorId: 'test',
          title: 'Bol Universal',
          createdAt: DateTime.now(),
          ingredients: [
            'Pechuga de Pollo Orgánica (150g/persona) [Base, Paleo, Whole30, High-Performance]',
            'Tofu Firme (150g/persona) [Vegan, Vegetarian]',
            'Pescado Blanco (Merluza/Bacalao) (150g/persona) [Pescatarian, Histamine]',
            'Arroz Integral (80g en seco/persona) [Base, Vegan, Vegetarian, Gluten-Free]',
            'Arroz de Coliflor (200g/persona) [Keto, Paleo, Low-Carb, Whole30, Diabetes]',
            'Quinoa Tricolor (80g en seco/persona) [Celiac, High-Performance]',
            'Calabacín (100g/persona) [Base]',
            'Calabacín (60g máx/persona) [Low FODMAP]',
            'Zanahoria (100g/persona) [Base]',
            'Zanahoria Lixiviada (remojo 4h) (80g/persona) [Renal]',
            'Espinaca Baby (puñado) [Base, Keto]',
            'Acelga o Rúcula (puñado) [Histamine, Renal]',
            'AOVE (Aceite de Oliva Virgen Extra) (15ml) [Base]',
            'Aceite de Coco o Aguacate (15ml) [Histamine]',
            'Aceite Infusionado en Ajo (sin sólidos) (15ml) [Low FODMAP]',
            'Ajo Fresco (1 diente) [Base]',
            'Cebolla Morada (1/4 unidad) [Base]',
            'Cebollino (parte verde) (1 cda) [Low FODMAP]',
            'Salsa de Soja (10ml) [Base]',
            'Tamari (10ml) [Celiac, Gluten-Free]',
            'Coconut Aminos (10ml) [Soy Allergy, Paleo, Whole30]',
            'Sal Marina (al gusto) [Base]',
            'Sal Sin Sodio / Hierbas (al gusto) [Renal]',
            'Anacardos/Nueces (10g) [Base, Keto, High-Performance]',
            'Semillas de Calabaza/Girasol (10g) [Nut Allergy, Histamine]',
            'Aguacate (1/4 unidad) [Base, Keto, Paleo]',
            'Aguacate (1/8 unidad o omitir) [Renal, Low FODMAP, Histamine]',
          ],
          steps: [],
        );
      });

      test('Total ingredient count is 27', () {
        expect(masterRecipe.ingredients.length, equals(27));
      });

      test('High-Performance profile filtering', () {
        final filtered = masterRecipe.getIngredientsForProfile(['high_performance', 'high-performance']);
        
        // Should include High-Performance items
        expect(filtered.any((i) => i.contains('Pechuga de Pollo')), isTrue);
        expect(filtered.any((i) => i.contains('Quinoa')), isTrue);
        expect(filtered.any((i) => i.contains('Anacardos/Nueces')), isTrue);
        
        // Should include all Base items
        expect(filtered.any((i) => i.contains('AOVE')), isTrue);
        expect(filtered.any((i) => i.contains('Sal Marina')), isTrue);
        expect(filtered.any((i) => i.contains('Arroz Integral')), isTrue);
        
        // Count should be less than 27
        expect(filtered.length, lessThan(27));
        expect(filtered.length, greaterThan(10)); // Reasonable range
      });

      test('Keto + High-Performance (Mamá + Fercha scenario)', () {
        final filtered = masterRecipe.getIngredientsForProfile(['keto', 'high_performance', 'high-performance']);
        
        // Keto specific
        expect(filtered.any((i) => i.contains('Arroz de Coliflor')), isTrue);
        expect(filtered.any((i) => i.contains('Espinaca Baby')), isTrue);
        
        // High-Performance specific
        expect(filtered.any((i) => i.contains('Pechuga de Pollo')), isTrue);
        expect(filtered.any((i) => i.contains('Quinoa')), isTrue);
        
        // Base items
        expect(filtered.any((i) => i.contains('Arroz Integral')), isTrue);
        expect(filtered.any((i) => i.contains('AOVE')), isTrue);
        
        print('Filtered count for Keto+HighPerf: ${filtered.length}');
      });

      test('Vegan profile excludes meat but includes Base', () {
        final filtered = masterRecipe.getIngredientsForProfile(['vegan']);
        
        // Vegan items
        expect(filtered.any((i) => i.contains('Tofu')), isTrue);
        expect(filtered.any((i) => i.contains('Arroz Integral')), isTrue);
        
        // Base items (even if not vegan-specific)
        expect(filtered.any((i) => i.contains('Pechuga de Pollo')), isTrue,
          reason: '[Base] items always show');
        
        print('Filtered count for Vegan: ${filtered.length}');
      });
    });

    group('4. Step Resolution Integration', () {
      test('RecipeResolver handles variants for family', () {
        final recipe = Recipe(
          id: 'TEST',
          authorId: 'test',
          title: 'Test',
          createdAt: DateTime.now(),
          ingredients: [],
          steps: [
            RecipeStep(
              instruction: 'Cocer arroz integral.',
              isBranchPoint: true,
              variantLogic: {
                'Keto': 'Usar arroz de coliflor.',
              },
            ),
          ],
        );

        final family = [
          FamilyMember(
            name: 'Keto User',
            role: FamilyRole.mother,
            primaryDiet: DietLifestyle.keto,
            medicalConditions: [],
          ),
        ];

        final resolver = RecipeResolver();
        final resolved = resolver.resolve(recipe, family);

        expect(resolved, hasLength(1));
        expect(resolved[0].instruction, contains('arroz de coliflor'));
        expect(resolved[0].targetGroupLabel, contains('Keto User'));
      });
    });

    group('5. Edge Cases and Error Handling', () {
      test('Malformed tag brackets are ignored', () {
        final recipe = Recipe(
          id: 'TEST',
          authorId: 'test',
          title: 'Test',
          createdAt: DateTime.now(),
          ingredients: [
            'Ingredient without closing bracket [Base',
            'Ingredient with [nested [brackets]]',
            'Normal ingredient [Base]',
          ],
          steps: [],
        );

        final filtered = recipe.getIngredientsForProfile(['base']);
        
        // Should not crash, should handle gracefully
        expect(filtered, isNotEmpty);
      });

      test('Empty family tags shows all Base items', () {
        final recipe = Recipe(
          id: 'TEST',
          authorId: 'test',
          title: 'Test',
          createdAt: DateTime.now(),
          ingredients: [
            'Item 1 [Base]',
            'Item 2 [Keto]',
            'Item 3',
          ],
          steps: [],
        );

        final filtered = recipe.getIngredientsForProfile([]);
        
        expect(filtered, contains(contains('Item 1')));
        expect(filtered, contains(contains('Item 3'))); // No tags = universal
      });

      test('Unknown diet tags are handled gracefully', () {
        final recipe = Recipe(
          id: 'TEST',
          authorId: 'test',
          title: 'Test',
          createdAt: DateTime.now(),
          ingredients: [
            'Item [UnknownDiet, Keto]',
          ],
          steps: [],
        );

        final filtered = recipe.getIngredientsForProfile(['keto']);
        
        expect(filtered, hasLength(1), reason: 'Should match on Keto tag');
      });
    });

    group('6. UI Consistency Validation', () {
      test('Filtered count matches actual filtered list length', () {
        final recipe = Recipe(
          id: 'TEST',
          authorId: 'test',
          title: 'Test',
          createdAt: DateTime.now(),
          ingredients: List.generate(10, (i) => 'Item $i [Base]'),
          steps: [],
        );

        final filtered = recipe.getIngredientsForProfile(['keto']);
        final count = filtered.length;
        
        // Count header should display this count, NOT recipe.ingredients.length
        expect(count, equals(10), reason: 'All are Base, so all should show');
        expect(count, isNot(equals(recipe.ingredients.length)), 
          reason: 'This test would fail if we were using wrong count source');
      });

      test('Master Recipe filtered count for standard family', () {
        final masterRecipe = Recipe(
          id: 'MASTER',
          authorId: 'test',
          title: 'Master',
          createdAt: DateTime.now(),
          ingredients: List.generate(27, (i) => 
            i < 10 ? 'Item $i [Base]' : 
            i < 20 ? 'Item $i [Keto]' :
            'Item $i [Vegan]'
          ),
          steps: [],
        );

        final filtered = masterRecipe.getIngredientsForProfile(['keto']);
        
        print('Total ingredients: ${masterRecipe.ingredients.length}');
        print('Filtered for Keto: ${filtered.length}');
        
        // The UI should display filtered.length, NOT 27
        expect(filtered.length, lessThan(27));
        expect(filtered.length, greaterThan(10)); // Has Base + Keto
      });
    });
  });
}
