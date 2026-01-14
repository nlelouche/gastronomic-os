// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeModel _$RecipeModelFromJson(Map<String, dynamic> json) => RecipeModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      originId: json['origin_id'] as String?,
      isFork: json['is_fork'] as bool? ?? false,
      title: json['title'] as String,
      description: json['description'] as String?,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      isPublic: json['is_public'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      steps: json['steps'] == null
          ? const []
          : const _RecipeStepListConverter().fromJson(json['steps'] as List),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      dietTags: (json['diet_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      titleEn: json['title_en'] as String?,
      descriptionEn: json['description_en'] as String?,
      ingredientsEn: (json['ingredients_en'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      stepsEn: _$JsonConverterFromJson<List<dynamic>, List<RecipeStep>>(
          json['steps_en'], const _RecipeStepListConverter().fromJson),
    );

Map<String, dynamic> _$RecipeModelToJson(RecipeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'author_id': instance.authorId,
      'cover_photo_url': instance.coverPhotoUrl,
      'origin_id': instance.originId,
      'is_fork': instance.isFork,
      'is_public': instance.isPublic,
      'created_at': instance.createdAt.toIso8601String(),
      'ingredients': instance.ingredients,
      'steps': const _RecipeStepListConverter().toJson(instance.steps),
      'tags': instance.tags,
      'diet_tags': instance.dietTags,
      'title_en': instance.titleEn,
      'description_en': instance.descriptionEn,
      'ingredients_en': instance.ingredientsEn,
      'steps_en': _$JsonConverterToJson<List<dynamic>, List<RecipeStep>>(
          instance.stepsEn, const _RecipeStepListConverter().toJson),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
