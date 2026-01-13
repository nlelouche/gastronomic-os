import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/domain/logic/recipe_resolver.dart';

void main() {
  late RecipeResolver resolver;
  late Recipe complexRecipe;
  late List<FamilyMember> impossibleFamily;

  setUp(() {
    resolver = RecipeResolver();

    // 1. Define "The Impossible Family"
    impossibleFamily = [
      FamilyMember(
        id: 'dad',
        name: 'Dad (Keto)',
        role: FamilyRole.dad,
        primaryDiet: DietLifestyle.keto,
        medicalConditions: [],
      ),
      FamilyMember(
        id: 'mom',
        name: 'Mom (Vegan+Nut)',
        role: FamilyRole.mom,
        primaryDiet: DietLifestyle.vegan,
        medicalConditions: [MedicalCondition.nutAllergy],
      ),
      FamilyMember(
        id: 'kid1',
        name: 'Kid1 (Celiac)',
        role: FamilyRole.son,
        primaryDiet: DietLifestyle.omnivore,
        medicalConditions: [MedicalCondition.celiac],
      ),
      FamilyMember(
        id: 'kid2',
        name: 'Kid2 (Renal)',
        role: FamilyRole.daughter,
        primaryDiet: DietLifestyle.omnivore,
        medicalConditions: [MedicalCondition.renal],
      ),
    ];

    // 2. Define a Test Recipe mirroring the Master Recipe's complexity
    complexRecipe = Recipe(
      id: 'stress_test_recipe',
      title: 'Universal High-Performance Bowl',
      authorId: 'system',
      isPublic: true,
      createdAt: DateTime.now(), // Test doesn't care
      ingredients: [],
      steps: [
        // Step 1: Carbohydrate Base (Variants: Keto, Celiac, Renal)
        RecipeStep(
          instruction: 'Base: Cook Brown Rice.',
          isBranchPoint: true,
          variantLogic: {
            'Keto': 'Make Cauliflower Rice.',
            'Celiac': 'Use Quinoa (Certified GF).',
            'Renal': 'Use White Rice (washed).',
            'Vegan': 'Base: Cook Brown Rice.', // Explicit verify fallback
          },
        ),
        // Step 2: Protein (Variants: Vegan, Renal)
        RecipeStep(
          instruction: 'Protein: Sear Chicken Breast.',
          isBranchPoint: true,
          variantLogic: {
            'Vegan': 'Protein: Sear Tofu Cubes.',
            'Vegetarian': 'Protein: Sear Halloumi or Tofu.',
            'Renal': 'Protein: Sear Chicken (Limit portion 100g).',
          },
        ),
        // Step 3: Seasoning (Variants: Celiac, Soy Allergy, Renal)
        RecipeStep(
          instruction: 'Season: Add Soy Sauce.',
          isBranchPoint: true,
          variantLogic: {
            'Celiac': 'Season: Add Tamari (GF).',
            'Renal': 'Season: Skip Soy (High Sodium). Use Lemon.',
            'Soy Allergy': 'Season: Coconut Aminos.',
            'Paleo': 'Season: Coconut Aminos.',
          },
        ),
        // Step 4: Topping (Variants: Nut Allergy, Keto, Renal)
        RecipeStep(
          instruction: 'Topping: Add Walnuts and Avocado.',
          isBranchPoint: true,
          variantLogic: {
            'Nut Allergy': 'Topping: Add Sunflower Seeds (No Nuts).',
            'Renal': 'Topping: Skip Avocado & Nuts (Potassium/Phos).',
            'Keto': 'Topping: Double Walnuts and Avocado.',
            'Low FODMAP': 'Topping: Walnuts ok, Limit Avocada.',
          },
        ),
      ], 
      tags: ['Master'],
      dietTags: [],
    );
  });

  test('Should resolve optimal path for every member of the Impossible Family', () {
    final resolvedSteps = resolver.resolve(complexRecipe, impossibleFamily);

    // DEBUG: Print results
    print('\n--- Resolved Steps for Impossible Family ---');
    for (var s in resolvedSteps) {
      print('Step ${s.index}: [${s.targetMembers.join(", ")}] -> ${s.instruction}');
    }
    print('--------------------------------------------\n');

    // --- ASSERTIONS ---

    // 1. Carbohydrate Base
    // Dad (Keto) -> Cauliflower
    expect(resolvedSteps.any((s) => s.instruction.contains('Cauliflower') && s.targetMembers.contains('Dad (Keto)')), isTrue, reason: 'Dad needs Keto Cauliflower');
    // Kid1 (Celiac) -> Quinoa
    expect(resolvedSteps.any((s) => s.instruction.contains('Quinoa') && s.targetMembers.contains('Kid1 (Celiac)')), isTrue, reason: 'Kid1 needs GF Quinoa');
    // Kid2 (Renal) -> White Rice
    expect(resolvedSteps.any((s) => s.instruction.contains('White Rice') && s.targetMembers.contains('Kid2 (Renal)')), isTrue, reason: 'Kid2 needs White Rice');
    // Mom (Vegan) -> Brown Rice (Base) - because Vegan wasn't overriden or Base is Vegan friendly
    // Note: In our mock, 'Vegan' variant was explicit 'Base: Cook Brown Rice' or just falls back.
    // Let's check fallback/explicit behavior.
    
    // 2. Protein
    // Mom (Vegan) -> Tofu
    expect(resolvedSteps.any((s) => s.instruction.contains('Tofu') && s.targetMembers.contains('Mom (Vegan+Nut)')), isTrue, reason: 'Mom needs Tofu');
    // Dad/Kids -> Chicken (or specific Renal variant for Kid2)
    expect(resolvedSteps.any((s) => s.instruction.contains('Chicken') && s.targetMembers.contains('Dad (Keto)')), isTrue, reason: 'Dad gets Chicken');
    expect(resolvedSteps.any((s) => s.instruction.contains('Limit portion') && s.targetMembers.contains('Kid2 (Renal)')), isTrue, reason: 'Kid2 gets Renal Chicken');

    // 3. Seasoning
    // Kid1 (Celiac) -> Tamari
    expect(resolvedSteps.any((s) => s.instruction.contains('Tamari') && s.targetMembers.contains('Kid1 (Celiac)')), isTrue, reason: 'Kid1 gets Tamari');
    // Kid2 (Renal) -> Skip Soy
    expect(resolvedSteps.any((s) => s.instruction.contains('Skip Soy') && s.targetMembers.contains('Kid2 (Renal)')), isTrue, reason: 'Kid2 skips soy');
    // Base/Dad/Mom -> Soy Sauce?
    // Wait, Dad is Keto. Does Keto have variant logic? No. So Dad gets 'Soy Sauce'.
    // Mom is Vegan. 'Soy Sauce' is vegan. So Mom gets 'Soy Sauce'.
    expect(resolvedSteps.any((s) => s.instruction.contains('Soy Sauce') && s.targetMembers.contains('Dad (Keto)')), isTrue);

    // 4. Toppings (Conflict High Risk)
    // Mom (Nut Allergy) -> Seeds
    expect(resolvedSteps.any((s) => s.instruction.contains('Sunflower Seeds') && s.targetMembers.contains('Mom (Vegan+Nut)')), isTrue, reason: 'Mom must NOT have nuts');
    // Dad (Keto) -> Double Walnuts
    expect(resolvedSteps.any((s) => s.instruction.contains('Double Walnuts') && s.targetMembers.contains('Dad (Keto)')), isTrue, reason: 'Dad gets extra fat');
    // Kid2 (Renal) -> Skip All
    expect(resolvedSteps.any((s) => s.instruction.contains('Skip Avocado') && s.targetMembers.contains('Kid2 (Renal)')), isTrue, reason: 'Kid2 skips toppings');

    // Verify Disjoint Sets (No one left behind)
    // Each step index (1, 2, 3...) should cover all 4 family members across its resolved sub-steps.
    // Not strictly enforced by this specific test logic but good to know.
  });
}
