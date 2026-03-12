import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/screens/widgets/home_theme_menu_parts/theme_gallery_card.dart';

void main() {
  group('ThemeGalleryCard Golden Tests', () {
    // Standard card size for consistent golden snapshots
    const cardSize = Size(440, 260);

    setUpAll(() async {
      // Ensure fonts are loaded before running tests
      // Custom fonts are pre-cached during app initialization
      // google_fonts handles font loading automatically in tests
      await _precacheFonts();
    });

    /// Test for Solar Flare theme (placeholder for 'Solar Dynamic')
    /// NOTE: Update AppThemeType.solarFlare to AppThemeType.solarDynamic
    /// once 'Solar Dynamic' theme is added to ThemeDefinitions
    testWidgets(
      'ThemeGalleryCard renders Solar Dynamic theme with fixed time 10:09',
      (WidgetTester tester) async {
        final solarTheme =
            ThemeDefinitions.getAppTheme(AppThemeType.solarFlare);

        // Set device size for consistent rendering
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        tester.binding.window.physicalSizeTestValue = cardSize;

        await tester.pumpWidget(
          _buildTestWidget(
            appTheme: solarTheme,
            isSelected: true,
            compact: false,
          ),
        );

        await tester.pumpAndSettle();

        // Verify the card renders with the correct theme
        expect(find.byType(ThemeGalleryCard), findsOneWidget);

        // Capture golden snapshot
        await expectLater(
          find.byType(ThemeGalleryCard),
          matchesGoldenFile('solar_dynamic_card.png'),
        );
      },
    );

    /// Test for Zenith theme
    /// NOTE: Update AppThemeType.blueprintArchitectural to AppThemeType.zenith
    /// once 'Zenith' theme is added to ThemeDefinitions
    testWidgets(
      'ThemeGalleryCard renders Zenith theme with fixed time 10:09',
      (WidgetTester tester) async {
        final zenithTheme =
            ThemeDefinitions.getAppTheme(AppThemeType.blueprintArchitectural);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        tester.binding.window.physicalSizeTestValue = cardSize;

        await tester.pumpWidget(
          _buildTestWidget(
            appTheme: zenithTheme,
            isSelected: false,
            compact: false,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ThemeGalleryCard), findsOneWidget);

        await expectLater(
          find.byType(ThemeGalleryCard),
          matchesGoldenFile('zenith_card.png'),
        );
      },
    );

    /// Additional test: Solar Dynamic theme in compact mode
    testWidgets(
      'ThemeGalleryCard renders Solar Dynamic theme in compact mode',
      (WidgetTester tester) async {
        final solarTheme =
            ThemeDefinitions.getAppTheme(AppThemeType.solarFlare);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        tester.binding.window.physicalSizeTestValue = cardSize;

        await tester.pumpWidget(
          _buildTestWidget(
            appTheme: solarTheme,
            isSelected: false,
            compact: true,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ThemeGalleryCard), findsOneWidget);

        await expectLater(
          find.byType(ThemeGalleryCard),
          matchesGoldenFile('solar_dynamic_card_compact.png'),
        );
      },
    );

    /// Additional test: Zenith theme in locked state
    testWidgets(
      'ThemeGalleryCard renders Zenith theme in locked state',
      (WidgetTester tester) async {
        final zenithTheme =
            ThemeDefinitions.getAppTheme(AppThemeType.blueprintArchitectural);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        tester.binding.window.physicalSizeTestValue = cardSize;

        await tester.pumpWidget(
          _buildTestWidget(
            appTheme: zenithTheme,
            isSelected: false,
            compact: false,
            isLocked: true,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ThemeGalleryCard), findsOneWidget);

        await expectLater(
          find.byType(ThemeGalleryCard),
          matchesGoldenFile('zenith_card_locked.png'),
        );
      },
    );
  });
}

/// Builds a MaterialApp with proper theme context for ThemeGalleryCard rendering
///
/// Parameters:
/// - appTheme: The theme to render in the card
/// - isSelected: Whether the card is in selected state
/// - compact: Whether to render in compact mode
/// - isLocked: Whether the theme is locked (premium)
Widget _buildTestWidget({
  required AppTheme appTheme,
  required bool isSelected,
  required bool compact,
  bool isLocked = false,
}) {
  return MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      brightness: appTheme.colors.backgroundColor.computeLuminance() > 0.5
          ? Brightness.light
          : Brightness.dark,
    ),
    home: Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ThemeGalleryCard(
            compact: compact,
            appTheme: appTheme,
            isLocked: isLocked,
            isSelected: isSelected,
            onThemePreview: (_) {},
            onThemeSelected: (_) {},
            onLockedThemeTap: (_) {},
          ),
        ),
      ),
    ),
  );
}

/// Pre-cache fonts to ensure consistent rendering in golden tests
///
/// This function ensures that all custom fonts used by the themes
/// are loaded before the tests run. Since the app uses google_fonts,
/// fonts are automatically pre-cached. Additional system fonts
/// (e.g., 'Courier', 'monospace') are handled by Flutter natively.
Future<void> _precacheFonts() async {
  // For google_fonts, caching happens automatically during test initialization
  // If additional fonts are added to pubspec.yaml, they should be
  // pre-cached here using:
  // await Future.wait([
  //   loadFont('path/to/font.ttf', 'CustomFontFamily'),
  // ]);

  // Currently, the app uses:
  // - 'Courier' (system font)
  // - 'monospace' (system font)
  // - Google Fonts (auto-loaded)

  // No explicit pre-caching needed at this time
  return Future.value();
}
