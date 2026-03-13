import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:true_time/models/app_theme.dart';

class WidgetSnapshotRenderer {
  static const Size defaultLogicalSize = Size(720, 360);

  Future<String?> renderSnapshot({
    required AppThemeType themeType,
    required DateTime displayedTime,
    required bool is24HourMode,
    required bool isSolarMode,
    required String storageKey,
  }) async {
    final appTheme = ThemeDefinitions.getAppTheme(themeType);
    final colors = appTheme.colors;
    final formatter = DateFormat(is24HourMode ? 'HH:mm:ss' : 'hh:mm:ss a');
    final timeString = formatter.format(displayedTime);

    final renderedPath = await HomeWidget.renderFlutterWidget(
      _WidgetSnapshotView(
        appTheme: appTheme,
        displayedTime: displayedTime,
        displayedTimeColor:
            isSolarMode ? colors.textColor : colors.secondaryTextColor,
        timeString: timeString,
      ),
      key: storageKey,
      logicalSize: defaultLogicalSize,
    );

    if (renderedPath.isNotEmpty) {
      return renderedPath;
    }

    return null;
  }
}

class _WidgetSnapshotView extends StatelessWidget {
  final AppTheme appTheme;
  final DateTime displayedTime;
  final String timeString;
  final Color displayedTimeColor;

  const _WidgetSnapshotView({
    required this.appTheme,
    required this.displayedTime,
    required this.timeString,
    required this.displayedTimeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: appTheme.colors.backgroundColor,
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (appTheme.customBackgroundBuilder != null)
              appTheme.customBackgroundBuilder!(context, displayedTime),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: appTheme.customClockBuilder != null
                    ? appTheme.customClockBuilder!(context, timeString)
                    : _DefaultSnapshotClock(
                        timeString: timeString,
                        appTheme: appTheme,
                        displayedTimeColor: displayedTimeColor,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultSnapshotClock extends StatelessWidget {
  final String timeString;
  final AppTheme appTheme;
  final Color displayedTimeColor;

  const _DefaultSnapshotClock({
    required this.timeString,
    required this.appTheme,
    required this.displayedTimeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isMonospace = appTheme.fontFamily == 'monospace';
    final letterSpacingValue = isMonospace ? 4.0 : 2.0;

    return Padding(
      padding: EdgeInsets.only(left: letterSpacingValue),
      child: Text(
        timeString,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 108,
          fontWeight: isMonospace ? FontWeight.w500 : FontWeight.w300,
          color: displayedTimeColor,
          fontFamily: appTheme.fontFamily,
          letterSpacing: letterSpacingValue,
          height: 1.0,
          leadingDistribution: TextLeadingDistribution.even,
          fontFeatures: const [FontFeature.tabularFigures()],
          shadows: appTheme.clockShadows,
        ),
      ),
    );
  }
}