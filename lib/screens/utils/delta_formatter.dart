/// Formats a Duration as a human-readable delta string used throughout the UI.
///
/// The string begins with a timezone label (defaults to the device's timezone
/// abbreviation), a plus or minus sign, and a zero-padded HH:MM:SS value.
/// Negative durations produce a leading `-` sign but never a double negative.
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

  // Use provided label or default to device's timezone abbreviation.
  final label = timeZoneLabel ?? DateTime.now().timeZoneName;

  return '$label $sign $hh:$mm:$ss';
}
