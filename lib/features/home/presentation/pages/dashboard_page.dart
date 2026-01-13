import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/inventory/presentation/pages/inventory_page.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_event.dart';
import 'package:gastronomic_os/features/planner/presentation/widgets/chefs_suggestions.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipes_page.dart';
import 'package:gastronomic_os/features/settings/presentation/pages/settings_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/features/planner/presentation/pages/planner_page.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                'Gastronomic OS',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<PlannerBloc>().add(LoadPlannerSuggestions());
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dashboardGreeting,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ).animate().fadeIn().slideX(begin: -0.1),
                      Text(
                        AppLocalizations.of(context)!.dashboardTitle,
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          height: 1.1,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                      
                      const SizedBox(height: 32),

                      // The Brain (New)
                      const ChefsSuggestions(),
                      const SizedBox(height: 32),

                      _buildFeatureCard(
                        context,
                        title: AppLocalizations.of(context)!.dashboardFridgeTitle,
                        subtitle: AppLocalizations.of(context)!.dashboardFridgeSubtitle,
                        icon: Icons.kitchen,
                        color: Colors.blueAccent,
                        delay: 400.ms,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const InventoryPage()),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        context,
                        title: AppLocalizations.of(context)!.dashboardCookbookTitle,
                        subtitle: AppLocalizations.of(context)!.dashboardCookbookSubtitle,
                        icon: Icons.menu_book_rounded,
                        color: Colors.orangeAccent,
                        delay: 500.ms,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const RecipesPage()),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Planner Card
                      _buildFeatureCard(
                        context,
                        title: AppLocalizations.of(context)!.dashboardPlannerTitle,
                        subtitle: AppLocalizations.of(context)!.dashboardPlannerSubtitle,
                        icon: Icons.calendar_month_rounded,
                        color: Colors.purpleAccent,
                        delay: 450.ms,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => BlocProvider.value(
                              value: context.read<PlannerBloc>(),
                              child: const PlannerPage(),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        context,
                        title: AppLocalizations.of(context)!.dashboardSocialTitle,
                        subtitle: AppLocalizations.of(context)!.dashboardSocialSubtitle,
                        icon: Icons.people_outline,
                        color: Colors.pinkAccent,
                        delay: 600.ms,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.socialComingSoon)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Duration delay = Duration.zero,
  }) {
    final theme = Theme.of(context);
    
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 140,
                color: color.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.2, curve: Curves.easeOut);
  }
}
