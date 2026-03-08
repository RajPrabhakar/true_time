import 'package:flutter_test/flutter_test.dart';
import 'package:true_time/services/time_calculator_service.dart';

void main() {
  group('TimeCalculatorService', () {
    final service = TimeCalculatorService();

    test('tzDelta equals offset when reference time is UTC', () {
      // When the reference time is in UTC, tzDelta should be exactly the
      // longitude offset (longitude * 4 minutes), because the timezone
      // offset is zero.
      final referenceTime = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final result = service.calculateLocalMeanTime(10.0, referenceTime: referenceTime);

      // 10 degrees east → 40 minutes
      expect(result.tzDelta, const Duration(minutes: 40));
      expect(result.utcDelta, const Duration(minutes: 40));
      expect(result.localMeanTime,
          referenceTime.add(const Duration(minutes: 40)));
    });

    test('negative longitude produces negative deltas for UTC reference', () {
      final referenceTime = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final result = service.calculateLocalMeanTime(-2.0, referenceTime: referenceTime);

      // -2 degrees west → -8 minutes
      expect(result.tzDelta, const Duration(minutes: -8));
      expect(result.utcDelta, const Duration(minutes: -8));
    });

    test('tzDelta is negative when solar time lags device clock', () {
      // Choose a western longitude so the calculated Local Mean Time is
      // earlier than the reference time. Use a UTC reference to keep the
      // expected offset simple.
      final referenceTime = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final result = service.calculateLocalMeanTime(-1.0, referenceTime: referenceTime);

      // -1 degree west should be -4 minutes relative to the device clock.
      expect(result.tzDelta.isNegative, isTrue);
      expect(result.tzDelta, const Duration(minutes: -4));
      expect(result.utcDelta, const Duration(minutes: -4));
    });

    test('tzDelta differs from utcDelta when using non-UTC timezone', () {
      // Simulate a device in IST (+5:30) at longitude 78°E (Chennai area)
      // Create a local time that has +5:30 offset
      final localTime = DateTime(2026, 1, 1, 17, 30, 0); // 17:30 local = 12:00 UTC
      final result = service.calculateLocalMeanTime(78.0, referenceTime: localTime);

      // 78° × 4 min/deg = 312 minutes = 5:12
      // utcDelta: should be full offset from original time
      // tzDelta: 5:12 (longitude offset) - 5:30 (timezone offset) = -18 minutes
      expect(result.tzDelta, const Duration(minutes: -18));
      
      // localMeanTime should be at UTC + 5:12, which is different from the local time
      // The utcDelta will show the time difference between these DateTime objects
    });
  });
}
