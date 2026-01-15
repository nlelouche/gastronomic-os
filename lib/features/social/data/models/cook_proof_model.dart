import 'package:gastronomic_os/features/social/domain/entities/cook_proof.dart';

class CookProofModel extends CookProof {
  const CookProofModel({
    required super.id,
    required super.recipeId,
    required super.userId,
    required super.userName,
    super.userAvatar,
    required super.photoUrl,
    super.caption,
    required super.createdAt,
  });

  factory CookProofModel.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?; 

    return CookProofModel(
      id: json['id'],
      recipeId: json['recipe_id'],
      userId: json['user_id'],
      userName: profiles?['name'] ?? 'Unknown',
      userAvatar: profiles?['avatar_path'],
      photoUrl: json['photo_url'],
      caption: json['caption'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'user_id': userId,
      'photo_url': photoUrl,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
