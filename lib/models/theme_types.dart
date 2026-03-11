import 'package:flutter/material.dart';

/// Enum representing the available app themes.
enum AppThemeType {
  void_, // Void (default): OLED black
  blueprint, // Blueprint (technical): deep blue with cyan
  solarFlare, // Solar Flare (high visibility): white with black text
  solarDynamic, // Solar Dynamic: time-based color transitions
  horologicalInstrument, // Horological Instrument: vintage tech with glow
  bauhaus1925, // Bauhaus 1925: geometric modernism
  solarDrift, // Solar Drift: adaptive gradient based on solar position
  blueprintArchitectural, // Blueprint Architectural: CAD-style with grid
  observer, // Observer: segmented red-on-black instrumentation
  cartographer, // Cartographer: parchment and warm brown tones
  zenith, // Zenith: dynamic indigo gradient field
  retroFlip, // Retro Flip: split-flap clock panels
  monolith, // Monolith: ultra-minimal monochrome
}

enum ThemeCategory {
  basic,
  premium,
  dynamic,
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
