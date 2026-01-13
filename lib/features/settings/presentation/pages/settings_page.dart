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
          'Settings',
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
                    const SectionHeader(title: 'Family & Data'),
                    const SizedBox(height: 12),
                    
                    _buildSettingsTile(
                      context,
                      title: 'Manage Family',
                      subtitle: 'Add, edit or remove family members.',
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
                      title: 'Reset App Data',
                      subtitle: 'Clear all family profiles and reset onboarding status.',
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
                    _buildSettingsTile(
                      context,
                      title: 'Debug: Seed Steak Only',
                      subtitle: 'Fast seed for "Steak & Eggs" debugging',
                      icon: Icons.bug_report,
                      iconColor: Colors.red,
                      onTap: () {
                        context.read<RecipeBloc>().add(const SeedDatabase(filterTitle: 'Steak'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Seeding ONLY Steak & Eggs...'))
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // --- Application Section ---
                    const SectionHeader(title: 'Application'),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      context,
                      title: 'Appearance',
                      subtitle: 'System default',
                      icon: Icons.palette_outlined,
                      onTap: () {
                        // TODO: Implement theme switching dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Theme switching coming soon (Locked to System for now)'))
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      context,
                      title: 'Glossary of Terms',
                      subtitle: 'Learn about APLV, Keto, and other tags.',
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
                      title: 'About',
                      subtitle: 'Version 0.5.0 Alpha',
                      icon: Icons.info_outline,
                      onTap: () {}, // No-op or show license page
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
