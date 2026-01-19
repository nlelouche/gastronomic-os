import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/social/domain/entities/social_feed_item.dart';
import 'package:gastronomic_os/features/social/presentation/bloc/social_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipe_detail_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

class FeedRecipeCard extends StatelessWidget {
  final SocialFeedItem item;

  const FeedRecipeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Avatar with proper fallback
    final avatarWidget = item.chefAvatar != null && item.chefAvatar!.isNotEmpty
        ? CircleAvatar(backgroundImage: NetworkImage(item.chefAvatar!), radius: 20)
        : CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.person, color: colorScheme.onPrimaryContainer, size: 20),
            radius: 20,
          );
    
    // Chef name with fallback
    final chefName = item.chefName ?? 'Gastronomic OS';

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(recipeId: item.recipeId),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Chef Info
          Padding(
            padding: const EdgeInsets.all(AppDimens.spaceS),
            child: Row(
              children: [
                avatarWidget,
                const SizedBox(width: AppDimens.spaceS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chefName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(timeago.format(item.createdAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
              ],
            ),
          ),

          // 2. Main Content (Hero Image + Title)
          if (item.coverPhotoUrl != null && item.coverPhotoUrl!.isNotEmpty)
            Image.network(
              item.coverPhotoUrl!,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image fails to load
                return Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 80,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.5),
                    ),
                  ),
                );
              },
            )
          else 
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: colorScheme.onPrimaryContainer.withOpacity(0.5),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppDimens.spaceS),
            child: Text(item.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),

          // 3. Action Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceS),
            child: Row(
              children: [
                // LIKE
                _LikeButton(item: item),
                const SizedBox(width: 16),
                
                // FORK
                IconButton(
                  icon: const Icon(Icons.fork_right_outlined),
                  onPressed: () {
                    // Navigate to fork (To be implemented fully connected)
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.featureComingSoon)));
                  },
                ),
                const Spacer(),
                Text(AppLocalizations.of(context)!.socialLikesCount(item.likesCount), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceS),
        ],
      ),
    );
  }
}

class _LikeButton extends StatefulWidget {
  final SocialFeedItem item;
  const _LikeButton({required this.item});

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  late bool isLiked;
  late int likesCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.item.isLikedByMe;
    likesCount = widget.item.likesCount;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : null),
      onPressed: () {
        setState(() {
          isLiked = !isLiked;
          likesCount += isLiked ? 1 : -1;
        });
        context.read<SocialBloc>().add(ToggleLikeEvent(widget.item.recipeId));
      },
    );
  }
}
