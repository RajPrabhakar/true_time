import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/screens/widgets/home_support_widgets.dart';

class HomeLoadingIndicator extends StatelessWidget {
  final AppThemeColors themeColors;

  const HomeLoadingIndicator({
    super.key,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedDots(accentColor: themeColors.accentColor),
        const SizedBox(height: 24),
        Text(
          'Acquiring GPS Lock...',
          style: TextStyle(
            fontSize: 14,
            color: themeColors.secondaryTextColor,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class HomeErrorState extends StatelessWidget {
  final String error;
  final AppThemeColors themeColors;

  const HomeErrorState({
    super.key,
    required this.error,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ERROR',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: themeColors.accentColor,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 300,
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: themeColors.secondaryTextColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
