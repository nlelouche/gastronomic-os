import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/inventory/domain/entities/inventory_item.dart';
import 'package:google_fonts/google_fonts.dart';

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
        statusText = 'Expired';
      } else if (daysUntil <= 3) {
        statusColor = Colors.orange;
        statusText = 'Expiring soon';
      } else {
        statusColor = Colors.green;
        statusText = '${daysUntil}d left';
      }
    }

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero, // We'll handle padding inside for better layout control
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.kitchen, // Placeholder icon, ideally meaningful based on category
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceDim,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.quantity} ${item.unit}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (statusText.isNotEmpty) ...[
                          const SizedBox(width: 8),
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
