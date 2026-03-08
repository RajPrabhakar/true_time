/// Represents the result of a Local Mean Time calculation.
class LocalTimeResult {
  /// The calculated Local Mean Time (Solar Time) based on GPS longitude.
  final DateTime localMeanTime;

  /// The current time in the device's standard timezone.
  final DateTime standardTimezoneTime;

  /// The exact difference between Local Mean Time and Standard Timezone Time.
  final Duration delta;

  /// Creates a [LocalTimeResult] with the three time values.
  const LocalTimeResult({
    required this.localMeanTime,
    required this.standardTimezoneTime,
    required this.delta,
  });

  @override
  String toString() =>
      'LocalTimeResult(localMeanTime: $localMeanTime, standardTimezoneTime: $standardTimezoneTime, delta: $delta)';
}
