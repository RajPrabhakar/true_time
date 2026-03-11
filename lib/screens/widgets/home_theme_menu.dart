import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/providers/theme_provider.dart';
import 'package:true_time/screens/widgets/home_theme_menu_parts/theme_menu_carousel.dart';
import 'package:true_time/screens/widgets/home_theme_menu_parts/theme_menu_filter_strip.dart';
import 'package:true_time/screens/widgets/home_theme_menu_parts/theme_menu_header.dart';

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
            ThemeMenuHeader(
              compact: compact,
              themeColors: widget.themeColors,
              is24HourMode: widget.is24HourMode,
              on24HourModeChanged: widget.on24HourModeChanged,
            ),
            ThemeMenuFilterStrip(
              filters: _filters,
              selectedFilter: _selectedFilter,
              themeColors: widget.themeColors,
              onSelectFilter: (filter) {
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
                  : ThemeMenuCarousel(
                      compact: compact,
                      dummyTime: _dummyTime,
                      pageController: _pageController,
                      galleryThemes: galleryThemes,
                      themeProvider: widget.themeProvider,
                      isLockedTheme: _isLockedTheme,
                      fontFamilyForTheme: _fontFamilyForTheme,
                      highContrast: _highContrast,
                      onThemePreview: widget.onThemePreview,
                      onThemeSelected: widget.onThemeSelected,
                      onLockedThemeTap: widget.onLockedThemeTap,
                      onScrollEvent: () => _syncPreviewFromPage(galleryThemes),
                    ),
            ),
          ],
        );
      },
    );
  }
}
