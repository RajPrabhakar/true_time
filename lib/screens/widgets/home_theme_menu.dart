import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/providers/theme_provider.dart';

class HomeThemeMenu extends StatefulWidget {
  final ThemeProvider themeProvider;
  final AppThemeColors themeColors;
  final bool is24HourMode;
  final ValueChanged<bool> on24HourModeChanged;
  final ValueChanged<AppThemeType> onThemePreview;
  final ValueChanged<AppThemeType> onThemeSelected;
  final ValueChanged<AppThemeType> onLockedThemeTap;

  const HomeThemeMenu({
    super.key,
    required this.themeProvider,
    required this.themeColors,
    required this.is24HourMode,
    required this.on24HourModeChanged,
    required this.onThemePreview,
    required this.onThemeSelected,
    required this.onLockedThemeTap,
  });

  @override
  State<HomeThemeMenu> createState() => _HomeThemeMenuState();
}

class _HomeThemeMenuState extends State<HomeThemeMenu> {
  static const String _dummyTime = '10:09';

  static const List<ThemeCategory> _orderedCategories = [
    ThemeCategory.basic,
    ThemeCategory.premium,
    ThemeCategory.dynamic,
    ThemeCategory.skins,
  ];

  static const List<ThemeCategory?> _filters = [
    null,
    ..._orderedCategories,
  ];

  late final PageController _pageController;
  ThemeCategory? _selectedFilter;
  int _lastPreviewIndex = -1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.72);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<AppThemeType> _filteredThemes() {
    final allThemes = ThemeDefinitions.getAllThemes();
    if (_selectedFilter == null) {
      return allThemes;
    }

    return allThemes
        .where(
          (theme) =>
              ThemeDefinitions.getTheme(theme).category == _selectedFilter,
        )
        .toList();
  }

  String _filterLabel(ThemeCategory? category) {
    if (category == null) {
      return 'ALL';
    }

    switch (category) {
      case ThemeCategory.basic:
        return 'BASIC';
      case ThemeCategory.premium:
        return 'PREMIUM';
      case ThemeCategory.dynamic:
        return 'DYNAMIC';
      case ThemeCategory.skins:
        return 'SKINS';
    }
  }

  bool _isLockedTheme(AppThemeType theme) {
    final category = ThemeDefinitions.getTheme(theme).category;
    return category != ThemeCategory.basic && !widget.themeProvider.hasPro;
  }

  String _fontFamilyForTheme(AppThemeType theme) {
    if (theme == AppThemeType.observer) {
      return 'monospace';
    }
    return 'Courier';
  }

  Color _highContrast(Color bg) {
    return bg.computeLuminance() > 0.45
        ? const Color(0xFF111111)
        : Colors.white;
  }

  void _syncPreviewFromPage(List<AppThemeType> themes) {
    if (themes.isEmpty || !_pageController.hasClients) {
      return;
    }

    final page = _pageController.page ?? _pageController.initialPage.toDouble();
    final index = page.round().clamp(0, themes.length - 1);
    if (_lastPreviewIndex == index) {
      return;
    }

    _lastPreviewIndex = index;
    final theme = themes[index];
    if (!_isLockedTheme(theme)) {
      widget.onThemePreview(theme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final galleryThemes = _filteredThemes();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 300;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'BOUTIQUE GALLERY',
                    style: TextStyle(
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      color: widget.themeColors.textColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '24H',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.6,
                          color: widget.themeColors.secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Transform.scale(
                        scale: compact ? 0.78 : 0.84,
                        child: Switch.adaptive(
                          value: widget.is24HourMode,
                          onChanged: widget.on24HourModeChanged,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          activeThumbColor: widget.themeColors.accentColor,
                          activeTrackColor: widget.themeColors.accentColor
                              .withValues(alpha: 0.4),
                          inactiveThumbColor:
                              widget.themeColors.secondaryTextColor,
                          inactiveTrackColor: widget
                              .themeColors.secondaryTextColor
                              .withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom,
              ),
              child: SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final selected = filter == _selectedFilter;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                          _lastPreviewIndex = -1;
                        });

                        if (_pageController.hasClients) {
                          _pageController.jumpToPage(0);
                        }

                        final first = _filteredThemes();
                        if (first.isNotEmpty && !_isLockedTheme(first.first)) {
                          widget.onThemePreview(first.first);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: selected
                              ? widget.themeColors.accentColor
                                  .withValues(alpha: 0.92)
                              : widget.themeColors.secondaryTextColor
                                  .withValues(alpha: 0.18),
                          border: Border.all(
                            color: selected
                                ? widget.themeColors.accentColor
                                : widget.themeColors.secondaryTextColor
                                    .withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          _filterLabel(filter),
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? _highContrast(widget.themeColors.accentColor)
                                : widget.themeColors.textColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: galleryThemes.isEmpty
                  ? Center(
                      child: Text(
                        'No themes in this filter.',
                        style: TextStyle(
                          color: widget.themeColors.secondaryTextColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (_) {
                        _syncPreviewFromPage(galleryThemes);
                        return false;
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.paddingOf(context).bottom,
                        ),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: galleryThemes.length,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (_) =>
                              _syncPreviewFromPage(galleryThemes),
                          itemBuilder: (context, index) {
                            final theme = galleryThemes[index];
                            final colors = ThemeDefinitions.getTheme(theme);
                            final isLocked = _isLockedTheme(theme);
                            final isSelected =
                                widget.themeProvider.currentTheme == theme;
                            final titleColor =
                                _highContrast(colors.backgroundColor);

                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                final page = _pageController.hasClients
                                    ? (_pageController.page ??
                                        _pageController.initialPage.toDouble())
                                    : _pageController.initialPage.toDouble();
                                final delta = (index - page).abs();
                                final scale =
                                    (1 - (delta * 0.15)).clamp(0.85, 1.0);
                                final opacity =
                                    (1 - (delta * 0.4)).clamp(0.6, 1.0);

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
                                    widget.onThemePreview(theme);
                                  }
                                },
                                onTap: () {
                                  if (isLocked) {
                                    HapticFeedback.vibrate();
                                    widget.onLockedThemeTap(theme);
                                    return;
                                  }
                                  widget.onThemeSelected(theme);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    color: colors.backgroundColor,
                                    border: Border.all(
                                      color: isSelected
                                          ? colors.accentColor
                                          : colors.secondaryTextColor
                                              .withValues(alpha: 0.4),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.accentColor
                                            .withValues(alpha: 0.2),
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
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            compact ? 16 : 18,
                                            compact ? 14 : 18,
                                            compact ? 16 : 18,
                                            compact ? 14 : 18,
                                          ),
                                          child: Column(
                                            children: [
                                              const Spacer(flex: 1),
                                              Expanded(
                                                child: Center(
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      _dummyTime,
                                                      style: TextStyle(
                                                        color: colors.textColor,
                                                        fontSize:
                                                            compact ? 54 : 62,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        letterSpacing: theme ==
                                                                AppThemeType
                                                                    .observer
                                                            ? 4.0
                                                            : 2.0,
                                                        fontFamily:
                                                            _fontFamilyForTheme(
                                                                theme),
                                                        fontFeatures: const [
                                                          FontFeature
                                                              .tabularFigures(),
                                                        ],
                                                        shadows: theme ==
                                                                AppThemeType
                                                                    .horologicalInstrument
                                                            ? ThemeDefinitions
                                                                .getHorologicalGlow()
                                                            : null,
                                                      ),
                                                    ),
                                                  ),
                                                ),
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
                                        ),
                                        if (isLocked)
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                    sigmaX: 4,
                                                    sigmaY: 4,
                                                  ),
                                                  child: Container(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.08),
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
                    ),
            ),
          ],
        );
      },
    );
  }
}
