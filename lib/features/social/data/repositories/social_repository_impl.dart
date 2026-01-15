import 'dart:io';
import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/error/error_context.dart';
import 'package:gastronomic_os/features/social/data/models/cook_proof_model.dart';
import 'package:gastronomic_os/features/social/data/models/recipe_review_model.dart';
import 'package:gastronomic_os/features/social/domain/entities/cook_proof.dart';
import 'package:gastronomic_os/features/social/domain/entities/recipe_review.dart';
import 'package:gastronomic_os/features/social/domain/repositories/social_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gastronomic_os/core/util/app_logger.dart';

class SocialRepositoryImpl implements ISocialRepository {
  final SupabaseClient supabaseClient;

  SocialRepositoryImpl({required this.supabaseClient});

  @override
  Future<(Failure?, void)> addReview(String recipeId, int rating, String comment) async {
    try {
      final userId = supabaseClient.auth.currentUser!.id;
      
      await supabaseClient.from('recipe_reviews').insert({
        'recipe_id': recipeId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      });
      return (null, null);
    } catch (e) {
      AppLogger.e('Add Review Failed', e);
      return (DatabaseFailure('Failed to submit review', context: ErrorContext.supabase('addReview')), null);
    }
  }

  @override
  Future<(Failure?, List<RecipeReview>?)> getReviewsForRecipe(String recipeId) async {
    try {
      final response = await supabaseClient
          .from('recipe_reviews')
          .select('*, profiles(name:display_name)')
          .eq('recipe_id', recipeId)
          .order('created_at', ascending: false);

      final reviews = (response as List).map((e) => RecipeReviewModel.fromJson(e)).toList();
      return (null, reviews);
    } catch (e) {
      AppLogger.e('Get Reviews Failed', e);
      return (DatabaseFailure('Failed to load reviews', context: ErrorContext.supabase('getReviewsForRecipe')), null);
    }
  }

  @override
  Future<(Failure?, void)> addCookProof(String recipeId, File photo, String caption) async {
    try {
      final userId = supabaseClient.auth.currentUser!.id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'proofs/$recipeId/$userId-$timestamp.jpg';

      await supabaseClient.storage.from('recipe_images').upload(
        path,
        photo,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      
      final url = supabaseClient.storage.from('recipe_images').getPublicUrl(path);

      await supabaseClient.from('cook_proofs').insert({
        'recipe_id': recipeId,
        'user_id': userId,
        'photo_url': url,
        'caption': caption,
      });
      
      return (null, null);
    } catch (e) {
      AppLogger.e('Add Cook Proof Failed', e);
      return (DatabaseFailure('Failed to upload proof', context: ErrorContext.supabase('addCookProof')), null);
    }
  }

  @override
  Future<(Failure?, List<CookProof>?)> getCookProofsForRecipe(String recipeId) async {
    try {
      final response = await supabaseClient
          .from('cook_proofs')
          .select('*, profiles(name:display_name)')
          .eq('recipe_id', recipeId)
          .order('created_at', ascending: false);

      final proofs = (response as List).map((e) => CookProofModel.fromJson(e)).toList();
      return (null, proofs);
    } catch (e) {
      AppLogger.e('Get Proofs Failed', e);
      return (DatabaseFailure('Failed to load proofs', context: ErrorContext.supabase('getCookProofsForRecipe')), null);
    }
  }
}
