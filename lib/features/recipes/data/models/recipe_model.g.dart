// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeModel _$RecipeModelFromJson(Map<String, dynamic> json) => RecipeModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      originId: json['origin_id'] as String?,
      isFork: json['is_fork'] as bool,
      title: json['title'] as String,
      description: json['description'] as String?,
      isPublic: json['is_public'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RecipeModelToJson(RecipeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'author_id': instance.authorId,
      'origin_id': instance.originId,
      'is_fork': instance.isFork,
      'is_public': instance.isPublic,
      'created_at': instance.createdAt.toIso8601String(),
    };
