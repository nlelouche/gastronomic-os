import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/planner/domain/usecases/get_meal_suggestions.dart';
import 'package:gastronomic_os/features/planner/domain/entities/shopping_item.dart';
import 'package:gastronomic_os/features/planner/domain/entities/meal_plan.dart';

abstract class PlannerState extends Equatable {
  const PlannerState();
  @override
  List<Object?> get props => [];
}

class PlannerInitial extends PlannerState {}


class PlannerLoading extends PlannerState {}

class PlannerLoaded extends PlannerState {
  final List<RecipeSuggestion> suggestions;
  final List<MealPlan> scheduledMeals;
  final List<ShoppingItem> shoppingList;

  const PlannerLoaded({
    this.suggestions = const [],
    this.scheduledMeals = const [],
    this.shoppingList = const [],
  });

  PlannerLoaded copyWith({
    List<RecipeSuggestion>? suggestions,
    List<MealPlan>? scheduledMeals,
    List<ShoppingItem>? shoppingList,
  }) {
    return PlannerLoaded(
      suggestions: suggestions ?? this.suggestions,
      scheduledMeals: scheduledMeals ?? this.scheduledMeals,
      shoppingList: shoppingList ?? this.shoppingList,
    );
  }

  @override
  List<Object?> get props => [suggestions, scheduledMeals, shoppingList];
}

class PlannerError extends PlannerState {
  final String message;
  const PlannerError(this.message);
  @override
  List<Object?> get props => [message];
}
