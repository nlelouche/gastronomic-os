import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';

class MealPlan extends Equatable {
  final String id;
  final String userId;
  final String recipeId;
  final DateTime scheduledDate;
  final String mealType; // 'Lunch', 'Dinner', etc.
  final DateTime createdAt;
  
  // Optional: Eager loaded recipe details for UI display
  final Recipe? recipe;

  const MealPlan({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.scheduledDate,
    this.mealType = 'Dinner',
    required this.createdAt,
    this.recipe,
  });

  MealPlan copyWith({
    String? mealType,
    DateTime? scheduledDate,
    Recipe? recipe,
  }) {
    return MealPlan(
      id: id,
      userId: userId,
      recipeId: recipeId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      mealType: mealType ?? this.mealType,
      createdAt: createdAt,
      recipe: recipe ?? this.recipe,
    );
  }

  @override
  List<Object?> get props => [id, userId, recipeId, scheduledDate, mealType, createdAt, recipe];
}
