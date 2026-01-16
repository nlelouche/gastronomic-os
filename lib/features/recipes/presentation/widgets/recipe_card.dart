import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    
    // Placeholder logic - In real app, use recipe.imageUrl
    const placeholderImage = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80';

    // Determine Glow Color based on Match Score
    Color glowColor = theme.primaryColor;
    if (recipe.matchScore != null) {
      if (recipe.matchScore! >= 80) {
        glowColor = const Color(0xFFCCFF00); // Neon Lime
      } else if (recipe.matchScore! >= 50) {
        glowColor = Colors.orangeAccent;
      }
    }

    return Hero(
      tag: 'recipe_${recipe.id}',
      child: NeonCard(
        glowColor: glowColor,
        intensity: 0.7, // Strong glow
        borderRadius: BorderRadius.circular(30), // Larger corner radius for modern look
        onTap: onTap,
        child: SizedBox(
          height: 320, // Taller card for immersive feel
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Full Bleed Image
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  imageUrl: placeholderImage,
                  memCacheWidth: 600, // Optimize memory usage
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[900]),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),

              // 2. Gradient REMOVED per user request

              // 3. Floating Match Badge (Glass Effect)
              if (recipe.matchScore != null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: GlassContainer(
                    blur: 5, // Reduced blur for performance
                    opacity: 0.2,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: glowColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${recipe.matchScore}% Match',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12,
                            shadows: [
                              const Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
               // 4. Fork Indicator (Top Left)
               if (recipe.isFork)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.alt_route_rounded, color: Colors.white, size: 16),
                  ),
                ),

              // 5. Title & Metadata (Bottom Glass Panel)
              Positioned(
                bottom: 12, // Slight float
                left: 12,
                right: 12,
                child: GlassContainer(
                  blur: 0, // Performance: Disable blur for list scrolling
                  opacity: 0.7, // Slightly higher opacity for legibility without blur
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        recipe.title,
                        style: GoogleFonts.outfit(
                          fontSize: 22, 
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface, // Adaptive Text
                          height: 1.1,
                          // No shadows needed now
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildInfoChip(context, Icons.timer_outlined, '45 min'),
                          const SizedBox(width: 8),
                          if (recipe.tags.any((t) => t.toLowerCase() == 'vegan'))
                            _buildInfoChip(context, Icons.eco, 'Vegan', color: Colors.greenAccent),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildGlassChip(IconData icon, String label, {Color color = Colors.white70, bool hasShadow = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color, shadows: hasShadow ? [const Shadow(color: Colors.black, blurRadius: 2, offset: Offset(0, 1))] : null),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: hasShadow ? [
                const Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1)),
              ] : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, {Color? color}) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface.withOpacity(0.7);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: effectiveColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
