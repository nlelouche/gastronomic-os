import 'package:equatable/equatable.dart';

class Commit extends Equatable {
  final String id;
  final String recipeId;
  final String? parentCommitId;
  final String authorId;
  final String message;
  final Map<String, dynamic> diff; // The core Git-for-Food delta
  final DateTime createdAt;

  const Commit({
    required this.id,
    required this.recipeId,
    this.parentCommitId,
    required this.authorId,
    required this.message,
    required this.diff,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, recipeId, parentCommitId, authorId, message, diff, createdAt];
}
