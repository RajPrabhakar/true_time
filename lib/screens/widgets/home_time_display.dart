import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';
// import 'package:true_time/screens/utils/delta_formatter.dart';
import 'package:true_time/screens/widgets/retro_flip_clock.dart';

class HomeTimeDisplay extends StatelessWidget {
  final dynamic result;
  final AppThemeColors themeColors;
  final AppThemeType currentTheme;
  final bool isSolarMode;
  final bool showSecondaryUi;
  final VoidCallback onToggleMode;

  const HomeTimeDisplay({
    super.key,
    required this.result,
    required this.themeColors,
    required this.currentTheme,
    required this.isSolarMode,
    required this.showSecondaryUi,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    final localTime = result.localMeanTime as DateTime;
    final politicalTime = DateTime.now();
    final displayedTime = isSolarMode ? localTime : politicalTime;
    // final Duration utcDelta = result.utcDelta;
    // final Duration tzDelta = result.tzDelta;

    final timeString =
        '${displayedTime.hour.toString().padLeft(2, '0')}:${displayedTime.minute.toString().padLeft(2, '0')}:${displayedTime.second.toString().padLeft(2, '0')}';

    // final utcDeltaString = formatDelta(utcDelta, timeZoneLabel: 'UTC');
    // final tzDeltaString = formatDelta(tzDelta);

    final isHorological = currentTheme == AppThemeType.horologicalInstrument;
    final isObserver = currentTheme == AppThemeType.observer;
    final isRetroFlip = currentTheme == AppThemeType.retroFlip;
    final letterSpacingValue = isObserver ? 4.0 : 2.0;
    final displayedTimeColor =
        isSolarMode ? themeColors.textColor : themeColors.secondaryTextColor;

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
                child: isRetroFlip
                    ? RetroFlipClock(
                        key: ValueKey(
                          'retro-flip-${isSolarMode ? 'solar' : 'political'}',
                        ),
                        displayedTime: displayedTime,
                        isSolarMode: isSolarMode,
                      )
                    : Padding(
                        padding: EdgeInsets.only(left: letterSpacingValue),
                        child: Text(
                          key: ValueKey(
                            isSolarMode ? 'solar-mode' : 'political-mode',
                          ),
                          timeString,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 120,
                            fontWeight:
                                isObserver ? FontWeight.w500 : FontWeight.w300,
                            color: displayedTimeColor,
                            fontFamily: isObserver ? 'monospace' : 'Courier',
                            letterSpacing: letterSpacingValue,
                            height: 1.0,
                            leadingDistribution: TextLeadingDistribution.even,
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
        ),
        // if (showSecondaryUi) ...[
        //   const SizedBox(height: 32),
        //   Text(
        //     'UTC Delta: $utcDeltaString',
        //     style: TextStyle(
        //       fontSize: 14,
        //       fontWeight: FontWeight.w300,
        //       color: themeColors.secondaryTextColor,
        //       letterSpacing: 1.2,
        //     ),
        //   ),
        //   const SizedBox(height: 8),
        //   Text(
        //     'TZ Delta: $tzDeltaString',
        //     style: TextStyle(
        //       fontSize: 14,
        //       fontWeight: FontWeight.w300,
        //       color: themeColors.secondaryTextColor,
        //       letterSpacing: 1.2,
        //     ),
        //   ),
        // ],
      ],
    );
  }
}
