import 'package:gastronomic_os/features/planner/data/models/meal_plan_model.dart';
import 'package:gastronomic_os/features/planner/domain/entities/meal_plan.dart';
import 'package:gastronomic_os/features/planner/domain/repositories/i_meal_plan_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealPlanRepositoryImpl implements IMealPlanRepository {
  final SupabaseClient supabaseClient;

  MealPlanRepositoryImpl(this.supabaseClient);

  @override
  Future<List<MealPlan>> getMealPlans(DateTime start, DateTime end) async {
    final response = await supabaseClient
        .from('meal_plans')
        .select('*, recipes(*)') // Join with recipes
        .gte('scheduled_date', start.toIso8601String())
        .lte('scheduled_date', end.toIso8601String())
        .order('scheduled_date', ascending: true);

    return (response as List)
        .map((json) => MealPlanModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> addMealPlan(MealPlan plan) async {
    final model = plan is MealPlanModel 
        ? plan 
        : MealPlanModel(
            id: plan.id, // Usually ignored on insert if default, but we pass ID
            userId: plan.userId,
            recipeId: plan.recipeId,
            scheduledDate: plan.scheduledDate,
            mealType: plan.mealType,
            createdAt: plan.createdAt,
          );
          
    await supabaseClient.from('meal_plans').insert(model.toJson());
  }

  @override
  Future<void> updateMealPlan(MealPlan plan) async {
    final model = plan is MealPlanModel 
        ? plan 
        : MealPlanModel(
             id: plan.id,
            userId: plan.userId,
            recipeId: plan.recipeId,
            scheduledDate: plan.scheduledDate,
            mealType: plan.mealType,
            createdAt: plan.createdAt
        );

    await supabaseClient
        .from('meal_plans')
        .update(model.toJson())
        .eq('id', plan.id);
  }

  @override
  Future<void> deleteMealPlan(String id) async {
    await supabaseClient.from('meal_plans').delete().eq('id', id);
  }
}
