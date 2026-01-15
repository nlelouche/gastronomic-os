import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/theme/app_theme.dart';

class ThemeState extends Equatable {
  final AppThemeType themeType;
  final ThemeMode themeMode;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const ThemeState({
    required this.themeType,
    required this.themeMode,
    required this.lightTheme,
    required this.darkTheme,
  });

  factory ThemeState.initial() {
    return ThemeState(
      themeType: AppThemeType.emeraldTech,
      themeMode: ThemeMode.dark,
      lightTheme: AppTheme.getTheme(AppThemeType.emeraldTech, Brightness.light),
      darkTheme: AppTheme.getTheme(AppThemeType.emeraldTech, Brightness.dark),
    );
  }

  ThemeState copyWith({
    AppThemeType? themeType,
    ThemeMode? themeMode,
  }) {
    final newType = themeType ?? this.themeType;
    return ThemeState(
      themeType: newType,
      themeMode: themeMode ?? this.themeMode,
      lightTheme: AppTheme.getTheme(newType, Brightness.light),
      darkTheme: AppTheme.getTheme(newType, Brightness.dark),
    );
  }

  @override
  List<Object?> get props => [themeType, themeMode];
}
