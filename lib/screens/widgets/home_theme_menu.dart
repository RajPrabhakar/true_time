import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/providers/theme_provider.dart';

class HomeThemeMenu extends StatefulWidget {
  final ThemeProvider themeProvider;
  final AppThemeColors themeColors;
  final ValueChanged<AppThemeType> onThemePreview;
  final ValueChanged<AppThemeType> onThemeSelected;
  final ValueChanged<AppThemeType> onLockedThemeTap;

  const HomeThemeMenu({
    super.key,
    required this.themeProvider,
    required this.themeColors,
    required this.onThemePreview,
    required this.onThemeSelected,
    required this.onLockedThemeTap,
  });

  @override
  State<HomeThemeMenu> createState() => _HomeThemeMenuState();
}

class _HomeThemeMenuState extends State<HomeThemeMenu> {
  static const Set<AppThemeType> _premiumThemes = {
    AppThemeType.blueprintArchitectural,
    AppThemeType.retroFlip,
    AppThemeType.zenith,
  };

  static const Map<AppThemeType, String> _descriptors = {
    AppThemeType.void_: 'Optimized for OLED battery saving',
    AppThemeType.blueprint: 'Crisp technical cyan contrast',
    AppThemeType.solarFlare: 'Daylight-ready high visibility',
    AppThemeType.solarDynamic: 'Breathes from dawn to dusk',
    AppThemeType.horologicalInstrument: 'Amber instrument-panel nostalgia',
    AppThemeType.bauhaus1925: 'Graphic modernist art energy',
    AppThemeType.solarDrift: 'Atmospheric gradient drift',
    AppThemeType.blueprintArchitectural: 'CAD grid overlays and precision',
    AppThemeType.observer: 'Mission-control red telemetry tone',
    AppThemeType.cartographer: 'Warm atlas parchment character',
    AppThemeType.zenith: 'Immersive indigo skyfield gradient',
    AppThemeType.retroFlip: 'Mechanical split-flap clock vibe',
    AppThemeType.monolith: 'Essential UI, zero distraction',
  };

  late final List<AppThemeType> _themes;
  late final PageController _pageController;
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _themes = ThemeDefinitions.getAllThemes();
    _activeIndex = _themes.indexOf(widget.themeProvider.activeTheme);
    if (_activeIndex < 0) {
      _activeIndex = 0;
    }
    _pageController = PageController(
      initialPage: _activeIndex,
      viewportFraction: 0.78,
    )..addListener(_onPageScroll);
  }

  @override
  void didUpdateWidget(covariant HomeThemeMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    final targetIndex = _themes.indexOf(widget.themeProvider.activeTheme);
    if (targetIndex >= 0 && targetIndex != _activeIndex) {
      _activeIndex = targetIndex;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          targetIndex,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    if (!_pageController.hasClients || !_pageController.position.hasPixels) {
      return;
    }
    final page = _pageController.page;
    if (page == null) {
      return;
    }
    final hoveredIndex = page.round().clamp(0, _themes.length - 1);
    if (hoveredIndex == _activeIndex) {
      return;
    }

    setState(() {
      _activeIndex = hoveredIndex;
    });
    widget.onThemePreview(_themes[hoveredIndex]);
  }

  Color _highContrast(Color bg) {
    return bg.computeLuminance() > 0.45 ? const Color(0xFF111111) : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'THEME GALLERY',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.themeColors.textColor,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _themes.length,
              onPageChanged: (index) {
                if (_activeIndex == index) {
                  return;
                }
                setState(() {
                  _activeIndex = index;
                });
                widget.onThemePreview(_themes[index]);
              },
              itemBuilder: (context, index) {
                final theme = _themes[index];
                final colors = ThemeDefinitions.getTheme(theme);
                final isHovered = index == _activeIndex;
                final isPremium = _premiumThemes.contains(theme);
                final isLocked = isPremium && !widget.themeProvider.hasPro;
                final isSelected = widget.themeProvider.currentTheme == theme;
                final titleColor = _highContrast(colors.backgroundColor);

                return AnimatedScale(
                  scale: isHovered ? 1.0 : 0.94,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: GestureDetector(
                    onTap: () {
                      if (isLocked) {
                        widget.onLockedThemeTap(theme);
                        return;
                      }
                      widget.onThemeSelected(theme);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isHovered
                              ? colors.accentColor.withValues(alpha: 0.9)
                              : colors.secondaryTextColor.withValues(alpha: 0.5),
                          width: isHovered ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.accentColor.withValues(alpha: isHovered ? 0.25 : 0.1),
                            blurRadius: isHovered ? 16 : 8,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  colors.name.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: titleColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                              ),
                              if (isLocked)
                                Icon(
                                  Icons.lock,
                                  size: 18,
                                  color: titleColor.withValues(alpha: 0.9),
                                )
                              else if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: colors.accentColor,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 5,
                            width: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colors.accentColor,
                                  colors.textColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _descriptors[theme] ?? colors.description,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              color: titleColor.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
