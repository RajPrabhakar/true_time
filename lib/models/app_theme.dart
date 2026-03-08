import 'package:flutter/material.dart';

/// Enum representing the available app themes.
enum AppThemeType {
  void_,     // Void (default): OLED black
  blueprint, // Blueprint (technical): deep blue with cyan
  solarFlare // Solar Flare (high visibility): white with black text
}

/// Data class containing colors and properties for a theme.
class AppThemeColors {
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color accentColor;

  const AppThemeColors({
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.accentColor,
  });
}

/// Theme definitions for each app theme.
class ThemeDefinitions {
  static const Map<AppThemeType, AppThemeColors> themes = {
    AppThemeType.void_: AppThemeColors(
      name: 'Void',
      backgroundColor: Color(0xFF000000),       // Pure OLED black
      textColor: Color(0xFFFFFFFF),             // White
      secondaryTextColor: Color(0xFF808080),    // Muted gray
      accentColor: Color(0xFF00FF00),           // Bright green (GPS indicator)
    ),
    AppThemeType.blueprint: AppThemeColors(
      name: 'Blueprint',
      backgroundColor: Color(0xFF001F3F),       // Deep blueprint blue
      textColor: Color(0xFF00FFFF),             // Cyan
      secondaryTextColor: Color(0xFF0088CC),    // Blue-cyan
      accentColor: Color(0xFF00FF00),           // Bright green (GPS indicator)
    ),
    AppThemeType.solarFlare: AppThemeColors(
      name: 'Solar Flare',
      backgroundColor: Color(0xFFFFFFFF),       // Pure white
      textColor: Color(0xFF000000),             // Pure black
      secondaryTextColor: Color(0xFF666666),    // Dark gray
      accentColor: Color(0xFFFF6B00),           // Orange (solar-inspired)
    ),
  };

  /// Get theme colors by type
  static AppThemeColors getTheme(AppThemeType type) {
    return themes[type]!;
  }

  /// Get all available themes as a list for UI selection
  static List<AppThemeType> getAllThemes() => AppThemeType.values;
}
