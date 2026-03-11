import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/providers/theme_provider.dart';

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
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        onScrollEvent();
        return false;
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + (compact ? 8.0 : 20.0),
        ),
        child: PageView.builder(
          controller: pageController,
          itemCount: galleryThemes.length,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (_) => onScrollEvent(),
          itemBuilder: (context, index) {
            final theme = galleryThemes[index];
            final colors = ThemeDefinitions.getTheme(theme);
            final isLocked = isLockedTheme(theme);
            final isSelected = themeProvider.currentTheme == theme;
            final titleColor = highContrast(colors.backgroundColor);

            return AnimatedBuilder(
              animation: pageController,
              builder: (context, child) {
                final page = pageController.hasClients
                    ? (pageController.page ?? pageController.initialPage.toDouble())
                    : pageController.initialPage.toDouble();
                final delta = (index - page).abs();
                final scale = (1 - (delta * 0.15)).clamp(0.85, 1.0);
                final opacity = (1 - (delta * 0.4)).clamp(0.6, 1.0);

                return Center(
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  ),
                );
              },
              child: GestureDetector(
                onTapDown: (_) {
                  if (!isLocked) {
                    onThemePreview(theme);
                  }
                },
                onTap: () {
                  if (isLocked) {
                    HapticFeedback.vibrate();
                    onLockedThemeTap(theme);
                    return;
                  }
                  onThemeSelected(theme);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: colors.backgroundColor,
                    border: Border.all(
                      color: isSelected
                          ? colors.accentColor
                          : colors.secondaryTextColor.withValues(alpha: 0.4),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.accentColor.withValues(alpha: 0.2),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        LayoutBuilder(
                          builder: (context, cardConstraints) {
                            final h = cardConstraints.maxHeight;
                            final tiny = h < 170;
                            final padH = tiny ? 12.0 : (compact ? 16.0 : 18.0);
                            final padV = tiny ? 8.0 : (compact ? 14.0 : 18.0);
                            final showTitle = h > 120;

                            final timeText = FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                dummyTime,
                                style: TextStyle(
                                  color: colors.textColor,
                                  fontSize: compact ? 54 : 62,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing:
                                      theme == AppThemeType.observer ? 4.0 : 2.0,
                                  fontFamily: fontFamilyForTheme(theme),
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  shadows:
                                      theme == AppThemeType.horologicalInstrument
                                          ? ThemeDefinitions.getHorologicalGlow()
                                          : null,
                                ),
                              ),
                            );

                            return Padding(
                              padding: EdgeInsets.fromLTRB(
                                padH,
                                padV,
                                padH,
                                padV,
                              ),
                              child: tiny
                                  ? Column(
                                      children: [
                                        Expanded(
                                          child: Center(child: timeText),
                                        ),
                                        if (showTitle)
                                          Text(
                                            colors.name.toUpperCase(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: titleColor,
                                              fontSize: 10,
                                              letterSpacing: 2.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        const Spacer(flex: 1),
                                        Expanded(
                                          child: Center(child: timeText),
                                        ),
                                        const Spacer(flex: 1),
                                        Text(
                                          colors.name.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: titleColor,
                                            fontSize: 10,
                                            letterSpacing: 2.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            );
                          },
                        ),
                        if (isLocked)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 4,
                                    sigmaY: 4,
                                  ),
                                  child: Container(
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                                const Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
