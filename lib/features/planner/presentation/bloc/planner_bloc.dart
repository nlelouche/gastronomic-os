import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/planner/domain/entities/meal_plan.dart';
import 'package:gastronomic_os/features/planner/domain/repositories/i_meal_plan_repository.dart';
import 'package:gastronomic_os/features/planner/domain/usecases/get_meal_suggestions.dart';
import 'planner_event.dart';
import 'planner_state.dart';

import 'package:gastronomic_os/features/planner/domain/logic/shopping_engine.dart';

// ...

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final GetMealSuggestions getMealSuggestions;
  final IMealPlanRepository mealPlanRepository;
  final ShoppingEngine shoppingEngine;

  PlannerBloc({
    required this.getMealSuggestions,
    required this.mealPlanRepository,
    required this.shoppingEngine,
  }) : super(PlannerInitial()) {
    on<LoadPlannerSuggestions>(_onLoadSuggestions);
    on<LoadScheduledMeals>(_onLoadScheduledMeals);
    on<AddMealToPlan>(_onAddMealToPlan);
    on<UpdateMealPlan>(_onUpdateMealPlan);
    on<DeleteMealPlan>(_onDeleteMealPlan);
    on<GenerateShoppingList>(_onGenerateShoppingList);
  }
  
  // ... existing handlers ...

  Future<void> _onGenerateShoppingList(GenerateShoppingList event, Emitter<PlannerState> emit) async {
    if (state is PlannerLoaded) {
      final current = (state as PlannerLoaded);
      try {
        // Use existing scheduled meals to generate list
        final list = shoppingEngine.generateList(current.scheduledMeals);
        emit(current.copyWith(shoppingList: list));
      } catch (e) {
        emit(PlannerError("Failed to generate list: $e"));
      }
    }
  }

  Future<void> _onLoadSuggestions(LoadPlannerSuggestions event, Emitter<PlannerState> emit) async {
    // Keep current state if loaded to preserve scheduledMeals, else emit loading
    final currentState = state;
    List<MealPlan> currentPlans = [];
    if (currentState is PlannerLoaded) {
      currentPlans = currentState.scheduledMeals;
    } else {
      emit(PlannerLoading());
    }
    
    final result = await getMealSuggestions();
    
    if (result.$1 != null) {
      emit(PlannerError(result.$1.toString()));
    } else {
      final suggestions = result.$2 ?? [];
      if (suggestions.isEmpty && currentPlans.isEmpty) {
         // Only Error if BOTH are empty? Or just show empty state?
         // Better to show empty list than Error state which blocks UI
         emit(PlannerLoaded(suggestions: [], scheduledMeals: currentPlans));
      } else {
        emit(PlannerLoaded(suggestions: suggestions, scheduledMeals: currentPlans));
      }
    }
  }

  Future<void> _onLoadScheduledMeals(LoadScheduledMeals event, Emitter<PlannerState> emit) async {
    final currentState = state;
    List<RecipeSuggestion> currentSuggestions = [];
    if (currentState is PlannerLoaded) {
      currentSuggestions = currentState.suggestions;
    } else {
      emit(PlannerLoading());
    }

    try {
      final plans = await mealPlanRepository.getMealPlans(event.start, event.end);
      emit(PlannerLoaded(suggestions: currentSuggestions, scheduledMeals: plans));
    } catch (e) {
      emit(PlannerError("Failed to load schedule: $e"));
    }
  }

  Future<void> _onAddMealToPlan(AddMealToPlan event, Emitter<PlannerState> emit) async {
    try {
      await mealPlanRepository.addMealPlan(event.plan);
      // Reload schedule for the week of the added plan?
      // Or just assume user will trigger reload / stream?
      // For now, simple approach: Reload current week (Logic needs date range from state? State doesn't hold range)
      // We'll trust UI to refresh or optimistically update. 
      // Optimistic update:
      if (state is PlannerLoaded) {
        final current = (state as PlannerLoaded);
        final updated = List<MealPlan>.from(current.scheduledMeals)..add(event.plan);
        emit(current.copyWith(scheduledMeals: updated));
      }
    } catch (e) {
      emit(PlannerError("Failed to add meal: $e"));
    }
  }

  Future<void> _onUpdateMealPlan(UpdateMealPlan event, Emitter<PlannerState> emit) async {
    try {
      await mealPlanRepository.updateMealPlan(event.plan);
      if (state is PlannerLoaded) {
        final current = (state as PlannerLoaded);
        final updated = List<MealPlan>.from(current.scheduledMeals);
        final index = updated.indexWhere((p) => p.id == event.plan.id);
        if (index != -1) {
          updated[index] = event.plan;
          emit(current.copyWith(scheduledMeals: updated));
        }
      }
    } catch (e) {
      emit(PlannerError("Failed to update meal: $e"));
    }
  }

  Future<void> _onDeleteMealPlan(DeleteMealPlan event, Emitter<PlannerState> emit) async {
    try {
      await mealPlanRepository.deleteMealPlan(event.id);
      if (state is PlannerLoaded) {
        final current = (state as PlannerLoaded);
        final updated = List<MealPlan>.from(current.scheduledMeals)..removeWhere((p) => p.id == event.id);
        emit(current.copyWith(scheduledMeals: updated));
      }
    } catch (e) {
      emit(PlannerError("Failed to delete meal: $e"));
    }
  }
}
