import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/providers/theme_provider.dart';
import 'package:true_time/screens/widgets/home_theme_menu_parts/theme_menu_carousel.dart';
import 'package:true_time/screens/widgets/home_theme_menu_parts/theme_menu_filter_strip.dart';
import 'package:true_time/screens/widgets/home_theme_menu_parts/theme_menu_header.dart';

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
  static const List<ThemeCategory> _orderedCategories = [
    ThemeCategory.basic,
    ThemeCategory.premium,
    ThemeCategory.skins,
  ];

  static const List<ThemeCategory?> _filters = [
    null,
    ..._orderedCategories,
  ];

  static int _persistedPageIndex = 0;
  static ThemeCategory? _persistedSelectedFilter;

  late final PageController _pageController;
  ThemeCategory? _selectedFilter;
  int _lastPreviewIndex = -1;

  @override
  void initState() {
    super.initState();
    _selectedFilter = _persistedSelectedFilter;
    _pageController = PageController(
      viewportFraction: 0.72,
      initialPage: _persistedPageIndex,
    );
  }

  @override
  void dispose() {
    if (_pageController.hasClients) {
      _persistedPageIndex =
          (_pageController.page ?? _pageController.initialPage.toDouble())
              .round();
    } else {
      _persistedPageIndex = _pageController.initialPage;
    }
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
              ThemeDefinitions.getAppTheme(theme).category == _selectedFilter,
        )
        .toList();
  }

  bool _isLockedTheme(AppThemeType theme) {
    return ThemeDefinitions.getAppTheme(theme).isPremium &&
        !widget.themeProvider.hasPro;
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
    _persistedPageIndex = index;
    final theme = themes[index];
    widget.onThemePreview(theme);
  }

  @override
  Widget build(BuildContext context) {
    final galleryThemes = _filteredThemes();

    return LayoutBuilder(
      builder: (context, constraints) {
        final panelHeight = constraints.maxHeight;
        final compact = panelHeight < 320;
        final showHeader = panelHeight >= 150;
        final showFilters = panelHeight >= 205;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              ThemeMenuHeader(
                compact: compact,
                themeColors: widget.themeColors,
              ),
            if (showFilters)
              ThemeMenuFilterStrip(
                filters: _filters,
                selectedFilter: _selectedFilter,
                themeColors: widget.themeColors,
                onSelectFilter: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                    _persistedSelectedFilter = filter;
                    _lastPreviewIndex = -1;
                    _persistedPageIndex = 0;
                  });

                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(0);
                  }

                  final first = _filteredThemes();
                  if (first.isNotEmpty) {
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
                      pageController: _pageController,
                      galleryThemes: galleryThemes,
                      themeProvider: widget.themeProvider,
                      isLockedTheme: _isLockedTheme,
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
