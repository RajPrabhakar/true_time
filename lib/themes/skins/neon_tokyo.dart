import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:true_time/models/theme_types.dart';

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
          child:
              Text(widget.timeString, style: _style(_hotPink, opacity: 0.65)),
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
// Static preview background (no animation – used in the gallery carousel)
// ---------------------------------------------------------------------------

class NeonTokyoPreviewBackground extends StatelessWidget {
  final AppThemeColors colors;

  const NeonTokyoPreviewBackground({
    super.key,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final start = Color.alphaBlend(
      colors.accentColor.withValues(alpha: 0.16),
      colors.backgroundColor,
    );
    final middle = Color.alphaBlend(
      colors.accentColor.withValues(alpha: 0.3),
      colors.backgroundColor,
    );
    final end = Color.alphaBlend(
      colors.secondaryTextColor.withValues(alpha: 0.22),
      colors.backgroundColor,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, middle, end],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}
