import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Configures platform-specific golden file directories so that goldens
/// generated on macOS (local dev) and Linux (CI) are stored separately and
/// don't cause cross-platform comparison failures.
///
/// - macOS : test/goldens/macos/<name>.png  (committed, used for local dev)
/// - Linux : test/goldens/linux/<name>.png  (generated fresh in CI each run)
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final String platformDir;
  if (Platform.isMacOS) {
    platformDir = 'macos';
  } else if (Platform.isLinux) {
    platformDir = 'linux';
  } else if (Platform.isWindows) {
    platformDir = 'windows';
  } else {
    platformDir = 'other';
  }

  goldenFileComparator = LocalFileComparator(
    Uri.parse(
      'file://${Directory.current.path}/test/goldens/$platformDir/dummy.dart',
    ),
  );

  await testMain();
}
