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

  static const Color allergyColor = Color(0xFFFF453A); // Red/Orange for alerts
  static const Color lifestyleColor = Color(0xFF30D158); // Green for Vegan/Veggie
  static const Color dietColor = Color(0xFF0A84FF); // Blue for Keto/Paleo
  
  static ThemeData _buildTheme(Color seed, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    // "Unicorn" Dark Mode Palette
    Color? scaffoldBg;
    Color? surface;
    
    if (isDark) {
      scaffoldBg = const Color(0xFF0F0F0F); // Deep Charcoal (almost black)
      surface = const Color(0xFF1C1C1E); // Apple-style dark surface
    } else {
      // "Premium" Light Mode Palette
      scaffoldBg = const Color(0xFFF2F2F7); // Soft Gray (Apple style)
      surface = const Color(0xFFFFFFFF); // Pure White
    }

    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary, // Matches the seed/primary exactly
        unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
        indicatorColor: scheme.primary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: surface,
      ),
    );
  }
  
  // Keep legacy getters for now if needed, mapping to Default
  static ThemeData get light => getTheme(AppThemeType.emeraldTech, Brightness.light);
  static ThemeData get dark => getTheme(AppThemeType.emeraldTech, Brightness.dark);
}
