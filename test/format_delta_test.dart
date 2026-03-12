import 'package:flutter_test/flutter_test.dart';
import 'package:true_time/screens/utils/delta_formatter.dart';

void main() {
  group('formatDelta', () {
    // Get the system timezone name for consistent testing
    final timeZoneName = DateTime.now().timeZoneName;

    test('Positive Offset (East) with default timezone produces correct string',
        () {
      const duration = Duration(hours: 5, minutes: 30, seconds: 15);
      final result = formatDelta(duration);
      expect(result, '$timeZoneName + 05:30:15');
    });

    test('Positive Offset (East) with UTC label produces correct string', () {
      const duration = Duration(hours: 5, minutes: 30, seconds: 15);
      final result = formatDelta(duration, timeZoneLabel: 'UTC');
      expect(result, 'UTC + 05:30:15');
    });

    test('Negative Offset (West) handles absolute values correctly', () {
      // 8 minutes 55 seconds west -> negative duration
      const duration = Duration(minutes: -8, seconds: -55);
      final result = formatDelta(duration, timeZoneLabel: 'UTC');
      expect(result, 'UTC - 00:08:55');
    });

    test('Zero Offset (Prime Meridian) returns zero delta', () {
      final result = formatDelta(Duration.zero, timeZoneLabel: 'UTC');
      expect(result, 'UTC + 00:00:00');
    });

    test('Single-digit padding works for negative durations', () {
      const duration = Duration(hours: -1, minutes: -2, seconds: -3);
      final result = formatDelta(duration, timeZoneLabel: 'UTC');
      expect(result, 'UTC - 01:02:03');
    });

    test('Custom timezone label is used when provided', () {
      const duration = Duration(hours: 2, minutes: 30, seconds: 0);
      final result = formatDelta(duration, timeZoneLabel: 'PST');
      expect(result, 'PST + 02:30:00');
    });
  });
}
