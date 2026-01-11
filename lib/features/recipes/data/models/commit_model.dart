import 'package:gastronomic_os/features/recipes/domain/entities/commit.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commit_model.g.dart';

@JsonSerializable()
class CommitModel extends Commit {
  @override
  @JsonKey(name: 'recipe_id')
  final String recipeId;
  @override
  @JsonKey(name: 'parent_commit_id')
  final String? parentCommitId;
  @override
  @JsonKey(name: 'author_id')
  final String authorId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const CommitModel({
    required String id,
    required this.recipeId,
    this.parentCommitId,
    required this.authorId,
    required String message,
    required Map<String, dynamic> diff,
    required this.createdAt,
  }) : super(
          id: id,
          recipeId: recipeId,
          parentCommitId: parentCommitId,
          authorId: authorId,
          message: message,
          diff: diff,
          createdAt: createdAt,
        );

  factory CommitModel.fromJson(Map<String, dynamic> json) => _$CommitModelFromJson(json);
  Map<String, dynamic> toJson() => _$CommitModelToJson(this);
}
