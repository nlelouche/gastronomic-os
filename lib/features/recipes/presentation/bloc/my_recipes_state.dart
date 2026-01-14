import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';

abstract class MyRecipesState extends Equatable {
  const MyRecipesState();

  @override
  List<Object> get props => [];
}

class MyRecipesInitial extends MyRecipesState {}

class MyRecipesLoading extends MyRecipesState {}

class MyRecipesLoaded extends MyRecipesState {
  final List<Recipe> createdRecipes;
  final List<Recipe> forkedRecipes;
  final List<Recipe> savedRecipes;

  const MyRecipesLoaded({
    this.createdRecipes = const [],
    this.forkedRecipes = const [],
    this.savedRecipes = const [],
  });

  @override
  List<Object> get props => [createdRecipes, forkedRecipes, savedRecipes];

  MyRecipesLoaded copyWith({
    List<Recipe>? createdRecipes,
    List<Recipe>? forkedRecipes,
    List<Recipe>? savedRecipes,
  }) {
    return MyRecipesLoaded(
      createdRecipes: createdRecipes ?? this.createdRecipes,
      forkedRecipes: forkedRecipes ?? this.forkedRecipes,
      savedRecipes: savedRecipes ?? this.savedRecipes,
    );
  }
}

class MyRecipesError extends MyRecipesState {
  final String message;

  const MyRecipesError(this.message);

  @override
  List<Object> get props => [message];
}
