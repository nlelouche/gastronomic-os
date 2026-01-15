import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/usecases/usecase.dart';
import 'package:gastronomic_os/features/social/domain/entities/cook_proof.dart';
import 'package:gastronomic_os/features/social/domain/repositories/social_repository.dart';

class GetCookProofs implements Usecase<List<CookProof>, String> {
  final ISocialRepository repository;

  GetCookProofs(this.repository);

  @override
  Future<(Failure?, List<CookProof>?)> call(String recipeId) async {
    return await repository.getCookProofsForRecipe(recipeId);
  }
}
