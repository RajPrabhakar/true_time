import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';

class ThemeMenuHeader extends StatelessWidget {
  final bool compact;
  final AppThemeColors themeColors;
  final bool is24HourMode;
  final ValueChanged<bool> on24HourModeChanged;

  const ThemeMenuHeader({
    super.key,
    required this.compact,
    required this.themeColors,
    required this.is24HourMode,
    required this.on24HourModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'BOUTIQUE GALLERY',
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: themeColors.textColor,
              letterSpacing: 2.0,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '24H',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.6,
                  color: themeColors.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Transform.scale(
                scale: compact ? 0.78 : 0.84,
                child: Switch.adaptive(
                  value: is24HourMode,
                  onChanged: on24HourModeChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeThumbColor: themeColors.accentColor,
                  activeTrackColor: themeColors.accentColor.withValues(alpha: 0.4),
                  inactiveThumbColor: themeColors.secondaryTextColor,
                  inactiveTrackColor:
                      themeColors.secondaryTextColor.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
