import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/services/theme_service.dart';

/// Provider that manages the app's theme selection and persists it.
class ThemeProvider extends ChangeNotifier {
  final ThemeService _themeService;

  AppThemeType _currentTheme;
  AppThemeType? _previewTheme;
  bool _hasPro;
  bool _isInitialized = false;

  ThemeProvider({
    required ThemeService themeService,
    AppThemeType initialTheme = AppThemeType.void_,
    bool initialHasPro = false,
  })  : _themeService = themeService,
        _currentTheme = initialTheme,
        _hasPro = initialHasPro;

  static AppThemeType? themeFromId(String? id) {
    if (id == null) {
      return null;
    }
    try {
      return AppThemeType.values.firstWhere(
        (theme) => theme.toString().split('.').last == id,
      );
    } catch (_) {
      return null;
    }
  }

  AppThemeType get currentTheme => _currentTheme;
  AppThemeType get activeTheme => _previewTheme ?? _currentTheme;
  bool get isPreviewingTheme => _previewTheme != null;
  bool get hasPro => _hasPro;
  bool get isInitialized => _isInitialized;

  /// Initialize the theme provider by loading saved preference
  Future<void> initialize() async {
    await _themeService.initialize();

    final savedTheme = themeFromId(_themeService.getSavedThemeId());
    _currentTheme = savedTheme ?? _currentTheme;
    _hasPro = _themeService.isProUnlocked();

    _isInitialized = true;
    notifyListeners();
  }

  /// Change the current theme and save to persistent storage
  Future<void> setTheme(AppThemeType theme) async {
    _currentTheme = theme;
    _previewTheme = null;
    final themeId = theme.toString().split('.').last;
    await _themeService.saveThemeId(themeId);
    notifyListeners();
  }

  Future<void> setProUnlocked(bool value) async {
    _hasPro = value;
    await _themeService.setProUnlocked(value);
    notifyListeners();
  }

  /// Temporarily previews a theme without persisting it.
  void previewTheme(AppThemeType theme) {
    if (_previewTheme == theme) {
      return;
    }
    _previewTheme = theme;
    notifyListeners();
  }

  /// Clears the temporary theme preview and returns to persisted theme.
  void clearThemePreview() {
    if (_previewTheme == null) {
      return;
    }
    _previewTheme = null;
    notifyListeners();
  }

  /// Get the colors for the current theme
  /// For Solar Dynamic and Solar Drift themes, pass [localMeanTime] to calculate dynamic colors
  AppThemeColors getCurrentThemeColors({DateTime? localMeanTime}) {
    final theme = activeTheme;

    if (theme == AppThemeType.solarDynamic && localMeanTime != null) {
      // For Solar Dynamic, calculate colors based on time of day
      final bgColor =
          ThemeDefinitions.getBackgroundColorForSolarDynamic(localMeanTime);
      final accentColor =
          ThemeDefinitions.getAccentColorForSolarDynamic(bgColor);

      return AppThemeColors(
        name: 'Solar Dynamic',
        description: 'Time-Based: Sunrise to Sunset Colors',
        backgroundColor: bgColor,
        textColor: const Color(0xFFFFFFFF), // Always white text
        secondaryTextColor: const Color(0xFF808080), // Always muted gray
        accentColor: accentColor,
      );
    }

    if (theme == AppThemeType.solarDrift && localMeanTime != null) {
      // For Solar Drift, calculate colors based on solar hour angle
      final bgColor =
          ThemeDefinitions.getBackgroundColorForSolarDrift(localMeanTime);

      return AppThemeColors(
        name: 'Solar Drift',
        description: 'Ambient: Breathing with the Planet',
        backgroundColor: bgColor,
        textColor: const Color(0xFFFFFFFF), // Always white text
        secondaryTextColor: const Color(0xFFAAAAAA), // Light gray
        accentColor: const Color(0xFF00DDFF), // Cyan accent
      );
    }

    return ThemeDefinitions.getTheme(theme);
  }
}
