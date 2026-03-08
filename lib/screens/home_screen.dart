import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:true_time/providers/true_time_provider.dart';

/// The main screen of the True Time app.
/// Displays Local Mean Time in a hyper-minimalist design.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  late TrueTimeProvider _provider;
  late AppLifecycleListener _lifecycleListener;
  bool _initialized = false;

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

  @override
  void dispose() {
    _lifecycleListener.dispose();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure OLED black
      body: SafeArea(
        child: Stack(
          children: [
            // Main centered time display
            Center(
              child: Consumer<TrueTimeProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return _buildLoadingIndicator();
                  }

                  if (provider.error != null) {
                    return _buildErrorState(provider.error!);
                  }

                  final result = provider.currentTimeResult;
                  if (result == null) {
                    return _buildLoadingIndicator();
                  }

                  return _buildTimeDisplay(result);
                },
              ),
            ),

            // GPS lock indicator (top right)
            Positioned(
              top: 16,
              right: 16,
              child: Consumer<TrueTimeProvider>(
                builder: (context, provider, _) {
                  return _buildGpsIndicator(provider.isLoading);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main time display with Local Mean Time and Delta.
  Widget _buildTimeDisplay(dynamic result) {
  final localTime = result.localMeanTime;
  final Duration utcDelta = result.utcDelta;
  final Duration tzDelta = result.tzDelta;

  // Format as HH:mm:ss
  final timeString =
      '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}:${localTime.second.toString().padLeft(2, '0')}';

  // Calculate delta components
  final utcDeltaString = formatDelta(utcDelta);
  final tzDeltaString = formatDelta(tzDelta);

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      // Wrapping in Padding and FittedBox prevents screen overflow
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            timeString,
            style: const TextStyle(
              fontSize: 120, // Now safe to be massive!
              fontWeight: FontWeight.w300,
              color: Colors.white,
              // 'Courier' works, but 'Roboto Mono' or omitting it and relying on 
              // the system's geometric sans-serif looks slightly more modern.
              fontFamily: 'Courier', 
              letterSpacing: 2.0,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),

      const SizedBox(height: 32),

      // UTC Delta (longitude offset from UTC)
      Text(
        'UTC Delta: $utcDeltaString',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: Color(0xFF606060), // Dimmer gray
          letterSpacing: 1.2,
        ),
      ),

      const SizedBox(height: 8),

      // TZ Delta (offset from device timezone)
      Text(
        'TZ Delta: $tzDeltaString',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: Color(0xFF808080), // Muted gray
          letterSpacing: 1.2,
        ),
      ),
    ],
  );
}

// Helper function to format the Duration into the clean UI string

  /// Builds a minimalist loading indicator.
  Widget _buildLoadingIndicator() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated dots
        _AnimatedDots(),
        SizedBox(height: 24),
        Text(
          'Acquiring GPS Lock...',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF808080),
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  /// Builds an error state display.
  Widget _buildErrorState(String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'ERROR',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Color(0xFFFF6B6B), // Soft red
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 300,
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF808080),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the pulsing GPS lock indicator.
  Widget _buildGpsIndicator(bool isLoading) {
    if (isLoading) {
      // Pulsing circle during loading
      return const _PulsingCircle();
    } else {
      // Steady green circle when locked
      return const _GpsLockCircle();
    }
  }

}

/// Formats a Duration as a human-readable delta string used throughout the UI.
///
/// The string always begins with "DELTA: UTC" followed by a plus or minus
/// sign and a zero-padded HH:MM:SS value. Negative durations produce a
/// leading `-` sign but never a double negative.
String formatDelta(Duration delta) {
  final isNegative = delta.isNegative;
  final abs = delta.abs();

  final hours = abs.inHours;
  final minutes = abs.inMinutes.remainder(60);
  final seconds = abs.inSeconds.remainder(60);

  final sign = isNegative ? '-' : '+';

  final hh = hours.toString().padLeft(2, '0');
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');

  return 'DELTA: UTC $sign $hh:$mm:$ss';
}

/// A pulsing green circle that animates during GPS acquisition.
class _PulsingCircle extends StatefulWidget {
  const _PulsingCircle();

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
        decoration: const BoxDecoration(
          color: Color(0xFF00FF00), // Bright green
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// A steady green circle indicating GPS lock.
class _GpsLockCircle extends StatelessWidget {
  const _GpsLockCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF00FF00), // Bright green
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Animated loading dots indicator.
class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

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
              decoration: const BoxDecoration(
                color: Color(0xFF808080),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
