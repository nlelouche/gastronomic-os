import 'package:equatable/equatable.dart';
import 'recipe_step.dart';

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
  final List<RecipeStep> steps;
  final List<String> tags; // e.g. ['Vegan', 'Keto', 'Gluten-Free']

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
    this.tags = const [],
  });

  @override
  List<Object?> get props => [id, authorId, originId, isFork, title, description, isPublic, createdAt, ingredients, steps, tags];
}
