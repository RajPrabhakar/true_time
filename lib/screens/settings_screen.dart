import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/providers/theme_provider.dart';
import 'package:true_time/providers/true_time_provider.dart';
import 'package:true_time/screens/widgets/home_screen_parts/home_theme_upgrade_sheet.dart';
import 'package:true_time/themes/theme_ui_tokens.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static final Uri _privacyPolicyUrl =
      Uri.parse('https://stellorah.com/privacy');
  static final Uri _supportEmailUri = Uri.parse('mailto:support@stellorah.com');

  @override
  Widget build(BuildContext context) {
    return Consumer2<TrueTimeProvider, ThemeProvider>(
      builder: (context, trueTimeProvider, themeProvider, _) {
        final localMeanTime = trueTimeProvider.currentTimeResult?.localMeanTime;
        final themeColors =
            themeProvider.getCurrentThemeColors(localMeanTime: localMeanTime);
        final activeTheme =
            ThemeDefinitions.getAppTheme(themeProvider.activeTheme);
        final titleColor = themeColors.textColor;
        final subtitleColor = themeColors.mutedTextColor;
        final sectionFont = activeTheme.fontFamily;

        return Scaffold(
          backgroundColor: themeColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: themeColors.backgroundColor,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Settings',
              style: TextStyle(
                color: titleColor,
                fontFamily: sectionFont,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            iconTheme: IconThemeData(color: titleColor),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SectionHeader(
                  label: 'Time & Physics',
                  fontFamily: sectionFont,
                  themeColors: themeColors,
                ),
                const SizedBox(height: 8),
                _SettingsGroup(
                  themeColors: themeColors,
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      value: trueTimeProvider.is24HourMode,
                      activeThumbColor: themeColors.accentColor,
                      activeTrackColor:
                          themeColors.accentColor.withValues(alpha: 0.45),
                      title: Text(
                        '12/24 Hour Toggle',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Use 24-hour solar time format',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        trueTimeProvider.set24HourMode(value);
                      },
                    ),
                    Divider(color: themeColors.dividerColor, height: 1),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      title: Text(
                        'Location Accuracy',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        _formatCoordinates(
                          trueTimeProvider.latitude,
                          trueTimeProvider.longitude,
                        ),
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  label: 'Boutique Store',
                  fontFamily: sectionFont,
                  themeColors: themeColors,
                ),
                const SizedBox(height: 8),
                _SettingsGroup(
                  themeColors: themeColors,
                  children: [
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      leading: Icon(
                        Icons.refresh_rounded,
                        color: titleColor,
                      ),
                      title: Text(
                        'Restore Purchases',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Sync your previous Pro unlock',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                      trailing: themeProvider.isRestoringPurchases
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: titleColor,
                              ),
                            )
                          : Icon(
                              Icons.chevron_right_rounded,
                              color: subtitleColor,
                            ),
                      onTap: themeProvider.isRestoringPurchases
                          ? null
                          : () async {
                              final restored =
                                  await themeProvider.restorePurchases();
                              if (!context.mounted) {
                                return;
                              }

                              final message = restored
                                  ? 'Purchases restored successfully.'
                                  : 'No purchases found';

                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      message,
                                      style: TextStyle(
                                        color: themeColors.highContrastOn(
                                          restored
                                              ? themeColors.successColor
                                              : themeColors
                                                  .neutralSnackbarColor,
                                        ),
                                      ),
                                    ),
                                    backgroundColor: restored
                                        ? themeColors.successColor
                                        : themeColors.neutralSnackbarColor,
                                  ),
                                );
                            },
                    ),
                    if (kDebugMode) ...[
                      Divider(color: themeColors.dividerColor, height: 1),
                      SwitchListTile.adaptive(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        value: themeProvider.hasPro,
                        activeThumbColor: themeColors.accentColor,
                        activeTrackColor:
                            themeColors.accentColor.withValues(alpha: 0.45),
                        title: Text(
                          'QA: Force Pro Unlock',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Debug only. Overrides Pro state for this install.',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 12,
                          ),
                        ),
                        onChanged: (value) async {
                          await themeProvider.setProUnlocked(value);
                          if (!context.mounted) {
                            return;
                          }

                          final backgroundColor = value
                              ? themeColors.successColor
                              : themeColors.neutralSnackbarColor;
                          final message = value
                              ? 'Pro unlocked for testing.'
                              : 'Pro relocked for testing.';

                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                backgroundColor: backgroundColor,
                                content: Text(
                                  message,
                                  style: TextStyle(
                                    color: themeColors.highContrastOn(
                                      backgroundColor,
                                    ),
                                  ),
                                ),
                              ),
                            );
                        },
                      ),
                    ],
                    if (!themeProvider.hasPro) ...[
                      Divider(color: themeColors.dividerColor, height: 1),
                      ListTile(
                        tileColor:
                            themeColors.accentColor.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        leading: Icon(
                          Icons.auto_awesome,
                          color: themeColors.accentColor,
                        ),
                        title: Text(
                          'Upgrade to Pro',
                          style: TextStyle(
                            color: themeColors.highContrastOn(
                              themeColors.accentColor.withValues(alpha: 0.2),
                            ),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(
                          'Unlock premium themes and experiences',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: titleColor,
                        ),
                        onTap: () {
                          showUpgradeToProSheet(
                            context,
                            lockedTheme: AppThemeType.blueprintArchitectural,
                            themeColors: themeColors,
                          );
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  label: 'Support & Legal',
                  fontFamily: sectionFont,
                  themeColors: themeColors,
                ),
                const SizedBox(height: 8),
                _SettingsGroup(
                  themeColors: themeColors,
                  children: [
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      title: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: subtitleColor,
                      ),
                      onTap: () => _launchUri(
                        context,
                        _privacyPolicyUrl,
                        themeColors: themeColors,
                      ),
                    ),
                    Divider(color: themeColors.dividerColor, height: 1),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      title: Text(
                        'Contact Support',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: subtitleColor,
                      ),
                      onTap: () => _launchUri(
                        context,
                        _supportEmailUri,
                        themeColors: themeColors,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'v1.0.0 (Build 1)',
                    style: TextStyle(
                      color:
                          themeColors.secondaryTextColor.withValues(alpha: 0.7),
                      fontSize: 12,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _formatCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return 'Acquiring GPS lock...';
    }

    return 'Lat ${latitude.toStringAsFixed(6)} | Long ${longitude.toStringAsFixed(6)}';
  }

  Future<void> _launchUri(
    BuildContext context,
    Uri uri, {
    required AppThemeColors themeColors,
  }) async {
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      final backgroundColor = themeColors.neutralSnackbarColor;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: backgroundColor,
            content: Text(
              'Unable to open link right now.',
              style: TextStyle(
                color: themeColors.highContrastOn(backgroundColor),
              ),
            ),
          ),
        );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final String fontFamily;
  final AppThemeColors themeColors;

  const _SectionHeader({
    required this.label,
    required this.fontFamily,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: fontFamily,
          color: themeColors.secondaryTextColor.withValues(alpha: 0.8),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final AppThemeColors themeColors;

  const _SettingsGroup({required this.children, required this.themeColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: themeColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: themeColors.surfaceBorderColor,
          width: 1,
        ),
      ),
      child: Column(children: children),
    );
  }
}
