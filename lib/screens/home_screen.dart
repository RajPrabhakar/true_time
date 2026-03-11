import 'dart:ui';

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
  AppThemeType? _lockedThemePrompt;

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
      _provider.initialize();
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

            final scaffold = Scaffold(
              backgroundColor: (isSolarDynamic || isZenith)
                  ? Colors.transparent
                  : themeColors.backgroundColor,
              body: SafeArea(
                child: GestureDetector(
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
                      if (isBlueprintArch)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: BlueprintGridPainter(),
                            ),
                          ),
                        ),

                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                        top: 0,
                        left: 0,
                        right: 0,
                        height: _menuOpen
                            ? MediaQuery.of(context).size.height * 0.4
                            : MediaQuery.of(context).size.height,
                        child: AnimatedAlign(
                          alignment:
                              _menuOpen ? const Alignment(0, 0.12) : Alignment.center,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          child: RepaintBoundary(
                            child: Builder(
                              builder: (context) {
                                if (timeProvider.isLoading) {
                                  return _buildLoadingIndicator(themeColors);
                                }

                                if (timeProvider.error != null) {
                                  return _buildErrorState(
                                    timeProvider.error!,
                                    themeColors,
                                  );
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
                                  showSecondaryUi: showSecondaryUi,
                                  onToggleMode: () {
                                    setState(() {
                                      _isSolarMode = !_isSolarMode;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      if (showSecondaryUi)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          left: 0,
                          right: 0,
                          top: _menuOpen ? 16 : 24,
                          child: IgnorePointer(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              opacity: _menuOpen ? 0.85 : 1.0,
                              child: Text(
                                _isSolarMode ? 'TRUE SOLAR' : 'OFFICIAL',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: _isSolarMode
                                      ? themeColors.textColor
                                      : themeColors.secondaryTextColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),

                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                        left: 0,
                        right: 0,
                        bottom: _menuOpen
                            ? (MediaQuery.of(context).size.height * 0.4) + 12
                            : 12,
                        child: Center(
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            scale: _menuOpen ? 1.05 : 1.0,
                            child: AnimatedRotation(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                              turns: _menuOpen ? 0.03 : 0.0,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (_menuOpen) {
                                      themeProvider.clearThemePreview();
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
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          height: _menuOpen
                              ? MediaQuery.of(context).size.height * 0.4
                              : 0,
                          decoration: BoxDecoration(
                            color: isZenith
                                ? themeColors.backgroundColor.withValues(alpha: 0.72)
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
                                    HapticFeedback.vibrate();
                                    setState(() {
                                      _lockedThemePrompt = theme;
                                    });
                                  },
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),

                      if (_lockedThemePrompt != null)
                        _buildPremiumUnlockOverlay(themeColors),
                    ],
                  ),
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

  Widget _buildPremiumUnlockOverlay(AppThemeColors themeColors) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _lockedThemePrompt = null;
          });
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.black.withValues(alpha: 0.42),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 360,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeColors.backgroundColor.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(16),
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
                            'Unlock the ${ThemeDefinitions.getTheme(_lockedThemePrompt!).name} collection',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: themeColors.textColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _lockedThemePrompt = null;
                            });
                          },
                          icon: Icon(
                            Icons.close,
                            color: themeColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 50,
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
                    const SizedBox(height: 14),
                    Text(
                      '• Unlock all 6 professional themes',
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
            ),
          ),
        ),
      ),
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
