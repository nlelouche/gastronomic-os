import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/social/domain/entities/cook_proof.dart';
import 'package:gastronomic_os/features/social/domain/entities/recipe_review.dart';

enum RecipeSocialStatus { initial, loading, loaded, error, submitting, successReview, successProof }

class RecipeSocialState extends Equatable {
  final RecipeSocialStatus status;
  final List<RecipeReview> reviews;
  final List<CookProof> proofs;
  final String? errorMessage;

  const RecipeSocialState({
    this.status = RecipeSocialStatus.initial,
    this.reviews = const [],
    this.proofs = const [],
    this.errorMessage,
  });

  RecipeSocialState copyWith({
    RecipeSocialStatus? status,
    List<RecipeReview>? reviews,
    List<CookProof>? proofs,
    String? errorMessage,
  }) {
    return RecipeSocialState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      proofs: proofs ?? this.proofs,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reviews, proofs, errorMessage];
}
