import 'package:equatable/equatable.dart';

class SocialFeedItem extends Equatable {
  final String recipeId;
  final String title;
  final String? coverPhotoUrl;
  final String? chefName;
  final String? chefAvatar;
  final int likesCount;
  final bool isLikedByMe; // Needs to be fetched/joined
  final DateTime createdAt;

  const SocialFeedItem({
    required this.recipeId,
    required this.title,
    this.coverPhotoUrl,
    this.chefName,
    this.chefAvatar,
    required this.likesCount,
    this.isLikedByMe = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [recipeId, title, coverPhotoUrl, chefName, chefAvatar, likesCount, isLikedByMe, createdAt];
}
