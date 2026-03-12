import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/models/local_time_result.dart';
import 'package:true_time/providers/true_time_provider.dart';
import 'package:true_time/screens/widgets/home_screen_parts/home_status_panels.dart';
// import 'package:true_time/screens/utils/delta_formatter.dart';
import 'package:true_time/screens/widgets/retro_flip_clock.dart';

/// Captures only the time-related state that [HomeTimeDisplay] needs.
/// Equality is second-level: the clock rebuilds once per tick and no more.
@immutable
class _ClockData {
  final LocalTimeResult? result;
  final bool isLoading;
  final String? error;
  final bool is24HourMode;

  const _ClockData({
    this.result,
    required this.isLoading,
    this.error,
    required this.is24HourMode,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _ClockData) return false;
    return isLoading == other.isLoading &&
        error == other.error &&
        is24HourMode == other.is24HourMode &&
        result?.localMeanTime == other.result?.localMeanTime;
  }

  @override
  int get hashCode =>
      Object.hash(isLoading, error, is24HourMode, result?.localMeanTime);
}

class HomeTimeDisplay extends StatelessWidget {
  final AppThemeColors themeColors;
  final AppThemeType currentTheme;
  final bool isSolarMode;
  final bool showSecondaryUi;
  final VoidCallback onToggleMode;

  const HomeTimeDisplay({
    super.key,
    required this.themeColors,
    required this.currentTheme,
    required this.isSolarMode,
    required this.showSecondaryUi,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<TrueTimeProvider, _ClockData>(
      selector: (_, p) => _ClockData(
        result: p.currentTimeResult,
        isLoading: p.isLoading,
        error: p.error,
        is24HourMode: p.is24HourMode,
      ),
      builder: (context, clockData, __) {
        if (clockData.isLoading) {
          return HomeLoadingIndicator(themeColors: themeColors);
        }
        if (clockData.error != null) {
          return HomeErrorState(
            error: clockData.error!,
            themeColors: themeColors,
          );
        }
        final result = clockData.result;
        if (result == null) {
          return HomeLoadingIndicator(themeColors: themeColors);
        }

        final localTime = result.localMeanTime;
        final politicalTime = DateTime.now();
        final displayedTime = isSolarMode ? localTime : politicalTime;
        // final Duration utcDelta = result.utcDelta;
        // final Duration tzDelta = result.tzDelta;

        final formatter = DateFormat(
          clockData.is24HourMode ? 'HH:mm:ss' : 'hh:mm:ss a',
        );
        final timeString = formatter.format(displayedTime);

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
      },
    );
  }
}
