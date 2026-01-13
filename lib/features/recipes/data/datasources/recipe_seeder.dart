import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gastronomic_os/core/util/app_logger.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_model.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_step_model.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/planner/domain/logic/diet_engine.dart';
import 'package:uuid/uuid.dart';

class RecipeSeeder {
  static const _uuid = Uuid();

  /// Load all recipes from JSON files in assets
  static Future<List<RecipeModel>> loadFromAssets({String? filterTitle}) async {
    final List<RecipeModel> allRecipes = [];

    // Load each JSON file
    final files = [
      'Documentation/test_recipes/json/recipes_01_05.json',
      'Documentation/test_recipes/json/recipes_06_10.json',
      'Documentation/test_recipes/json/recipes_11_15.json',
      'Documentation/test_recipes/json/recipes_16_30.json',
      'Documentation/test_recipes/json/recipes_31_45.json',
      'Documentation/test_recipes/json/recetas_procesadas_batch_1.json',
    ];

    for (final file in files) {
      try {
        final jsonString = await rootBundle.loadString(file);
        final List<dynamic> jsonList = json.decode(jsonString);
        
        for (final recipeJson in jsonList) {
          final recipe = _parseRecipe(recipeJson);
          
          // Debug filtering
          if (filterTitle != null && !recipe.title.toLowerCase().contains(filterTitle.toLowerCase())) {
            continue;
          }
          
          allRecipes.add(recipe);
        }
      } catch (e, stack) {
        AppLogger.e('Error loading $file', e, stack);
      }
    }

    return allRecipes;
  }

  static RecipeModel _parseRecipe(Map<String, dynamic> json) {
    // Parse steps with branching logic
    final List<RecipeStep> steps = [];
    final stepsJson = json['steps'] as List<dynamic>?;

    if (stepsJson != null) {
      for (final stepData in stepsJson) {
        if (stepData is Map<String, dynamic>) {
          final skippedDiets = (stepData['skipped_for_diets'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList();
          
          AppLogger.d('📦 Seeder parsing step: "${stepData['instruction']}" - skipped_for_diets from JSON: $skippedDiets');
          
          final createdStep = RecipeStepModel(
            instruction: stepData['instruction'] as String,
            isBranchPoint: stepData['is_branch_point'] as bool? ?? false,
            variantLogic: (stepData['variant_logic'] as Map<String, dynamic>?)
                ?.map((key, value) => MapEntry(key, value.toString())),
            crossContaminationAlert: stepData['cross_contamination_alert'] as String?,
            skippedForDiets: skippedDiets,
          );
          
          AppLogger.d('   ✅ Created model - skippedForDiets field value: ${createdStep.skippedForDiets}');
          
          steps.add(createdStep);
        }
      }
    }

    // Calculate Dynamic Diet Tags
    // Convert to Entity temporarily for the Engine
    final recipeEntity = Recipe(
      id: json['id'] as String? ?? _uuid.v4(),
      authorId: 'system',
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.now(),
      ingredients: (json['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dietTags: [], // Empty for now
      steps: steps,
    );
    
    final dietEngine = DietEngine();
    final compatibleDiets = dietEngine.calculateCompatibleDiets(recipeEntity);
    
    AppLogger.d('   ✅ Computed Diet Tags: $compatibleDiets');

    return RecipeModel(
      id: recipeEntity.id,
      authorId: 'system',
      isFork: false,
      title: recipeEntity.title,
      description: recipeEntity.description,
      isPublic: true,
      createdAt: DateTime.now(),
      tags: recipeEntity.tags,
      dietTags: compatibleDiets,
      ingredients: recipeEntity.ingredients,
      steps: steps,
    );
  }
}
