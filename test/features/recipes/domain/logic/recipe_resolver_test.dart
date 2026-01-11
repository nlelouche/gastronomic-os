import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/domain/logic/recipe_resolver.dart';

void main() {
  late RecipeResolver resolver;

  setUp(() {
    resolver = RecipeResolver();
  });

  group('RecipeResolver Logic', () {
    final dad = FamilyMember(id: '1', name: 'Dad', role: 'Dad', diet: 'Omnivore', allergies: []);
    final son = FamilyMember(id: '2', name: 'Son', role: 'Child', diet: 'Vegetarian', allergies: []);

    Recipe createRecipeWithSteps(List<RecipeStep> steps) {
      return Recipe(
        id: '1',
        title: 'Test',
        description: 'Desc',
        tags: [],
        ingredients: [],
        steps: steps,
        isPublic: true,
        authorId: 'u1',
        createdAt: DateTime.now(), // Fixed
      );
    }

    test('Should show universal step to everyone', () async {
      final step = RecipeStep(instruction: 'Boil Water', isBranchPoint: false);
      final recipe = createRecipeWithSteps([step]);
      
      final resolved = await resolver.resolve(recipe, [dad, son]);
      
      expect(resolved.length, 1);
      expect(resolved.first.targetMembers.length, 2); // Both
      expect(resolved.first.isUniversal, isTrue);
    });

    test('Should skip meat step for Vegetarian', () async {
      final step = RecipeStep(
        instruction: 'Fry Steak', 
        isBranchPoint: false,
        skippedForDiets: ['Vegetarian']
      );
      final recipe = createRecipeWithSteps([step]);
      
      final resolved = await resolver.resolve(recipe, [dad, son]);
      
      expect(resolved.length, 1);
      expect(resolved.first.targetMembers, contains('Dad'));
      expect(resolved.first.targetMembers, isNot(contains('Son'))); // Son skipped
      expect(resolved.first.isUniversal, isFalse);
    });

    test('Should apply variant text for Vegetarian', () async {
      final step = RecipeStep(
        instruction: 'Add Egg', 
        isBranchPoint: true,
        variantLogic: {'Vegetarian': 'Add Tofu'}
      );
      final recipe = createRecipeWithSteps([step]);
      
      final resolved = await resolver.resolve(recipe, [dad, son]);
      
      // Since Dad gets "Add Egg" and Son gets "Add Tofu",
      // The resolver should produce 2 resolved steps.
      expect(resolved.length, 2);
      
      final dadStep = resolved.firstWhere((s) => s.targetMembers.contains('Dad'));
      expect(dadStep.instruction, 'Add Egg');
      
      final sonStep = resolved.firstWhere((s) => s.targetMembers.contains('Son'));
      expect(sonStep.instruction, 'Add Tofu');
    });
  });
}
