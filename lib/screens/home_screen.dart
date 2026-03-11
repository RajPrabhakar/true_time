import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/providers/theme_provider.dart';
import 'package:true_time/providers/true_time_provider.dart';
import 'package:true_time/screens/widgets/home_support_widgets.dart';
import 'package:true_time/screens/widgets/home_theme_menu.dart';
import 'package:true_time/screens/widgets/home_time_display.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
  bool _showMonolithSecondaryUi = false;

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
      _provider.initialize(
        default24HourMode: MediaQuery.of(context).alwaysUse24HourFormat,
      );
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
        return Consumer<TrueTimeProvider>(
          builder: (context, timeProvider, _) {
            final themeColors = themeProvider.getCurrentThemeColors(
              localMeanTime: timeProvider.currentTimeResult?.localMeanTime,
            );

            _updateSystemChromeStyle(themeColors.backgroundColor);

            final activeTheme = themeProvider.activeTheme;
            final isSolarDynamic = activeTheme == AppThemeType.solarDynamic;
            final isBlueprintArch =
                activeTheme == AppThemeType.blueprintArchitectural;
            final isZenith = activeTheme == AppThemeType.zenith;
            final isMonolith = activeTheme == AppThemeType.monolith;
            final showSecondaryUi = !isMonolith || _showMonolithSecondaryUi;
            final storeHeight = _menuOpen
              ? MediaQuery.of(context).size.height * 0.35
              : 0.0;

            final scaffold = Scaffold(
              backgroundColor: (isSolarDynamic || isZenith)
                  ? Colors.transparent
                  : themeColors.backgroundColor,
              body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPressStart: (_) {
                  if (!isMonolith || _showMonolithSecondaryUi) {
                    return;
                  }
                  setState(() {
                    _showMonolithSecondaryUi = true;
                  });
                },
                onLongPressEnd: (_) {
                  if (!isMonolith || !_showMonolithSecondaryUi) {
                    return;
                  }
                  setState(() {
                    _showMonolithSecondaryUi = false;
                  });
                },
                onLongPressCancel: () {
                  if (!isMonolith || !_showMonolithSecondaryUi) {
                    return;
                  }
                  setState(() {
                    _showMonolithSecondaryUi = false;
                  });
                },
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: SafeArea(
                            child: Stack(
                              children: [
                                if (isBlueprintArch)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: CustomPaint(
                                        painter: BlueprintGridPainter(),
                                      ),
                                    ),
                                  ),
                                Center(
                                  child: RepaintBoundary(
                                    child: _buildTimeDisplay(
                                      timeProvider: timeProvider,
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
                            color: isZenith
                                ? themeColors.backgroundColor
                                    .withValues(alpha: 0.72)
                                : themeColors.backgroundColor,
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
                              ? HomeThemeMenu(
                                  themeProvider: themeProvider,
                                  themeColors: themeColors,
                                  is24HourMode: timeProvider.is24HourMode,
                                  on24HourModeChanged: (value) {
                                    timeProvider.set24HourMode(value);
                                  },
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
                                    _showUpgradeToProSheet(
                                      context,
                                      lockedTheme: theme,
                                      themeColors: themeColors,
                                    );
                                  },
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );

            if (isSolarDynamic) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 2000),
                color: themeColors.backgroundColor,
                child: scaffold,
              );
            }

            if (isZenith) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: ThemeDefinitions.getZenithGradient(
                    isSolarMode: _isSolarMode,
                  ),
                ),
                child: scaffold,
              );
            }

            return scaffold;
          },
        );
      },
    );
  }

  Future<void> _showUpgradeToProSheet(
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

  Widget _buildTimeDisplay({
    required TrueTimeProvider timeProvider,
    required AppThemeColors themeColors,
    required AppThemeType activeTheme,
    required bool showSecondaryUi,
  }) {
    if (timeProvider.isLoading) {
      return _buildLoadingIndicator(themeColors);
    }

    if (timeProvider.error != null) {
      return _buildErrorState(timeProvider.error!, themeColors);
    }

    final result = timeProvider.currentTimeResult;
    if (result == null) {
      return _buildLoadingIndicator(themeColors);
    }

    return HomeTimeDisplay(
      result: result,
      themeColors: themeColors,
      currentTheme: activeTheme,
      isSolarMode: _isSolarMode,
      is24HourMode: timeProvider.is24HourMode,
      showSecondaryUi: showSecondaryUi,
      onToggleMode: () {
        setState(() {
          _isSolarMode = !_isSolarMode;
        });
      },
    );
  }

  Widget _buildLoadingIndicator(AppThemeColors themeColors) {
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

  Widget _buildErrorState(String error, AppThemeColors themeColors) {
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
