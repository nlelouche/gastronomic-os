import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/resolved_step.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/formatted_recipe_text.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';

class RecipeInstructionsWidget extends StatelessWidget {
  final List<ResolvedStep>? resolvedSteps;
  final bool isResolving;

  const RecipeInstructionsWidget({
    super.key, 
    required this.resolvedSteps,
    required this.isResolving,
  });

  @override
  Widget build(BuildContext context) {
    if (isResolving) {
      return const Center(child: CircularProgressIndicator());
    }

    if (resolvedSteps == null || resolvedSteps!.isEmpty) {
      return Text(AppLocalizations.of(context)!.recipeInstructionsEmpty);
    }

    final Map<int, List<ResolvedStep>> groupedSteps = {};
    for (var step in resolvedSteps!) {
      if (!groupedSteps.containsKey(step.index)) {
        groupedSteps[step.index] = [];
      }
      groupedSteps[step.index]!.add(step);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedSteps.entries.map((groupEntry) {
        final stepIndex = groupEntry.key;
        final variants = groupEntry.value;
        final isLast = stepIndex == groupedSteps.keys.last;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(context, stepIndex, isLast),
              const SizedBox(width: AppDimens.spaceL),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.space2XL),
                  child: Column(
                    children: variants.map((resolvedStep) => _buildStepVariant(context, resolvedStep)).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepIndicator(BuildContext context, int index, bool isLast) {
    return Column(
      children: [
        Container(
          width: AppDimens.iconSizeL,
          height: AppDimens.iconSizeL,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          child: Center(
            child: Text(
              '$index',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: AppDimens.fontSizeSmall + 2,
              ),
            ),
          ),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              color: Theme.of(context).colorScheme.outlineVariant,
              margin: const EdgeInsets.symmetric(vertical: AppDimens.spaceXS),
            ),
          ),
      ],
    );
  }

  Widget _buildStepVariant(BuildContext context, ResolvedStep resolvedStep) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.spaceM),
      padding: const EdgeInsets.all(AppDimens.spaceM),
      decoration: BoxDecoration(
        color: resolvedStep.isUniversal
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(
          color: resolvedStep.isUniversal
              ? Colors.transparent
              : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppDimens.spaceS,
            runSpacing: AppDimens.spaceXS,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spaceS, vertical: AppDimens.spaceXS),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (resolvedStep.targetMembers.isNotEmpty)
                      ...resolvedStep.targetMembers.map((member) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _buildMicroAvatar(context, member, 20),
                          )),
                    if (resolvedStep.targetMembers.isEmpty)
                      Icon(Icons.person,
                          size: AppDimens.iconSizeS, 
                          color: Theme.of(context).colorScheme.onTertiaryContainer),
                    const SizedBox(width: AppDimens.spaceXS),
                    Text(
                      resolvedStep.targetGroupLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                    ),
                  ],
                ),
              ),
              if (resolvedStep.substitutionReason != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.spaceS, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    resolvedStep.substitutionReason!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
            ],
          ),
          if (!resolvedStep.isUniversal) const SizedBox(height: AppDimens.spaceS),
          FormattedRecipeText(
            text: resolvedStep.instruction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          if (resolvedStep.crossContaminationAlert != null)
            Container(
              margin: const EdgeInsets.only(top: AppDimens.spaceS),
              padding: const EdgeInsets.all(AppDimens.spaceS),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
                border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, size: AppDimens.iconSizeS, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: AppDimens.spaceS),
                  Expanded(
                    child: Text(
                      resolvedStep.crossContaminationAlert!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMicroAvatar(BuildContext context, FamilyMember member, double size) {
    final path = member.avatarPath;
    Color color = Theme.of(context).colorScheme.primary;
    Widget? content;

    if (path != null) {
      if (path.startsWith('preset_')) {
        IconData icon;
        switch (path) {
          case 'preset_dad':
            icon = Icons.man;
            color = Colors.blue.shade200;
            break;
          case 'preset_mom':
            icon = Icons.woman;
            color = Colors.pink.shade200;
            break;
          case 'preset_boy':
            icon = Icons.boy;
            color = Colors.blue.shade100;
            break;
          case 'preset_girl':
            icon = Icons.girl;
            color = Colors.pink.shade100;
            break;
          case 'preset_grandpa':
            icon = Icons.elderly;
            color = Colors.grey.shade400;
            break;
          case 'preset_grandma':
            icon = Icons.elderly_woman;
            color = Colors.purple.shade200;
            break;
          default:
            icon = Icons.face;
            color = Colors.grey;
        }
        content = Icon(icon, size: size * 0.7, color: Colors.white);
      } else {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        );
      }
    } else {
      content = Text(
        member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }
}
