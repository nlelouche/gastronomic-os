// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_snapshot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeSnapshotModel _$RecipeSnapshotModelFromJson(Map<String, dynamic> json) =>
    RecipeSnapshotModel(
      commitId: json['commit_id'] as String,
      recipeId: json['recipe_id'] as String,
      fullStructure: json['full_structure'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RecipeSnapshotModelToJson(
        RecipeSnapshotModel instance) =>
    <String, dynamic>{
      'commit_id': instance.commitId,
      'recipe_id': instance.recipeId,
      'full_structure': instance.fullStructure,
      'created_at': instance.createdAt.toIso8601String(),
    };
