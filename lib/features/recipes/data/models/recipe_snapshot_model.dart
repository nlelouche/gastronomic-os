import 'dart:math';
import 'package:json_annotation/json_annotation.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_step_model.dart';

part 'recipe_snapshot_model.g.dart';

@JsonSerializable()
class RecipeSnapshotModel {
  @JsonKey(name: 'commit_id')
  final String commitId;

  @JsonKey(name: 'recipe_id')
  final String recipeId;

  @JsonKey(name: 'full_structure')
  final Map<String, dynamic> fullStructure;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  RecipeSnapshotModel({
    required this.commitId,
    required this.recipeId,
    required this.fullStructure,
    required this.createdAt,
  });

  factory RecipeSnapshotModel.fromJson(Map<String, dynamic> json) => _$RecipeSnapshotModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeSnapshotModelToJson(this);

  // Helpers to retrieve typed lists from the JSONB column
  List<String> get ingredients => List<String>.from(fullStructure['ingredients'] ?? []);
  
  List<RecipeStep> get steps {
    final stepsData = fullStructure['steps'] ?? [];
    if (stepsData is List) {
      return stepsData.map((e) {
        if (e is String) {
          // Backward compatibility for old string-based steps
          return RecipeStepModel(instruction: e);
        } else if (e is Map<String, dynamic>) {
          print('📥 Loading step from Supabase: $e');
          final step = RecipeStepModel.fromJson(e);
          print('   → Loaded as: instruction="${step.instruction.substring(0, min(30, step.instruction.length))}...", skippedForDiets=${step.skippedForDiets}');
          return step;
        }
        return RecipeStepModel(instruction: e.toString());
      }).toList();
    }
    return [];
  }
}
