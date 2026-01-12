import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/planner/domain/entities/meal_plan.dart';

abstract class PlannerEvent extends Equatable {
  const PlannerEvent();
  @override
  List<Object> get props => [];
}

class LoadPlannerSuggestions extends PlannerEvent {}

class LoadScheduledMeals extends PlannerEvent {
  final DateTime start;
  final DateTime end;
  const LoadScheduledMeals(this.start, this.end);
  @override
  List<Object> get props => [start, end];
}

class AddMealToPlan extends PlannerEvent {
  final MealPlan plan;
  const AddMealToPlan(this.plan);
  @override
  List<Object> get props => [plan];
}

class UpdateMealPlan extends PlannerEvent {
  final MealPlan plan;
  const UpdateMealPlan(this.plan);
  @override
  List<Object> get props => [plan];
}

class DeleteMealPlan extends PlannerEvent {
  final String id;
  const DeleteMealPlan(this.id);
  @override
  List<Object> get props => [id];
}

class GenerateShoppingList extends PlannerEvent {}
