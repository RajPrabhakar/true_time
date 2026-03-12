import 'package:flutter/material.dart';
import 'package:true_time/models/theme_types.dart';

const Map<AppThemeType, AppThemeColors> premiumThemes = {
  AppThemeType.blueprintArchitectural: AppThemeColors(
    name: 'Blueprint Arch',
    description: 'CAD Design: Drafting Grid Layer',
    category: ThemeCategory.premium,
    backgroundColor: Color(0xFF002B36),
    textColor: Color(0xFF2AA198),
    secondaryTextColor: Color(0xFF00B8B8),
    accentColor: Color(0xFF2AA198),
  ),
  AppThemeType.bauhaus1925: AppThemeColors(
    name: 'Bauhaus 1925',
    description: 'Geometric: Modern Art Aesthetic',
    category: ThemeCategory.premium,
    backgroundColor: Color(0xFFF5F5DC),
    textColor: Color(0xFF333333),
    secondaryTextColor: Color(0xFF666666),
    accentColor: Color(0xFFE10600),
  ),
  AppThemeType.cartographer: AppThemeColors(
    name: 'Cartographer',
    description: 'Atlas: Parchment with Brown Ink',
    category: ThemeCategory.premium,
    backgroundColor: Color(0xFFF2E7D0),
    textColor: Color(0xFF4E342E),
    secondaryTextColor: Color(0xFF8D6E63),
    accentColor: Color(0xFFA66A2C),
  ),
};

void paintBlueprintGrid(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = const Color(0xFF00B8B8).withValues(alpha: 0.08)
    ..strokeWidth = 0.5;

  const double gridSize = 10;

  for (double x = 0; x < size.width; x += gridSize) {
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
  }

  for (double y = 0; y < size.height; y += gridSize) {
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
}

class BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    paintBlueprintGrid(canvas, size);
  }

  @override
  bool shouldRepaint(BlueprintGridPainter oldDelegate) => false;
}
