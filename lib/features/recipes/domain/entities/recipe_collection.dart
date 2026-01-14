import 'package:equatable/equatable.dart';

class RecipeCollection extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final int recipeCount; // Useful for UI
  final DateTime createdAt;

  const RecipeCollection({
    required this.id,
    required this.ownerId,
    required this.name,
    this.recipeCount = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, ownerId, name, recipeCount, createdAt];

  RecipeCollection copyWith({
    String? id,
    String? ownerId,
    String? name,
    int? recipeCount,
    DateTime? createdAt,
  }) {
    return RecipeCollection(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      recipeCount: recipeCount ?? this.recipeCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
