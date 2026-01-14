import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';

abstract class RecipeState extends Equatable {
  const RecipeState();
  
  @override
  List<Object> get props => [];
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeDeleted extends RecipeState {}


class RecipeLoaded extends RecipeState {
  final List<Recipe> recipes;
  final bool hasReachedMax;

  // Filter State
  final bool isFamilySafe;
  final bool isPantryReady;
  final String query;
  final List<String> requiredIngredients;

  const RecipeLoaded({
    required this.recipes,
    this.hasReachedMax = false,
    this.isFamilySafe = false,
    this.isPantryReady = false,
    this.query = '',
    this.requiredIngredients = const [],
  });
  
  RecipeLoaded copyWith({
    List<Recipe>? recipes,
    bool? hasReachedMax,
    bool? isFamilySafe,
    bool? isPantryReady,
    String? query,
    List<String>? requiredIngredients,
  }) {
    return RecipeLoaded(
      recipes: recipes ?? this.recipes,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFamilySafe: isFamilySafe ?? this.isFamilySafe,
      isPantryReady: isPantryReady ?? this.isPantryReady,
      query: query ?? this.query,
      requiredIngredients: requiredIngredients ?? this.requiredIngredients,
    );
  }

  @override
  List<Object> get props => [recipes, hasReachedMax, isFamilySafe, isPantryReady, query, requiredIngredients];
}

class RecipeError extends RecipeState {
  final String message;

  const RecipeError(this.message);

  @override
  List<Object> get props => [message];
}

class RecipeForked extends RecipeState {
  final Recipe newRecipe;
  final Recipe originalRecipe;

  const RecipeForked({required this.newRecipe, required this.originalRecipe});

  @override
  List<Object> get props => [newRecipe, originalRecipe];
}

class RecipeDetailLoaded extends RecipeState {
  final Recipe recipe;
  final bool isSaved;

  const RecipeDetailLoaded(this.recipe, {this.isSaved = false});

  @override
  List<Object> get props => [recipe, isSaved];
}
