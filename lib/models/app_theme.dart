import 'package:flutter/material.dart';
import 'package:true_time/models/theme_types.dart';
import 'package:true_time/models/themes/basic_themes.dart';
import 'package:true_time/models/themes/dynamic_themes.dart';
import 'package:true_time/models/themes/premium_themes.dart' as premium_themes;
import 'package:true_time/models/themes/skin_themes.dart' as skin_themes;

export 'package:true_time/models/theme_types.dart';

/// Theme definitions for each app theme.
class ThemeDefinitions {
  static const Map<AppThemeType, AppThemeColors> themes = {
    ...basicThemes,
    ...premium_themes.premiumThemes,
    ...dynamicThemes,
    ...skin_themes.skinThemes,
  };

  /// Get theme colors by type
  static AppThemeColors getTheme(AppThemeType type) {
    return themes[type]!;
  }

  /// Get all available themes as a list for UI selection
  static List<AppThemeType> getAllThemes() => AppThemeType.values;

  /// Returns the Zenith gradient.
  ///
  /// In solar mode the gradient rises diagonally to feel "sunward".
  /// In official mode it shifts vertically to feel more archival.
  static LinearGradient getZenithGradient({required bool isSolarMode}) {
    return zenithGradient(isSolarMode: isSolarMode);
  }

  /// Calculates the background color for Solar Dynamic theme based on local mean time.
  ///
  /// Color mapping:
  /// - 8 PM to 5 AM: Pure OLED black (#000000) - OLED Black Night
  /// - 5 AM to 6 AM: Deep navy gradient (#000015 to #000025) - Civil Twilight (Dawn)
  /// - 6 AM to 11 AM: Gradual lightening towards charcoal - Morning
  /// - 11 AM to 1 PM: Very dark charcoal (#121212) - High Noon (differentiates from night)
  /// - 1 PM to 6 PM: Gradual darkening from charcoal - Afternoon
  /// - 6 PM to 7 PM: Deep navy gradient (#000025 to #000015) - Civil Twilight (Dusk)
  /// - 7 PM to 8 PM: Deep navy fading to black - Evening
  static Color getBackgroundColorForSolarDynamic(DateTime localMeanTime) {
    return backgroundColorForSolarDynamic(localMeanTime);
  }

  /// Determines the accent color based on background brightness for Solar Dynamic.
  /// Uses cyan for dark backgrounds (night) and orange for light backgrounds (noon).
  static Color getAccentColorForSolarDynamic(Color backgroundColor) {
    return accentColorForSolarDynamic(backgroundColor);
  }

  /// Returns shadow/glow effect for Horological Instrument theme
  static List<Shadow> getHorologicalGlow() {
    return skin_themes.horologicalGlow();
  }

  /// Calculates the background color for Solar Drift theme based on solar hour angle
  /// Shifts from zenith blue at noon to dusk violet at sunset
  static Color getBackgroundColorForSolarDrift(DateTime localMeanTime) {
    return backgroundColorForSolarDrift(localMeanTime);
  }

  /// Returns a grid pattern overlay for Blueprint Architectural theme
  /// Used in a CustomPaint widget
  static void paintBlueprintGrid(Canvas canvas, Size size) {
    premium_themes.paintBlueprintGrid(canvas, size);
  }
}
