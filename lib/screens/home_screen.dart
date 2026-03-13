import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/providers/theme_provider.dart';
import 'package:true_time/providers/true_time_provider.dart';
import 'package:true_time/screens/settings_screen.dart';
import 'package:true_time/screens/widgets/home_screen_parts/home_theme_upgrade_sheet.dart';
import 'package:true_time/screens/widgets/home_theme_menu.dart';
import 'package:true_time/screens/widgets/home_time_display.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Holds the time-related slice of [TrueTimeProvider] state that the scaffold
/// needs. Uses minute-level equality for [localMeanTime] so the scaffold only
/// rebuilds when the minute rolls over (for solar-dynamic theme colours) or
/// when [is24HourMode] is toggled — not on every clock tick.
@immutable
class _ScaffoldTimeData {
  final DateTime? localMeanTime;
  final bool is24HourMode;

  const _ScaffoldTimeData({
    this.localMeanTime,
    required this.is24HourMode,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _ScaffoldTimeData) return false;
    return is24HourMode == other.is24HourMode &&
        localMeanTime?.hour == other.localMeanTime?.hour &&
        localMeanTime?.minute == other.localMeanTime?.minute;
  }

  @override
  int get hashCode =>
      Object.hash(is24HourMode, localMeanTime?.hour, localMeanTime?.minute);
}

/// The main screen of the TruTime app.
/// Displays Local Mean Time in a hyper-minimalist design.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late TrueTimeProvider _provider;
  late AppLifecycleListener _lifecycleListener;
  bool _initialized = false;
  bool _menuOpen = false;
  bool _isSolarMode = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WakelockPlus.enable();

    _lifecycleListener = AppLifecycleListener(
      onResume: _handleAppResumed,
      onPause: _handleAppPaused,
      onDetach: _handleAppDetached,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = Provider.of<TrueTimeProvider>(context, listen: false);
    if (!_initialized) {
      final default24HourMode = MediaQuery.of(context).alwaysUse24HourFormat;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(
          _provider.initialize(default24HourMode: default24HourMode),
        );
      });
      _initialized = true;
    }
  }

  void _handleAppResumed() {
    _provider.resumeTimer();
  }

  void _handleAppPaused() {
    _provider.pauseTimer();
  }

  void _handleAppDetached() {
    _provider.pauseTimer();
  }

  void _updateSystemChromeStyle(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    final brightness = luminance < 0.5 ? Brightness.light : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: backgroundColor,
        statusBarBrightness: brightness,
        statusBarIconBrightness: brightness,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarDividerColor: backgroundColor,
        systemNavigationBarIconBrightness: brightness,
      ),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Selector<TrueTimeProvider, _ScaffoldTimeData>(
          selector: (_, p) => _ScaffoldTimeData(
            localMeanTime: p.currentTimeResult?.localMeanTime,
            is24HourMode: p.is24HourMode,
          ),
          builder: (context, scaffoldData, _) {
            final themeColors = themeProvider.getCurrentThemeColors(
              localMeanTime: scaffoldData.localMeanTime,
            );

            final displayedTime = _isSolarMode
                ? (scaffoldData.localMeanTime ?? DateTime.now())
                : DateTime.now();
            unawaited(
              themeProvider.syncWidgetSnapshot(
                displayedTime: displayedTime,
                is24HourMode: scaffoldData.is24HourMode,
                isSolarMode: _isSolarMode,
              ),
            );

            _updateSystemChromeStyle(themeColors.backgroundColor);

            final activeTheme = themeProvider.activeTheme;
            final activeThemeData = ThemeDefinitions.getAppTheme(activeTheme);
            const showSecondaryUi = true;
            final storeHeight =
                _menuOpen ? MediaQuery.of(context).size.height * 0.35 : 0.0;

            final scaffold = Scaffold(
              backgroundColor: themeColors.backgroundColor,
              body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: SafeArea(
                            child: Stack(
                              children: [
                                if (activeThemeData.customBackgroundBuilder !=
                                    null)
                                  Positioned.fill(
                                    child: activeThemeData
                                        .customBackgroundBuilder!(
                                      context,
                                      scaffoldData.localMeanTime ??
                                          DateTime.now(),
                                    ),
                                  ),
                                Center(
                                  child: RepaintBoundary(
                                    child: _buildTimeDisplay(
                                      themeColors: themeColors,
                                      activeTheme: activeTheme,
                                      showSecondaryUi: showSecondaryUi,
                                    ),
                                  ),
                                ),
                                if (showSecondaryUi)
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 280),
                                    curve: Curves.easeInOut,
                                    left: 0,
                                    right: 0,
                                    top: _menuOpen ? 16 : 24,
                                    child: IgnorePointer(
                                      child: AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        opacity: _menuOpen ? 0.85 : 1.0,
                                        child: Text(
                                          _isSolarMode
                                              ? 'TRUE SOLAR'
                                              : 'OFFICIAL',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            color: _isSolarMode
                                                ? themeColors.textColor
                                                : themeColors
                                                    .secondaryTextColor,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 12,
                                  child: Center(
                                    child: AnimatedScale(
                                      duration:
                                          const Duration(milliseconds: 220),
                                      curve: Curves.easeOut,
                                      scale: _menuOpen ? 1.05 : 1.0,
                                      child: AnimatedRotation(
                                        duration:
                                            const Duration(milliseconds: 260),
                                        curve: Curves.easeOutCubic,
                                        turns: _menuOpen ? 0.03 : 0.0,
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (_menuOpen) {
                                                themeProvider
                                                    .clearThemePreview();
                                              }
                                              _menuOpen = !_menuOpen;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.palette_outlined,
                                            color: themeColors.accentColor,
                                            size: 22,
                                          ),
                                          tooltip: 'Theme Gallery',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 6,
                                  child: SafeArea(
                                    bottom: false,
                                    child: IconButton(
                                      tooltip: 'Settings',
                                      icon: Icon(
                                        Icons.settings_outlined,
                                        size: 22,
                                        color: themeColors.secondaryTextColor,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          CupertinoPageRoute<void>(
                                            builder: (_) =>
                                                const SettingsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.fastOutSlowIn,
                          height: storeHeight,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: themeColors.backgroundColor,
                            border: _menuOpen
                                ? Border(
                                    top: BorderSide(
                                      color: themeColors.accentColor
                                          .withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  )
                                : null,
                          ),
                          child: _menuOpen
                              ? RepaintBoundary(
                                  child: HomeThemeMenu(
                                    themeProvider: themeProvider,
                                    themeColors: themeColors,
                                    onThemePreview: (theme) {
                                      themeProvider.previewTheme(theme);
                                    },
                                    onThemeSelected: (theme) async {
                                      await themeProvider.setTheme(theme);
                                      setState(() {
                                        _menuOpen = false;
                                      });
                                    },
                                    onLockedThemeTap: (theme) {
                                      showUpgradeToProSheet(
                                        context,
                                        lockedTheme: theme,
                                        themeColors: themeColors,
                                      );
                                    },
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );

            return scaffold;
          },
        );
      },
    );
  }

  Widget _buildTimeDisplay({
    required AppThemeColors themeColors,
    required AppThemeType activeTheme,
    required bool showSecondaryUi,
  }) {
    // Loading, error, and null-result states are now handled inside
    // HomeTimeDisplay via its own Selector<TrueTimeProvider, _ClockData>.
    return HomeTimeDisplay(
      themeColors: themeColors,
      currentTheme: activeTheme,
      isSolarMode: _isSolarMode,
      showSecondaryUi: showSecondaryUi,
      onToggleMode: () {
        setState(() {
          _isSolarMode = !_isSolarMode;
        });
      },
    );
  }
}
