import 'dart:io';
import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/usecases/usecase.dart';
import 'package:gastronomic_os/features/social/domain/repositories/social_repository.dart';

class AddCookProof implements Usecase<void, AddCookProofParams> {
  final ISocialRepository repository;

  AddCookProof(this.repository);

  @override
  Future<(Failure?, void)> call(AddCookProofParams params) async {
    return await repository.addCookProof(params.recipeId, params.photo, params.caption);
  }
}

class AddCookProofParams {
  final String recipeId;
  final File photo;
  final String caption;

  const AddCookProofParams({required this.recipeId, required this.photo, required this.caption});
}
