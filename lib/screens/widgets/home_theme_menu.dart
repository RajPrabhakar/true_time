import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/providers/theme_provider.dart';

class HomeThemeMenu extends StatelessWidget {
  final ThemeProvider themeProvider;
  final AppThemeColors themeColors;
  final VoidCallback onThemeSelected;

  const HomeThemeMenu({
    super.key,
    required this.themeProvider,
    required this.themeColors,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Theme',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: themeColors.textColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ...ThemeDefinitions.getAllThemes().map((theme) {
              final colors = ThemeDefinitions.getTheme(theme);
              final isActive = themeProvider.currentTheme == theme;

              return ThemeMenuRow(
                colors: colors,
                isActive: isActive,
                textColor: themeColors.textColor,
                secondaryTextColor: themeColors.secondaryTextColor,
                onTap: () {
                  themeProvider.setTheme(theme);
                  onThemeSelected();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ThemeMenuRow extends StatelessWidget {
  final AppThemeColors colors;
  final bool isActive;
  final Color textColor;
  final Color secondaryTextColor;
  final VoidCallback onTap;

  const ThemeMenuRow({
    super.key,
    required this.colors,
    required this.isActive,
    required this.textColor,
    required this.secondaryTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? colors.textColor : secondaryTextColor,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colors.backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: colors.textColor, width: 1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    colors.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w500 : FontWeight.w300,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    colors.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              Icon(
                Icons.check_circle,
                color: colors.textColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
