import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:true_time/models/app_theme.dart';
import 'package:true_time/themes/theme_ui_tokens.dart';

class ThemeGalleryCard extends StatelessWidget {
  static const String _previewTimeSnapshot = '10:09';

  final bool compact;
  final AppTheme appTheme;
  final bool isLocked;
  final bool isSelected;
  final ValueChanged<AppThemeType> onThemePreview;
  final ValueChanged<AppThemeType> onThemeSelected;
  final ValueChanged<AppThemeType> onLockedThemeTap;

  const ThemeGalleryCard({
    super.key,
    required this.compact,
    required this.appTheme,
    required this.isLocked,
    required this.isSelected,
    required this.onThemePreview,
    required this.onThemeSelected,
    required this.onLockedThemeTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = appTheme.colors;
    final titleColor = colors.highContrastOn(colors.backgroundColor);
    final checkIconColor = colors.highContrastOn(colors.accentColor);
    final lockOverlayColor = colors.lockOverlayColor;
    final lockBorderColor = colors.lockBorderColor;
    final lockIconColor = colors.lockIconColor;

    return GestureDetector(
      onTapDown: (_) {
        onThemePreview(appTheme.id);
      },
      onTap: () {
        if (isLocked) {
          HapticFeedback.vibrate();
          onLockedThemeTap(appTheme.id);
          return;
        }
        onThemeSelected(appTheme.id);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
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
              appTheme.buildPreviewBackground(context),
              LayoutBuilder(
                builder: (context, cardConstraints) {
                  final h = cardConstraints.maxHeight;
                  final tiny = h < 170;
                  final padH = tiny ? 12.0 : (compact ? 16.0 : 18.0);
                  final padV = tiny ? 8.0 : (compact ? 14.0 : 18.0);
                  final showTitle = h > 120;
                  final timeReferenceWidth =
                      tiny ? 200.0 : (compact ? 220.0 : 240.0);

                  final timeText = FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: timeReferenceWidth,
                      child: Text(
                        _previewTimeSnapshot,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textColor,
                          fontSize: compact ? 54 : 62,
                          fontWeight: FontWeight.w400,
                          letterSpacing:
                              appTheme.fontFamily == 'monospace' ? 4.0 : 2.0,
                          fontFamily: appTheme.fontFamily,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                          shadows: appTheme.clockShadows,
                        ),
                      ),
                    ),
                  );

                  return Padding(
                    padding: EdgeInsets.fromLTRB(padH, padV, padH, padV),
                    child: tiny
                        ? Column(
                            children: [
                              Expanded(
                                child: Center(child: timeText),
                              ),
                              if (showTitle)
                                Text(
                                  appTheme.name.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
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
                                appTheme.name.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
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
              if (isSelected && !isLocked)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: colors.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: checkIconColor,
                    ),
                  ),
                ),
              if (isLocked)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: lockOverlayColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: lockBorderColor,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: lockIconColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
