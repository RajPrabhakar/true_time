import 'package:flutter/material.dart';
import 'package:true_time/models/theme_types.dart';

const Map<AppThemeType, AppThemeColors> skinThemes = {
  AppThemeType.horologicalInstrument: AppThemeColors(
    name: 'Horological Instrument',
    description: 'Vintage Tech: Amber Glow Display',
    category: ThemeCategory.skins,
    backgroundColor: Color(0xFF000000),
    textColor: Color(0xFFFFBF00),
    secondaryTextColor: Color(0xFF664400),
    accentColor: Color(0xFFFFBF00),
  ),
  AppThemeType.retroFlip: AppThemeColors(
    name: 'Retro Flip',
    description: 'Mechanical: Split-Flap Clock Aesthetic',
    category: ThemeCategory.skins,
    backgroundColor: Color(0xFF0E0E0E),
    textColor: Color(0xFFE0E0E0),
    secondaryTextColor: Color(0xFFAFAFAF),
    accentColor: Color(0xFF8B8B8B),
  ),
  AppThemeType.neonTokyo: AppThemeColors(
    name: 'Neon Tokyo',
    description: 'Cyberpunk: Glitch Clock & Neon Grid',
    category: ThemeCategory.skins,
    backgroundColor: Color(0xFF0A0A0A),
    textColor: Color(0xFFFF0055),
    secondaryTextColor: Color(0xFF8A0030),
    accentColor: Color(0xFF00FFCC),
  ),
};

List<Shadow> horologicalGlow() {
  return const [
    Shadow(
      color: Color(0xFFFFBF00),
      blurRadius: 10,
      offset: Offset(0, 0),
    ),
    Shadow(
      color: Color(0xFFFFBF00),
      blurRadius: 20,
      offset: Offset(0, 0),
    ),
  ];
}
