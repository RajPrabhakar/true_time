import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/services/theme_service.dart';
import 'package:true_time/services/widget_sync_service.dart';

/// Provider that manages the app's theme selection and persists it.
class ThemeProvider extends ChangeNotifier {
  final ThemeService _themeService;
  final WidgetSyncService _widgetSyncService;

  AppThemeType _currentTheme;
  AppThemeType? _previewTheme;
  bool _hasPro;
  bool _isRestoringPurchases = false;
  bool _isInitialized = false;
  String? _lastWidgetSyncSignature;

  ThemeProvider({
    required ThemeService themeService,
    required WidgetSyncService widgetSyncService,
    AppThemeType initialTheme = AppThemeType.void_,
    bool initialHasPro = false,
  })  : _themeService = themeService,
        _widgetSyncService = widgetSyncService,
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
  bool get isRestoringPurchases => _isRestoringPurchases;
  bool get isInitialized => _isInitialized;

  /// Initialize the theme provider by loading saved preference
  Future<void> initialize() async {
    await _themeService.initialize();

    final savedTheme = themeFromId(_themeService.getSavedThemeId());
    _currentTheme = savedTheme ?? _currentTheme;
    _hasPro = _themeService.isProUnlocked();
    await _syncWidgetTheme();

    _isInitialized = true;
    notifyListeners();
  }

  /// Change the current theme and save to persistent storage
  Future<void> setTheme(AppThemeType theme) async {
    _currentTheme = theme;
    _previewTheme = null;
    final themeId = theme.toString().split('.').last;
    await _themeService.saveThemeId(themeId);
    await _syncWidgetTheme();
    notifyListeners();
  }

  Future<void> _syncWidgetTheme() async {
    final colors = getCurrentThemeColors(localMeanTime: DateTime.now());
    final bgHex = _widgetSyncService.colorToHex(colors.backgroundColor);
    final textHex = _widgetSyncService.colorToHex(colors.textColor);
    await _widgetSyncService.updateWidgetTheme(bgHex, textHex);
  }

  Future<void> syncWidgetSnapshot({
    required DateTime displayedTime,
    required bool is24HourMode,
    required bool isSolarMode,
  }) async {
    final active = activeTheme;
    final minuteBucket =
        '${displayedTime.year}-${displayedTime.month}-${displayedTime.day}-${displayedTime.hour}-${displayedTime.minute}';
    final signature =
        '${active.name}-$minuteBucket-$is24HourMode-$isSolarMode';

    if (_lastWidgetSyncSignature == signature) {
      return;
    }

    _lastWidgetSyncSignature = signature;
    final colors = getCurrentThemeColors(localMeanTime: displayedTime);
    final bgHex = _widgetSyncService.colorToHex(colors.backgroundColor);
    final textHex = _widgetSyncService.colorToHex(colors.textColor);

    await _widgetSyncService.updateWidgetSnapshot(
      themeType: active,
      displayedTime: displayedTime,
      is24HourMode: is24HourMode,
      isSolarMode: isSolarMode,
      bgHex: bgHex,
      textHex: textHex,
    );
  }

  Future<void> setProUnlocked(bool value) async {
    _hasPro = value;
    await _themeService.setProUnlocked(value);
    notifyListeners();
  }

  Future<bool> restorePurchases() async {
    if (_isRestoringPurchases) {
      return _hasPro;
    }

    _isRestoringPurchases = true;
    notifyListeners();

    try {
      final restored = await _themeService.restorePurchases();
      _hasPro = restored;
      return restored;
    } finally {
      _isRestoringPurchases = false;
      notifyListeners();
    }
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

  /// Get the colors for the current active theme.
  AppThemeColors getCurrentThemeColors({DateTime? localMeanTime}) {
    return ThemeDefinitions.getTheme(activeTheme);
  }
}
