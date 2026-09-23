import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/palette.dart';

class Waveform extends StatelessWidget {
  const Waveform({
    super.key,
    required this.seconds,
    required this.focus,
    required this.energy,
    this.tint = Ember.gold,
  });

  final double seconds;
  final double focus;
  final double energy;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _WavePainter(seconds: seconds, focus: focus, energy: energy, tint: tint),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.seconds, required this.focus, required this.energy, required this.tint});

  final double seconds;
  final double focus;
  final double energy;
  final Color tint;

  static const bars = 56;
  static final _seedTable = List.generate(bars, (i) {
    final r = math.Random(i * 977 + 13);
    return (r.nextDouble(), 0.4 + r.nextDouble() * 1.4, r.nextDouble() * math.pi * 2);
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gap = size.width / bars;
    final mid = size.height / 2;
    for (var i = 0; i < bars; i++) {
      final x = gap * (i + 0.5);
      final (base, rate, phase) = _seedTable[i];
      final d = (x / size.width - focus).abs();
      final envelope = math.exp(-(d * d) / 0.030);
      final flicker = 0.55 + 0.45 * math.sin(seconds * rate * 2.4 + phase + i * 0.22);
      final travel = 0.72 + 0.28 * math.sin(seconds * 1.6 - i * 0.28);
      var h = size.height * (0.10 + 1.02 * envelope * (0.42 + 0.58 * base) * flicker * travel * energy);
      if (d < 0.010) h = size.height * (1.00 + 0.10 * flicker);
      final alpha = (0.14 + 0.86 * envelope).clamp(0.0, 1.0);
      final color = Color.lerp(Ember.clay, tint, envelope.clamp(0.0, 1.0))!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, mid), width: 2.0, height: h),
          const Radius.circular(1.4),
        ),
        Paint()..color = color.withValues(alpha: alpha * 0.92),
      );
    }
    final cx = size.width * focus;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, mid), width: 2.6, height: size.height * 1.16),
        const Radius.circular(2),
      ),
      Paint()..color = tint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, mid), width: 8, height: size.height * 1.2),
        const Radius.circular(4),
      ),
      Paint()
        ..color = tint.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.seconds != seconds || old.focus != focus || old.energy != energy || old.tint != tint;
}

class MoodLabel extends StatelessWidget {
  const MoodLabel({super.key, required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 340),
      switchInCurve: gentle,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.55), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
      child: Text(text, key: ValueKey(text), style: style),
    );
  }
}
