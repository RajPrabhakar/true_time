import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/providers/theme_provider.dart';

class HomeThemeMenu extends StatelessWidget {
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

  static const List<ThemeCategory> _orderedCategories = [
    ThemeCategory.basic,
    ThemeCategory.premium,
    ThemeCategory.dynamic,
    ThemeCategory.skins,
  ];

  List<AppThemeType> _themesForCategory(ThemeCategory category) {
    return ThemeDefinitions.getAllThemes()
        .where((theme) => ThemeDefinitions.getTheme(theme).category == category)
        .toList();
  }

  String _sectionHeader(ThemeCategory category) {
    switch (category) {
      case ThemeCategory.basic:
        return 'BASIC THEMES';
      case ThemeCategory.premium:
        return 'PREMIUM THEMES';
      case ThemeCategory.dynamic:
        return 'DYNAMIC THEMES';
      case ThemeCategory.skins:
        return 'SKINS';
    }
  }

  bool _isLocked({required ThemeCategory category}) {
    return category != ThemeCategory.basic && !themeProvider.hasPro;
  }

  Color _highContrast(Color bg) {
    return bg.computeLuminance() > 0.45
        ? const Color(0xFF111111)
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final panelHeight = constraints.maxHeight;
        final compact = panelHeight < 300;
        final veryTight = panelHeight < 220;
        final horizontalPadding = compact ? 12.0 : 16.0;
        final topPadding = veryTight ? 8.0 : 12.0;
        final rowHeight = veryTight ? 108.0 : 120.0;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            compact ? 8.0 : 12.0,
          ),
          child: Column(
            children: [
              Text(
                'THEME GALLERY',
                style: TextStyle(
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: themeColors.textColor,
                  letterSpacing: compact ? 1.5 : 2.0,
                ),
              ),
              SizedBox(height: compact ? 6 : 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Use 24-Hour Format',
                      style: TextStyle(
                        fontSize: compact ? 10.5 : 11.5,
                        fontWeight: FontWeight.w600,
                        color: themeColors.secondaryTextColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: compact ? 0.82 : 0.9,
                    child: Switch.adaptive(
                      value: is24HourMode,
                      onChanged: on24HourModeChanged,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeThumbColor: themeColors.accentColor,
                      activeTrackColor:
                          themeColors.accentColor.withValues(alpha: 0.4),
                      inactiveThumbColor: themeColors.secondaryTextColor,
                      inactiveTrackColor:
                          themeColors.secondaryTextColor.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 6 : 10),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _orderedCategories.length,
                  separatorBuilder: (_, __) => SizedBox(height: compact ? 10 : 14),
                  itemBuilder: (context, sectionIndex) {
                    final category = _orderedCategories[sectionIndex];
                    final themes = _themesForCategory(category);
                    final lockedSection = _isLocked(category: category);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _sectionHeader(category),
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: rowHeight,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: themes.length,
                            itemBuilder: (context, index) {
                              final theme = themes[index];
                              final colors = ThemeDefinitions.getTheme(theme);
                              final isSelected = themeProvider.currentTheme == theme;
                              final titleColor = _highContrast(colors.backgroundColor);

                              return SizedBox(
                                width: veryTight ? 182 : 208,
                                child: GestureDetector(
                                  onTapDown: (_) {
                                    if (!lockedSection) {
                                      onThemePreview(theme);
                                    }
                                  },
                                  onTap: () {
                                    if (lockedSection) {
                                      HapticFeedback.vibrate();
                                      onLockedThemeTap(theme);
                                      return;
                                    }
                                    onThemeSelected(theme);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Stack(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          decoration: BoxDecoration(
                                            color: colors.backgroundColor.withValues(alpha: 0.82),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: isSelected
                                                  ? colors.accentColor
                                                  : colors.secondaryTextColor.withValues(alpha: 0.5),
                                              width: isSelected ? 2 : 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colors.accentColor.withValues(alpha: 0.18),
                                                blurRadius: 12,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(veryTight ? 8 : 12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  colors.name.toUpperCase(),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: titleColor,
                                                    fontSize: veryTight ? 11 : 12,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.8,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Expanded(
                                                  child: Text(
                                                    colors.description,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: veryTight ? 9.2 : 10.2,
                                                      height: 1.25,
                                                      color: titleColor.withValues(alpha: 0.84),
                                                    ),
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Icon(
                                                    Icons.check_circle,
                                                    size: 14,
                                                    color: colors.accentColor,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (lockedSection)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.36),
                                                borderRadius: BorderRadius.circular(11),
                                                border: Border.all(
                                                  color: titleColor.withValues(alpha: 0.45),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.lock_outline,
                                                size: 12,
                                                color: titleColor.withValues(alpha: 0.95),
                                              ),
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
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
