import 'dart:async';

import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/providers/theme_provider.dart';
import 'package:true_time/screens/widgets/home_theme_menu_parts/carousel_item_transform.dart';
import 'package:true_time/screens/widgets/home_theme_menu_parts/theme_gallery_card.dart';

class ThemeMenuCarousel extends StatefulWidget {
  final bool compact;
  final PageController pageController;
  final List<AppThemeType> galleryThemes;
  final ThemeProvider themeProvider;
  final bool Function(AppThemeType) isLockedTheme;
  final ValueChanged<AppThemeType> onThemePreview;
  final ValueChanged<AppThemeType> onThemeSelected;
  final ValueChanged<AppThemeType> onLockedThemeTap;
  final VoidCallback onScrollEvent;

  const ThemeMenuCarousel({
    super.key,
    required this.compact,
    required this.pageController,
    required this.galleryThemes,
    required this.themeProvider,
    required this.isLockedTheme,
    required this.onThemePreview,
    required this.onThemeSelected,
    required this.onLockedThemeTap,
    required this.onScrollEvent,
  });

  @override
  State<ThemeMenuCarousel> createState() => _ThemeMenuCarouselState();
}

class _ThemeMenuCarouselState extends State<ThemeMenuCarousel> {
  Timer? _settleDebounce;
  bool _pendingScrollUpdate = false;

  void _flushScrollUpdate() {
    if (!_pendingScrollUpdate) return;
    _pendingScrollUpdate = false;
    widget.onScrollEvent();
  }

  void _scheduleScrollUpdate() {
    _settleDebounce?.cancel();
    _settleDebounce = Timer(const Duration(milliseconds: 90), () {
      if (!mounted) return;
      _flushScrollUpdate();
    });
  }

  @override
  void dispose() {
    _settleDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom +
            (widget.compact ? 8.0 : 20.0),
      ),
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (_) {
          _scheduleScrollUpdate();
          return false;
        },
        child: PageView.builder(
          controller: widget.pageController,
          itemCount: widget.galleryThemes.length,
          physics: const BouncingScrollPhysics(),
          // Defer preview updates until scrolling settles to avoid heavy churn.
          onPageChanged: (_) {
            _pendingScrollUpdate = true;
            _scheduleScrollUpdate();
          },
          itemBuilder: (context, index) {
            final theme = widget.galleryThemes[index];
            final appTheme = ThemeDefinitions.getAppTheme(theme);
            final isLocked = widget.isLockedTheme(theme);
            final isSelected = widget.themeProvider.currentTheme == theme;

            return CarouselItemTransform(
              pageController: widget.pageController,
              index: index,
              child: RepaintBoundary(
                child: ThemeGalleryCard(
                  compact: widget.compact,
                  appTheme: appTheme,
                  isLocked: isLocked,
                  isSelected: isSelected,
                  onThemePreview: widget.onThemePreview,
                  onThemeSelected: widget.onThemeSelected,
                  onLockedThemeTap: widget.onLockedThemeTap,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
