import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/planner/domain/logic/diet_engine.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';

void main() {
  late DietEngine dietEngine;

  setUp(() {
    dietEngine = DietEngine();
  });

  group('DietEngine Filter Logic', () {
    // Factory method helper
    Recipe createRecipe({
      required String title,
      List<String> tags = const [],
      List<String> ingredients = const [],
      List<RecipeStep> steps = const [],
    }) {
      return Recipe(
        id: '1',
        title: title,
        description: 'Test Desc',
        tags: tags,
        ingredients: ingredients,
        steps: steps,
        isPublic: true,
        authorId: 'user1',
        createdAt: DateTime.now(), // Fixed: Required
      );
    }

    // Fixed: Added required 'role' argument
    final veganMember = FamilyMember(id: '1', name: 'Vegan', role: 'Member', diet: 'Vegan', allergies: []);
    final vegetarianMember = FamilyMember(id: '2', name: 'Veg', role: 'Member', diet: 'Vegetarian', allergies: []);
    final omnivoreMember = FamilyMember(id: '3', name: 'Omni', role: 'Member', diet: 'Omnivore', allergies: []);
    final allergyMember = FamilyMember(id: '4', name: 'Allergic', role: 'Member', diet: 'Omnivore', allergies: ['Nuts']);

    test('Should accept any recipe for Omnivore', () {
      final recipe = createRecipe(title: 'Meat Feast', tags: ['Meat']);
      expect(dietEngine.areRecipesCompatible(recipe, [omnivoreMember]), isTrue);
    });

    test('Should reject meat recipe for Vegan', () {
      final recipe = createRecipe(title: 'Steak', tags: ['Keto', 'Meat']);
      expect(dietEngine.areRecipesCompatible(recipe, [veganMember]), isFalse);
    });

    test('Should accept Vegan Tagged recipe for Vegan', () {
      final recipe = createRecipe(title: 'Tofu Salad', tags: ['Vegan']);
      expect(dietEngine.areRecipesCompatible(recipe, [veganMember]), isTrue);
    });

    test('Should accept Keyword inferred recipe (Tofu) for Vegetarian', () {
      final recipe = createRecipe(title: 'Bowl de Tofu Mágico', tags: []); 
      expect(dietEngine.areRecipesCompatible(recipe, [vegetarianMember]), isTrue);
    });

    test('Should REJECT Keyword inferred recipe if conflicting (Fish)', () {
      // "Lentils" usually safe, but check logic doesn't infer from Lentils
      final recipe = createRecipe(title: 'Lentil Soup', tags: [], ingredients: ['Lentils']);
      expect(dietEngine.areRecipesCompatible(recipe, [vegetarianMember]), isFalse);
    });

    test('Should accept recipe with Vegan VARIANT for Vegan', () {
      final recipe = createRecipe(
        title: 'Steak & Eggs', 
        tags: ['Keto'],
        steps: [
           RecipeStep( // Fixed class name
             instruction: 'Cook Steak',
             isBranchPoint: true,
             variantLogic: {'Vegan': 'Use Tempeh'}
           )
        ]
      );
      expect(dietEngine.areRecipesCompatible(recipe, [veganMember]), isTrue);
    });

    test('Should block Allergen ingredients regardless of diet', () {
      final recipe = createRecipe(
        title: 'Nut Cake', 
        tags: ['Pro-Metabolic'], 
        ingredients: ['Flour', 'Walnuts', 'Sugar']
      );
      expect(dietEngine.areRecipesCompatible(recipe, [allergyMember]), isFalse);
    });
  });
}
