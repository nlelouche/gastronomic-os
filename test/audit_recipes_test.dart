import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart'; // REQUIRED
import 'package:gastronomic_os/features/planner/domain/logic/diet_engine.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';

void main() {
  final dietEngine = DietEngine();
  
  Recipe parseRecipe(Map<String, dynamic> json) { /* ... same ... */ 
      // Need to include dietTags empty to avoid error
      return Recipe(
      id: json['id'] ?? 'unknown',
      authorId: 'system',
      title: json['title'] ?? 'Untitled',
      description: json['description'],
      createdAt: DateTime.now(),
      ingredients: (json['ingredients'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      tags: (json['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      steps: (json['steps'] as List<dynamic>? ?? []).map((s) {
        return RecipeStep(
            instruction: s['instruction'] ?? '',
            isBranchPoint: s['is_branch_point'] ?? false,
            variantLogic: s['variant_logic'] != null ? Map<String, String>.from(s['variant_logic']) : null,
        );
      }).toList(),
      dietTags: const [],
    );
  }

  test('Audit All Recipes for Clinical Safety Gaps', () async {
    final dir = Directory('d:/Gastronomic OS/Documentation/test_recipes/json'); 
    final files = dir.listSync().where((f) => f.path.endsWith('.json')).toList();
    
    final List<String> failures = [];
    int totalRecipes = 0;

    print('\n--- 🏥 STARTING CLINICAL DATA AUDIT ---');

    for (final file in files) {
      if (file is File) {
        final content = file.readAsStringSync();
        final List<dynamic> jsonList = jsonDecode(content);
        
        print('📂 Scanning ${file.path.split(Platform.pathSeparator).last} (${jsonList.length} recipes)...');
        
        for (final rJson in jsonList) {
          totalRecipes++;
          final recipe = parseRecipe(rJson);
          
          for (final condition in [
            MedicalCondition.aplv, 
            MedicalCondition.celiac, 
            MedicalCondition.renal,
            MedicalCondition.lowFodmap,
            MedicalCondition.histamine
          ]) {
             final member = FamilyMember(
               id: 'audit-user',
               name: 'AuditBot', 
               role: FamilyRole.dad, // Using enum instead of String
               primaryDiet: DietLifestyle.omnivore, 
               medicalConditions: [condition]
             );

             final isSafe = dietEngine.isRecipeCompatible(recipe, [member]);
             
             if (!isSafe) {
               failures.add('[${recipe.id}] ${recipe.title} -> FAILS ${condition.displayName}');
             }
          }
        }
      }
    }
    
    print('\n--- AUDIT RESULTS ---');
    if (failures.isEmpty) {
      print('✅ ALL $totalRecipes RECIPES ARE FULLY ADAPTED!');
    } else {
      print('❌ FOUND ${failures.length} COMPLIANCE FAILURES:');
      failures.forEach(print);
      // Fail the test to alert me
      fail('Clinical Audit Failed: ${failures.length} recipes unadapted.');
    }
  });
}
