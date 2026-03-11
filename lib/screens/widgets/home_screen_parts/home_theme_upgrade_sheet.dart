import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';

Future<void> showUpgradeToProSheet(
  BuildContext context, {
  required AppThemeType lockedTheme,
  required AppThemeColors themeColors,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: themeColors.backgroundColor.withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: themeColors.accentColor.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Unlock ${ThemeDefinitions.getTheme(lockedTheme).name}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: themeColors.textColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: themeColors.secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: themeColors.textColor,
                    foregroundColor: themeColors.backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Upgrade to Pro - ₹99',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• Unlock Premium, Dynamic, and Skin themes',
                style: TextStyle(
                  fontSize: 13,
                  color: themeColors.textColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Remove the 30-second preview limit',
                style: TextStyle(
                  fontSize: 13,
                  color: themeColors.textColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Support independent solar engineering.',
                style: TextStyle(
                  fontSize: 13,
                  color: themeColors.textColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
