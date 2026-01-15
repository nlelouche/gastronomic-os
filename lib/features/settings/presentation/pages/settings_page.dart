import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/util/app_logger.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:gastronomic_os/features/settings/presentation/pages/glossary_page.dart';
import 'package:gastronomic_os/features/settings/presentation/pages/appearance_page.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_state_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/main.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gastronomic_os/features/premium/presentation/pages/paywall_page.dart';
import 'package:gastronomic_os/features/premium/presentation/bloc/subscription_cubit.dart';
import 'package:gastronomic_os/features/premium/presentation/bloc/subscription_state.dart';

import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/bloc/localization_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingBloc>(create: (context) => sl<OnboardingBloc>()),
        BlocProvider<RecipeBloc>(create: (context) => sl<RecipeBloc>()),
      ],
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _logsEnabled = AppLogger.isEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: AppDimens.avatarFontSize),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
           if (state is OnboardingInitial) {
             Navigator.of(context).pushAndRemoveUntil(
               MaterialPageRoute(builder: (_) => const AuthWrapper()), 
               (route) => false,
             );
           } else if (state is OnboardingError) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text(state.message), 
                 backgroundColor: colorScheme.error,
                 behavior: SnackBarBehavior.floating,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusS)),
               )
             );
           }
        },
        builder: (context, state) {
          if (state is OnboardingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppDimens.paddingPage),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                      // --- Premium Section ---
                    BlocBuilder<SubscriptionCubit, SubscriptionState>(
                      builder: (context, state) {
                        final isPremium = state is SubscriptionPremium;
                        return _buildSettingsTile(
                          context,
                          title: isPremium ? AppLocalizations.of(context)!.settingsPremiumTitleManage : AppLocalizations.of(context)!.settingsPremiumTitleGet,
                          subtitle: isPremium ? AppLocalizations.of(context)!.monetizationProBadge : AppLocalizations.of(context)!.monetizationUnlockFeatures,
                          icon: Icons.diamond_outlined,
                          iconColor: Colors.amber,
                          onTap: () {
                             if (isPremium) {
                               // TODO: Open Manage Subscription (Platform specific)
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.monetizationManageSubscription)));
                             } else {
                               Navigator.of(context).push(
                                 MaterialPageRoute(builder: (_) => const PaywallPage()),
                               );
                             }
                          },
                        ).animate().shimmer(duration: 2.seconds, delay: 1.seconds);
                      },
                    ),
                    const SizedBox(height: AppDimens.spaceM),
                    
                    // --- Data Management Section ---
                    SectionHeader(title: AppLocalizations.of(context)!.settingsDataPrivacy.toUpperCase()), 
                    const SizedBox(height: AppDimens.spaceM),
                    
                    _buildSettingsTile(
                      context,
                      title: AppLocalizations.of(context)!.manageFamilyTitle,
                      subtitle: AppLocalizations.of(context)!.manageFamilySubtitle,
                      icon: Icons.people_outline,
                      onTap: () {
                         Navigator.of(context).push(
                           MaterialPageRoute(builder: (_) => const OnboardingPage(isEditing: true)),
                         );
                      },
                    ),
                    const SizedBox(height: AppDimens.spaceM),

                    _buildSettingsTile(
                      context,
                      title: AppLocalizations.of(context)!.resetDataTitle,
                      subtitle: AppLocalizations.of(context)!.resetDataSubtitle,
                      icon: Icons.restore,
                      iconColor: colorScheme.error,
                      onTap: () => _confirmReset(context),
                      isDestructive: true,
                    ),
                    const SizedBox(height: AppDimens.spaceM),
                    
                    // --- Localization Section ---
                    SectionHeader(title: AppLocalizations.of(context)!.settingsLanguage.toUpperCase()),
                    const SizedBox(height: AppDimens.spaceM),
                    BlocBuilder<LocalizationBloc, LocalizationState>(
                      builder: (context, localeState) {
                        final isEnglish = localeState.locale.languageCode == 'en';
                        return _buildSettingsTile(
                          context,
                          title: isEnglish ? AppLocalizations.of(context)!.settingsLanguageEnglish : AppLocalizations.of(context)!.settingsLanguageSpanish,
                          subtitle: isEnglish ? AppLocalizations.of(context)!.settingsLanguageSwitchToSpanish : AppLocalizations.of(context)!.settingsLanguageSwitchToEnglish,
                          icon: Icons.language,
                          iconColor: colorScheme.primary,
                          onTap: () {
                            final newLocale = isEnglish ? const Locale('es') : const Locale('en');
                            context.read<LocalizationBloc>().add(ChangeLocale(newLocale));
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppDimens.spaceM),

                    // --- Application Section ---
                    SectionHeader(title: AppLocalizations.of(context)!.settingsApplication.toUpperCase()),
                    const SizedBox(height: AppDimens.spaceM),
                    _buildSettingsTile(
                      context,
                      title: AppLocalizations.of(context)!.appearanceTitle,
                      subtitle: AppLocalizations.of(context)!.appearanceSubtitle,
                      icon: Icons.palette_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AppearancePage()),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimens.spaceM),
                    _buildSettingsTile(
                      context,
                      title: AppLocalizations.of(context)!.glossaryTitle,
                      subtitle: AppLocalizations.of(context)!.glossarySubtitle,
                      icon: Icons.menu_book_rounded,
                      iconColor: colorScheme.secondary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const GlossaryPage()),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimens.spaceM),
                    _buildSettingsTile(
                      context,
                      title: AppLocalizations.of(context)!.aboutTitle,
                      subtitle: AppLocalizations.of(context)!.aboutSubtitle,
                      icon: Icons.info_outline,
                      onTap: () {}, 
                    ),

                    // --- Debug Zone (Visible only in Debug Mode) ---
                    if (kDebugMode) ...[
                      const SizedBox(height: AppDimens.space2XL),
                      SectionHeader(title: AppLocalizations.of(context)!.settingsDebugZone.toUpperCase()),
                      const SizedBox(height: AppDimens.spaceM),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          border: Border.all(color: Colors.amber.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(AppDimens.radiusM),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text(AppLocalizations.of(context)!.settingsEnableLogs, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(AppLocalizations.of(context)!.settingsEnableLogsSubtitle),
                              value: _logsEnabled,
                              activeColor: Colors.amber,
                              onChanged: (bool value) {
                                AppLogger.enableLogs(value);
                                setState(() {
                                  _logsEnabled = value;
                                });
                              },
                            ),
                            const Divider(height: 1),
                            _buildSettingsTile(
                              context,
                              title: AppLocalizations.of(context)!.settingsSeedTestRecipes,
                              subtitle: AppLocalizations.of(context)!.settingsSeedTestRecipesSubtitle,
                              icon: Icons.science,
                              iconColor: Colors.amber,
                              onTap: () {
                                context.read<RecipeBloc>().add(const SeedDatabase());
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Seeding Database... Check logs.'))
                                );
                              },
                              isDestructive: false, // Override
                            ),
                          ],
                        ),
                      ).animate().fadeIn(),
                    ],
                    
                    const SizedBox(height: AppDimens.space3XL),
                    Center(
                      child: Text(
                        'Gastronomic OS ${kDebugMode ? '(Debug Build)' : ''}',
                        style: GoogleFonts.outfit(
                          color: colorScheme.outline.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingCard, vertical: AppDimens.spaceM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceS + 2),
            decoration: BoxDecoration(
              color: (iconColor ?? colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusS + 2),
            ),
            child: Icon(icon, color: iconColor ?? colorScheme.primary, size: 22),
          ),
          const SizedBox(width: AppDimens.spaceL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? colorScheme.error : null,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colorScheme.outlineVariant),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, duration: 300.ms, curve: Curves.easeOut);
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusXL)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: AppDimens.spaceM),
            Text(AppLocalizations.of(context)!.settingsResetDialogTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.settingsResetDialogContent,
          style: const TextStyle(height: 1.5),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingPage, vertical: AppDimens.paddingPage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.dialogCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OnboardingBloc>().add(ResetOnboarding());
            },
            child: Text(AppLocalizations.of(context)!.settingsResetDialogConfirm),
          ),
        ],
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }
}
