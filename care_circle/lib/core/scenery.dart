import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'theme.dart';

class Wash extends StatelessWidget {
  const Wash({super.key, this.tint = const Color(0xFFEDE4FF), this.warm = const Color(0xFFFFE6D6)});

  final Color tint;
  final Color warm;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(size: Size.infinite, painter: _WashPainter(tint, warm)),
    );
  }
}

class _WashPainter extends CustomPainter {
  const _WashPainter(this.tint, this.warm);

  final Color tint;
  final Color warm;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Hue.canvas);
    void blob(Offset c, double r, Color color, double alpha) {
      canvas.drawCircle(
        c,
        r,
        Paint()..shader = ui.Gradient.radial(c, r, [color.withValues(alpha: alpha), color.withValues(alpha: 0)]),
      );
    }

    final w = size.width;
    final h = size.height;
    blob(Offset(-w * 0.1, h * 0.08), w * 0.75, tint, 0.9);
    blob(Offset(w * 1.1, h * 0.3), w * 0.7, warm, 0.55);
    blob(Offset(w * 0.2, h * 0.62), w * 0.6, const Color(0xFFF6E9FF), 0.7);
    blob(Offset(w * 0.95, h * 0.95), w * 0.7, const Color(0xFFE6F3EA), 0.6);
  }

  @override
  bool shouldRepaint(_WashPainter oldDelegate) => false;
}

class Landscape extends StatelessWidget {
  const Landscape({super.key, this.height = 260, this.seed = 0});

  final double height;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(size: Size(double.infinity, height), painter: _LandscapePainter(seed)),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter(this.seed);

  final int seed;

  Path _hill(Size size, double base, double amp, double freq, double phase) {
    final path = Path()..moveTo(0, size.height);
    for (var x = 0.0; x <= size.width; x += 6) {
      final y =
          base +
          math.sin(x / size.width * math.pi * freq + phase) * amp +
          math.sin(x / size.width * math.pi * freq * 2.3 + phase * 1.7) * amp * 0.3;
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = seed * 0.9;

    canvas.drawCircle(
      Offset(w * 0.78, h * 0.28),
      w * 0.28,
      Paint()
        ..shader = ui.Gradient.radial(Offset(w * 0.78, h * 0.28), w * 0.28, [
          const Color(0x55FFE3C4),
          const Color(0x00FFE3C4),
        ]),
    );

    canvas.drawPath(
      _hill(size, h * 0.42, h * 0.08, 1.6, 0.6 + p),
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, h * 0.3), Offset(0, h), [
          const Color(0xFFE7DFF6),
          const Color(0x00E7DFF6),
        ]),
    );
    canvas.drawPath(
      _hill(size, h * 0.55, h * 0.07, 2.2, 2.1 + p),
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, h * 0.45), Offset(0, h), [
          const Color(0xFFE3EBDA),
          const Color(0x00E3EBDA),
        ]),
    );

    void cypress(double x, double base, double height, Color color) {
      final path = Path()
        ..moveTo(x, base - height)
        ..cubicTo(x + height * 0.22, base - height * 0.6, x + height * 0.2, base - height * 0.1, x, base)
        ..cubicTo(x - height * 0.2, base - height * 0.1, x - height * 0.22, base - height * 0.6, x, base - height)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }

    void bush(Offset c, double r, Color color) {
      canvas.drawCircle(c, r, Paint()..color = color);
      canvas.drawCircle(c + Offset(r * 0.8, r * 0.25), r * 0.75, Paint()..color = color);
      canvas.drawCircle(c + Offset(-r * 0.75, r * 0.3), r * 0.7, Paint()..color = color);
    }

    cypress(w * 0.84, h * 0.58, h * 0.3, const Color(0x99A9C3B8));
    cypress(w * 0.9, h * 0.6, h * 0.22, const Color(0x80B8CFC4));
    cypress(w * 0.79, h * 0.6, h * 0.17, const Color(0x70BCD2C7));
    bush(Offset(w * 0.1, h * 0.55), h * 0.07, const Color(0x66D8D0A6));
    bush(Offset(w * 0.2, h * 0.6), h * 0.05, const Color(0x66C8D8AE));

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = ui.Gradient.linear(Offset(0, h * 0.55), Offset(0, h), [const Color(0x00FBF8F4), Hue.canvas]),
    );
  }

  @override
  bool shouldRepaint(_LandscapePainter oldDelegate) => false;
}

class Meadow extends StatelessWidget {
  const Meadow({super.key, required this.sway});

  final Animation<double> sway;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(size: Size.infinite, painter: _MeadowPainter(sway)),
    );
  }
}

class _MeadowPainter extends CustomPainter {
  _MeadowPainter(this.sway) : super(repaint: sway);

  final Animation<double> sway;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = sway.value * math.pi * 2;

    final back = Path()..moveTo(0, h);
    for (var x = 0.0; x <= w; x += 6) {
      back.lineTo(x, h * 0.45 + math.sin(x / w * math.pi * 1.4 + 0.4) * h * 0.12);
    }
    back
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      back,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, h * 0.3), Offset(0, h), [
          const Color(0xFFE6DCFA),
          const Color(0xFFF2EDFC),
        ]),
    );
    final front = Path()..moveTo(0, h);
    for (var x = 0.0; x <= w; x += 6) {
      front.lineTo(x, h * 0.7 + math.sin(x / w * math.pi * 1.1 + 2.2) * h * 0.1);
    }
    front
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      front,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, h * 0.55), Offset(0, h), [
          const Color(0xFFD9CCF6),
          const Color(0xFFEDE6FB),
        ]),
    );

    void stem(Offset root, double height, double lean, Color leaf, double phase, bool flower) {
      final bend = math.sin(t + phase) * 4 + lean;
      final tip = root + Offset(bend, -height);
      final path = Path()
        ..moveTo(root.dx, root.dy)
        ..quadraticBezierTo(root.dx + bend * 0.2, root.dy - height * 0.6, tip.dx, tip.dy);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = leaf,
      );
      for (var i = 1; i <= 5; i++) {
        final f = i / 6;
        final p = Offset(root.dx + bend * f * f, root.dy - height * f);
        final side = i.isEven ? 1 : -1;
        final reach = 20 - i * 1.8;
        final droop = math.sin(t + phase + i) * 2;
        final leafPath = Path()
          ..moveTo(p.dx, p.dy)
          ..quadraticBezierTo(
            p.dx + side * reach * 0.55,
            p.dy - reach * 0.75 + droop,
            p.dx + side * reach,
            p.dy - reach * 0.3 + droop,
          )
          ..quadraticBezierTo(p.dx + side * reach * 0.5, p.dy + reach * 0.15, p.dx, p.dy)
          ..close();
        canvas.drawPath(
          leafPath,
          Paint()
            ..shader = ui.Gradient.linear(p, p + Offset(side * reach, -reach * 0.3), [
              leaf,
              Color.lerp(leaf, const Color(0xFFFFFFFF), 0.35)!,
            ]),
        );
      }
      if (flower) {
        for (var k = 0; k < 5; k++) {
          final a = k * math.pi * 2 / 5 + t * 0.1;
          canvas.drawCircle(
            tip + Offset(math.cos(a) * 4.2, math.sin(a) * 4.2),
            3.4,
            Paint()..color = const Color(0xFFF9D98C),
          );
        }
        canvas.drawCircle(tip, 2.6, Paint()..color = const Color(0xFFEA9C3F));
      }
    }

    stem(Offset(w * 0.05, h), h * 0.62, -4, const Color(0xFF8FB286), 0, true);
    stem(Offset(w * 0.12, h), h * 0.44, 5, const Color(0xFFA3C197), 1.3, false);
    stem(Offset(w * 0.19, h), h * 0.54, 3, const Color(0xFF94B78C), 2.1, true);
    stem(Offset(w * 0.84, h), h * 0.58, -5, const Color(0xFFAE97E4), 0.7, false);
    stem(Offset(w * 0.91, h), h * 0.66, 2, const Color(0xFFBBA7EC), 1.9, true);
    stem(Offset(w * 0.97, h), h * 0.4, -2, const Color(0xFFC7B6F0), 2.7, false);
  }

  @override
  bool shouldRepaint(_MeadowPainter oldDelegate) => false;
}
