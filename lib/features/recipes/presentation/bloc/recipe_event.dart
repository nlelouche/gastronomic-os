import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';

abstract class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object> get props => [];
}

class LoadRecipes extends RecipeEvent {}

class CreateRecipe extends RecipeEvent {
  final Recipe recipe;

  const CreateRecipe(this.recipe);

  @override
  List<Object> get props => [recipe];
}

class ForkRecipe extends RecipeEvent {
  final String originalRecipeId;
  final String newTitle;

  const ForkRecipe({required this.originalRecipeId, required this.newTitle});

  @override
  List<Object> get props => [originalRecipeId, newTitle];
}


class LoadRecipeDetails extends RecipeEvent {
  final String recipeId;

  const LoadRecipeDetails(this.recipeId);

  @override
  List<Object> get props => [recipeId];
}

class SeedDatabase extends RecipeEvent {
  final String? filterTitle;
  const SeedDatabase({this.filterTitle});
  
  @override
  List<Object> get props => [if (filterTitle != null) filterTitle!];
}

