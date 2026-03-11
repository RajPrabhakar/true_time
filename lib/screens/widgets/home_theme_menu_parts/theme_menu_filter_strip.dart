import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';

class ThemeMenuFilterStrip extends StatelessWidget {
  final List<ThemeCategory?> filters;
  final ThemeCategory? selectedFilter;
  final ValueChanged<ThemeCategory?> onSelectFilter;
  final AppThemeColors themeColors;

  const ThemeMenuFilterStrip({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelectFilter,
    required this.themeColors,
  });

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

  Color _highContrast(Color bg) {
    return bg.computeLuminance() > 0.45
        ? const Color(0xFF111111)
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = filters[index];
            final selected = filter == selectedFilter;

            return GestureDetector(
              onTap: () => onSelectFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: selected
                      ? themeColors.accentColor.withValues(alpha: 0.92)
                      : themeColors.secondaryTextColor.withValues(alpha: 0.18),
                  border: Border.all(
                    color: selected
                        ? themeColors.accentColor
                        : themeColors.secondaryTextColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  _filterLabel(filter),
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? _highContrast(themeColors.accentColor)
                        : themeColors.textColor,
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
