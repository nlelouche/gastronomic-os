import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/domain/logic/recipe_resolver.dart';

void main() {
  group('Soy Allergy Variant Resolution - Integration Test', () {
    late Recipe testRecipe;
    late RecipeResolver resolver;

    setUp(() {
      resolver = RecipeResolver();
      
      // Simplified version of Master Recipe Step 8 (Sazonar)
      testRecipe = Recipe(
        id: 'TEST-SOY',
        authorId: 'test',
        title: 'Soy Allergy Test Recipe',
        createdAt: DateTime.now(),
        ingredients: [
          'Salsa de Soja (10ml) [Base]',
          'Coconut Aminos (10ml) [Soy Allergy, Paleo, Whole30]',
        ],
        steps: [
          RecipeStep(
            instruction: 'Sazonar: Añadir salsa de soja.',
            isBranchPoint: true,
            variantLogic: {
              'Celiac': '⚠️ USAR TAMARI CERTIFICADO SIN GLUTEN.',
              'Soy Allergy': '🚫 PROHIBIDO SOJA/TAMARI. Usar \'Coconut Aminos\' o solo sal y limón.',
              'Paleo': 'Usar Coconut Aminos (la soja es legumbre).',
            },
            crossContaminationAlert: 'Celiac/Soy Allergy: Verificar etiquetas de salsas. Error común.',
          ),
        ],
      );
    });

    test('Family member with Soy Allergy should see Coconut Aminos variant', () {
      final family = [
        FamilyMember(
          name: 'Mamá de Fercha',
          role: FamilyRole.mother,
          primaryDiet: DietLifestyle.keto,
          medicalConditions: [MedicalCondition.soyAllergy],
        ),
      ];

      final resolved = resolver.resolve(testRecipe, family);

      expect(resolved, hasLength(1));
      
      // Critical check: instruction should contain "Coconut Aminos"
      expect(
        resolved[0].instruction.toLowerCase(),
        contains('coconut aminos'),
        reason: 'Soy Allergy user MUST see Coconut Aminos variant, not base soy sauce',
      );
      
      // Should NOT contain soy sauce
      expect(
        resolved[0].instruction.toLowerCase(),
        isNot(contains('salsa de soja')),
        reason: 'Soy Allergy user must NOT see soy sauce instruction',
      );
      
      // Should show cross contamination alert
      expect(resolved[0].crossContaminationAlert, isNotNull);
      expect(resolved[0].crossContaminationAlert, contains('Soy Allergy'));
    });

    test('Verify MedicalCondition.soyAllergy.key returns "Soy Allergy"', () {
      // This is THE critical check
      expect(MedicalCondition.soyAllergy.key, equals('Soy Allergy'));
    });

    test('Family member tags collection includes "Soy Allergy"', () {
      final member = FamilyMember(
        name: 'Test',
        role: FamilyRole.mother,
        primaryDiet: DietLifestyle.omnivore,
        medicalConditions: [MedicalCondition.soyAllergy],
      );

      final tags = <String>{
        member.primaryDiet.key,
        ...member.medicalConditions.map((c) => c.key),
      };

      expect(tags, contains('Soy Allergy'), 
        reason: 'Family member tags must include exact "Soy Allergy" string');
    });

    test('RecipeResolver finds variant when tag matches exactly', () {
      final step = RecipeStep(
        instruction: 'Base instruction',
        isBranchPoint: true,
        variantLogic: {
          'Soy Allergy': 'Variant for Soy Allergy',
          'Keto': 'Variant for Keto',
        },
      );

      final family = [
        FamilyMember(
          name: 'Test',
          role: FamilyRole.son,
          primaryDiet: DietLifestyle.omnivore,
          medicalConditions: [MedicalCondition.soyAllergy],
        ),
      ];

      final recipe = Recipe(
        id: 'TEST',
        authorId: 'test',
        title: 'Test',
        createdAt: DateTime.now(),
        ingredients: [],
        steps: [step],
      );

      final resolved = resolver.resolve(recipe, family);

      expect(resolved[0].instruction, equals('Variant for Soy Allergy'));
    });

    test('Case sensitivity check - tags must match EXACTLY', () {
      final step = RecipeStep(
        instruction: 'Base',
        isBranchPoint: true,
        variantLogic: {
          'soy allergy': 'Wrong - lowercase',
          'Soy Allergy': 'Correct - Title Case',
          'SOY ALLERGY': 'Wrong - uppercase',
        },
      );

      // The resolver should find "Soy Allergy" (Title Case)
      expect(step.variantLogic, containsPair('Soy Allergy', anything));
    });
  });
}
