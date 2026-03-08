import 'package:flutter_test/flutter_test.dart';
import 'package:true_time/services/time_calculator_service.dart';

void main() {
  group('TimeCalculatorService', () {
    final service = TimeCalculatorService();

    test('delta equals offset when reference time is UTC', () {
      // When the reference time is in UTC, the delta should be exactly the
      // longitude offset (longitude * 4 minutes), because the system local
      // time has zero offset from UTC.
      final referenceTime = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final result = service.calculateLocalMeanTime(10.0, referenceTime: referenceTime);

      // 10 degrees east → 40 minutes
      expect(result.delta, const Duration(minutes: 40));
      expect(result.localMeanTime,
          referenceTime.add(const Duration(minutes: 40)));
    });

    test('negative longitude produces negative delta for UTC reference', () {
      final referenceTime = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final result = service.calculateLocalMeanTime(-2.0, referenceTime: referenceTime);

      // -2 degrees west → -8 minutes
      expect(result.delta, const Duration(minutes: -8));
    });

    test('delta is negative when solar time lags device clock', () {
      // Choose a western longitude so the calculated Local Mean Time is
      // earlier than the reference time. Use a UTC reference to keep the
      // expected offset simple.
      final referenceTime = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final result = service.calculateLocalMeanTime(-1.0, referenceTime: referenceTime);

      // -1 degree west should be -4 minutes relative to the device clock.
      expect(result.delta.isNegative, isTrue);
      expect(result.delta, const Duration(minutes: -4));
    });
  });
}
