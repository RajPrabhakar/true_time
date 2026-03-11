import 'package:shared_preferences/shared_preferences.dart';

/// Persists and retrieves theme-related preferences.
class ThemeService {
  static const String themeIdKey = 'app_theme_id';
  static const String proUnlockedKey = 'isPro_user';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String? getSavedThemeId() {
    return _prefs?.getString(themeIdKey);
  }

  Future<void> saveThemeId(String themeId) async {
    await _prefs?.setString(themeIdKey, themeId);
  }

  bool isProUnlocked() {
    final prefs = _prefs;
    if (prefs == null) {
      return false;
    }
    final bool isPro = prefs.getBool(proUnlockedKey) ?? false;
    return isPro;
  }

  Future<void> setProUnlocked(bool value) async {
    await _prefs?.setBool(proUnlockedKey, value);
  }
}
