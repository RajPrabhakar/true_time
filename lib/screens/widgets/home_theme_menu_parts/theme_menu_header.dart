import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';

class ThemeMenuHeader extends StatelessWidget {
  final bool compact;
  final AppThemeColors themeColors;

  const ThemeMenuHeader({
    super.key,
    required this.compact,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
        ],
      ),
    );
  }
}
