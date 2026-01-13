import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
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
    
    // Determine avatar color based on role (could be dynamic or random)
    final avatarColor = _getColorForRole(member.role, colorScheme);
    final localizedRole = _getLocalizedRole(context, member.role);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12), // Reduced from 16
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56, // Reduced from 64
            height: 56,
            decoration: BoxDecoration(
              color: avatarColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: avatarColor, width: 2),
            ),
            child: Center(
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: GoogleFonts.outfit(
                  fontSize: 24, // Reduced from 28
                  fontWeight: FontWeight.bold,
                  color: avatarColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8), // Reduced from 12
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
          const SizedBox(height: 4),
          Text(
            localizedRole,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8), // Reduced from 12
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${member.medicalConditions.length} ${l10n.medicalTags}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontSize: 10,
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
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Color _getColorForRole(String role, ColorScheme scheme) {
    switch (role.toLowerCase()) {
      case 'dad': return Colors.blue;
      case 'mom': return Colors.pink;
      case 'son': return Colors.green;
      case 'daughter': return Colors.purple;
      case 'grandparent': return Colors.orange;
      default: return scheme.primary;
    }
  }

  String _getLocalizedRole(BuildContext context, String roleKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (roleKey) {
      case 'Dad': return l10n.roleDad;
      case 'Mom': return l10n.roleMom;
      case 'Son': return l10n.roleSon;
      case 'Daughter': return l10n.roleDaughter;
      case 'Grandparent': return l10n.roleGrandparent;
      case 'Roommate': return l10n.roleRoommate;
      case 'Other': return l10n.roleOther;
      default: return roleKey;
    }
  }
}
