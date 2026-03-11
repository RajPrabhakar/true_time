import 'dart:ui';

import 'package:home_widget/home_widget.dart';

/// Bridges Flutter theme colors to native home screen widgets.
class WidgetSyncService {
  static const String _appGroupId = 'group.com.stellorah.truetime';
  static const String _bgHexKey = 'bgHex';
  static const String _textHexKey = 'textHex';

  Future<void> updateWidgetTheme(String bgHex, String textHex) async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await HomeWidget.saveWidgetData<String>(_bgHexKey, bgHex);
    await HomeWidget.saveWidgetData<String>(_textHexKey, textHex);
    await HomeWidget.updateWidget(name: 'TrueTimeWidget');
  }

  String colorToHex(Color color) {
    final rgb = color.toARGB32() & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
