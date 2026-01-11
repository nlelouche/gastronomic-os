import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/planner/domain/usecases/get_meal_suggestions.dart';

abstract class PlannerState extends Equatable {
  const PlannerState();
  @override
  List<Object?> get props => [];
}

class PlannerInitial extends PlannerState {}

class PlannerLoading extends PlannerState {}

class PlannerLoaded extends PlannerState {
  final List<RecipeSuggestion> suggestions;

  const PlannerLoaded(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

class PlannerError extends PlannerState {
  final String message;
  const PlannerError(this.message);
  @override
  List<Object?> get props => [message];
}
