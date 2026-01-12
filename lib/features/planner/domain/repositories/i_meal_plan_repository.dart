import 'package:gastronomic_os/features/planner/domain/entities/meal_plan.dart';

abstract class IMealPlanRepository {
  /// Fetches meal plans for a given date range.
  Future<List<MealPlan>> getMealPlans(DateTime start, DateTime end);

  /// Adds a new meal plan.
  Future<void> addMealPlan(MealPlan plan);

  /// Updates an existing meal plan.
  Future<void> updateMealPlan(MealPlan plan);

  /// Deletes a meal plan by ID.
  Future<void> deleteMealPlan(String id);
}
