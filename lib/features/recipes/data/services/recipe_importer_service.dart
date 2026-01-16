import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gastronomic_os/core/util/app_logger.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_model.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_step_model.dart'; // Added Import
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:uuid/uuid.dart';

class RecipeImporterService {
  final IRecipeRepository _repository;
  final Uuid _uuid;

  RecipeImporterService(this._repository) : _uuid = const Uuid();

  Future<(int created, int skipped)> importMasterRecipes() async {
    try {
      // 1. Discover all recipe localized files
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final recipeFiles = manifest.listAssets()
          .where((key) => key.startsWith('assets/data/recipes_') && key.endsWith('.json'))
          .toList();

      AppLogger.i('Found ${recipeFiles.length} recipe files to import: $recipeFiles');

      int totalCreated = 0;
      int totalSkipped = 0;

      // 2. Fetch existing recipes to check for duplicates
      final existingResult = await _repository.getRecipes(limit: 1000);
      final existingKeys = <String>{}; // Key = Title + LanguageCode
      
      if (existingResult.$2 != null) {
        for (final r in existingResult.$2!) {
           existingKeys.add('${r.title.trim().toLowerCase()}_${r.languageCode}');
        }
      }

      // 3. Process each file
      for (final filePath in recipeFiles) {
         // Extract Language Code: recipes_1_en.json -> en
         final regExp = RegExp(r'recipes_\d+_([a-z]{2})\.json$');
         final match = regExp.firstMatch(filePath);
         
         if (match == null) {
           AppLogger.w('⚠️ Skipping file with invalid name format: $filePath');
           continue; 
         }
         
         final languageCode = match.group(1)!; // Force non-null from group
         AppLogger.i('📂 Processing $filePath as Language: [$languageCode]');
         
         final jsonString = await rootBundle.loadString(filePath);
         final List<dynamic> jsonList = jsonDecode(jsonString);

         for (var item in jsonList) {
            try {
              final title = (item['title'] as String).trim();
              final uniqueKey = '${title.toLowerCase()}_${languageCode}';

              if (existingKeys.contains(uniqueKey)) {
                AppLogger.d('Skipping duplicate: $title ($languageCode)');
                totalSkipped++;
                continue;
              }

              // Assign ID
              final id = _uuid.v4();
              
              final recipe = RecipeModel(
                id: id,
                authorId: 'system_master_chef',
                title: title,
                description: item['description'],
                prepTime: item['prep_time'],
                isPublic: true,
                createdAt: DateTime.now(),
                ingredients: (item['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                steps: (item['steps'] as List<dynamic>?)?.map((s) => _mapStep(s)).toList() ?? [],
                tags: _inferTagsFromSteps(item['steps'] as List<dynamic>?)..add('System Master'),
                dietTags: [],
                languageCode: languageCode, // Set Language Code
              );

              // We use generic createMasterRecipe. 
              // Repository needs to support saving languageCode (it should if it just inserts the object).
              await _repository.createMasterRecipe(recipe);
              existingKeys.add(uniqueKey); // Add to local cache to prevent dupes within same batch
              totalCreated++;

            } catch (e) {
               AppLogger.e('Failed to parse recipe in $filePath: $e');
            }
         }
      }

      return (totalCreated, totalSkipped);
    } catch (e) {
      AppLogger.e('Critical failure in RecipeImporterService: $e');
      rethrow;
    }
  }

  // Helper to map dynamic step to RecipeStepModel
  RecipeStepModel _mapStep(dynamic json) {
     return RecipeStepModel.fromJson(json as Map<String, dynamic>);
  }

  List<String> _inferTagsFromSteps(List<dynamic>? steps) {
    if (steps == null) return [];
    final tags = <String>{};
    for (var step in steps) {
      final logic = step['variant_logic'] as Map<String, dynamic>?;
      if (logic != null) {
        tags.addAll(logic.keys);
      }
    }
    tags.remove('Standard');
    return tags.toList();
  }
}
