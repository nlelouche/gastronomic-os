import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/planner/domain/usecases/get_meal_suggestions.dart';
import 'planner_event.dart';
import 'planner_state.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final GetMealSuggestions getMealSuggestions;

  PlannerBloc({required this.getMealSuggestions}) : super(PlannerInitial()) {
    on<LoadPlannerSuggestions>(_onLoadSuggestions);
  }

  Future<void> _onLoadSuggestions(LoadPlannerSuggestions event, Emitter<PlannerState> emit) async {
    emit(PlannerLoading());
    
    final result = await getMealSuggestions();
    
    if (result.$1 != null) {
      emit(PlannerError(result.$1.toString())); // Simplified error mapping
    } else {
      final suggestions = result.$2 ?? [];
      if (suggestions.isEmpty) {
        emit(const PlannerError("No recipes match your criteria."));
      } else {
        emit(PlannerLoaded(suggestions));
      }
    }
  }
}
