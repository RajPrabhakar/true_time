import 'package:flutter/material.dart';
import 'package:true_time/models/theme_types.dart';

const Map<AppThemeType, AppThemeColors> basicThemes = {
  AppThemeType.void_: AppThemeColors(
    name: 'Void',
    description: 'Default: Pure OLED Black',
    category: ThemeCategory.basic,
    backgroundColor: Color(0xFF000000),
    textColor: Color(0xFFFFFFFF),
    secondaryTextColor: Color(0xFF808080),
    accentColor: Color(0xFF00FF00),
  ),
  AppThemeType.blueprint: AppThemeColors(
    name: 'Blueprint',
    description: 'Technical: Deep Blue with Cyan',
    category: ThemeCategory.basic,
    backgroundColor: Color(0xFF001F3F),
    textColor: Color(0xFF00FFFF),
    secondaryTextColor: Color(0xFF0088CC),
    accentColor: Color(0xFF00FF00),
  ),
  AppThemeType.solarFlare: AppThemeColors(
    name: 'Solar Flare',
    description: 'High Visibility: White Background',
    category: ThemeCategory.basic,
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF000000),
    secondaryTextColor: Color(0xFF666666),
    accentColor: Color(0xFFFF6B00),
  ),
  AppThemeType.observer: AppThemeColors(
    name: 'Observer',
    description: 'Instrument: Red Segmented Display',
    category: ThemeCategory.basic,
    backgroundColor: Color(0xFF060606),
    textColor: Color(0xFFFF3B30),
    secondaryTextColor: Color(0xFF9A2A23),
    accentColor: Color(0xFFFF6B63),
  ),
};
