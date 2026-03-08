import 'package:flutter/foundation.dart';
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
  AppThemeColors getCurrentThemeColors() {
    return ThemeDefinitions.getTheme(_currentTheme);
  }
}
