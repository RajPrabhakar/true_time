import 'package:flutter/material.dart';

class CarouselItemTransform extends StatelessWidget {
  final PageController pageController;
  final int index;
  final Widget child;

  const CarouselItemTransform({
    super.key,
    required this.pageController,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final page = pageController.hasClients
            ? (pageController.page ?? pageController.initialPage.toDouble())
            : pageController.initialPage.toDouble();
        final delta = (index - page).abs();
        final double scale = (1 - (delta * 0.15)).clamp(0.85, 1.0);
        final double opacity = (1 - (delta * 0.4)).clamp(0.4, 1.0);

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
    );
  }
}
