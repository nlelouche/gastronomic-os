// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_collection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeCollectionModel _$RecipeCollectionModelFromJson(
        Map<String, dynamic> json) =>
    RecipeCollectionModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      recipeCount: (json['recipeCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RecipeCollectionModelToJson(
        RecipeCollectionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'name': instance.name,
      'created_at': instance.createdAt.toIso8601String(),
    };
