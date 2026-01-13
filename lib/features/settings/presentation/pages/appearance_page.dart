import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/bloc/theme_cubit.dart';
import 'package:gastronomic_os/core/bloc/theme_event.dart';
import 'package:gastronomic_os/core/bloc/theme_state.dart';
import 'package:gastronomic_os/core/theme/app_theme.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appearanceTitle),
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(context, 'Theme Mode'),
              const SizedBox(height: 16),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
                  ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                ],
                selected: {state.themeMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  context.read<ThemeCubit>().changeThemeMode(newSelection.first);
                },
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Color Theme'),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: AppThemeType.values.length,
                itemBuilder: (context, index) {
                  final themeType = AppThemeType.values[index];
                  final isSelected = state.themeType == themeType;
                  
                  // Generate a preview color from the theme definition manually or implicitly
                  // We know the seeds: 
                  Color seedColor;
                  String label;
                  switch (themeType) {
                    case AppThemeType.emeraldTech: seedColor = const Color(0xFF009688); label = "Emerald Tech"; break;
                    case AppThemeType.deepBlue: seedColor = const Color(0xFF1565C0); label = "Deep Blue"; break;
                    case AppThemeType.sunsetHaze: seedColor = const Color(0xFFFF5722); label = "Sunset Haze"; break;
                    case AppThemeType.forestGreen: seedColor = const Color(0xFF2E7D32); label = "Forest Green"; break;
                    case AppThemeType.elegantSlate: seedColor = const Color(0xFF455A64); label = "Elegant Slate"; break;
                  }

                  return InkWell(
                    onTap: () => context.read<ThemeCubit>().changeTheme(themeType),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: seedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? seedColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(backgroundColor: seedColor, radius: 20),
                          const SizedBox(height: 8),
                          Text(
                            label,
                            style: GoogleFonts.outfit(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? seedColor : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (isSelected) 
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Icon(Icons.check_circle, size: 16, color: seedColor),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
