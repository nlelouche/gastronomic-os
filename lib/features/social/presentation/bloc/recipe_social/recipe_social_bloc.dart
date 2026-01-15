import 'package:bloc/bloc.dart';
import 'package:gastronomic_os/features/social/domain/usecases/add_cook_proof.dart';
import 'package:gastronomic_os/features/social/domain/usecases/add_review.dart';
import 'package:gastronomic_os/features/social/domain/usecases/get_cook_proofs.dart';
import 'package:gastronomic_os/features/social/domain/usecases/get_reviews.dart';
import 'recipe_social_event.dart';
import 'recipe_social_state.dart';

class RecipeSocialBloc extends Bloc<RecipeSocialEvent, RecipeSocialState> {
  final GetReviews getReviews;
  final AddReview addReview;
  final GetCookProofs getCookProofs;
  final AddCookProof addCookProof;

  RecipeSocialBloc({
    required this.getReviews,
    required this.addReview,
    required this.getCookProofs,
    required this.addCookProof,
  }) : super(const RecipeSocialState()) {
    on<LoadRecipeSocialData>(_onLoadData);
    on<SubmitReview>(_onSubmitReview);
    on<SubmitCookProof>(_onSubmitCookProof);
  }

  Future<void> _onLoadData(LoadRecipeSocialData event, Emitter<RecipeSocialState> emit) async {
    emit(state.copyWith(status: RecipeSocialStatus.loading));
    
    // Parallel Fetching
    final reviewsFuture = getReviews(event.recipeId);
    final proofsFuture = getCookProofs(event.recipeId);

    final results = await Future.wait([reviewsFuture, proofsFuture]);
    
    final reviewsResult = results[0] as (dynamic, dynamic); // Helper to cast tuple? No, dynamic check.
    // Tuple destructuring from list is tricky in Dart without declaring types or casting.
    // Let's await individually to be safe with type inference or cast carefully.
    
    // Actually, let's just do sequential for simplicity or correct type casting
    // final (failureReviews, reviews) = await getReviews(event.recipeId); 
    // final (failureProofs, proofs) = await getCookProofs(event.recipeId);
    
    // Re-doing parallel properly:
    final reviews = await getReviews(event.recipeId);
    final proofs = await getCookProofs(event.recipeId);
    
    if (reviews.$1 != null) {
      emit(state.copyWith(status: RecipeSocialStatus.error, errorMessage: reviews.$1!.message));
      return;
    }
    
    if (proofs.$1 != null) {
      // Non-critical? Maybe just log and show empty. But sticking to error for now.
       emit(state.copyWith(status: RecipeSocialStatus.error, errorMessage: proofs.$1!.message));
       return;
    }

    emit(state.copyWith(
      status: RecipeSocialStatus.loaded,
      reviews: reviews.$2 ?? [],
      proofs: proofs.$2 ?? [],
    ));
  }

  Future<void> _onSubmitReview(SubmitReview event, Emitter<RecipeSocialState> emit) async {
    emit(state.copyWith(status: RecipeSocialStatus.submitting));
    
    final result = await addReview(AddReviewParams(
      recipeId: event.recipeId,
      rating: event.rating,
      comment: event.comment,
    ));

    if (result.$1 != null) {
      emit(state.copyWith(status: RecipeSocialStatus.error, errorMessage: result.$1!.message));
      // Revert to loaded?
    } else {
      emit(state.copyWith(status: RecipeSocialStatus.successReview));
      add(LoadRecipeSocialData(event.recipeId)); // Reload data
    }
  }

  Future<void> _onSubmitCookProof(SubmitCookProof event, Emitter<RecipeSocialState> emit) async {
    emit(state.copyWith(status: RecipeSocialStatus.submitting));

    final result = await addCookProof(AddCookProofParams(
      recipeId: event.recipeId,
      photo: event.photo,
      caption: event.caption,
    ));

    if (result.$1 != null) {
      emit(state.copyWith(status: RecipeSocialStatus.error, errorMessage: result.$1!.message));
    } else {
      emit(state.copyWith(status: RecipeSocialStatus.successProof));
      add(LoadRecipeSocialData(event.recipeId)); // Reload
    }
  }
}
