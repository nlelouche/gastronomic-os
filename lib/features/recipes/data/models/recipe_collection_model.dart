import 'package:gastronomic_os/features/recipes/domain/entities/recipe_collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe_collection_model.g.dart';

@JsonSerializable()
class RecipeCollectionModel extends RecipeCollection {
  const RecipeCollectionModel({
    required super.id,
    @JsonKey(name: 'owner_id') required super.ownerId,
    required super.name,
    @JsonKey(includeFromJson: true, includeToJson: false) super.recipeCount = 0,
    @JsonKey(name: 'created_at') required super.createdAt,
  });

  factory RecipeCollectionModel.fromJson(Map<String, dynamic> json) => 
      _$RecipeCollectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeCollectionModelToJson(this);

  factory RecipeCollectionModel.fromEntity(RecipeCollection entity) {
    return RecipeCollectionModel(
      id: entity.id,
      ownerId: entity.ownerId,
      name: entity.name,
      recipeCount: entity.recipeCount,
      createdAt: entity.createdAt,
    );
  }

  @override
  RecipeCollectionModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    int? recipeCount,
    DateTime? createdAt,
  }) {
    return RecipeCollectionModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      recipeCount: recipeCount ?? this.recipeCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
