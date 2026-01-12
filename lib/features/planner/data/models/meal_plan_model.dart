import 'package:gastronomic_os/features/planner/domain/entities/meal_plan.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_model.dart'; // Ensure this exists

class MealPlanModel extends MealPlan {
  const MealPlanModel({
    required super.id,
    required super.userId,
    required super.recipeId,
    required super.scheduledDate,
    required super.mealType,
    required super.createdAt,
    super.recipe,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      recipeId: json['recipe_id'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      mealType: json['meal_type'] as String? ?? 'Dinner',
      createdAt: DateTime.parse(json['created_at'] as String),
      recipe: json['recipes'] != null ? RecipeModel.fromJson(json['recipes'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'meal_type': mealType,
      'created_at': createdAt.toIso8601String(),
      // 'recipes': recipe?.toJson(), // Read-only typically
    };
  }
}
