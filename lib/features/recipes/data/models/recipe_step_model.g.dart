// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_step_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeStepModel _$RecipeStepModelFromJson(Map<String, dynamic> json) =>
    RecipeStepModel(
      instruction: json['instruction'] as String,
      isBranchPoint: json['is_branch_point'] as bool? ?? false,
      variantLogic: (json['variant_logic'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      crossContaminationAlert: json['cross_contamination_alert'] as String?,
      skippedForDiets: (json['skipped_for_diets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$RecipeStepModelToJson(RecipeStepModel instance) =>
    <String, dynamic>{
      'instruction': instance.instruction,
      'is_branch_point': instance.isBranchPoint,
      'variant_logic': instance.variantLogic,
      'cross_contamination_alert': instance.crossContaminationAlert,
      'skipped_for_diets': instance.skippedForDiets,
    };
