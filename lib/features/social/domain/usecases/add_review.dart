import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/usecases/usecase.dart';
import 'package:gastronomic_os/features/social/domain/repositories/social_repository.dart';

class AddReview implements Usecase<void, AddReviewParams> {
  final ISocialRepository repository;

  AddReview(this.repository);

  @override
  Future<(Failure?, void)> call(AddReviewParams params) async {
    return await repository.addReview(params.recipeId, params.rating, params.comment);
  }
}

class AddReviewParams {
  final String recipeId;
  final int rating;
  final String comment;

  const AddReviewParams({required this.recipeId, required this.rating, required this.comment});
}
