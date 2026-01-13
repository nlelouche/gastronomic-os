import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/bloc/theme_state.dart';
import 'package:gastronomic_os/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_type';
  static const String _modeKey = 'theme_mode';

  ThemeCubit() : super(ThemeState.initial()) {
    _loadPersistedTheme();
  }

  Future<void> _loadPersistedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      final modeIndex = prefs.getInt(_modeKey);

      AppThemeType type = AppThemeType.emeraldTech;
      ThemeMode mode = ThemeMode.system;

      if (themeIndex != null && themeIndex >= 0 && themeIndex < AppThemeType.values.length) {
        type = AppThemeType.values[themeIndex];
      }

      if (modeIndex != null) {
        // 0: system, 1: light, 2: dark
        if (modeIndex == 1) mode = ThemeMode.light;
        if (modeIndex == 2) mode = ThemeMode.dark;
      }

      if (!isClosed) {
        emit(state.copyWith(themeType: type, themeMode: mode));
      }
    } catch (_) {
      // Fallback
    }
  }

  Future<void> changeTheme(AppThemeType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, type.index);
    emit(state.copyWith(themeType: type));
  }

  Future<void> changeThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    int modeIndex = 0; // system
    if (mode == ThemeMode.light) modeIndex = 1;
    if (mode == ThemeMode.dark) modeIndex = 2;
    
    await prefs.setInt(_modeKey, modeIndex);
    emit(state.copyWith(themeMode: mode));
  }
}
