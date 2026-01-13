import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/inventory/domain/entities/inventory_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const InventoryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Calculate expiration status for color coding
    Color statusColor = colorScheme.primary; // Default
    String statusText = '';
    
    if (item.expirationDate != null) {
      final daysUntil = item.expirationDate!.difference(DateTime.now()).inDays;
      if (daysUntil < 0) {
        statusColor = colorScheme.error;
        statusText = AppLocalizations.of(context)!.inventoryExpired;
      } else if (daysUntil <= 3) {
        statusColor = Colors.orange;
        statusText = AppLocalizations.of(context)!.inventoryExpiringSoon;
      } else {
        statusColor = Colors.green;
        statusText = AppLocalizations.of(context)!.inventoryDaysLeft(daysUntil);
      }
    }

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero, // We'll handle padding inside for better layout control
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          // Subtle gradient for "glassmorphism" feel if supported, otherwise solid surface
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surfaceContainer,
              colorScheme.surfaceContainer.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingCard),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: AppDimens.iconSizeXL,
                height: AppDimens.iconSizeXL,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                child: Center(
                  child: Icon(
                    Icons.kitchen, // Placeholder icon, ideally meaningful based on category
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.spaceM),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.outfit().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceS, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceDim,
                            borderRadius: BorderRadius.circular(AppDimens.radiusXS),
                          ),
                          child: Text(
                            '${item.quantity} ${item.unit}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (statusText.isNotEmpty) ...[
                          const SizedBox(width: AppDimens.spaceS),
                          Text(
                            '•  $statusText',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
              
              // Edit Action
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: onEdit,
                  style: IconButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, duration: 300.ms, curve: Curves.easeOutQuad);
  }
}
