import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/theme/app_theme.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ChangeTheme extends ThemeEvent {
  final AppThemeType themeType;
  const ChangeTheme(this.themeType);

  @override
  List<Object?> get props => [themeType];
}

class ChangeThemeMode extends ThemeEvent {
  final ThemeMode themeMode;
  const ChangeThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}
