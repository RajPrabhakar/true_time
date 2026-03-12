import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/providers/theme_provider.dart';
import 'package:true_time/providers/true_time_provider.dart';
import 'package:true_time/screens/widgets/home_screen_parts/home_theme_upgrade_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static final Uri _privacyPolicyUrl =
      Uri.parse('https://stellorah.com/privacy');
  static final Uri _supportEmailUri = Uri.parse('mailto:support@stellorah.com');

  @override
  Widget build(BuildContext context) {
    final voidThemeFont =
        ThemeDefinitions.getAppTheme(AppThemeType.void_).fontFamily;

    return Consumer2<TrueTimeProvider, ThemeProvider>(
      builder: (context, trueTimeProvider, themeProvider, _) {
        final localMeanTime = trueTimeProvider.currentTimeResult?.localMeanTime;
        final themeColors =
            themeProvider.getCurrentThemeColors(localMeanTime: localMeanTime);

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontFamily: voidThemeFont,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SectionHeader(
                  label: 'Time & Physics',
                  fontFamily: voidThemeFont,
                ),
                const SizedBox(height: 8),
                _SettingsGroup(
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      value: trueTimeProvider.is24HourMode,
                      activeThumbColor: themeColors.accentColor,
                      activeTrackColor:
                          themeColors.accentColor.withValues(alpha: 0.45),
                      title: const Text(
                        '12/24 Hour Toggle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: const Text(
                        'Use 24-hour solar time format',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        trueTimeProvider.set24HourMode(value);
                      },
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      title: const Text(
                        'Location Accuracy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        _formatCoordinates(
                          trueTimeProvider.latitude,
                          trueTimeProvider.longitude,
                        ),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  label: 'Boutique Store',
                  fontFamily: voidThemeFont,
                ),
                const SizedBox(height: 8),
                _SettingsGroup(
                  children: [
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      leading: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Restore Purchases',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: const Text(
                        'Sync your previous Pro unlock',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      trailing: themeProvider.isRestoringPurchases
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white70,
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
                                    content: Text(message),
                                    backgroundColor: restored
                                        ? Colors.green.shade700
                                        : Colors.grey.shade900,
                                  ),
                                );
                            },
                    ),
                    if (!themeProvider.hasPro) ...[
                      const Divider(color: Colors.white12, height: 1),
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
                        title: const Text(
                          'Upgrade to Pro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: const Text(
                          'Unlock premium themes and experiences',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
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
                  fontFamily: voidThemeFont,
                ),
                const SizedBox(height: 8),
                _SettingsGroup(
                  children: [
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      title: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white70,
                      ),
                      onTap: () => _launchUri(context, _privacyPolicyUrl),
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      title: const Text(
                        'Contact Support',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white70,
                      ),
                      onTap: () => _launchUri(context, _supportEmailUri),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'v1.0.0 (Build 1)',
                    style: TextStyle(
                      color: Colors.white54,
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

  Future<void> _launchUri(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Unable to open link right now.'),
          ),
        );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final String fontFamily;

  const _SectionHeader({
    required this.label,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white60,
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

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white10,
          width: 1,
        ),
      ),
      child: Column(children: children),
    );
  }
}
