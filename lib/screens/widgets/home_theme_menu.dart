import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const List<String> _categories = [
    'Essentials',
    'Vintage',
    'Dynamic',
  ];

  static const Set<AppThemeType> _premiumThemes = {
    AppThemeType.blueprintArchitectural,
    AppThemeType.retroFlip,
    AppThemeType.zenith,
  };

  static const Set<AppThemeType> _celestialThemes = {
    AppThemeType.zenith,
    AppThemeType.solarDynamic,
    AppThemeType.solarDrift,
    AppThemeType.blueprintArchitectural,
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

  String _selectedCategory = 'Essentials';
  final Map<String, PageController> _pageControllers = {};
  final Map<String, VoidCallback> _pageListeners = {};
  final Map<String, int> _activeIndexByCategory = {};
  final Map<String, int> _lastPreviewIndexByCategory = {};
  final Map<String, int> _lastDetentIndexByCategory = {};

  @override
  void initState() {
    super.initState();
    final activeCategory =
        ThemeDefinitions.getTheme(widget.themeProvider.activeTheme).category;
    if (_categories.contains(activeCategory)) {
      _selectedCategory = activeCategory;
    }
  }

  @override
  void dispose() {
    for (final entry in _pageControllers.entries) {
      final listener = _pageListeners[entry.key];
      if (listener != null) {
        entry.value.removeListener(listener);
      }
    }
    for (final controller in _pageControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<AppThemeType> _themesForCategory(String category) {
    return ThemeDefinitions.getAllThemes()
        .where((theme) => ThemeDefinitions.getTheme(theme).category == category)
        .toList();
  }

  String _sectionTitleForCategory(String category) {
    if (category == 'Essentials') {
      return 'THE CORE COLLECTION';
    }
    if (category == 'Vintage') {
      return 'THE VINTAGE COLLECTION';
    }
    return 'THE DYNAMIC COLLECTION';
  }

  List<AppThemeType> _themesForSelectedCategory() {
    return _themesForCategory(_selectedCategory);
  }

  PageController _controllerForCategory(
    String category,
    List<AppThemeType> themes,
  ) {
    final existing = _pageControllers[category];
    if (existing != null) {
      if (!_pageListeners.containsKey(category)) {
        _attachPageListener(category, themes, existing);
      }
      return existing;
    }

    final savedIndex = _activeIndexByCategory[category] ?? 0;
    final activeIndex = themes.indexOf(widget.themeProvider.activeTheme);
    final initial = activeIndex >= 0 ? activeIndex : savedIndex;
    final initialPage =
        initial.clamp(0, themes.isEmpty ? 0 : themes.length - 1);

    final controller = PageController(
      viewportFraction: 0.76,
      initialPage: initialPage,
    );
    _pageControllers[category] = controller;
    _activeIndexByCategory[category] = initialPage;
    _lastPreviewIndexByCategory[category] = initialPage;
    _lastDetentIndexByCategory[category] = initialPage;
    _attachPageListener(category, themes, controller);
    return controller;
  }

  void _attachPageListener(
    String category,
    List<AppThemeType> themes,
    PageController controller,
  ) {
    if (themes.isEmpty) {
      return;
    }

    final existing = _pageListeners[category];
    if (existing != null) {
      controller.removeListener(existing);
    }

    void listener() {
      if (!controller.hasClients || themes.isEmpty) {
        return;
      }

      final page = controller.page ?? controller.initialPage.toDouble();
      final centered = page.round().clamp(0, themes.length - 1);
      if (_lastPreviewIndexByCategory[category] == centered) {
        return;
      }

      _lastPreviewIndexByCategory[category] = centered;
      _activeIndexByCategory[category] = centered;
      widget.onThemePreview(themes[centered]);
    }

    controller.addListener(listener);
    _pageListeners[category] = listener;
  }

  void _syncCategoryPreview(String category, List<AppThemeType> themes) {
    if (themes.isEmpty) {
      return;
    }

    final controller = _controllerForCategory(category, themes);
    if (!controller.hasClients) {
      final index = _activeIndexByCategory[category] ?? 0;
      final centered = index.clamp(0, themes.length - 1);
      _lastPreviewIndexByCategory[category] = centered;
      widget.onThemePreview(themes[centered]);
      return;
    }

    final page = controller.page ?? controller.initialPage.toDouble();
    final centered = page.round().clamp(0, themes.length - 1);
    if (_lastPreviewIndexByCategory[category] != centered) {
      _lastPreviewIndexByCategory[category] = centered;
      widget.onThemePreview(themes[centered]);
    }
  }

  double _cardScale(double pageDelta) {
    return (1 - (pageDelta.abs() * 0.15)).clamp(0.85, 1.0);
  }

  double _cardOpacity(double pageDelta) {
    return (1 - (pageDelta.abs() * 0.45)).clamp(0.55, 1.0);
  }

  double _cardParallax(double pageDelta) {
    final shift = -pageDelta * 22;
    return shift.clamp(-26, 26);
  }

  Color _highContrast(Color bg) {
    return bg.computeLuminance() > 0.45
        ? const Color(0xFF111111)
        : Colors.white;
  }

  double _contrastRatio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }

  Color _chipForeground(Color bg) {
    const dark = Color(0xFF111111);
    const light = Colors.white;
    final darkContrast = _contrastRatio(bg, dark);
    final lightContrast = _contrastRatio(bg, light);

    // Prefer darker text for better perceived sharpness unless it fails contrast.
    if (darkContrast >= 4.5) {
      return dark;
    }
    if (lightContrast >= 4.5) {
      return light;
    }

    return darkContrast >= lightContrast ? dark : light;
  }

  Color _chipBackground({required bool selected}) {
    final source = selected
        ? widget.themeColors.accentColor
        : widget.themeColors.secondaryTextColor;
    final alpha = selected ? 0.92 : 0.34;
    final blended = Color.alphaBlend(
      source.withValues(alpha: alpha),
      widget.themeColors.backgroundColor,
    );

    final pageContrast =
        _contrastRatio(blended, widget.themeColors.backgroundColor);
    if (pageContrast < 1.6) {
      return widget.themeColors.backgroundColor.computeLuminance() > 0.5
          ? const Color(0xFF222222)
          : const Color(0xFFECECEC);
    }

    return blended;
  }

  @override
  Widget build(BuildContext context) {
    final sectionTitle = _sectionTitleForCategory(_selectedCategory);
    final sectionThemes = _themesForSelectedCategory();
    final sectionController =
        _controllerForCategory(_selectedCategory, sectionThemes);

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
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _categories.map((category) {
              final selected = _selectedCategory == category;
              final selectedBg = _chipBackground(selected: true);
              final unselectedBg = _chipBackground(selected: false);
              final chipBg = selected ? selectedBg : unselectedBg;
              final chipText = _chipForeground(chipBg);
              return ChoiceChip(
                label: Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: chipText,
                  ),
                ),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedCategory = category;
                  });

                  final themed = _themesForCategory(category);
                  _syncCategoryPreview(category, themed);
                },
                selectedColor: selectedBg,
                backgroundColor: unselectedBg,
                side: BorderSide(
                  color: chipText.withValues(alpha: selected ? 0.7 : 0.55),
                  width: selected ? 1.8 : 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                showCheckmark: true,
                checkmarkColor: chipText,
                elevation: selected ? 2 : 0,
                shadowColor: chipText.withValues(alpha: 0.22),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: sectionThemes.isEmpty
                ? Center(
                    child: Text(
                      'No themes in this collection yet.',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.themeColors.secondaryTextColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sectionTitle,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: widget.themeColors.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: PageView.builder(
                          controller: sectionController,
                          itemCount: sectionThemes.length,
                          onPageChanged: (index) {
                            _activeIndexByCategory[_selectedCategory] = index;
                            if (_lastDetentIndexByCategory[_selectedCategory] !=
                                index) {
                              _lastDetentIndexByCategory[_selectedCategory] =
                                  index;
                              HapticFeedback.selectionClick();
                            }
                            widget.onThemePreview(sectionThemes[index]);
                          },
                          itemBuilder: (context, index) {
                            final theme = sectionThemes[index];
                            final colors = ThemeDefinitions.getTheme(theme);
                            final isPremium = _premiumThemes.contains(theme);
                            final isLocked =
                                isPremium && !widget.themeProvider.hasPro;
                            final isSelected =
                                widget.themeProvider.currentTheme == theme;
                            final isCelestial =
                                _celestialThemes.contains(theme);
                            final titleColor =
                                _highContrast(colors.backgroundColor);
                            final borderRadius = BorderRadius.circular(14);

                            return AnimatedBuilder(
                              animation: sectionController,
                              builder: (context, child) {
                                final page = sectionController.hasClients
                                    ? (sectionController.page ??
                                        sectionController.initialPage
                                            .toDouble())
                                    : sectionController.initialPage.toDouble();
                                final pageDelta = index - page;
                                final cardScale = _cardScale(pageDelta);
                                final cardOpacity = _cardOpacity(pageDelta);
                                final parallax = _cardParallax(pageDelta);

                                return Opacity(
                                  opacity: cardOpacity,
                                  child: Transform.scale(
                                    scale: cardScale,
                                    child: child == null
                                        ? const SizedBox.shrink()
                                        : _ThemeStoreCardShell(
                                            card: child,
                                            parallax: parallax,
                                            colors: colors,
                                            titleColor: titleColor,
                                            borderRadius: borderRadius,
                                          ),
                                  ),
                                );
                              },
                              child: GestureDetector(
                                onTapDown: (_) => widget.onThemePreview(theme),
                                onTap: () {
                                  if (isLocked) {
                                    widget.onLockedThemeTap(theme);
                                    return;
                                  }
                                  widget.onThemeSelected(theme);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: colors.backgroundColor
                                          .withValues(alpha: 0.74),
                                      borderRadius: borderRadius,
                                      border: Border.all(
                                        color: isCelestial
                                            ? const Color(0xFFD4AF37)
                                            : (isSelected
                                                ? colors.accentColor
                                                : colors.secondaryTextColor
                                                    .withValues(alpha: 0.45)),
                                        width: isCelestial
                                            ? 1.2
                                            : (isSelected ? 2 : 1),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors.accentColor
                                              .withValues(alpha: 0.2),
                                          blurRadius: 14,
                                          spreadRadius: 0.5,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                            ),
                                            if (isLocked)
                                              Icon(
                                                Icons.lock,
                                                size: 16,
                                                color: titleColor.withValues(
                                                    alpha: 0.88),
                                              )
                                            else if (isSelected)
                                              Icon(
                                                Icons.check_circle,
                                                size: 16,
                                                color: colors.accentColor,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Spacer(),
                                        Text(
                                          _descriptors[theme] ??
                                              colors.description,
                                          style: TextStyle(
                                            fontSize: 11,
                                            height: 1.35,
                                            color: titleColor.withValues(
                                                alpha: 0.84),
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
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ThemeStoreCardShell extends StatelessWidget {
  final Widget card;
  final double parallax;
  final AppThemeColors colors;
  final Color titleColor;
  final BorderRadius borderRadius;

  const _ThemeStoreCardShell({
    required this.card,
    required this.parallax,
    required this.colors,
    required this.titleColor,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(
            offset: Offset(parallax, 0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.backgroundColor.withValues(alpha: 0.82),
                    colors.accentColor.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: _ThemeParallaxGridPainter(
                  lineColor: titleColor.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          card,
        ],
      ),
    );
  }
}

class _ThemeParallaxGridPainter extends CustomPainter {
  final Color lineColor;

  const _ThemeParallaxGridPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    const spacing = 18.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThemeParallaxGridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}
