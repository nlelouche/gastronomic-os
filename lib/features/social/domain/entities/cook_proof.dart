import 'package:equatable/equatable.dart';

class CookProof extends Equatable {
  final String id;
  final String recipeId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String photoUrl;
  final String? caption;
  final DateTime createdAt;

  const CookProof({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.photoUrl,
    this.caption,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, recipeId, userId, photoUrl, caption, createdAt];
}
