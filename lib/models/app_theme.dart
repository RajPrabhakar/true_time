import 'package:flutter/material.dart';
import 'package:true_time/models/theme_types.dart';
import 'package:true_time/models/themes/basic_themes.dart';
import 'package:true_time/models/themes/premium_themes.dart' as premium_themes;
import 'package:true_time/models/themes/skin_themes.dart' as skin_themes;

export 'package:true_time/models/theme_types.dart';

/// Theme definitions for each app theme.
class ThemeDefinitions {
  static const Map<AppThemeType, AppThemeColors> themes = {
    ...basicThemes,
    ...premium_themes.premiumThemes,
    ...skin_themes.skinThemes,
  };

  /// Get theme colors by type
  static AppThemeColors getTheme(AppThemeType type) {
    return themes[type]!;
  }

  /// Get all available themes as a list for UI selection
  static List<AppThemeType> getAllThemes() => AppThemeType.values;

  /// Returns shadow/glow effect for Horological Instrument theme
  static List<Shadow> getHorologicalGlow() {
    return skin_themes.horologicalGlow();
  }

  /// Returns a grid pattern overlay for Blueprint Architectural theme
  /// Used in a CustomPaint widget
  static void paintBlueprintGrid(Canvas canvas, Size size) {
    premium_themes.paintBlueprintGrid(canvas, size);
  }
}
