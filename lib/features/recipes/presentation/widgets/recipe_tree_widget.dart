import 'package:flutter/material.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

class RecipeTreeWidget extends StatelessWidget {
  final Recipe currentRecipe;
  final Recipe? parentRecipe;
  final List<Recipe> forks;
  final Function(String) onRecipeTap;

  const RecipeTreeWidget({
    super.key,
    required this.currentRecipe,
    this.parentRecipe,
    required this.forks,
    required this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (parentRecipe == null && forks.isEmpty) {
        return const SizedBox.shrink();
    }
    
    final l10n = AppLocalizations.of(context)!;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Parent Node
          if (parentRecipe != null) ...[
            _buildNode(context, parentRecipe!, isCurrent: false, label: l10n.recipeLineageParent),
            _buildConnector(context),
          ],

          // Current Node
          _buildNode(context, currentRecipe, isCurrent: true, label: l10n.recipeLineageCurrent),

          // Forks
          if (forks.isNotEmpty) ...[
            _buildConnector(context),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: forks.map((f) => _buildNode(context, f, isCurrent: false, label: l10n.recipeLineageVariation)).toList(),
            ),
          ],
        ],
    );
  }

  Widget _buildConnector(BuildContext context) {
    return Container(
      height: 24,
      width: 2,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  Widget _buildNode(BuildContext context, Recipe recipe, {required bool isCurrent, String? label}) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: isCurrent ? null : () => onRecipeTap(recipe.id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 200),
        decoration: BoxDecoration(
          color: isCurrent ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isCurrent ? Border.all(color: colorScheme.primary, width: 2) : null,
          boxShadow: isCurrent ? [
            BoxShadow(color: colorScheme.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Column(
          children: [
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                ),
              ),
            Text(
              recipe.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isCurrent ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
