import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/planner/domain/entities/meal_plan.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

class MealPlanCard extends StatelessWidget {
  final MealPlan plan;
  final VoidCallback? onDateTap;
  final VoidCallback? onContentTap;
  final VoidCallback? onDelete;

  const MealPlanCard({
    super.key,
    required this.plan,
    this.onDateTap,
    this.onContentTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recipe = plan.recipe;

    return AppCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left: Time/Date vertical strip (Editable Date)
            InkWell(
              onTap: onDateTap,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)), // Assuming Card radius
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  border: Border(right: BorderSide(color: colorScheme.outlineVariant)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E', Localizations.localeOf(context).toString()).format(plan.scheduledDate).toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      DateFormat('d').format(plan.scheduledDate),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(Icons.edit_calendar, size: 12, color: colorScheme.primary.withOpacity(0.5)),
                  ],
                ),
              ),
            ),
            
            // Middle: Content (Quick View)
            Expanded(
              child: InkWell(
                onTap: onContentTap,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.paddingCard),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getLocalizedMealType(context, plan.mealType),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (recipe?.title ?? 'Loading Recipe...').replaceAll(RegExp(r'\[GOS-\d+\]\s*'), ''), // Clean title
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Right: Actions (Delete)
            if (onDelete != null)
              Center(
                child: IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: onDelete,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedMealType(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type.toLowerCase()) {
      case 'dinner': return l10n.mealTypeDinner.toUpperCase();
      case 'lunch': return l10n.mealTypeLunch.toUpperCase();
      case 'breakfast': return l10n.mealTypeBreakfast.toUpperCase();
      case 'snack': return l10n.mealTypeSnack.toUpperCase();
      default: return type.toUpperCase();
    }
  }
}
