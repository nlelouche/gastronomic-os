import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';

class UpdateRecipe {
  final IRecipeRepository repository;

  UpdateRecipe(this.repository);

  Future<(Failure?, Recipe?)> call(Recipe recipe) async {
    return await repository.updateRecipe(recipe);
  }
}
