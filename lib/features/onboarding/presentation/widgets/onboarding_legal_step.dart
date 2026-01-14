import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingLegalStep extends StatefulWidget {
  final VoidCallback onAccepted;

  const OnboardingLegalStep({super.key, required this.onAccepted});

  @override
  State<OnboardingLegalStep> createState() => _OnboardingLegalStepState();
}

class _OnboardingLegalStepState extends State<OnboardingLegalStep> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimens.spaceXL),
          Icon(Icons.gavel_rounded, size: 64, color: theme.colorScheme.primary)
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: AppDimens.spaceL),
          Text(
            l10n.legalWelcome,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ).animate().fadeIn().slideY(begin: 0.3),
          const SizedBox(height: AppDimens.spaceM),
          Text(
            l10n.legalSummary,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: AppDimens.space2XL),
          
          // --- Medical Disclaimer Card ---
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceL),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
              border: Border.all(color: theme.colorScheme.error.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Row(children: [
                   Icon(Icons.medical_services_outlined, color: theme.colorScheme.error),
                   const SizedBox(width: AppDimens.spaceS),
                   Text(l10n.legalDisclaimerTitle, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.error)),
                ]),
                const SizedBox(height: AppDimens.spaceS),
                Text(
                  l10n.legalDisclaimerContent,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideX(),
          
          const Spacer(),

          // --- Terms & Privacy Links (Mock) ---
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppDimens.spaceM,
            children: [
              TextButton(onPressed: () {}, child: Text(l10n.legalTermsTitle)),
              TextButton(onPressed: () {}, child: Text(l10n.legalPrivacyTitle)),
            ],
          ),

          const SizedBox(height: AppDimens.spaceL),

          // --- Accept Button ---
          PrimaryButton(
            label: l10n.legalAccept,
            icon: Icons.check_circle_outline,
            onPressed: () {
                widget.onAccepted();
            },
          ).animate().fadeIn(delay: 600.ms).scale(),
        ],
      ),
    );
  }
}
