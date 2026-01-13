import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:gastronomic_os/features/settings/presentation/pages/glossary_page.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_state_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/main.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/bloc/localization_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<OnboardingBloc>()),
        BlocProvider(create: (context) => sl<RecipeBloc>()),
      ],
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24),
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
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    // --- Data Management Section ---
                    SectionHeader(title: AppLocalizations.of(context)!.manageFamilyTitle.toUpperCase().split(' ').last), // 'Data' part hack or just hardcode 'Family & Data' for now?
                    // Let's stick to using the L10n keys we defined, assuming 'Family & Data' wasn't exactly defined.
                    // Actually, let's use the defined keys or keep structure.
                    // Wait, I defined specific keys in arb. Let's use them.
                    const SectionHeader(title: 'DATA & PRIVACY'), 
                    const SizedBox(height: 12),
                    
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
                    const SizedBox(height: 12),

                    _buildSettingsTile(
                      context,
                      title: AppLocalizations.of(context)!.resetDataTitle,
                      subtitle: AppLocalizations.of(context)!.resetDataSubtitle,
                      icon: Icons.restore,
                      iconColor: Colors.orange,
                      onTap: () => _confirmReset(context),
                      isDestructive: true,
                    ),
                    const SizedBox(height: 12),

                    _buildSettingsTile(
                      context,
                      title: 'Seed Test Recipes',
                      subtitle: 'Dev: Populate Graph DB with Matrix Recipes',
                      icon: Icons.science,
                      iconColor: Colors.deepPurple,
                      onTap: () {
                        context.read<RecipeBloc>().add(const SeedDatabase());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Seeding Database with Graph Recipes... Check Dashboard shortly.'))
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // --- Localization Section ---
                    const SectionHeader(title: 'LANGUAGE'),
                    const SizedBox(height: 12),
                    BlocBuilder<LocalizationBloc, LocalizationState>(
                      builder: (context, localeState) {
                        final isEnglish = localeState.locale.languageCode == 'en';
                        return _buildSettingsTile(
                          context,
                          title: isEnglish ? 'English' : 'Español',
                          subtitle: isEnglish ? 'Tap to switch to Spanish' : 'Toca para cambiar a Inglés',
                          icon: Icons.language,
                          iconColor: Colors.blue,
                          onTap: () {
                            final newLocale = isEnglish ? const Locale('es') : const Locale('en');
                            context.read<LocalizationBloc>().add(ChangeLocale(newLocale));
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // --- Application Section ---
                    const SectionHeader(title: 'APPLICATION'),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      context,
                      title: AppLocalizations.of(context)!.appearanceTitle,
                      subtitle: AppLocalizations.of(context)!.appearanceSubtitle,
                      icon: Icons.palette_outlined,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Theme switching coming soon (Locked to System for now)'))
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      context,
                      title: AppLocalizations.of(context)!.glossaryTitle,
                      subtitle: AppLocalizations.of(context)!.glossarySubtitle,
                      icon: Icons.menu_book_rounded,
                      iconColor: Colors.teal,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const GlossaryPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      context,
                      title: AppLocalizations.of(context)!.aboutTitle,
                      subtitle: AppLocalizations.of(context)!.aboutSubtitle,
                      icon: Icons.info_outline,
                      onTap: () {}, 
                    ),
                    
                    const SizedBox(height: 48),
                    Center(
                      child: Text(
                        'Gastronomic OS',
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor ?? colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Text('Reset Everything?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'This action is irreversible. It will delete your family members, inventory, recipes, and reset the onboarding flow to the beginning.',
          style: TextStyle(height: 1.5),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
             style: FilledButton.styleFrom(
               backgroundColor: Theme.of(context).colorScheme.error,
               foregroundColor: Theme.of(context).colorScheme.onError,
             ),
            onPressed: () {
              Navigator.pop(dialogContext);
              // Dispatch reset event via the context from the PARENT widget (SettingsView)
              // We need to capture the Bloc provided in SettingsPage
              context.read<OnboardingBloc>().add(ResetOnboarding());
            },
            child: const Text('Delete & Reset'),
          ),
        ],
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }
}
