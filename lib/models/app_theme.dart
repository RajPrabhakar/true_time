import 'package:flutter/material.dart';
import 'package:true_time/models/theme_types.dart';
import 'package:true_time/models/themes/basic_themes.dart';
import 'package:true_time/models/themes/premium_themes.dart' as premium_themes;
import 'package:true_time/models/themes/skin_themes.dart' as skin_themes;
import 'package:true_time/themes/skins/retro_flip_clock.dart';

export 'package:true_time/models/theme_types.dart';

typedef ClockBuilder = Widget Function(BuildContext context, String timeString);

typedef BackgroundBuilder = Widget Function(
  BuildContext context,
  DateTime currentTime,
);

typedef PreviewBackgroundBuilder = Widget Function(BuildContext context);

class AppTheme {
  final AppThemeType id;
  final String name;
  final ThemeCategory category;
  final bool isPremium;
  final AppThemeColors colors;
  final ClockBuilder? customClockBuilder;
  final BackgroundBuilder? customBackgroundBuilder;
  final PreviewBackgroundBuilder? customPreviewBackgroundBuilder;
  final String fontFamily;
  final List<Shadow>? clockShadows;

  const AppTheme._({
    required this.id,
    required this.name,
    required this.category,
    required this.isPremium,
    required this.colors,
    required this.fontFamily,
    this.customClockBuilder,
    this.customBackgroundBuilder,
    this.customPreviewBackgroundBuilder,
    this.clockShadows,
  });

  factory AppTheme.blueprint({
    required AppThemeType id,
    required String name,
    required ThemeCategory category,
    required bool isPremium,
    required AppThemeColors colors,
    required String fontFamily,
    ClockBuilder? customClockBuilder,
    BackgroundBuilder? customBackgroundBuilder,
    PreviewBackgroundBuilder? customPreviewBackgroundBuilder,
    List<Shadow>? clockShadows,
  }) {
    return AppTheme._(
      id: id,
      name: name,
      category: category,
      isPremium: isPremium,
      colors: colors,
      fontFamily: fontFamily,
      customClockBuilder: customClockBuilder,
      customBackgroundBuilder: customBackgroundBuilder,
      customPreviewBackgroundBuilder: customPreviewBackgroundBuilder,
      clockShadows: clockShadows,
    );
  }

  Widget buildPreviewBackground(BuildContext context) {
    return customPreviewBackgroundBuilder?.call(context) ??
        ColoredBox(color: colors.backgroundColor);
  }
}

/// Theme definitions for each app theme.
class ThemeDefinitions {
  static final Map<AppThemeType, AppTheme> themes = {
    AppThemeType.void_: AppTheme.blueprint(
      id: AppThemeType.void_,
      name: 'Void',
      category: ThemeCategory.basic,
      isPremium: false,
      colors: basicThemes[AppThemeType.void_]!,
      fontFamily: 'Courier',
    ),
    AppThemeType.blueprint: AppTheme.blueprint(
      id: AppThemeType.blueprint,
      name: 'Blueprint',
      category: ThemeCategory.basic,
      isPremium: false,
      colors: basicThemes[AppThemeType.blueprint]!,
      fontFamily: 'Courier',
    ),
    AppThemeType.solarFlare: AppTheme.blueprint(
      id: AppThemeType.solarFlare,
      name: 'Solar Flare',
      category: ThemeCategory.basic,
      isPremium: false,
      colors: basicThemes[AppThemeType.solarFlare]!,
      fontFamily: 'Courier',
    ),
    AppThemeType.observer: AppTheme.blueprint(
      id: AppThemeType.observer,
      name: 'Observer',
      category: ThemeCategory.basic,
      isPremium: false,
      colors: basicThemes[AppThemeType.observer]!,
      fontFamily: 'monospace',
    ),
    AppThemeType.blueprintArchitectural: AppTheme.blueprint(
      id: AppThemeType.blueprintArchitectural,
      name: 'Blueprint Arch',
      category: ThemeCategory.premium,
      isPremium: true,
      colors:
          premium_themes.premiumThemes[AppThemeType.blueprintArchitectural]!,
      fontFamily: 'Courier',
      customBackgroundBuilder: (context, _) => IgnorePointer(
        child: CustomPaint(
          painter: premium_themes.BlueprintGridPainter(),
        ),
      ),
    ),
    AppThemeType.bauhaus1925: AppTheme.blueprint(
      id: AppThemeType.bauhaus1925,
      name: 'Bauhaus 1925',
      category: ThemeCategory.premium,
      isPremium: true,
      colors: premium_themes.premiumThemes[AppThemeType.bauhaus1925]!,
      fontFamily: 'Courier',
    ),
    AppThemeType.cartographer: AppTheme.blueprint(
      id: AppThemeType.cartographer,
      name: 'Cartographer',
      category: ThemeCategory.premium,
      isPremium: true,
      colors: premium_themes.premiumThemes[AppThemeType.cartographer]!,
      fontFamily: 'Courier',
    ),
    AppThemeType.horologicalInstrument: AppTheme.blueprint(
      id: AppThemeType.horologicalInstrument,
      name: 'Horological Instrument',
      category: ThemeCategory.skins,
      isPremium: true,
      colors: skin_themes.skinThemes[AppThemeType.horologicalInstrument]!,
      fontFamily: 'Courier',
      clockShadows: skin_themes.horologicalGlow(),
    ),
    AppThemeType.retroFlip: AppTheme.blueprint(
      id: AppThemeType.retroFlip,
      name: 'Retro Flip',
      category: ThemeCategory.skins,
      isPremium: true,
      colors: skin_themes.skinThemes[AppThemeType.retroFlip]!,
      fontFamily: 'Courier',
      customClockBuilder: (context, timeString) =>
          RetroFlipClock(timeString: _normalizeRetroFlipTime(timeString)),
    ),
  };

  static String _normalizeRetroFlipTime(String timeString) {
    final upper = timeString.toUpperCase();
    final match = RegExp(r'\d{2}:\d{2}:\d{2}').firstMatch(upper);
    return match?.group(0) ?? '00:00:00';
  }

  /// Get full app theme blueprint by type.
  static AppTheme getAppTheme(AppThemeType type) {
    return themes[type]!;
  }

  /// Get theme colors by type
  static AppThemeColors getTheme(AppThemeType type) {
    return getAppTheme(type).colors;
  }

  /// Get all available themes as a list for UI selection
  static List<AppThemeType> getAllThemes() =>
      themes.keys.toList(growable: false);

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
