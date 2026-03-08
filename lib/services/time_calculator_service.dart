import 'package:true_time/models/local_time_result.dart';

/// Calculates Local Mean Time (Solar Time) based on GPS longitude.
///
/// The calculation uses the fundamental principle that Earth rotates 360° in 24 hours,
/// meaning each degree of longitude represents exactly 4 minutes of solar time offset
/// from UTC.
///
/// Formula: Local Mean Time = UTC + (Longitude × 4 minutes)
///
/// This service requires no internet, APIs, or backend calls—all computation is
/// performed locally on the device.
class TimeCalculatorService {
  /// The number of minutes per degree of longitude.
  static const double _minutesPerDegree = 4.0;

  /// The number of microseconds in a minute.
  static const int _microsecondsPerMinute = 60 * 1000 * 1000;

  /// Calculates the Local Mean Time (True Solar Time) based on the given longitude.
  ///
  /// Parameters:
  ///   - [longitude]: The GPS longitude in degrees. Positive values represent East,
  ///                  negative values represent West (range: -180 to 180).
  ///
  /// Returns:
  ///   A [LocalTimeResult] containing:
  ///   - [localMeanTime]: The calculated Local Mean Time
  ///   - [standardTimezoneTime]: The device's current time in its standard timezone
  ///   - [delta]: The Duration offset between the two times
  ///
  /// Example:
  ///   ```dart
  ///   final service = TimeCalculatorService();
  ///   final result = service.calculateLocalMeanTime(82.9);
  ///   print(result.localMeanTime);  // Local Mean Time
  ///   print(result.delta);           // Offset from standard timezone
  ///   ```
  LocalTimeResult calculateLocalMeanTime(double longitude) {
    // Step 1: Get current UTC time from system clock
    final utcNow = DateTime.now().toUtc();

    // Step 2: Calculate the offset in minutes
    // Each degree of longitude = 4 minutes of solar time
    final offsetMinutes = longitude * _minutesPerDegree;

    // Step 3: Convert offset to Duration (using microseconds for precision)
    // This correctly handles both positive (East) and negative (West) longitudes
    final offsetMicroseconds = (offsetMinutes * _microsecondsPerMinute).toInt();
    final offsetDuration = Duration(microseconds: offsetMicroseconds);

    // Step 4: Calculate Local Mean Time by adding offset to UTC
    final localMeanTime = utcNow.add(offsetDuration);

    // Step 5: Get the device's current standard timezone time
    final standardTimezoneTime = DateTime.now();

    // Step 6: Calculate the delta between Local Mean Time and Standard Timezone Time
    final delta = localMeanTime.difference(standardTimezoneTime);

    // Step 7: Return the result object with all three values
    return LocalTimeResult(
      localMeanTime: localMeanTime,
      standardTimezoneTime: standardTimezoneTime,
      delta: delta,
    );
  }
}
