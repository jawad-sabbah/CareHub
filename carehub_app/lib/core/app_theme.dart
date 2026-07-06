import 'package:flutter/material.dart';

/// Single source of truth for CareHub's brand identity: name, colour palette,
/// and the app-wide [ThemeData].
class AppTheme {
  AppTheme._();

  /// Product name shown in headers, the PDF report, and auth screens.
  static const String brandName = 'CareHub';

  /// Short marketing line used on the welcome screen.
  static const String tagline = 'Find all your needs faster\nthan ever';

  // --- Core palette -------------------------------------------------------
  static const Color primaryBlue = Color(0xFF1E3FE0);
  static const Color pillPink = Color(0xFFFCE4EC);
  static const Color pillTextBlue = Color(0xFF1E3FE0);
  static const Color accentCyan = Color(0xFF3DE7FF);

  /// Neutral background used by the logged-in (light) screens.
  static const Color lightBackground = Color(0xFFF5F6FA);

  // --- Text styles --------------------------------------------------------
  static const TextStyle display = TextStyle(
    color: Colors.white,
    fontSize: 46,
    height: 1.05,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static const TextStyle subtitle = TextStyle(
    color: Colors.white70,
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  // --- ThemeData ----------------------------------------------------------
  static ThemeData get themeData => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
        ),
      );
}