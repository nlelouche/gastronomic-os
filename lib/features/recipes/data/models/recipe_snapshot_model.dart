import 'package:json_annotation/json_annotation.dart';

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
  List<String> get steps => List<String>.from(fullStructure['steps'] ?? []);
}
