import 'package:gastronomic_os/features/social/domain/entities/recipe_review.dart';

class RecipeReviewModel extends RecipeReview {
  const RecipeReviewModel({
    required super.id,
    required super.recipeId,
    required super.userId,
    required super.userName,
    super.userAvatar,
    required super.rating,
    super.comment,
    required super.createdAt,
  });

  factory RecipeReviewModel.fromJson(Map<String, dynamic> json) {
    // Handling joins if user profile is joined
    final profiles = json['profiles'] as Map<String, dynamic>?; // assuming join
    // Or if Supabase flat join: profiles.name, profiles.avatar_url
    
    // Actually, depending on query, it might be nested. 
    // Standard Supabase select `*, profiles(*)` returns profiles as object.
    
    return RecipeReviewModel(
      id: json['id'],
      recipeId: json['recipe_id'],
      userId: json['user_id'],
      userName: profiles?['name'] ?? 'Unknown', // Fallback
      userAvatar: profiles?['avatar_path'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
