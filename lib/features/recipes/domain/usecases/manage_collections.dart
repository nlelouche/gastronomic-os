import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_collection.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';

class CreateCollection {
  final IRecipeRepository repository;

  CreateCollection(this.repository);

  Future<(Failure?, RecipeCollection?)> call(String name) {
    return repository.createCollection(name);
  }
}

class GetUserCollections {
  final IRecipeRepository repository;

  GetUserCollections(this.repository);

  Future<(Failure?, List<RecipeCollection>?)> call() {
    return repository.getUserCollections();
  }
}

class AddToCollection {
  final IRecipeRepository repository;

  AddToCollection(this.repository);

  Future<(Failure?, void)> call(String recipeId, String collectionId) {
    return repository.addToCollection(recipeId, collectionId);
  }
}

class RemoveFromCollection {
  final IRecipeRepository repository;

  RemoveFromCollection(this.repository);

  Future<(Failure?, void)> call(String recipeId, String collectionId) {
    return repository.removeFromCollection(recipeId, collectionId);
  }
}

class DeleteCollection {
  final IRecipeRepository repository;

  DeleteCollection(this.repository);

  Future<(Failure?, void)> call(String collectionId) {
    return repository.deleteCollection(collectionId);
  }
}
