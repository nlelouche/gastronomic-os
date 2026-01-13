import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/domain/logic/recipe_resolver.dart';

void main() {
  late RecipeResolver resolver;

  setUp(() {
    resolver = RecipeResolver();
  });

  // --- Helpers ---
  FamilyMember createMember(String name, DietLifestyle diet, {List<MedicalCondition> conditions = const []}) {
    return FamilyMember(
      id: name,
      name: name,
      role: FamilyRole.other,
      primaryDiet: diet,
      medicalConditions: conditions,
    );
  }

  Recipe createRecipe(List<RecipeStep> steps) {
    return Recipe(
      id: 'test',
      authorId: 'auth',
      title: 'Test Recipe',
      createdAt: DateTime.now(),
      ingredients: [],
      tags: [],
      dietTags: [],
      steps: steps,
    );
  }

  group('RecipeResolver Logic', () {
    test('Should return universal steps when no family is provided', () {
      final steps = [
        RecipeStep(instruction: 'Step 1'),
        RecipeStep(instruction: 'Step 2'),
      ];
      final recipe = createRecipe(steps);
      
      final result = resolver.resolve(recipe, []);
      
      expect(result.length, 2);
      expect(result[0].isUniversal, true);
      expect(result[1].isUniversal, true);
    });

    test('Should resolve universal steps for single member', () {
      final steps = [RecipeStep(instruction: 'Cook meat')];
      final recipe = createRecipe(steps);
      final member = createMember('Dad', DietLifestyle.omnivore);

      final result = resolver.resolve(recipe, [member]);

      expect(result.length, 1);
      expect(result[0].targetMembers, contains('Dad'));
      expect(result[0].isUniversal, true);
    });

    test('Should skip steps marked as skipped for specific diet', () {
      final steps = [
        RecipeStep(instruction: 'Add Cheese', skippedForDiets: ['Vegan']),
        RecipeStep(instruction: 'Serve'),
      ];
      final recipe = createRecipe(steps);
      final vegan = createMember('VeganUser', DietLifestyle.vegan);

      final result = resolver.resolve(recipe, [vegan]);

      // Expect only 'Serve'
      expect(result.length, 1);
      expect(result[0].instruction, 'Serve');
    });

    test('Should branch correctly for mixed diets', () {
      final steps = [
        RecipeStep(
          instruction: 'Cook Protein',
          isBranchPoint: true,
          variantLogic: {'Vegan': 'Cook Tofu', 'Omnivore': 'Cook Steak'},
        )
      ];
      final recipe = createRecipe(steps);
      
      final dad = createMember('Dad', DietLifestyle.omnivore);
      final mom = createMember('Mom', DietLifestyle.vegan);

      final result = resolver.resolve(recipe, [dad, mom]);

      // Should have 2 resolved steps (one for each variance)
      expect(result.length, 2);
      
      final tofuStep = result.firstWhere((s) => s.instruction == 'Cook Tofu');
      final steakStep = result.firstWhere((s) => s.instruction == 'Cook Steak');

      expect(tofuStep.targetMembers, contains('Mom'));
      expect(steakStep.targetMembers, contains('Dad'));
      expect(tofuStep.isUniversal, false);
    });

    test('Should identify functionally universal steps (convergence)', () {
      // Logic: If branching exists but all users map to the SAME instruction (e.g. Vegetarian and Vegan both map to 'Tofu'), 
      // it should appear as a single step, effectively universal for the present group.
      
      final steps = [
        RecipeStep(
          instruction: 'Main',
          isBranchPoint: true,
          variantLogic: {'Vegan': 'Tofu', 'Vegetarian': 'Tofu', 'Omnivore': 'Steak'},
        )
      ];
      final recipe = createRecipe(steps);
      
      final vegan = createMember('Vegan', DietLifestyle.vegan);
      final vegetarian = createMember('Vegetarian', DietLifestyle.vegetarian);
      
      // Both users get 'Tofu'
      final result = resolver.resolve(recipe, [vegan, vegetarian]);

      expect(result.length, 1);
      expect(result[0].instruction, 'Tofu');
      expect(result[0].isUniversal, true); // Should be marked universal as everyone sees it
    });
  });
}
