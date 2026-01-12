import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';

abstract class RecipeState extends Equatable {
  const RecipeState();
  
  @override
  List<Object> get props => [];
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final List<Recipe> recipes;
  final List<Recipe> allRecipes;
  
  // Filter State
  final bool isFamilySafe;
  final bool isPantryReady;
  final String query;
  final List<String> requiredIngredients;

  const RecipeLoaded({
    required this.recipes,
    required this.allRecipes,
    this.isFamilySafe = false,
    this.isPantryReady = false,
    this.query = '',
    this.requiredIngredients = const [],
  });
  
  RecipeLoaded copyWith({
    List<Recipe>? recipes,
    List<Recipe>? allRecipes,
    bool? isFamilySafe,
    bool? isPantryReady,
    String? query,
    List<String>? requiredIngredients,
  }) {
    return RecipeLoaded(
      recipes: recipes ?? this.recipes,
      allRecipes: allRecipes ?? this.allRecipes,
      isFamilySafe: isFamilySafe ?? this.isFamilySafe,
      isPantryReady: isPantryReady ?? this.isPantryReady,
      query: query ?? this.query,
      requiredIngredients: requiredIngredients ?? this.requiredIngredients,
    );
  }

  @override
  List<Object> get props => [recipes, allRecipes, isFamilySafe, isPantryReady, query, requiredIngredients];
}

class RecipeError extends RecipeState {
  final String message;

  const RecipeError(this.message);

  @override
  List<Object> get props => [message];
}

class RecipeDetailLoaded extends RecipeState {
  final Recipe recipe;

  const RecipeDetailLoaded(this.recipe);

  @override
  List<Object> get props => [recipe];
}
