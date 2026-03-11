import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/providers/theme_provider.dart';
import 'package:true_time/screens/widgets/home_theme_menu_parts/carousel_item_transform.dart';
import 'package:true_time/screens/widgets/home_theme_menu_parts/theme_gallery_card.dart';

class ThemeMenuCarousel extends StatelessWidget {
  final bool compact;
  final String dummyTime;
  final PageController pageController;
  final List<AppThemeType> galleryThemes;
  final ThemeProvider themeProvider;
  final bool Function(AppThemeType) isLockedTheme;
  final String Function(AppThemeType) fontFamilyForTheme;
  final Color Function(Color) highContrast;
  final ValueChanged<AppThemeType> onThemePreview;
  final ValueChanged<AppThemeType> onThemeSelected;
  final ValueChanged<AppThemeType> onLockedThemeTap;
  final VoidCallback onScrollEvent;

  const ThemeMenuCarousel({
    super.key,
    required this.compact,
    required this.dummyTime,
    required this.pageController,
    required this.galleryThemes,
    required this.themeProvider,
    required this.isLockedTheme,
    required this.fontFamilyForTheme,
    required this.highContrast,
    required this.onThemePreview,
    required this.onThemeSelected,
    required this.onLockedThemeTap,
    required this.onScrollEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + (compact ? 8.0 : 20.0),
      ),
      child: PageView.builder(
        controller: pageController,
        itemCount: galleryThemes.length,
        physics: const BouncingScrollPhysics(),
        // Preview only when snap settles to avoid expensive per-frame rebuilds.
        onPageChanged: (_) => onScrollEvent(),
        itemBuilder: (context, index) {
          final theme = galleryThemes[index];
          final colors = ThemeDefinitions.getTheme(theme);
          final isLocked = isLockedTheme(theme);
          final isSelected = themeProvider.currentTheme == theme;

          return CarouselItemTransform(
            pageController: pageController,
            index: index,
            child: ThemeGalleryCard(
              compact: compact,
              dummyTime: dummyTime,
              theme: theme,
              colors: colors,
              isLocked: isLocked,
              isSelected: isSelected,
              fontFamilyForTheme: fontFamilyForTheme,
              highContrast: highContrast,
              onThemePreview: onThemePreview,
              onThemeSelected: onThemeSelected,
              onLockedThemeTap: onLockedThemeTap,
            ),
          );
        },
      ),
    );
  }
}
