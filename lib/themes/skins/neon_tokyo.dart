import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Glitch Effect Clock
// ---------------------------------------------------------------------------

class GlitchEffectClock extends StatefulWidget {
  final String timeString;

  const GlitchEffectClock({super.key, required this.timeString});

  @override
  State<GlitchEffectClock> createState() => _GlitchEffectClockState();
}

class _GlitchEffectClockState extends State<GlitchEffectClock> {
  static const _hotPink = Color(0xFFFF0055);
  static const _cyan = Color(0xFF00FFCC);

  final _rng = Random();
  Timer? _timer;
  bool _glitching = false;
  double _dxRed = 0;
  double _dxCyan = 0;
  double _sliceDx = 0;

  @override
  void initState() {
    super.initState();
    _scheduleGlitch();
  }

  void _scheduleGlitch() {
    _timer?.cancel();
    final delay = 1800 + _rng.nextInt(3200);
    _timer = Timer(Duration(milliseconds: delay), _startGlitch);
  }

  void _startGlitch() {
    if (!mounted) return;
    setState(() {
      _glitching = true;
      _dxRed = 3 + _rng.nextDouble() * 6;
      _dxCyan = -(3 + _rng.nextDouble() * 6);
      _sliceDx = (_rng.nextDouble() - 0.5) * 14;
    });
    _timer = Timer(Duration(milliseconds: 60 + _rng.nextInt(140)), _endGlitch);
  }

  void _endGlitch() {
    if (!mounted) return;
    setState(() => _glitching = false);
    _scheduleGlitch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  TextStyle _style(Color color, {double opacity = 1.0}) =>
      GoogleFonts.shareTechMono(
        fontSize: 96,
        fontWeight: FontWeight.w400,
        color: color.withValues(alpha: opacity),
        letterSpacing: 4,
        height: 1.0,
      );

  @override
  Widget build(BuildContext context) {
    if (!_glitching) {
      return Text(
        widget.timeString,
        style: _style(_hotPink).copyWith(
          shadows: const [
            Shadow(color: Color(0xAAFF0055), blurRadius: 12),
            Shadow(color: Color(0x55FF0055), blurRadius: 28),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: Offset(_dxCyan, 0),
          child: Text(widget.timeString, style: _style(_cyan, opacity: 0.65)),
        ),
        Transform.translate(
          offset: Offset(_dxRed, 0),
          child: Text(widget.timeString, style: _style(_hotPink, opacity: 0.65)),
        ),
        Transform.translate(
          offset: Offset(_sliceDx, 0),
          child: Text(widget.timeString, style: _style(_hotPink)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Animated Neon Grid Background
// ---------------------------------------------------------------------------

class AnimatedNeonGridBackground extends StatefulWidget {
  const AnimatedNeonGridBackground({super.key});

  @override
  State<AnimatedNeonGridBackground> createState() =>
      _AnimatedNeonGridBackgroundState();
}

class _AnimatedNeonGridBackgroundState
    extends State<AnimatedNeonGridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        painter: _NeonGridPainter(_controller.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _NeonGridPainter extends CustomPainter {
  final double t;

  const _NeonGridPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Solid background
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0A0A0A));

    final vanishX = w / 2;
    final vanishY = h * 0.46;
    final gridPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8;

    // Scrolling horizontal perspective lines
    const hLines = 10;
    for (int i = 1; i <= hLines; i++) {
      final progress = ((i / hLines + t) % 1.0);
      final curved = progress * progress; // non-linear: sparse near horizon, dense at bottom
      final y = vanishY + (h - vanishY) * curved;
      final spread = (y - vanishY) / (h - vanishY);
      final xLeft = vanishX - spread * vanishX;
      final xRight = vanishX + spread * (w - vanishX);
      final alpha = (spread * 0.5).clamp(0.0, 0.5);
      gridPaint.color = const Color(0xFFFF0055).withValues(alpha: alpha);
      canvas.drawLine(Offset(xLeft, y), Offset(xRight, y), gridPaint);
    }

    // Static vertical perspective lines
    const vLines = 8;
    for (int i = 0; i <= vLines; i++) {
      final frac = i / vLines;
      final bottomX = w * frac;
      final centrality = 1 - (2 * frac - 1).abs(); // peaks at center
      final alpha = (0.08 + 0.28 * centrality).clamp(0.0, 0.36);
      gridPaint.color = const Color(0xFF00FFCC).withValues(alpha: alpha);
      canvas.drawLine(Offset(vanishX, vanishY), Offset(bottomX, h), gridPaint);
    }

    // Animated scan line
    final scanY = vanishY + (h - vanishY) * t;
    canvas.drawLine(
      Offset(0, scanY),
      Offset(w, scanY),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF00FFCC).withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Top fade so the grid doesn't compete with the clock above the horizon
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0A), Colors.transparent],
          stops: [0.0, 0.38],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_NeonGridPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Static preview background (no animation – used in the gallery carousel)
// ---------------------------------------------------------------------------

class NeonTokyoPreviewBackground extends StatelessWidget {
  const NeonTokyoPreviewBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0A0A), Color(0xFF1A0022), Color(0xFF00090F)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}
