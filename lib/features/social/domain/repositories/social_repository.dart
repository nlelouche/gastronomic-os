import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/social/domain/entities/recipe_review.dart';
import 'package:gastronomic_os/features/social/domain/entities/cook_proof.dart';
import 'dart:io';

abstract class ISocialRepository {
  Future<(Failure?, void)> addReview(String recipeId, int rating, String comment);
  Future<(Failure?, List<RecipeReview>?)> getReviewsForRecipe(String recipeId);
  Future<(Failure?, void)> addCookProof(String recipeId, File photo, String caption); // File from dart:io
  Future<(Failure?, List<CookProof>?)> getCookProofsForRecipe(String recipeId);
}
