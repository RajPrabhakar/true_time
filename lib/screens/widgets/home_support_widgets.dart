import 'package:flutter/material.dart';
import 'package:true_time/models/app_theme.dart';

class BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    ThemeDefinitions.paintBlueprintGrid(canvas, size);
  }

  @override
  bool shouldRepaint(BlueprintGridPainter oldDelegate) => false;
}

class PulsingCircle extends StatefulWidget {
  final Color accentColor;

  const PulsingCircle({super.key, required this.accentColor});

  @override
  State<PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<PulsingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.accentColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class GpsLockCircle extends StatelessWidget {
  final Color accentColor;

  const GpsLockCircle({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: accentColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

class AnimatedDots extends StatefulWidget {
  final Color accentColor;

  const AnimatedDots({super.key, required this.accentColor});

  @override
  State<AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.6, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                index * 0.33,
                (index + 1) * 0.33,
                curve: Curves.easeInOut,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: widget.accentColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
