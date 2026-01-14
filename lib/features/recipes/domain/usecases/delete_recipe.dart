import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';

class DeleteRecipe {
  final IRecipeRepository repository;

  DeleteRecipe(this.repository);

  Future<(Failure?, void)> call(String id) async {
    return await repository.deleteRecipe(id);
  }
}
