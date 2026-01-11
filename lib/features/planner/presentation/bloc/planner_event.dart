import 'package:equatable/equatable.dart';

abstract class PlannerEvent extends Equatable {
  const PlannerEvent();
  @override
  List<Object> get props => [];
}

class LoadPlannerSuggestions extends PlannerEvent {}
