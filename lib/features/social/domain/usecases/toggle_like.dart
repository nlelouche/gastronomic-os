import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/usecases/usecase.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';

class ToggleLike implements Usecase<void, String> {
  final IRecipeRepository repository;

  ToggleLike(this.repository);

  @override
  Future<(Failure?, void)> call(String recipeId) async {
    return await repository.toggleLike(recipeId);
  }
}
