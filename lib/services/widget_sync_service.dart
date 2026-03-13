import 'dart:ui';

import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/services/widget_snapshot_renderer.dart';

/// Bridges Flutter theme colors to native home screen widgets.
class WidgetSyncService {
  static const String _appGroupId = 'group.com.stellorah.truetime';
  static const String bgHexKey = 'bgHex';
  static const String textHexKey = 'textHex';
  static const String fontFamilyKey = 'widgetFontFamily';
  static const String clockStyleKey = 'widgetClockStyle';
  static const String snapshotPathKey = 'widgetSnapshotPath';
  static const String snapshotThemeKey = 'widgetThemeId';
  static const String snapshotTimeKey = 'widgetTimeString';
  static const String snapshot24HourKey = 'widgetIs24HourMode';
  static const String snapshotSolarModeKey = 'widgetIsSolarMode';
  static const String snapshotRenderVersionKey = 'widgetRenderVersion';
  static const String _androidWidgetName = 'TrueTimeWidgetProvider';
  static const String _iosWidgetKind = 'TrueTimeWidget';
  static const int _renderVersion = 1;

  final WidgetSnapshotRenderer _snapshotRenderer;

  WidgetSyncService({WidgetSnapshotRenderer? snapshotRenderer})
      : _snapshotRenderer = snapshotRenderer ?? WidgetSnapshotRenderer();

  Future<void> updateWidgetTheme(
    String bgHex,
    String textHex,
    String fontFamily,
    String clockStyle,
  ) async {
    await _prepareSharedStore();
    await HomeWidget.saveWidgetData<String>(bgHexKey, bgHex);
    await HomeWidget.saveWidgetData<String>(textHexKey, textHex);
    await HomeWidget.saveWidgetData<String>(fontFamilyKey, fontFamily);
    await HomeWidget.saveWidgetData<String>(clockStyleKey, clockStyle);
    await _requestWidgetRefresh();
  }

  Future<void> updateWidgetSnapshot({
    required AppThemeType themeType,
    required DateTime displayedTime,
    required bool is24HourMode,
    required bool isSolarMode,
    required String bgHex,
    required String textHex,
    required String fontFamily,
    required String clockStyle,
  }) async {
    await _prepareSharedStore();

    await HomeWidget.saveWidgetData<String>(bgHexKey, bgHex);
    await HomeWidget.saveWidgetData<String>(textHexKey, textHex);
    await HomeWidget.saveWidgetData<String>(fontFamilyKey, fontFamily);
    await HomeWidget.saveWidgetData<String>(clockStyleKey, clockStyle);

    final formatter = DateFormat(is24HourMode ? 'HH:mm:ss' : 'hh:mm:ss a');
    final snapshotPath = await _snapshotRenderer.renderSnapshot(
      themeType: themeType,
      displayedTime: displayedTime,
      is24HourMode: is24HourMode,
      isSolarMode: isSolarMode,
      storageKey: snapshotPathKey,
    );

    await HomeWidget.saveWidgetData<String>(snapshotThemeKey, themeType.name);
    await HomeWidget.saveWidgetData<String>(
      snapshotTimeKey,
      formatter.format(displayedTime),
    );
    await HomeWidget.saveWidgetData<bool>(snapshot24HourKey, is24HourMode);
    await HomeWidget.saveWidgetData<bool>(snapshotSolarModeKey, isSolarMode);
    await HomeWidget.saveWidgetData<int>(snapshotRenderVersionKey, _renderVersion);

    if (snapshotPath != null) {
      await HomeWidget.saveWidgetData<String>(snapshotPathKey, snapshotPath);
    }

    await _requestWidgetRefresh();
  }

  Future<void> _prepareSharedStore() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  Future<void> _requestWidgetRefresh() async {
    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      iOSName: _iosWidgetKind,
    );
  }

  String colorToHex(Color color) {
    final rgb = color.toARGB32() & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
