import 'package:flutter/material.dart';
import 'package:true_time/models/theme_types.dart';

const Map<AppThemeType, AppThemeColors> dynamicThemes = {
  AppThemeType.solarDynamic: AppThemeColors(
    name: 'Solar Dynamic',
    description: 'Time-Based: Sunrise to Sunset Colors',
    category: ThemeCategory.dynamic,
    backgroundColor: Color(0xFF000000),
    textColor: Color(0xFFFFFFFF),
    secondaryTextColor: Color(0xFF808080),
    accentColor: Color(0xFF00CCFF),
  ),
  AppThemeType.solarDrift: AppThemeColors(
    name: 'Solar Drift',
    description: 'Ambient: Breathing with the Planet',
    category: ThemeCategory.dynamic,
    backgroundColor: Color(0xFF001122),
    textColor: Color(0xFFFFFFFF),
    secondaryTextColor: Color(0xFFAAAAAA),
    accentColor: Color(0xFF00DDFF),
  ),
  AppThemeType.zenith: AppThemeColors(
    name: 'Zenith',
    description: 'Atmospheric: Indigo Gradient Field',
    category: ThemeCategory.dynamic,
    backgroundColor: Color(0xFF15143D),
    textColor: Color(0xFFE9ECFF),
    secondaryTextColor: Color(0xFFB9BEDF),
    accentColor: Color(0xFF7FA7FF),
  ),
};

LinearGradient zenithGradient({required bool isSolarMode}) {
  return LinearGradient(
    begin: isSolarMode ? Alignment.topLeft : Alignment.bottomCenter,
    end: isSolarMode ? Alignment.bottomRight : Alignment.topCenter,
    colors: const [
      Color(0xFF0B102B),
      Color(0xFF1C1A52),
      Color(0xFF2A2478),
    ],
    stops: const [0.0, 0.45, 1.0],
  );
}

Color backgroundColorForSolarDynamic(DateTime localMeanTime) {
  final hour = localMeanTime.hour;
  final minute = localMeanTime.minute;
  final timeInMinutes = hour * 60 + minute;

  const int civilTwilightDawnStart = 5 * 60;
  const int civilTwilightDawnEnd = 6 * 60;
  const int solarNoonStart = 11 * 60;
  const int solarNoonEnd = 13 * 60;
  const int civilTwilightDuskStart = 18 * 60;
  const int civilTwilightDuskEnd = 19 * 60;
  const int nightStart = 20 * 60;

  if (timeInMinutes >= nightStart || timeInMinutes < civilTwilightDawnStart) {
    return const Color(0xFF000000);
  }

  if (timeInMinutes >= civilTwilightDawnStart &&
      timeInMinutes < civilTwilightDawnEnd) {
    final progress = (timeInMinutes - civilTwilightDawnStart) /
        (civilTwilightDawnEnd - civilTwilightDawnStart);
    return Color.lerp(
      const Color(0xFF000015),
      const Color(0xFF000025),
      progress,
    )!;
  }

  if (timeInMinutes >= civilTwilightDawnEnd &&
      timeInMinutes < solarNoonStart) {
    final progress = (timeInMinutes - civilTwilightDawnEnd) /
        (solarNoonStart - civilTwilightDawnEnd);
    return Color.lerp(
      const Color(0xFF000025),
      const Color(0xFF121212),
      progress,
    )!;
  }

  if (timeInMinutes >= solarNoonStart && timeInMinutes < solarNoonEnd) {
    return const Color(0xFF121212);
  }

  if (timeInMinutes >= solarNoonEnd &&
      timeInMinutes < civilTwilightDuskStart) {
    final progress = (timeInMinutes - solarNoonEnd) /
        (civilTwilightDuskStart - solarNoonEnd);
    return Color.lerp(
      const Color(0xFF121212),
      const Color(0xFF000025),
      progress,
    )!;
  }

  if (timeInMinutes >= civilTwilightDuskStart &&
      timeInMinutes < civilTwilightDuskEnd) {
    final progress = (timeInMinutes - civilTwilightDuskStart) /
        (civilTwilightDuskEnd - civilTwilightDuskStart);
    return Color.lerp(
      const Color(0xFF000025),
      const Color(0xFF000015),
      progress,
    )!;
  }

  if (timeInMinutes >= civilTwilightDuskEnd && timeInMinutes < nightStart) {
    final progress =
        (timeInMinutes - civilTwilightDuskEnd) / (nightStart - civilTwilightDuskEnd);
    return Color.lerp(
      const Color(0xFF000015),
      const Color(0xFF000000),
      progress,
    )!;
  }

  return const Color(0xFF000000);
}

Color accentColorForSolarDynamic(Color backgroundColor) {
  final luminance = backgroundColor.computeLuminance();
  if (luminance < 0.2) {
    return const Color(0xFF00CCFF);
  }
  return const Color(0xFFFF8800);
}

Color backgroundColorForSolarDrift(DateTime localMeanTime) {
  final hour = localMeanTime.hour;
  final minute = localMeanTime.minute;
  final timeInMinutes = hour * 60 + minute;

  const int noonStart = 11 * 60;
  const int noonEnd = 13 * 60;
  const int sunsetStart = 17 * 60;
  const int sunsetEnd = 19 * 60;

  if (timeInMinutes >= 5 * 60 && timeInMinutes < noonStart) {
    final progress = (timeInMinutes - 5 * 60) / (noonStart - 5 * 60);
    return Color.lerp(
      const Color(0xFF000033),
      const Color(0xFF001122),
      progress,
    )!;
  }

  if (timeInMinutes >= noonStart && timeInMinutes < noonEnd) {
    return const Color(0xFF001122);
  }

  if (timeInMinutes >= noonEnd && timeInMinutes < sunsetStart) {
    final progress = (timeInMinutes - noonEnd) / (sunsetStart - noonEnd);
    return Color.lerp(
      const Color(0xFF001122),
      const Color(0xFF0A0015),
      progress,
    )!;
  }

  if (timeInMinutes >= sunsetStart && timeInMinutes < sunsetEnd) {
    final progress = (timeInMinutes - sunsetStart) / (sunsetEnd - sunsetStart);
    return Color.lerp(
      const Color(0xFF0A0015),
      const Color(0xFF1A0033),
      progress,
    )!;
  }

  return const Color(0xFF000000);
}
