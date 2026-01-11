import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe_model.g.dart';

@JsonSerializable()
class RecipeModel extends Recipe {
  @override
  @JsonKey(name: 'author_id')
  final String authorId;
  @override
  @JsonKey(name: 'origin_id')
  final String? originId;
  @override
  @JsonKey(name: 'is_fork')
  final bool isFork;
  @override
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  final List<String> ingredients;
  @override
  final List<String> steps;

  const RecipeModel({
    required String id,
    required this.authorId,
    this.originId,
    required this.isFork,
    required String title,
    String? description,
    required this.isPublic,
    required this.createdAt,
    this.ingredients = const [],
    this.steps = const [],
  }) : super(
          id: id,
          authorId: authorId,
          originId: originId,
          isFork: isFork,
          title: title,
          description: description,
          isPublic: isPublic,
          createdAt: createdAt,
          ingredients: ingredients,
          steps: steps,
        );

  factory RecipeModel.fromJson(Map<String, dynamic> json) => _$RecipeModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeModelToJson(this);
}
