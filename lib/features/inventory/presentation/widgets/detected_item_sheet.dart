import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:google_fonts/google_fonts.dart';

class DetectedItem {
  final String label;
  final double confidence;
  int count; // How many frames we've seen it (stability)

  DetectedItem({required this.label, required this.confidence, this.count = 1});
}

class DetectedItemSheet extends StatelessWidget {
  final List<DetectedItem> items;
  final Function(DetectedItem) onDelete;
  final VoidCallback onAddAll;

  const DetectedItemSheet({
    super.key,
    required this.items,
    required this.onDelete,
    required this.onAddAll,
  });

  @override
  Widget build(BuildContext context) {
    // Determine height based on content
    // Minimal height if empty (just a hint), expanded if items exist
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingPage),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle/Title
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.spaceL),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detected Items (${items.length})', 
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              if (items.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    // Clear all action? Or just ignore.
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset'),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceM),
          
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Point camera at ingredients to scan...',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Managed by modal usually, but here fixed
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Icon(Icons.fastfood, color: theme.colorScheme.onSecondaryContainer, size: 20),
                  ),
                  title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${(item.confidence * 100).toStringAsFixed(0)}% confidence'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => onDelete(item),
                  ),
                );
              },
            ),
            
          if (items.isNotEmpty) ...[
            const SizedBox(height: AppDimens.spaceL),
            PrimaryButton(
              label: 'Add ${items.length} to Fridge',
              icon: Icons.kitchen,
              onPressed: onAddAll,
            ),
          ],
          
          const SizedBox(height: AppDimens.spaceM),
        ],
      ),
    );
  }
}
