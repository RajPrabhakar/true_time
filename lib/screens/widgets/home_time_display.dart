import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/screens/utils/delta_formatter.dart';

class HomeTimeDisplay extends StatelessWidget {
  final dynamic result;
  final AppThemeColors themeColors;
  final bool isSolarMode;
  final VoidCallback onToggleMode;

  const HomeTimeDisplay({
    super.key,
    required this.result,
    required this.themeColors,
    required this.isSolarMode,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    final localTime = result.localMeanTime as DateTime;
    final politicalTime = DateTime.now();
    final displayedTime = isSolarMode ? localTime : politicalTime;
    final Duration utcDelta = result.utcDelta;
    final Duration tzDelta = result.tzDelta;

    final timeString =
        '${displayedTime.hour.toString().padLeft(2, '0')}:${displayedTime.minute.toString().padLeft(2, '0')}:${displayedTime.second.toString().padLeft(2, '0')}';

    final utcDeltaString = formatDelta(utcDelta, timeZoneLabel: 'UTC');
    final tzDeltaString = formatDelta(tzDelta);

    final isHorological = themeColors.name == 'Horological Instrument';
    final displayedTimeColor =
        isSolarMode ? Colors.white : const Color(0xFFA0A0A0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: GestureDetector(
              onTap: onToggleMode,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  key: ValueKey(isSolarMode ? 'solar-mode' : 'political-mode'),
                  timeString,
                  style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.w300,
                    color: displayedTimeColor,
                    fontFamily: 'Courier',
                    letterSpacing: 2.0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    shadows: isHorological
                        ? ThemeDefinitions.getHorologicalGlow()
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'UTC Delta: $utcDeltaString',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: themeColors.secondaryTextColor,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'TZ Delta: $tzDeltaString',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: themeColors.secondaryTextColor,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
