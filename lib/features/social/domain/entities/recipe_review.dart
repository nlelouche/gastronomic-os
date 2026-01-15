import 'package:equatable/equatable.dart';

class RecipeReview extends Equatable {
  final String id;
  final String recipeId;
  final String userId;
  final String userName; // To display without fetching profile again
  final String? userAvatar; // To display without fetching profile again
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const RecipeReview({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, recipeId, userId, rating, comment, createdAt];
}
