import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:true_time/models/app_theme.dart';

/// Provider that manages the app's theme selection and persists it.
class ThemeProvider extends ChangeNotifier {
  static const String _themeStorageKey = 'app_theme';

  late AppThemeType _currentTheme;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  AppThemeType get currentTheme => _currentTheme;
  bool get isInitialized => _isInitialized;

  /// Initialize the theme provider by loading saved preference
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    final savedThemeName = _prefs.getString(_themeStorageKey);
    if (savedThemeName != null) {
      try {
        _currentTheme = AppThemeType.values.firstWhere(
          (theme) => theme.toString() == 'AppThemeType.$savedThemeName',
        );
      } catch (_) {
        // Fallback to default if saved theme is invalid
        _currentTheme = AppThemeType.void_;
      }
    } else {
      _currentTheme = AppThemeType.void_;
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Change the current theme and save to persistent storage
  Future<void> setTheme(AppThemeType theme) async {
    _currentTheme = theme;
    final themeName = theme.toString().split('.').last;
    await _prefs.setString(_themeStorageKey, themeName);
    notifyListeners();
  }

  /// Get the colors for the current theme
  /// For Solar Dynamic and Solar Drift themes, pass [localMeanTime] to calculate dynamic colors
  AppThemeColors getCurrentThemeColors({DateTime? localMeanTime}) {
    if (_currentTheme == AppThemeType.solarDynamic && localMeanTime != null) {
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

    if (_currentTheme == AppThemeType.solarDrift && localMeanTime != null) {
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

    return ThemeDefinitions.getTheme(_currentTheme);
  }
}
