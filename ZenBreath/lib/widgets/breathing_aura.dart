import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BreathingAura extends StatelessWidget {
  const BreathingAura({
    super.key,
    required this.diameter,
    required this.time,
    required this.breath,
    this.progress,
    this.turbulence = 1,
    this.ripples = true,
    this.particles = true,
    this.child,
  });

  final double diameter;
  final double time;
  final double breath;
  final double? progress;
  final double turbulence;
  final bool ripples;
  final bool particles;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: diameter,
      child: CustomPaint(
        painter: _AuraPainter(
          time: time,
          breath: breath.clamp(0.0, 1.0),
          progress: progress,
          turbulence: turbulence,
          ripples: ripples,
          particles: particles,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _AuraPainter extends CustomPainter {
  const _AuraPainter({
    required this.time,
    required this.breath,
    required this.progress,
    required this.turbulence,
    required this.ripples,
    required this.particles,
  });

  final double time;
  final double breath;
  final double? progress;
  final double turbulence;
  final bool ripples;
  final bool particles;
  static const _modes = [3, 5, 7];

  static const _shells = [
    (radius: 1.00, opacity: 0.07, spin: 0.09),
    (radius: 0.86, opacity: 0.11, spin: -0.13),
    (radius: 0.70, opacity: 0.17, spin: 0.17),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final unit = size.shortestSide / 2;

    final scale = 0.82 + 0.18 * breath;

    final amplitude = (0.050 - 0.030 * breath) * turbulence;

    if (ripples) _paintRipples(canvas, center, unit * scale);

    for (final shell in _shells) {
      final r = unit * scale * shell.radius;
      canvas.drawPath(
        _harmonicPath(center, r, amplitude, shell.spin),
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.blue.withValues(alpha: shell.opacity * 0.35),
              AppColors.blue.withValues(alpha: shell.opacity),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }

    _paintCore(canvas, center, unit * scale * 0.52, amplitude);
    if (particles) _paintParticles(canvas, center, unit * scale);
    if (progress != null) _paintProgress(canvas, center, unit * scale);
  }

  Path _harmonicPath(Offset center, double radius, double amplitude, double spin) {
    const samples = 168;
    final path = Path();

    for (var i = 0; i <= samples; i++) {
      final theta = i / samples * 2 * math.pi;
      var factor = 1.0;

      for (var m = 0; m < _modes.length; m++) {
        factor +=
            amplitude /
            (m + 1) *
            math.sin(_modes[m] * theta + time * (0.55 + 0.27 * m) + spin * time);
      }

      final point = center + Offset(math.cos(theta), math.sin(theta)) * (radius * factor);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    return path..close();
  }

  void _paintRipples(Canvas canvas, Offset center, double radius) {
    const count = 3;
    const period = 4.2;

    for (var i = 0; i < count; i++) {
      final p = ((time / period) + i / count) % 1.0;
      final r = radius * (0.86 + p * 0.42);
      final fade = (1 - p) * (1 - p);

      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = AppColors.blue.withValues(alpha: 0.20 * fade),
      );
    }
  }

  void _paintCore(Canvas canvas, Offset center, double radius, double amplitude) {
    final path = _harmonicPath(center, radius, amplitude * 0.5, -0.07);

    canvas
      ..drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.35),
      )
      ..drawPath(
        path,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.28, -0.36),
            colors: [Color(0xFFFFFFFF), Color(0xFFE4F2FA), Color(0xFFBBDCF0)],
            stops: [0.0, 0.52, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
  }

  void _paintParticles(Canvas canvas, Offset center, double radius) {
    const count = 26;

    for (var i = 0; i < count; i++) {
      final base = i / count * 2 * math.pi;
      final theta = base + time * (0.10 + 0.05 * math.sin(i.toDouble()));
      final r = radius * (1.06 + 0.10 * math.sin(3 * theta + time * 0.6));
      final twinkle = 0.5 + 0.5 * math.sin(time * 1.7 + i * 1.3);

      canvas.drawCircle(
        center + Offset(math.cos(theta), math.sin(theta)) * r,
        (0.9 + 1.1 * twinkle) * (0.55 + 0.45 * breath),
        Paint()..color = Colors.white.withValues(alpha: 0.30 + 0.45 * twinkle),
      );
    }
  }

  void _paintProgress(Canvas canvas, Offset center, double radius) {
    final sweep = 2 * math.pi * progress!.clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..color = AppColors.blueDeep.withValues(alpha: 0.55),
    );

    final head = -math.pi / 2 + sweep;
    final position = center + Offset(math.cos(head), math.sin(head)) * radius;

    canvas
      ..drawCircle(position, 6, Paint()..color = AppColors.blueDeep.withValues(alpha: 0.22))
      ..drawCircle(position, 3, Paint()..color = AppColors.blueDeep);
  }

  @override
  bool shouldRepaint(_AuraPainter oldDelegate) =>
      oldDelegate.time != time ||
      oldDelegate.breath != breath ||
      oldDelegate.progress != progress;
}
