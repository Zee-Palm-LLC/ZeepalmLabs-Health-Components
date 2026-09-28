import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion.dart';

double sheetTop(double x, [double wobble = 0]) {
  if (x < 32) {
    final dx = 32 - x;
    return 301 - math.sqrt(math.max(0, 32 * 32 - dx * dx));
  }
  if (x < 300) {
    final t = (x - 32) / 268;
    final a = 1 - t;
    final lift = wobble * math.sin(t * math.pi);
    return a * a * a * 269 + 3 * a * a * t * 269 + 3 * a * t * t * 316 + t * t * t * 313 - lift;
  }
  return 313 + (307 - 313) * ((x - 300) / 93);
}

class SheetClipper extends CustomClipper<Path> {
  SheetClipper(this.wobble);

  final double wobble;

  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, size.height);
    path.lineTo(0, sheetTop(0, wobble));
    for (var x = 1.0; x <= size.width; x += 3) {
      path.lineTo(x, sheetTop(x, wobble));
    }
    path.lineTo(size.width, sheetTop(size.width, wobble));
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(SheetClipper old) => old.wobble != wobble;
}

class GrinderDust extends StatelessWidget {
  const GrinderDust({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Tick(builder: (context, s, _) => CustomPaint(painter: _DustPainter(s))),
    );
  }
}

class _DustPainter extends CustomPainter {
  _DustPainter(this.seconds);

  final double seconds;

  static final _seeds = List.generate(26, (i) {
    final r = math.Random(i * 13 + 1);
    return (r.nextDouble(), r.nextDouble(), r.nextDouble(), r.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tip = Offset(size.width * 0.18, 0);
    for (final (i, (a, b, c, d)) in _seeds.indexed) {
      final period = 0.9 + c * 0.7;
      final u = (seconds / period + a) % 1.0;
      final drift = (b - 0.35) * size.width * 0.7;
      final p = tip + Offset(drift * u + math.sin((u + d) * 9) * 2, size.height * u * u);
      final fade = u < 0.12 ? u / 0.12 : (1 - u) / 0.88;
      final pepper = i % 3 == 0;
      final color = pepper ? const Color(0xFF3A2A20) : (i % 3 == 1 ? const Color(0xFFFFF4D6) : const Color(0xFFF5D98A));
      final r = pepper ? 0.9 + d * 0.6 : 1.1 + d * 1.1;
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(u * 6 + d * 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: r * 2.2, height: r * 1.3), Radius.circular(r * 0.6)),
        Paint()..color = color.withValues(alpha: 0.95 * fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_DustPainter old) => old.seconds != seconds;
}

class BowlSteam extends StatelessWidget {
  const BowlSteam({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Tick(builder: (context, s, _) => CustomPaint(painter: _SteamPainter(s))),
    );
  }
}

class _SteamPainter extends CustomPainter {
  _SteamPainter(this.seconds);

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 6; i++) {
      final u = (seconds / 3.2 + i / 6) % 1.0;
      final x = size.width * (0.12 + 0.15 * i);
      final y = size.height * (1 - u);
      final sway = math.sin(seconds * 1.1 + i * 1.7) * 7;
      final path = Path()..moveTo(x, y + 26);
      path.cubicTo(x - 10 + sway, y + 14, x + 10 + sway, y + 4, x + sway * 0.7, y - 14);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5 * (1 - u * 0.6)
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: math.sin(u * math.pi) * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
      );
    }
  }

  @override
  bool shouldRepaint(_SteamPainter old) => old.seconds != seconds;
}

class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.animation, required this.value, required this.suffix, required this.style, required this.begin});

  final Animation<double> animation;
  final int value;
  final String suffix;
  final TextStyle style;
  final double begin;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = span(animation.value, begin, begin + 0.36, Curves.easeOutCubic);
        return Text('${(value * t).round()}$suffix', style: style, softWrap: false);
      },
    );
  }
}
