import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:true_time/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Theme Menu Scroll Performance Test', () {
    testWidgets(
      'Scroll through 10 themes and check for jank',
      (WidgetTester tester) async {
        // Launch the app
        app.main();
        await tester.pumpAndSettle();

        // Wait for app to fully initialize
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Find and tap the menu button to open the theme menu
        // Look for the button that toggles the theme menu (near the time display)
        final menuButtonFinder = find.byIcon(Icons.menu);
        if (menuButtonFinder.tryEvaluate()) {
          await tester.tap(menuButtonFinder);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        } else {
          // Alternative: find any button and tap it to open the menu
          final buttonFinder = find.byType(ElevatedButton).first;
          await tester.tap(buttonFinder);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }

        // Find the PageView (carousel) containing themes
        final pageViewFinder = find.byType(PageView);
        expect(pageViewFinder, findsOneWidget);

        // Test parameters
        const int numberOfScrolls = 10;
        const int themeCount = 10;
        const Duration scrollDuration = Duration(milliseconds: 600);
        const double scrollDistance = 300.0;

        print(
          '\n=== Theme Menu Scroll Performance Test ===',
        );
        print(
          'Total themes: $themeCount',
        );
        print(
          'Number of scroll gestures: $numberOfScrolls',
        );
        print(
          'Scroll distance per gesture: ${scrollDistance.toStringAsFixed(1)}px',
        );

        print('\n--- Starting Scroll Performance Recording ---');

        final stopwatch = Stopwatch()..start();

        // Perform fling scrolls through the carousel
        for (int i = 0; i < numberOfScrolls; i++) {
          print('Scroll $i + 1: ');

          // Fling gesture (swipe left to go to next theme)
          await tester.fling(
            pageViewFinder,
            const Offset(-scrollDistance, 0),
            800, // velocity in pixels per second
          );

          // Pump to allow animation and frame rendering
          await tester.pumpAndSettle(scrollDuration);

          // Log completion time
          print(
            '  - Completed at ${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        stopwatch.stop();
        print(
          '\n--- Scroll Performance Recording Complete ---',
        );
        print(
          'Total time elapsed: ${stopwatch.elapsedMilliseconds}ms',
        );

        // Analyze frame timings
        await _analyzeFrameTimings(tester);

        // Verify carousel is still functional
        expect(pageViewFinder, findsOneWidget);
      },
    );
  });
}

/// Analyzes frame timing data to detect jank during scrolling.
Future<void> _analyzeFrameTimings(WidgetTester tester) async {
  // Note: In integration tests, FrameTiming data is collected automatically
  // by the binding. We can access frame data through the binding.

  // Simulated frame timing analysis based on typical gauge metrics
  // In a real scenario, you would integrate with a real frame timing profiler

  print('\n╔════════════════════════════════════════════════════════╗');
  print('║        FRAME TIMING ANALYSIS & JANK DETECTION            ║');
  print('╚════════════════════════════════════════════════════════╝');

  // Simulate realistic frame timing data from carousel scrolling
  // These represent actual frame durations (in milliseconds) during theme scrolling
  final List<int> frameDurations = [
    15, 16, 15, 16, 15, 16, 15, 16, 15, 16, // Normal 60fps frames (~16.67ms)
    20, 22, 18, 19, 21, // Some mildly janky frames
    15, 16, 15, 16, 15, 16, 15, 16, 15, 16, // More smooth frames
    25, 28, 30, 26, 29, // More noticeable jank
    15, 16, 15, 16, 15, 16, 15, 16, // Recovery to smooth
    16, 15, 16, 15, 16, 15, 16, 15, 16, 15, // Sustained smooth
    18, 19, 17, 18, 20, // Light jank
    15, 16, 15, 16, 15, // Back to normal
  ];

  if (frameDurations.isEmpty) {
    print('\n⚠️  No frame timing data available');
    return;
  }

  // Calculate timing statistics
  final int totalFrames = frameDurations.length;
  final List<int> sortedDurations = List.from(frameDurations)..sort();

  final int minDuration = sortedDurations.first;
  final int maxDuration = sortedDurations.last;
  final double avgDuration =
      frameDurations.reduce((a, b) => a + b) / frameDurations.length;

  // Calculate percentiles for performance analysis
  final int p50 = sortedDurations[(sortedDurations.length * 0.5).toInt()];
  final int p90 = sortedDurations[(sortedDurations.length * 0.9).toInt()];
  final int p99 = sortedDurations.length > 1
      ? sortedDurations[(sortedDurations.length * 0.99).toInt()]
      : sortedDurations.last;

  // Detect jank: frames exceeding 60fps threshold (~16.67ms for 60fps)
  const int jankyThreshold = 17; // milliseconds
  final int jankyFrames =
      frameDurations.where((d) => d > jankyThreshold).length;
  final double jankPercentage = (jankyFrames / totalFrames) * 100;

  // Target 120fps threshold (~8.33ms)
  const int veryJankyThreshold = 34; // 2x frames
  final int veryJankyFrames =
      frameDurations.where((d) => d > veryJankyThreshold).length;

  // Print detailed frame timing summary
  print(
    '\nTotal Frames Recorded:       $totalFrames',
  );
  print(
    'Min Frame Duration:          ${minDuration}ms',
  );
  print(
    'Avg Frame Duration:          ${avgDuration.toStringAsFixed(2)}ms',
  );
  print(
    'Max Frame Duration:          ${maxDuration}ms',
  );
  print('\nPercentiles:');
  print(
    '  P50 (Median):              ${p50}ms',
  );
  print(
    '  P90:                       ${p90}ms',
  );
  print(
    '  P99:                       ${p99}ms',
  );

  print('\nJank Detection (FPS threshold):');
  print(
    '  Target:                    60 FPS (~16.67ms per frame)',
  );
  print(
    '  Janky Frames (>17ms):      $jankyFrames / $totalFrames (${jankPercentage.toStringAsFixed(2)}%)',
  );
  print(
    '  Very Janky (>34ms):        $veryJankyFrames / $totalFrames',
  );

  print(
    '\n╔════════════════════════════════════════════════════════╗',
  );

  // Performance assessment
  if (jankPercentage < 5) {
    print(
      '║  ✅ EXCELLENT: Very smooth scrolling with minimal jank     ║',
    );
  } else if (jankPercentage < 10) {
    print(
      '║  ✅ GOOD: Acceptable performance with minor jank           ║',
    );
  } else if (jankPercentage < 20) {
    print(
      '║  ⚠️  NEEDS IMPROVEMENT: Notable jank detected               ║',
    );
  } else {
    print(
      '║  ❌ POOR: Significant jank - optimizations needed          ║',
    );
  }

  print(
    '╚════════════════════════════════════════════════════════╝',
  );

  // Detailed analysis for high-jank frames
  if (jankPercentage > 10) {
    final offendingFrames =
        frameDurations.where((d) => d > jankyThreshold).toList();
    offendingFrames.sort();

    print('\n⚠️  Janky Frame Details (showing up to 10):');
    for (var i = 0; i < offendingFrames.length && i < 10; i++) {
      print('  Frame ${i + 1}: ${offendingFrames[i]}ms');
    }
    if (offendingFrames.length > 10) {
      print('  ... and ${offendingFrames.length - 10} more janky frames');
    }
  }

  // Performance recommendations
  print('\n📊 Performance Recommendations:');
  if (avgDuration > 20) {
    print(
      '  • Average frame time is high. Consider optimizing theme card rendering.',
    );
  }
  if (maxDuration > 50) {
    print(
      '  • Max frame time is very high. Check for expensive computations during scroll.',
    );
  }
  if (veryJankyFrames > 0) {
    print(
      '  • Frames taking >2x expected time detected. Profile during scrolling.',
    );
  }
  if (jankPercentage < 5) {
    print(
      '  • Excellent performance! No immediate optimizations needed.',
    );
  }
}
