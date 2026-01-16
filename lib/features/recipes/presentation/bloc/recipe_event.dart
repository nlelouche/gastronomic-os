import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';

abstract class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object> get props => [];
}

class LoadRecipes extends RecipeEvent {
  final String? collectionId;
  final String languageCode;
  const LoadRecipes({this.collectionId, required this.languageCode});

  @override
  List<Object> get props => [if (collectionId != null) collectionId!, languageCode];
}
class LoadMoreRecipes extends RecipeEvent {}

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

class DeleteRecipe extends RecipeEvent {
  final String recipeId;
  const DeleteRecipe(this.recipeId);
  @override
  List<Object> get props => [recipeId];
}



class UpdateRecipe extends RecipeEvent {
  final Recipe recipe;
  const UpdateRecipe(this.recipe);
  @override
  List<Object> get props => [recipe];
}

class LoadRecipeDetails extends RecipeEvent {
  final String recipeId;

  const LoadRecipeDetails(this.recipeId);

  @override
  List<Object> get props => [recipeId];
}

class ToggleSaveRecipe extends RecipeEvent {
  final String recipeId;
  const ToggleSaveRecipe(this.recipeId);
  @override
  List<Object> get props => [recipeId];
}

class SeedDatabase extends RecipeEvent {
  final String? filterTitle;
  const SeedDatabase({this.filterTitle});
  
  @override
  List<Object> get props => [if (filterTitle != null) filterTitle!];
}

class FilterRecipes extends RecipeEvent {
  final String query;
  final bool isFamilySafe;
  final bool isPantryReady;
  final List<String> requiredIngredients;

  const FilterRecipes({
    this.query = '',
    this.isFamilySafe = false,
    this.isPantryReady = false,
    this.requiredIngredients = const [],
  });

  @override
  List<Object> get props => [query, isFamilySafe, isPantryReady, requiredIngredients];
}

class ClearAllRecipes extends RecipeEvent {}

