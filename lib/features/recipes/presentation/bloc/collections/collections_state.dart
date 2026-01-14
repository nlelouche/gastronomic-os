import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_collection.dart';

abstract class CollectionsState extends Equatable {
  const CollectionsState();
  
  @override
  List<Object> get props => [];
}

class CollectionsInitial extends CollectionsState {}

class CollectionsLoading extends CollectionsState {}

class CollectionsLoaded extends CollectionsState {
  final List<RecipeCollection> collections;

  const CollectionsLoaded(this.collections);

  @override
  List<Object> get props => [collections];
}

class CollectionsError extends CollectionsState {
  final String message;

  const CollectionsError(this.message);

  @override
  List<Object> get props => [message];
}

class CollectionActionSuccess extends CollectionsState {
  final String message;

  const CollectionActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}
