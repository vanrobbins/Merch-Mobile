import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A1917);
  static const Color accent = Color(0xFFBF5534);
  static const Color canvasBg = Color(0xFFF2EFE8);
  static const Color textPrimary = Color(0xFF1A1917);
  static const Color textSecondary = Color(0xFF6B6762);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const double borderRadius = 2.0;
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1A1A1917),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const Map<String, Color> zoneColors = {
    'womens': Color(0xFF3B6BC2),
    'mens': Color(0xFF3A7D44),
    'accessories': Color(0xFFC19A6B),
    'fitting': Color(0xFF8B3D8B),
    'entrance': Color(0xFFE07B54),
  };

  static Color roleColor(String role) {
    switch (role) {
      case 'coordinator':
        return accent;
      case 'staff':
        return primary;
      case 'manager':
        return textSecondary;
      default:
        return primary;
    }
  }

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: accent,
          surface: canvasBg,
        ),
        scaffoldBackgroundColor: canvasBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Color(0xFFF2EFE8),
          titleTextStyle: TextStyle(
            color: Color(0xFFF2EFE8),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
      );
}
