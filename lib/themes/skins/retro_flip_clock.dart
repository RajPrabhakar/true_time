import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroFlipClock extends StatelessWidget {
  final DateTime displayedTime;
  final bool isSolarMode;

  const RetroFlipClock({
    super.key,
    required this.displayedTime,
    required this.isSolarMode,
  });

  @override
  Widget build(BuildContext context) {
    final timeString =
        '${displayedTime.hour.toString().padLeft(2, '0')}:${displayedTime.minute.toString().padLeft(2, '0')}:${displayedTime.second.toString().padLeft(2, '0')}';

    return RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < timeString.length; i++) ...[
            if (timeString[i] == ':')
              _FlipSeparator(isSolarMode: isSolarMode)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: RetroFlipDigit(
                  key: ValueKey('digit-$i'),
                  value: timeString[i],
                  isSolarMode: isSolarMode,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class RetroFlipDigit extends StatefulWidget {
  final String value;
  final bool isSolarMode;

  const RetroFlipDigit({
    super.key,
    required this.value,
    required this.isSolarMode,
  });

  @override
  State<RetroFlipDigit> createState() => _RetroFlipDigitState();
}

class _RetroFlipDigitState extends State<RetroFlipDigit>
    with SingleTickerProviderStateMixin {
  static const Duration _flipDuration = Duration(milliseconds: 260);

  late final AnimationController _controller;
  late String _currentValue;
  String? _incomingValue;
  String? _queuedValue;

  bool get _isFlipping => _controller.isAnimating && _incomingValue != null;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: _flipDuration,
    )..addStatusListener((status) {
        if (status != AnimationStatus.completed || _incomingValue == null) {
          return;
        }

        HapticFeedback.lightImpact();

        setState(() {
          _currentValue = _incomingValue!;
          _incomingValue = null;
        });

        if (_queuedValue != null && _queuedValue != _currentValue) {
          _startFlipTo(_queuedValue!);
        }
        _queuedValue = null;
      });
  }

  @override
  void didUpdateWidget(covariant RetroFlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value == _currentValue || widget.value == _incomingValue) {
      return;
    }

    if (_controller.isAnimating) {
      _queuedValue = widget.value;
      return;
    }

    _startFlipTo(widget.value);
  }

  void _startFlipTo(String value) {
    _incomingValue = value;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: 88,
        height: 136,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final valueForFace = _incomingValue ?? _currentValue;

            if (!_isFlipping) {
              return _digitFace(valueForFace);
            }

            final progress = _controller.value;
            if (progress < 0.5) {
              final topAngle = -math.pi / 2 * (progress / 0.5);
              return Stack(
                children: [
                  _digitFace(_currentValue),
                  _buildFlippingHalf(
                    value: _currentValue,
                    top: true,
                    angle: topAngle,
                  ),
                ],
              );
            }

            final bottomAngle =
                math.pi / 2 * (1 - ((progress - 0.5) / 0.5).clamp(0.0, 1.0));
            return Stack(
              children: [
                _digitFace(_incomingValue!),
                _buildFlippingHalf(
                  value: _incomingValue!,
                  top: false,
                  angle: bottomAngle,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFlippingHalf({
    required String value,
    required bool top,
    required double angle,
  }) {
    return Transform(
      alignment: top ? Alignment.bottomCenter : Alignment.topCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0022)
        ..rotateX(angle),
      child: _halfFace(value: value, top: top),
    );
  }

  Widget _halfFace({required String value, required bool top}) {
    return ClipRect(
      clipper: _HalfClipper(top: top),
      child: _digitFace(value),
    );
  }

  Widget _digitFace(String value) {
    final panelColor = widget.isSolarMode
        ? Color.lerp(const Color(0xFF1A1A1A), const Color(0xFF31281E), 0.24)!
        : const Color(0xFF1A1A1A);

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: widget.isSolarMode
          ? [
              panelColor.withValues(alpha: 0.98),
              const Color(0xFF2A2118),
            ]
          : [
              panelColor.withValues(alpha: 0.98),
              panelColor.withValues(alpha: 0.92),
            ],
    );

    final digitColor =
        widget.isSolarMode ? const Color(0xFFE4D8C7) : const Color(0xFFE0E0E0);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: gradient,
        border: Border.all(
          color: widget.isSolarMode
              ? const Color(0xFF65513C).withValues(alpha: 0.55)
              : const Color(0xFF3A3A3A),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              value,
              style: GoogleFonts.bebasNeue(
                color: digitColor,
                fontSize: 110,
                fontWeight: FontWeight.w700,
                height: 1.0,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: widget.isSolarMode
                  ? const Color(0xFF8A6F53).withValues(alpha: 0.45)
                  : Colors.black.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlipSeparator extends StatelessWidget {
  final bool isSolarMode;

  const _FlipSeparator({required this.isSolarMode});

  @override
  Widget build(BuildContext context) {
    final color =
        isSolarMode ? const Color(0xFFE4D8C7) : const Color(0xFFE0E0E0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        ':',
        style: GoogleFonts.bebasNeue(
          color: color,
          fontSize: 94,
          fontWeight: FontWeight.w700,
          height: 1.0,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  final bool top;

  const _HalfClipper({required this.top});

  @override
  Rect getClip(Size size) {
    if (top) {
      return Rect.fromLTWH(0, 0, size.width, size.height / 2);
    }
    return Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2);
  }

  @override
  bool shouldReclip(covariant _HalfClipper oldClipper) {
    return oldClipper.top != top;
  }
}
