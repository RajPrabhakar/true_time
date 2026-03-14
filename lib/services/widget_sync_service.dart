import 'dart:ui';

import 'package:home_widget/home_widget.dart';

/// Bridges Flutter theme colors to native home screen widgets.
class WidgetSyncService {
  static const String _appGroupId = 'group.com.stellorah.truetime';
  static const String bgHexKey = 'bgHex';
  static const String textHexKey = 'textHex';
  static const String fontFamilyKey = 'widgetFontFamily';
  static const String clockStyleKey = 'widgetClockStyle';
  static const String is24HourModeKey = 'widgetIs24HourMode';
  static const String _androidWidgetName = 'TrueTimeWidgetProvider';
  static const String _iosWidgetKind = 'TrueTimeWidget';

  WidgetSyncService();

  Future<void> updateWidgetTheme(
      String bgHex, String textHex, String fontFamily, String clockStyle,
      {bool? is24HourMode}) async {
    await _prepareSharedStore();
    await HomeWidget.saveWidgetData<String>(bgHexKey, bgHex);
    await HomeWidget.saveWidgetData<String>(textHexKey, textHex);
    await HomeWidget.saveWidgetData<String>(fontFamilyKey, fontFamily);
    await HomeWidget.saveWidgetData<String>(clockStyleKey, clockStyle);
    if (is24HourMode != null) {
      await HomeWidget.saveWidgetData<bool>(is24HourModeKey, is24HourMode);
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
