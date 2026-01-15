import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onFork;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onFork,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Image Placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: colorScheme.surfaceContainerHighest,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.restaurant_menu_rounded,
                    size: 48,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                ),
                // Fork Badge (Top Right)
                if (recipe.isFork)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fork_right, size: 14, color: colorScheme.onTertiaryContainer),
                          const SizedBox(width: 4),
                          Text(
                            'Fork',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Ingredients Ribbon (Top Left)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.format_list_bulleted, size: 14, color: colorScheme.onPrimary),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.getIngredientsForProfile([]).length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Match Score Badge
                if (recipe.matchScore != null && recipe.matchScore! > 0)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary, // Use tertiary for "Smart Match"
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 14, color: colorScheme.onTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.matchScore!.round()}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onTertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(curve: Curves.elasticOut),
                  ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(AppDimens.paddingCard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title.replaceAll(RegExp(r'\[GOS-\d+\]\s*'), ''),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.description ?? 'No description available.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Clinical Tags Row
                if (recipe.tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: recipe.tags.take(3).map((tag) {
                       final isClinical = ['renal', 'keto', 'diabetes', 'celiac', 'aplv', 'histamine', 'low fodmap']
                          .contains(tag.toLowerCase());
                       if (!isClinical) return const SizedBox.shrink(); // Only show clinical tags on card to save space

                       return Container(
                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                         decoration: BoxDecoration(
                           color: colorScheme.primaryContainer,
                           borderRadius: BorderRadius.circular(4),
                         ),
                         child: Text(
                           tag,
                           style: theme.textTheme.labelSmall?.copyWith(
                             color: colorScheme.onPrimaryContainer,
                             fontWeight: FontWeight.bold,
                             fontSize: 10,
                           ),
                         ),
                       );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOutQuad);
  }
}
