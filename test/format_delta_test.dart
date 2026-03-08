import 'package:flutter_test/flutter_test.dart';
import 'package:true_time/screens/home_screen.dart';

void main() {
  group('formatDelta', () {
    test('Positive Offset (East) produces correct string', () {
      const duration = Duration(hours: 5, minutes: 30, seconds: 15);
      final result = formatDelta(duration);
      expect(result, 'DELTA: IST + 05:30:15');
    });

    test('Negative Offset (West) handles absolute values correctly', () {
      // 8 minutes 55 seconds west -> negative duration
      const duration = Duration(minutes: -8, seconds: -55);
      final result = formatDelta(duration);
      expect(result, 'DELTA: IST - 00:08:55');
    });

    test('Zero Offset (Prime Meridian) returns zero delta', () {
      final result = formatDelta(Duration.zero);
      expect(result, 'DELTA: IST + 00:00:00');
    });

    test('Single-digit padding works for negative durations', () {
      const duration = Duration(hours: -1, minutes: -2, seconds: -3);
      final result = formatDelta(duration);
      expect(result, 'DELTA: IST - 01:02:03');
    });
  });
}
