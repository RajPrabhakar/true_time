
import 'package:flutter_test/flutter_test.dart';
import 'package:true_time/models/app_theme.dart';

void main() {
  group('Theme Registry Integrity Tests', () {



    late List<AppThemeType> allThemes;

    setUp(() {
      allThemes = ThemeDefinitions.getAllThemes();
    });

    test('Theme registry contains expected number of themes', () {
      expect(allThemes, isNotEmpty);
      expect(allThemes.length, equals(AppThemeType.values.length),
          reason: 'All defined AppThemeType enum values should be in registry');
    });

    test('Every theme has valid AppTheme definition', () {
      for (final themeType in allThemes) {
        final theme = ThemeDefinitions.getAppTheme(themeType);
        expect(theme, isNotNull, reason: 'Theme $themeType should be defined');
        expect(theme.id, equals(themeType),
            reason: 'Theme ID should match its type');
        expect(theme.name, isNotEmpty,
            reason: 'Theme ${themeType.name} should have a non-empty name');
      }
    });

    group('customPreviewBackgroundBuilder Regression Prevention', () {
      test(
        'All themes must provide customPreviewBackgroundBuilder',
        () {
          final themesMissingPreviewBackground = <String>[];

          for (final themeType in allThemes) {
            final theme = ThemeDefinitions.getAppTheme(themeType);
            if (theme.customPreviewBackgroundBuilder == null) {
              themesMissingPreviewBackground.add(theme.name);
            }
          }

          expect(
            themesMissingPreviewBackground,
            isEmpty,
            reason:
                'The following themes are missing customPreviewBackgroundBuilder '
                'which can cause transparency/stuttering regression: '
                '${themesMissingPreviewBackground.join(", ")}. '
                'Each theme must provide its own preview background builder to '
                'prevent falling back to default ColoredBox behavior.',
          );
        },
      );
    });

    group('Skin Category Theme Requirements', () {
      test(
        'All skins category themes must provide customClockBuilder',
        () {
          final skinThemes = allThemes
              .where((t) => ThemeDefinitions.getAppTheme(t).category ==
                  ThemeCategory.skins)
              .toList();

          expect(skinThemes, isNotEmpty,
              reason: 'Should have at least one skin theme defined');

          final skinsMissingClockBuilder = <String>[];

          for (final skinTheme in skinThemes) {
            final theme = ThemeDefinitions.getAppTheme(skinTheme);
            if (theme.customClockBuilder == null) {
              skinsMissingClockBuilder.add(theme.name);
            }
          }

          expect(
            skinsMissingClockBuilder,
            isEmpty,
            reason:
                'The following skin category themes are missing customClockBuilder: '
                '${skinsMissingClockBuilder.join(", ")}. '
                'All skins MUST provide a unique clock builder for proper theming.',
          );
        },
      );
    });

    group('Font Family Validation', () {
      test(
        'No theme should have empty fontFamily string',
        () {
          final themesWithEmptyFont = <String>[];

          for (final themeType in allThemes) {
            final theme = ThemeDefinitions.getAppTheme(themeType);
            if (theme.fontFamily.isEmpty) {
              themesWithEmptyFont.add(theme.name);
            }
          }

          expect(
            themesWithEmptyFont,
            isEmpty,
            reason:
                'The following themes have empty fontFamily: ${themesWithEmptyFont.join(", ")}. '
                'All themes must specify a valid font family.',
          );
        },
      );

      test(
        'All themes should have non-whitespace fontFamily',
        () {
          final themesWithWhitespaceFont = <String>[];

          for (final themeType in allThemes) {
            final theme = ThemeDefinitions.getAppTheme(themeType);
            if (theme.fontFamily.trim().isEmpty) {
              themesWithWhitespaceFont.add(theme.name);
            }
          }

          expect(
            themesWithWhitespaceFont,
            isEmpty,
            reason:
                'The following themes have whitespace-only fontFamily: ${themesWithWhitespaceFont.join(", ")}',
          );
        },
      );
    });

    group('Theme Consistency Checks', () {
      test(
        'Theme IDs should be unique',
        () {
          final ids = allThemes.map((t) => t.index).toSet();
          expect(ids.length, equals(allThemes.length),
              reason: 'All theme IDs should be unique');
        },
      );

      test(
        'Theme names should be non-empty and distinct',
        () {
          final names = <String>{};

          for (final themeType in allThemes) {
            final theme = ThemeDefinitions.getAppTheme(themeType);
            expect(theme.name, isNotEmpty,
                reason: 'Theme $themeType should have a name');
            expect(
              names.contains(theme.name),
              false,
              reason:
                  'Theme name "${theme.name}" is duplicated. Each theme must have a unique name.',
            );
            names.add(theme.name);
          }
        },
      );

      test(
        'Theme categories should be valid',
        () {
          for (final themeType in allThemes) {
            final theme = ThemeDefinitions.getAppTheme(themeType);
            expect(
              theme.category,
              isIn([ThemeCategory.basic, ThemeCategory.premium, ThemeCategory.skins]),
              reason: 'Theme ${theme.name} has invalid category',
            );
          }
        },
      );

      test(
        'Premium flag should match theme category',
        () {
          for (final themeType in allThemes) {
            final theme = ThemeDefinitions.getAppTheme(themeType);

            // Premium and skins themes should be marked as premium
            final shouldBePremium = theme.category == ThemeCategory.premium ||
                theme.category == ThemeCategory.skins;

            expect(
              theme.isPremium,
              equals(shouldBePremium),
              reason:
                  'Theme ${theme.name} (${theme.category}) has incorrect isPremium flag',
            );
          }
        },
      );
    });

    group('Clock Shadows Validation', () {
      test(
        'Clock shadows should not be empty list if defined',
        () {
          for (final themeType in allThemes) {
            final theme = ThemeDefinitions.getAppTheme(themeType);

            if (theme.clockShadows != null) {
              expect(
                theme.clockShadows,
                isNotEmpty,
                reason:
                    'Theme ${theme.name} has clockShadows defined but empty',
              );
            }
          }
        },
      );
    });

    group('Builder Functions Integrity', () {
      test(
        'customPreviewBackgroundBuilder should be function type if defined',
        () {
          for (final themeType in allThemes) {
            final theme = ThemeDefinitions.getAppTheme(themeType);

            if (theme.customPreviewBackgroundBuilder != null) {
              expect(
                theme.customPreviewBackgroundBuilder,
                isA<Function>(),
                reason:
                    'Theme ${theme.name} customPreviewBackgroundBuilder should be callable',
              );
            }
          }
        },
      );

      test(
        'customClockBuilder should be function type if defined',
        () {
          for (final themeType in allThemes) {
            final theme = ThemeDefinitions.getAppTheme(themeType);

            if (theme.customClockBuilder != null) {
              expect(
                theme.customClockBuilder,
                isA<Function>(),
                reason:
                    'Theme ${theme.name} customClockBuilder should be callable',
              );
            }
          }
        },
      );

      test(
        'customBackgroundBuilder should be function type if defined',
        () {
          for (final themeType in allThemes) {
            final theme = ThemeDefinitions.getAppTheme(themeType);

            if (theme.customBackgroundBuilder != null) {
              expect(
                theme.customBackgroundBuilder,
                isA<Function>(),
                reason:
                    'Theme ${theme.name} customBackgroundBuilder should be callable',
              );
            }
          }
        },
      );
    });

    group('Color Validation', () {
      test(
        'All themes should have valid color properties',
        () {
          for (final themeType in allThemes) {
            final theme = ThemeDefinitions.getAppTheme(themeType);
            final colors = theme.colors;

            expect(colors.backgroundColor, isNotNull,
                reason: 'Theme ${theme.name} should have backgroundColor');
            expect(colors.textColor, isNotNull,
                reason: 'Theme ${theme.name} should have textColor');
            expect(colors.secondaryTextColor, isNotNull,
                reason: 'Theme ${theme.name} should have secondaryTextColor');
            expect(colors.accentColor, isNotNull,
                reason: 'Theme ${theme.name} should have accentColor');
          }
        },
      );
    });

    test('All themes registered in enum are present in definitions', () {
      final registeredThemes = allThemes.toSet();
      final enumThemes = AppThemeType.values.toSet();

      expect(
        registeredThemes,
        equals(enumThemes),
        reason:
            'All AppThemeType enum values must be registered in ThemeDefinitions.themes',
      );
    });
  });
}
