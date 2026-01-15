import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/usecases/usecase.dart';
import 'package:gastronomic_os/features/social/domain/entities/recipe_review.dart';
import 'package:gastronomic_os/features/social/domain/repositories/social_repository.dart';

class GetReviews implements Usecase<List<RecipeReview>, String> {
  final ISocialRepository repository;

  GetReviews(this.repository);

  @override
  Future<(Failure?, List<RecipeReview>?)> call(String recipeId) async {
    return await repository.getReviewsForRecipe(recipeId);
  }
}
