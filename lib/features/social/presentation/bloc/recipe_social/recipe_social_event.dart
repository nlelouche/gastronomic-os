import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class RecipeSocialEvent extends Equatable {
  const RecipeSocialEvent();

  @override
  List<Object> get props => [];
}

class LoadRecipeSocialData extends RecipeSocialEvent {
  final String recipeId;
  const LoadRecipeSocialData(this.recipeId);
  
  @override
  List<Object> get props => [recipeId];
}

class SubmitReview extends RecipeSocialEvent {
  final String recipeId;
  final int rating;
  final String comment;
  
  const SubmitReview({required this.recipeId, required this.rating, required this.comment});

  @override
  List<Object> get props => [recipeId, rating, comment];
}

class SubmitCookProof extends RecipeSocialEvent {
  final String recipeId;
  final File photo;
  final String caption;
  
  const SubmitCookProof({required this.recipeId, required this.photo, required this.caption});

  @override
  List<Object> get props => [recipeId, photo, caption];
}
