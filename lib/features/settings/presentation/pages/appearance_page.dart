import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/bloc/theme_cubit.dart';
import 'package:gastronomic_os/core/bloc/theme_event.dart';
import 'package:gastronomic_os/core/bloc/theme_state.dart';
import 'package:gastronomic_os/core/theme/app_theme.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
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
            padding: const EdgeInsets.all(AppDimens.paddingPage),
            children: [
              _buildSectionHeader(context, AppLocalizations.of(context)!.appearanceThemeMode),
              const SizedBox(height: AppDimens.spaceL),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(value: ThemeMode.system, label: Text(AppLocalizations.of(context)!.themeModeSystem), icon: const Icon(Icons.brightness_auto)),
                  ButtonSegment(value: ThemeMode.light, label: Text(AppLocalizations.of(context)!.themeModeLight), icon: const Icon(Icons.light_mode)),
                  ButtonSegment(value: ThemeMode.dark, label: Text(AppLocalizations.of(context)!.themeModeDark), icon: const Icon(Icons.dark_mode)),
                ],
                selected: {state.themeMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  context.read<ThemeCubit>().changeThemeMode(newSelection.first);
                },
              ),
              const SizedBox(height: AppDimens.space2XL),
              _buildSectionHeader(context, AppLocalizations.of(context)!.appearanceColorTheme),
              const SizedBox(height: AppDimens.spaceL),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: AppDimens.spaceL,
                  mainAxisSpacing: AppDimens.spaceL,
                ),
                itemCount: AppThemeType.values.length,
                itemBuilder: (context, index) {
                  final themeType = AppThemeType.values[index];
                  final isSelected = state.themeType == themeType;
                  
                  // Generate a preview color from the theme definition manually or implicitly
                  // We know the seeds: 
                  Color seedColor;
                  String label;
                  final l10n = AppLocalizations.of(context)!;
                  
                  switch (themeType) {
                    case AppThemeType.emeraldTech: seedColor = const Color(0xFF009688); label = l10n.themeNameEmerald; break;
                    case AppThemeType.deepBlue: seedColor = const Color(0xFF1565C0); label = l10n.themeNameBlue; break;
                    case AppThemeType.sunsetHaze: seedColor = const Color(0xFFFF5722); label = l10n.themeNameSunset; break;
                    case AppThemeType.forestGreen: seedColor = const Color(0xFF2E7D32); label = l10n.themeNameForest; break;
                    case AppThemeType.elegantSlate: seedColor = const Color(0xFF455A64); label = l10n.themeNameSlate; break;
                  }

                  return InkWell(
                    onTap: () => context.read<ThemeCubit>().changeTheme(themeType),
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    child: Container(
                      decoration: BoxDecoration(
                        color: seedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimens.radiusM),
                        border: Border.all(
                          color: isSelected ? seedColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(backgroundColor: seedColor, radius: AppDimens.iconSizeM),
                          const SizedBox(height: AppDimens.spaceS),
                          Text(
                            label,
                            style: GoogleFonts.outfit(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? seedColor : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (isSelected) 
                            Padding(
                              padding: const EdgeInsets.only(top: AppDimens.spaceXS),
                              child: Icon(Icons.check_circle, size: AppDimens.iconSizeS, color: seedColor),
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
        fontSize: AppDimens.fontSizeHeader,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
