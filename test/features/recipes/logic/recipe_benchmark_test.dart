import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/domain/logic/recipe_resolver.dart';

void main() {
  late RecipeResolver resolver;
  late Recipe heavyRecipe;
  late List<FamilyMember> hugeFamily;

  setUp(() {
    resolver = RecipeResolver();

    // 1. Create a "Huge Family" (10 members) to stress the loops
    hugeFamily = List.generate(10, (index) {
      return FamilyMember(
        id: 'user_$index',
        name: 'User $index',
        role: FamilyRole.dad, // Doesn't matter
        primaryDiet: index % 2 == 0 ? DietLifestyle.keto : DietLifestyle.vegan,
        medicalConditions: index % 3 == 0 ? [MedicalCondition.celiac] : [],
      );
    });

    // 2. Create a "Heavy Recipe" (20 steps, lots of branching)
    heavyRecipe = Recipe(
      id: 'benchmark_recipe',
      title: 'Benchmark Feast',
      authorId: 'system',
      isPublic: true,
      createdAt: DateTime.now(),
      ingredients: [],
      steps: List.generate(20, (index) {
        return RecipeStep(
          instruction: 'Step $index: Do something.',
          isBranchPoint: true,
          variantLogic: {
            'Keto': 'Step $index: Keto variant.',
            'Vegan': 'Step $index: Vegan variant.',
            'Celiac': 'Step $index: GF variant.',
            'Renal': 'Step $index: Low sodium variant.',
          },
        );
      }), 
      tags: ['Benchmark'],
      dietTags: [],
    );
  });

  test('Benchmark: Resolver should process 100 iterations in < 1000ms (Target < 10ms per op)', () {
    final stopwatch = Stopwatch()..start();
    
    const iterations = 100;
    
    for (int i = 0; i < iterations; i++) {
      final result = resolver.resolve(heavyRecipe, hugeFamily);
      // Basic sanity check (length will be > 20 due to splitting)
      expect(result.isNotEmpty, isTrue); 
    }
    
    stopwatch.stop();
    final totalMs = stopwatch.elapsedMilliseconds;
    final avgMs = totalMs / iterations;
    
    print('\n🚀 BENCHMARK RESULTS 🚀');
    print('Total Time (100 ops x 10 members x 20 steps): ${totalMs}ms');
    print('Average Time per Resolution: ${avgMs.toStringAsFixed(4)}ms');
    
    // Target: 16ms (60fps budget). We aim for < 5ms likely.
    expect(avgMs, lessThan(16.0), reason: 'Resolver is too slow! Must be < 16ms to avoid jank.');
  });
}
