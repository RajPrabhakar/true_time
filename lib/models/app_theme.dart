import 'package:flutter/material.dart';

/// Enum representing the available app themes.
enum AppThemeType {
  void_,              // Void (default): OLED black
  blueprint,          // Blueprint (technical): deep blue with cyan
  solarFlare,         // Solar Flare (high visibility): white with black text
  solarDynamic,       // Solar Dynamic: time-based color transitions
  horologicalInstrument, // Horological Instrument: vintage tech with glow
  bauhaus1925,        // Bauhaus 1925: geometric modernism
  solarDrift,         // Solar Drift: adaptive gradient based on solar position
  blueprintArchitectural // Blueprint Architectural: CAD-style with grid
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
    AppThemeType.solarDynamic: AppThemeColors(
      name: 'Solar Dynamic',
      backgroundColor: Color(0xFF000000),       // Midnight default
      textColor: Color(0xFFFFFFFF),             // White
      secondaryTextColor: Color(0xFF808080),    // Muted gray
      accentColor: Color(0xFF00CCFF),           // Cyan (night accent)
    ),
    AppThemeType.horologicalInstrument: AppThemeColors(
      name: 'Horological Instrument',
      backgroundColor: Color(0xFF000000),       // Pure black
      textColor: Color(0xFFFFBF00),             // Amber
      secondaryTextColor: Color(0xFF664400),    // Dark amber
      accentColor: Color(0xFFFFBF00),           // Amber glow
    ),
    AppThemeType.bauhaus1925: AppThemeColors(
      name: 'Bauhaus 1925',
      backgroundColor: Color(0xFFF5F5DC),       // Off-white
      textColor: Color(0xFF333333),             // Charcoal
      secondaryTextColor: Color(0xFF666666),    // Dark gray
      accentColor: Color(0xFFE10600),           // Primary red
    ),
    AppThemeType.solarDrift: AppThemeColors(
      name: 'Solar Drift',
      backgroundColor: Color(0xFF001122),       // Deep zenith blue (default)
      textColor: Color(0xFFFFFFFF),             // White
      secondaryTextColor: Color(0xFFAAAAAA),    // Light gray
      accentColor: Color(0xFF00DDFF),           // Cyan accent
    ),
    AppThemeType.blueprintArchitectural: AppThemeColors(
      name: 'Blueprint Arch',
      backgroundColor: Color(0xFF002B36),       // Deep drafting blue
      textColor: Color(0xFF2AA198),             // Cyan
      secondaryTextColor: Color(0xFF00B8B8),    // Light cyan
      accentColor: Color(0xFF2AA198),           // Cyan accent
    ),
  };

  /// Get theme colors by type
  static AppThemeColors getTheme(AppThemeType type) {
    return themes[type]!;
  }

  /// Get all available themes as a list for UI selection
  static List<AppThemeType> getAllThemes() => AppThemeType.values;

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
    final hour = localMeanTime.hour;
    final minute = localMeanTime.minute;
    final timeInMinutes = hour * 60 + minute;

    // 5 AM = 300 min, 6 AM = 360 min, 11 AM = 660 min, 1 PM = 780 min
    // 6 PM = 1080 min, 7 PM = 1140 min, 8 PM = 1200 min
    const int civilTwilightDawnStart = 5 * 60;    // 5 AM
    const int civilTwilightDawnEnd = 6 * 60;      // 6 AM
    const int solarNoonStart = 11 * 60;           // 11 AM
    const int solarNoonEnd = 13 * 60;             // 1 PM
    const int civilTwilightDuskStart = 18 * 60;   // 6 PM
    const int civilTwilightDuskEnd = 19 * 60;     // 7 PM
    const int nightStart = 20 * 60;               // 8 PM

    // OLED Black Night: 8 PM to 5 AM
    if (timeInMinutes >= nightStart || timeInMinutes < civilTwilightDawnStart) {
      return const Color(0xFF000000); // Pure black
    }

    // Civil Twilight Dawn: 5 AM to 6 AM
    // Gradient from #000015 to #000025 as we approach day
    if (timeInMinutes >= civilTwilightDawnStart &&
        timeInMinutes < civilTwilightDawnEnd) {
      final progress =
          (timeInMinutes - civilTwilightDawnStart) /
          (civilTwilightDawnEnd - civilTwilightDawnStart);
      return Color.lerp(
          const Color(0xFF000015), const Color(0xFF000025), progress)!;
    }

    // Morning: 6 AM to 11 AM - gradual transition to charcoal
    if (timeInMinutes >= civilTwilightDawnEnd && timeInMinutes < solarNoonStart) {
      final progress =
          (timeInMinutes - civilTwilightDawnEnd) /
          (solarNoonStart - civilTwilightDawnEnd);
      // Transition from #000025 to #121212
      return Color.lerp(
          const Color(0xFF000025), const Color(0xFF121212), progress)!;
    }

    // Solar Noon: 11 AM to 1 PM - High Noon charcoal
    if (timeInMinutes >= solarNoonStart && timeInMinutes < solarNoonEnd) {
      return const Color(0xFF121212); // Dark charcoal
    }

    // Afternoon: 1 PM to 6 PM - gradual darkening from charcoal
    if (timeInMinutes >= solarNoonEnd && timeInMinutes < civilTwilightDuskStart) {
      final progress =
          (timeInMinutes - solarNoonEnd) /
          (civilTwilightDuskStart - solarNoonEnd);
      // Transition from #121212 to #000025
      return Color.lerp(
          const Color(0xFF121212), const Color(0xFF000025), progress)!;
    }

    // Civil Twilight Dusk: 6 PM to 7 PM - gradient from #000025 to #000015
    if (timeInMinutes >= civilTwilightDuskStart &&
        timeInMinutes < civilTwilightDuskEnd) {
      final progress =
          (timeInMinutes - civilTwilightDuskStart) /
          (civilTwilightDuskEnd - civilTwilightDuskStart);
      return Color.lerp(
          const Color(0xFF000025), const Color(0xFF000015), progress)!;
    }

    // Evening: 7 PM to 8 PM - fade to pure black
    if (timeInMinutes >= civilTwilightDuskEnd && timeInMinutes < nightStart) {
      final progress =
          (timeInMinutes - civilTwilightDuskEnd) /
          (nightStart - civilTwilightDuskEnd);
      // Transition from #000015 to #000000
      return Color.lerp(const Color(0xFF000015), const Color(0xFF000000), progress)!;
    }

    // Fallback (should not reach)
    return const Color(0xFF000000);
  }

  /// Determines the accent color based on background brightness for Solar Dynamic.
  /// Uses cyan for dark backgrounds (night) and orange for light backgrounds (noon).
  static Color getAccentColorForSolarDynamic(Color backgroundColor) {
    // Calculate luminance of the background color
    final luminance = backgroundColor.computeLuminance();
    
    // If background is very dark (luminance < 0.2), use cyan accent
    // If background is lighter (luminance >= 0.2), use orange/warm accent
    if (luminance < 0.2) {
      return const Color(0xFF00CCFF); // Cyan for night
    } else {
      return const Color(0xFFFF8800); // Warm orange for day
    }
  }

  /// Returns shadow/glow effect for Horological Instrument theme
  static List<Shadow> getHorologicalGlow() {
    return [
      const Shadow(
        color: Color(0xFFFFBF00),
        blurRadius: 10,
        offset: Offset(0, 0),
      ),
      const Shadow(
        color: Color(0xFFFFBF00),
        blurRadius: 20,
        offset: Offset(0, 0),
      ),
    ];
  }

  /// Calculates the background color for Solar Drift theme based on solar hour angle
  /// Shifts from zenith blue at noon to dusk violet at sunset
  static Color getBackgroundColorForSolarDrift(DateTime localMeanTime) {
    final hour = localMeanTime.hour;
    final minute = localMeanTime.minute;
    final timeInMinutes = hour * 60 + minute;

    // Zenith Blue at Solar Noon (12:00 = 720 min)
    // Gradually shift to Dusk Violet towards evening
    // Simple approximation: peak blue at noon, fade to violet by sunset
    
    const int noonStart = 11 * 60;   // 11 AM
    const int noonEnd = 13 * 60;     // 1 PM
    const int sunsetStart = 17 * 60; // 5 PM
    const int sunsetEnd = 19 * 60;   // 7 PM

    // 5 AM to 11 AM: fade in to blue
    if (timeInMinutes >= 5 * 60 && timeInMinutes < noonStart) {
      final progress = (timeInMinutes - 5 * 60) / (noonStart - 5 * 60);
      return Color.lerp(
          const Color(0xFF000033), const Color(0xFF001122), progress)!;
    }

    // 11 AM to 1 PM: peak zenith blue
    if (timeInMinutes >= noonStart && timeInMinutes < noonEnd) {
      return const Color(0xFF001122); // Zenith Blue
    }

    // 1 PM to 5 PM: gradual fade from zenith blue
    if (timeInMinutes >= noonEnd && timeInMinutes < sunsetStart) {
      final progress = (timeInMinutes - noonEnd) / (sunsetStart - noonEnd);
      return Color.lerp(
          const Color(0xFF001122), const Color(0xFF0A0015), progress)!;
    }

    // 5 PM to 7 PM: sunset to dusk violet
    if (timeInMinutes >= sunsetStart && timeInMinutes < sunsetEnd) {
      final progress = (timeInMinutes - sunsetStart) / (sunsetEnd - sunsetStart);
      return Color.lerp(
          const Color(0xFF0A0015), const Color(0xFF1A0033), progress)!;
    }

    // 7 PM to 5 AM: dusk violet to dark night
    return const Color(0xFF000000);
  }

  /// Returns a grid pattern overlay for Blueprint Architectural theme
  /// Used in a CustomPaint widget
  static void paintBlueprintGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00B8B8).withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    const double gridSize = 10;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
}
