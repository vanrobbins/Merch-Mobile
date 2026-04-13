import 'package:flutter/material.dart';

abstract class DesignTokens {
  // Spacing
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double space2xl = 48.0;

  // Border radius (2px is the primary radius throughout the app)
  static const double radiusSm = 2.0;
  static const double radiusMd = 4.0;
  static const double radiusLg = 8.0;

  // Type scale
  static const double typeXs = 9.0;    // eyebrow labels (ALL CAPS)
  static const double typeSm = 12.0;
  static const double typeMd = 14.0;
  static const double typeLg = 16.0;
  static const double typeXl = 20.0;
  static const double typeHeading = 24.0;

  // Font weights
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightBold = FontWeight.w700; // eyebrow labels

  // Letter spacing for ALL CAPS labels
  static const double letterSpacingEyebrow = 1.2;
  static const double letterSpacingAppBar = 1.5;

  // Animation durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMed = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  // Debounce
  static const Duration debounceSearch = Duration(milliseconds: 300);

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
}
