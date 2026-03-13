import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Theme Drift Guard', () {
    test('critical themed UI files avoid hardcoded black/white colors',
        () async {
      const filesToGuard = [
        'lib/screens/settings_screen.dart',
        'lib/screens/widgets/home_theme_menu_parts/theme_gallery_card.dart',
        'lib/screens/widgets/home_theme_menu_parts/theme_menu_filter_strip.dart',
      ];
      final hardcodedColorPattern = RegExp(r'Colors\\.(black|white|white\\d+)');
      final violations = <String>[];

      for (final path in filesToGuard) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Missing file: $path');

        final lines = await file.readAsLines();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (hardcodedColorPattern.hasMatch(line)) {
            violations.add('$path:${i + 1}: ${line.trim()}');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Hardcoded black/white colors found in theme-driven UI:\n${violations.join("\n")}',
      );
    });
  });
}
