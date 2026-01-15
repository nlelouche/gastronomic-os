import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/social/domain/entities/recipe_review.dart';
import 'rating_bar.dart';
// import 'package:timeago/timeago.dart' as timeago; // If available, otherwise basic format

class ReviewListTile extends StatelessWidget {
  final RecipeReview review;

  const ReviewListTile({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
       padding: const EdgeInsets.all(AppDimens.spaceM),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             children: [
               CircleAvatar(
                 radius: 16,
                 backgroundImage: review.userAvatar != null 
                     ? NetworkImage(review.userAvatar!) 
                     : null,
                 child: review.userAvatar == null 
                     ? Text(review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?')
                     : null,
               ),
               const SizedBox(width: AppDimens.spaceM),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(review.userName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                     Text(
                        _formatDate(review.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                     ),
                   ],
                 ),
               ),
               RatingBar(rating: review.rating.toDouble(), size: 16),
             ],
           ),
           if (review.comment != null && review.comment!.isNotEmpty) ...[
             const SizedBox(height: AppDimens.spaceS),
             Text(review.comment!, style: theme.textTheme.bodyMedium),
           ],
         ],
       ),
    );
  }

  String _formatDate(DateTime date) {
    // Basic formatting
    return "${date.day}/${date.month}/${date.year}";
  }
}
