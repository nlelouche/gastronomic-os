import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/util/localized_enums.dart';

class FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const FamilyMemberCard({
    super.key,
    required this.member,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    // Determine avatar color based on role
    final avatarColor = _getColorForRole(member.role, colorScheme);
    
    // Use the extension endpoint we created in localized_enums.dart
    final localizedRole = member.role.localized(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimens.spaceM), 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: AppDimens.avatarSizeL, 
            height: AppDimens.avatarSizeL,
            decoration: BoxDecoration(
              color: avatarColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: avatarColor, width: 2),
            ),
            child: Center(
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: GoogleFonts.outfit(
                  fontSize: AppDimens.avatarFontSize, 
                  fontWeight: FontWeight.bold,
                  color: avatarColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.spaceS), 
          Text(
            member.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.outfit().fontFamily,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimens.spaceXS),
          Text(
            localizedRole,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimens.spaceS), 
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceS + 2, vertical: AppDimens.spaceXS),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.primaryDiet.localized(context),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (member.medicalConditions.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.spaceXS),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Keep slightly smaller/custom for pill
                    decoration: BoxDecoration(
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(AppDimens.radiusS),
                    ),
                    child: Text(
                      '${member.medicalConditions.length} ${l10n.medicalTags}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontSize: AppDimens.fontSizeTiny,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(duration: AppDimens.durationMediumMs.ms, curve: Curves.easeOutBack);
  }

  Color _getColorForRole(FamilyRole role, ColorScheme scheme) {
    switch (role) {
      case FamilyRole.dad: return Colors.blue;
      case FamilyRole.mom: return Colors.pink;
      case FamilyRole.son: return Colors.green;
      case FamilyRole.daughter: return Colors.purple;
      case FamilyRole.grandparent: return Colors.orange;
      default: return scheme.primary;
    }
  }
}
