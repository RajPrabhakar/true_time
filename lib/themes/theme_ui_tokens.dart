import 'package:flutter/material.dart';
import 'package:true_time/models/theme_types.dart';

extension ThemeUiTokens on AppThemeColors {
  bool get isLightBackground => backgroundColor.computeLuminance() > 0.45;

  Color highContrastOn(Color color) {
    return color.computeLuminance() > 0.45
        ? const Color(0xFF111111)
        : const Color(0xFFF6F6F6);
  }

  Color get surfaceColor {
    final overlayOpacity = isLightBackground ? 0.06 : 0.18;
    return Color.alphaBlend(
      secondaryTextColor.withValues(alpha: overlayOpacity),
      backgroundColor,
    );
  }

  Color get surfaceBorderColor {
    return secondaryTextColor.withValues(
        alpha: isLightBackground ? 0.28 : 0.42);
  }

  Color get dividerColor {
    return secondaryTextColor.withValues(alpha: isLightBackground ? 0.24 : 0.2);
  }

  Color get mutedTextColor {
    return secondaryTextColor.withValues(
        alpha: isLightBackground ? 0.88 : 0.92);
  }

  Color get lockOverlayColor {
    return Color.alphaBlend(
      secondaryTextColor.withValues(alpha: isLightBackground ? 0.22 : 0.26),
      backgroundColor,
    );
  }

  Color get lockBorderColor {
    return highContrastOn(lockOverlayColor).withValues(alpha: 0.45);
  }

  Color get lockIconColor {
    return highContrastOn(lockOverlayColor);
  }

  Color get successColor {
    return Color.lerp(accentColor, textColor, isLightBackground ? 0.4 : 0.2) ??
        accentColor;
  }

  Color get neutralSnackbarColor {
    return Color.alphaBlend(
      secondaryTextColor.withValues(alpha: isLightBackground ? 0.16 : 0.28),
      backgroundColor,
    );
  }
}
