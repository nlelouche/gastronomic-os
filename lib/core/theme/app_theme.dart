import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeType {
  emeraldTech,
  deepBlue,
  sunsetHaze,
  forestGreen,
  elegantSlate,
}

class AppTheme {
  const AppTheme._();

  static final String? _fontFamily = GoogleFonts.outfit().fontFamily;

  static ThemeData getTheme(AppThemeType type, Brightness brightness) {
    switch (type) {
      case AppThemeType.deepBlue:
        return _buildTheme(const Color(0xFF1565C0), brightness); // Blue 800
      case AppThemeType.sunsetHaze:
        return _buildTheme(const Color(0xFFFF5722), brightness); // Deep Orange
      case AppThemeType.forestGreen:
        return _buildTheme(const Color(0xFF2E7D32), brightness); // Green 800
      case AppThemeType.elegantSlate:
        return _buildTheme(const Color(0xFF455A64), brightness); // Blue Grey
      case AppThemeType.emeraldTech:
      default:
        return _buildTheme(const Color(0xFF009688), brightness); // Teal
    }
  }

  static ThemeData _buildTheme(Color seed, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    // Custom overrides for dark mode "Slate" look
    Color? scaffoldBg;
    if (isDark) {
      scaffoldBg = const Color(0xFF020617); // Slate 950
    }

    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
        surface: isDark ? const Color(0xFF0F172A) : null, // Slate 900
        onSurface: isDark ? const Color(0xFFE2E8F0) : null, // Slate 200
      ),
      scaffoldBackgroundColor: scaffoldBg,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? const Color(0xFF1E293B) : null, // Slate 800
      ),
    );
  }
  
  // Keep legacy getters for now if needed, mapping to Default
  static ThemeData get light => getTheme(AppThemeType.emeraldTech, Brightness.light);
  static ThemeData get dark => getTheme(AppThemeType.emeraldTech, Brightness.dark);
}
