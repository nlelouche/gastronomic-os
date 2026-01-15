import 'package:gastronomic_os/features/social/domain/entities/social_feed_item.dart';

class SocialFeedItemModel extends SocialFeedItem {
  const SocialFeedItemModel({
    required super.recipeId,
    required super.title,
    super.coverPhotoUrl,
    super.chefName,
    super.chefAvatar,
    required super.likesCount,
    super.isLikedByMe,
    required super.createdAt,
  });

  factory SocialFeedItemModel.fromJson(Map<String, dynamic> json) {
    return SocialFeedItemModel(
      recipeId: json['recipe_id'] as String,
      title: json['title'] as String,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      chefName: json['chef_name'] as String?,
      chefAvatar: json['chef_avatar'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      // isLikedByMe needs separate injection or lateral join
    );
  }
}
