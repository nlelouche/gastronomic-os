// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommitModel _$CommitModelFromJson(Map<String, dynamic> json) => CommitModel(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      parentCommitId: json['parent_commit_id'] as String?,
      authorId: json['author_id'] as String,
      message: json['message'] as String,
      diff: json['diff'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CommitModelToJson(CommitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'diff': instance.diff,
      'recipe_id': instance.recipeId,
      'parent_commit_id': instance.parentCommitId,
      'author_id': instance.authorId,
      'created_at': instance.createdAt.toIso8601String(),
    };
