import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:true_time/providers/true_time_provider.dart';
import 'package:true_time/providers/theme_provider.dart';
import 'package:true_time/models/app_theme.dart';

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
                          painter: _BlueprintGridPainter(),
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

                          return _buildTimeDisplay(result, themeColors);
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
                          ? _buildThemeMenu(context, themeProvider, themeColors)
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

  /// Show the theme selection bottom sheet
  /// Builds the inline theme selection menu for the bottom slider
  Widget _buildThemeMenu(BuildContext context, ThemeProvider themeProvider,
      AppThemeColors themeColors) {
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

              return GestureDetector(
                onTap: () {
                  themeProvider.setTheme(theme);
                  // Close menu after selection
                  setState(() {
                    _menuOpen = false;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isActive
                          ? colors.textColor
                          : themeColors.secondaryTextColor,
                      width: isActive ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.backgroundColor,
                          border: Border.all(color: colors.textColor, width: 1),
                          borderRadius: BorderRadius.circular(4),
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
                                fontWeight: isActive
                                    ? FontWeight.w500
                                    : FontWeight.w300,
                                color: themeColors.textColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              colors.description,
                              style: TextStyle(
                                fontSize: 10,
                                color: themeColors.secondaryTextColor,
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
            }),
          ],
        ),
      ),
    );
  }

  /// Builds the main time display with Local Mean Time and Delta.
  Widget _buildTimeDisplay(dynamic result, AppThemeColors themeColors) {
    final localTime = result.localMeanTime;
    final politicalTime = DateTime.now();
    final displayedTime = _isSolarMode ? localTime : politicalTime;
    final Duration utcDelta = result.utcDelta;
    final Duration tzDelta = result.tzDelta;

    // Format as HH:mm:ss
    final timeString =
      '${displayedTime.hour.toString().padLeft(2, '0')}:${displayedTime.minute.toString().padLeft(2, '0')}:${displayedTime.second.toString().padLeft(2, '0')}';

    // Calculate delta components
    final utcDeltaString = formatDelta(utcDelta, timeZoneLabel: 'UTC');
    final tzDeltaString = formatDelta(tzDelta);

    // Check if using Horological Instrument theme for glow effect
    final isHorological =
        _getCurrentThemeName(themeColors) == 'Horological Instrument';
    final displayedTimeColor =
        _isSolarMode ? Colors.white : const Color(0xFFA0A0A0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Wrapping in Padding and FittedBox prevents screen overflow
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSolarMode = !_isSolarMode;
                });
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Column(
                  key: ValueKey(_isSolarMode ? 'solar-mode' : 'political-mode'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.w300,
                        color: displayedTimeColor,
                        fontFamily: 'Courier',
                        letterSpacing: 2.0,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        shadows: isHorological
                            ? ThemeDefinitions.getHorologicalGlow()
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // UTC Delta (longitude offset from UTC)
        Text(
          'UTC Delta: $utcDeltaString',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: themeColors.secondaryTextColor,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        // TZ Delta (offset from device timezone)
        Text(
          'TZ Delta: $tzDeltaString',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: themeColors.secondaryTextColor,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

// Helper function to format the Duration into the clean UI string

  /// Builds a minimalist loading indicator.
  Widget _buildLoadingIndicator(AppThemeColors themeColors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated dots
        _AnimatedDots(accentColor: themeColors.accentColor),
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
      return _PulsingCircle(accentColor: themeColors.accentColor);
    } else {
      // Steady circle when locked
      return _GpsLockCircle(accentColor: themeColors.accentColor);
    }
  }

  /// Helper to get the current theme name from theme colors
  String _getCurrentThemeName(AppThemeColors themeColors) {
    return themeColors.name;
  }
}

/// Custom painter for Blueprint Architectural theme - renders a grid overlay
class _BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    ThemeDefinitions.paintBlueprintGrid(canvas, size);
  }

  @override
  bool shouldRepaint(_BlueprintGridPainter oldDelegate) => false;
}

/// Formats a Duration as a human-readable delta string used throughout the UI.
///
/// The string begins with "DELTA:" followed by a timezone label (defaults to
/// the device's timezone abbreviation), a plus or minus sign, and a zero-padded
/// HH:MM:SS value. Negative durations produce a leading `-` sign but never a
/// double negative.
String formatDelta(Duration delta, {String? timeZoneLabel}) {
  final isNegative = delta.isNegative;
  final abs = delta.abs();

  final hours = abs.inHours;
  final minutes = abs.inMinutes.remainder(60);
  final seconds = abs.inSeconds.remainder(60);

  final sign = isNegative ? '-' : '+';

  final hh = hours.toString().padLeft(2, '0');
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');

  // Use provided label or default to device's timezone abbreviation
  final label = timeZoneLabel ?? DateTime.now().timeZoneName;

  return '$label $sign $hh:$mm:$ss';
}

/// A pulsing green circle that animates during GPS acquisition.
class _PulsingCircle extends StatefulWidget {
  final Color accentColor;

  const _PulsingCircle({required this.accentColor});

  @override
  State<_PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<_PulsingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.accentColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// A steady circle indicating GPS lock.
class _GpsLockCircle extends StatelessWidget {
  final Color accentColor;

  const _GpsLockCircle({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: accentColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Animated loading dots indicator.
class _AnimatedDots extends StatefulWidget {
  final Color accentColor;

  const _AnimatedDots({required this.accentColor});

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.6, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                index * 0.33,
                (index + 1) * 0.33,
                curve: Curves.easeInOut,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: widget.accentColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
