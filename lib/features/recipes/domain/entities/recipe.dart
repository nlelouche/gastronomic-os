import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String authorId;
  final String? originId;
  final bool isFork;
  final String title;
  final String? description;
  final bool isPublic;
  final DateTime createdAt;
  final List<String> ingredients;
  final List<String> steps;

  const Recipe({
    required this.id,
    required this.authorId,
    this.originId,
    this.isFork = false,
    required this.title,
    this.description,
    this.isPublic = true,
    required this.createdAt,
    this.ingredients = const [],
    this.steps = const [],
  });

  @override
  List<Object?> get props => [id, authorId, originId, isFork, title, description, isPublic, createdAt, ingredients, steps];
}
