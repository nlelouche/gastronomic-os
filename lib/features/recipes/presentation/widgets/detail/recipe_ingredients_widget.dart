import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

class RecipeIngredientsWidget extends StatelessWidget {
  final List<String> ingredients;

  const RecipeIngredientsWidget({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return Text(AppLocalizations.of(context)!.recipeIngredientsEmpty);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
            title: AppLocalizations.of(context)!.recipeIngredientsTitle,
            subtitle: AppLocalizations.of(context)!.recipeIngredientsCount(ingredients.length)),
        const SizedBox(height: AppDimens.spaceL),
        ...ingredients.map((ingredient) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceXS),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, 
                    size: AppDimens.iconSizeS + 4, // 20.0
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppDimens.spaceM),
                Expanded(child: Text(ingredient, style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
