import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:true_time/providers/true_time_provider.dart';
import 'package:true_time/providers/theme_provider.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/screens/widgets/home_support_widgets.dart';
import 'package:true_time/screens/widgets/home_theme_menu.dart';
import 'package:true_time/screens/widgets/home_time_display.dart';

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

    // Enable screen wake lock
    WakelockPlus.enable();

    // Listen to app lifecycle events
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

  /// Updates the system chrome (status bar and navigation bar) to match the background.
  /// Uses the background color's luminance to determine icon brightness.
  void _updateSystemChromeStyle(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();

    // For dark backgrounds (luminance < 0.5), use light icons
    // For light backgrounds (luminance >= 0.5), use dark icons
    final brightness = luminance < 0.5 ? Brightness.light : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // Status bar (top)
        statusBarColor: backgroundColor,
        statusBarBrightness: brightness,
        statusBarIconBrightness: brightness,

        // Navigation bar (bottom)
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
        return Consumer<TrueTimeProvider>(builder: (context, timeProvider, _) {
          // Get theme colors (pass localMeanTime for Solar Dynamic)
          final themeColors = themeProvider.getCurrentThemeColors(
            localMeanTime: timeProvider.currentTimeResult?.localMeanTime,
          );

          // Update system chrome (status bar and navigation bar) to match background
          _updateSystemChromeStyle(themeColors.backgroundColor);

          // For Solar Dynamic theme, animate background color
          final isSolarDynamic =
              themeProvider.currentTheme == AppThemeType.solarDynamic;
          final isBlueprintArch =
              themeProvider.currentTheme == AppThemeType.blueprintArchitectural;

          final scaffold = Scaffold(
            backgroundColor: isSolarDynamic
                ? Colors.transparent
                : themeColors.backgroundColor,
            body: SafeArea(
              child: Stack(
                children: [
                  // Full-screen grid overlay for Blueprint Architectural theme
                  if (isBlueprintArch)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: BlueprintGridPainter(),
                        ),
                      ),
                    ),

                  // Main time display with Squeeze animation
                  AnimatedAlign(
                    alignment:
                        _menuOpen ? const Alignment(0, -0.5) : Alignment.center,
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
                                timeProvider.error!, themeColors);
                          }

                          final result = timeProvider.currentTimeResult;
                          if (result == null) {
                            return _buildLoadingIndicator(themeColors);
                          }

                          return HomeTimeDisplay(
                            result: result,
                            themeColors: themeColors,
                            isSolarMode: _isSolarMode,
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

                  // Mode label at page bottom (moves with theme menu toggle)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    left: 0,
                    right: 0,
                    bottom: _menuOpen
                        ? (MediaQuery.of(context).size.height * 0.4) + 16
                        : 24,
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
                                ? Colors.white
                                : const Color(0xFFA0A0A0),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Theme selector button (top left)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _menuOpen = !_menuOpen;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: themeColors.accentColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: themeColors.accentColor, width: 1),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.palette,
                            color: themeColors.accentColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // GPS lock indicator (top right)
                  Positioned(
                    top: 16,
                    right: 16,
                    child:
                        _buildGpsIndicator(timeProvider.isLoading, themeColors),
                  ),

                  // Custom animated theme menu at the bottom
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
                          ? HomeThemeMenu(
                              themeProvider: themeProvider,
                              themeColors: themeColors,
                              onThemeSelected: () {
                                setState(() {
                                  _menuOpen = false;
                                });
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          );

          // If Solar Dynamic, wrap with AnimatedContainer for background color animation
          if (isSolarDynamic) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 2000),
              color: themeColors.backgroundColor,
              child: scaffold,
            );
          }

          return scaffold;
        });
      },
    );
  }

  /// Builds a minimalist loading indicator.
  Widget _buildLoadingIndicator(AppThemeColors themeColors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated dots
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

  /// Builds an error state display.
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
            color: themeColors.accentColor, // Use accent for error
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

  /// Builds the pulsing GPS lock indicator.
  Widget _buildGpsIndicator(bool isLoading, AppThemeColors themeColors) {
    if (isLoading) {
      // Pulsing circle during loading
      return PulsingCircle(accentColor: themeColors.accentColor);
    } else {
      // Steady circle when locked
      return GpsLockCircle(accentColor: themeColors.accentColor);
    }
  }
}
