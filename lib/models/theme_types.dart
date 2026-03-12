import 'package:flutter/material.dart';

/// Enum representing the available app themes.
enum AppThemeType {
  void_, // Void (default): OLED black
  blueprint, // Blueprint (technical): deep blue with cyan
  solarFlare, // Solar Flare (high visibility): white with black text
  horologicalInstrument, // Horological Instrument: vintage tech with glow
  bauhaus1925, // Bauhaus 1925: geometric modernism
  blueprintArchitectural, // Blueprint Architectural: CAD-style with grid
  observer, // Observer: segmented red-on-black instrumentation
  cartographer, // Cartographer: parchment and warm brown tones
  retroFlip, // Retro Flip: split-flap clock panels
  neonTokyo, // Neon Tokyo: cyberpunk glitch clock with neon grid
}

enum ThemeCategory {
  basic,
  premium,
  skins,
}

/// Data class containing colors and properties for a theme.
class AppThemeColors {
  final String name;
  final String description;
  final ThemeCategory category;
  final Color backgroundColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color accentColor;

  const AppThemeColors({
    required this.name,
    required this.description,
    required this.category,
    required this.backgroundColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.accentColor,
  });
}
