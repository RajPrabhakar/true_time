/// Represents the result of a Local Mean Time calculation.
class LocalTimeResult {
  /// The calculated Local Mean Time (Solar Time) based on GPS longitude.
  final DateTime localMeanTime;

  /// The current time in the device's standard timezone.
  final DateTime standardTimezoneTime;

  /// Delta from UTC (longitude offset): LMT - UTC
  final Duration utcDelta;

  /// Delta from device timezone: (longitude offset) - (timezone offset)
  final Duration tzDelta;

  /// Creates a [LocalTimeResult] with the three time values.
  const LocalTimeResult({
    required this.localMeanTime,
    required this.standardTimezoneTime,
    required this.utcDelta,
    required this.tzDelta,
  });

  @override
  String toString() =>
      'LocalTimeResult(localMeanTime: $localMeanTime, standardTimezoneTime: $standardTimezoneTime, utcDelta: $utcDelta, tzDelta: $tzDelta)';
}
