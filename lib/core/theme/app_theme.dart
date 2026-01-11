import 'package:flutter/material.dart' as material;
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  // Define the primary font family
  static final String? _fontFamily = GoogleFonts.outfit().fontFamily;

  // Manual definition of "Emerald Tech" and "Deep Blue" concepts

  static material.ThemeData get light {
    return material.ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: material.ColorScheme.fromSeed(
        seedColor: const material.Color(0xFF009688), // Emerald-like
        brightness: material.Brightness.light,
      ),
      visualDensity: material.VisualDensity.standard,
      appBarTheme: const material.AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
      /*
      cardTheme: material.CardTheme(
        elevation: 0,
        shape: material.RoundedRectangleBorder(borderRadius: material.BorderRadius.circular(16)),
      ),
      */
    );
  }

  static material.ThemeData get dark {
    // Deep Blue inspired
    return material.ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: material.ColorScheme.fromSeed(
        seedColor: const material.Color(0xFF0D47A1), // Deep Blue
        brightness: material.Brightness.dark,
        surface: const material.Color(0xFF0F172A), // Slate 900
        onSurface: const material.Color(0xFFE2E8F0), // Slate 200
      ),
      scaffoldBackgroundColor: const material.Color(0xFF020617), // Slate 950
      visualDensity: material.VisualDensity.standard,
      appBarTheme: const material.AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: material.Colors.transparent,
      ),
      /*
      cardTheme: material.CardTheme(
        elevation: 0,
        color: const material.Color(0xFF1E293B), // Slate 800
        shape: material.RoundedRectangleBorder(borderRadius: material.BorderRadius.circular(16)),
      ),
      */
    );
  }
}
