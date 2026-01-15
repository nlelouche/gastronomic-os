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
    
    // Placeholder logic - In real app, use recipe.imageUrl
    const placeholderImage = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80';

    return Hero(
      tag: 'recipe_${recipe.id}',
      child: Material( // Material required for Hero flight
        color: Colors.transparent,
        child: AppCard(
          onTap: onTap,
          padding: EdgeInsets.zero,
          backgroundImage: DecorationImage(
            image: ResizeImage(
              const NetworkImage(placeholderImage),
              width: 400, // Optimize decode size
            ), 
            fit: BoxFit.cover,
          ),
      child: Container(
        height: 280, // Much taller for impact
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1), // Glass border
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5, 1.0],
            colors: [
              Colors.black.withOpacity(0.2), // Upper tint
              Colors.transparent,
              Colors.black.withOpacity(0.95), // Deep bottom shade
            ],
          ),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.3),
               blurRadius: 12,
               offset: const Offset(0, 8),
             ),
          ],
        ),
        child: Stack(
          children: [
            // Fork Badge & Match Badge
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   if (recipe.isFork)
                    SemanticPill(
                      label: 'Fork',
                      icon: Icons.alt_route_rounded,
                      type: PillType.neutral,
                    )
                   else const SizedBox(), // Spacer
                   
                   if (recipe.matchScore != null)
                     MatchBadge(score: recipe.matchScore!.toDouble()),
                ],
              ),
            ),

            // Content at Bottom
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipe.title,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800, // Extra bold
                      color: Colors.white,
                      height: 1.1,
                      shadows: [
                        Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4, offset: const Offset(0, 2)),
                      ]
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(context, Icons.timer_outlined, '45 min'),
                      const SizedBox(width: 8),
                      // Dynamic Tags
                       if (recipe.tags.any((t) => t.toLowerCase() == 'vegan'))
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: SemanticPill(label: 'Vegan', type: PillType.lifestyle),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    ),
    ).animate().fadeIn().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
