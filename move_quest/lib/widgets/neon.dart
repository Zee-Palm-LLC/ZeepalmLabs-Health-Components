import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class Glow {
  const Glow(this.color, {this.blur = 10, this.spread = 0, this.width = 6});

  final Color color;
  final double blur;
  final double spread;
  final double width;
}

class NeonStyle {
  const NeonStyle({
    required this.fill,
    this.overlays = const [],
    this.rim,
    this.rimWidth = 1.5,
    this.halo,
    this.inner,
    this.radius,
  });

  final Gradient fill;
  final List<Gradient> overlays;
  final Gradient? rim;
  final double rimWidth;
  final Glow? halo;
  final Glow? inner;
  final double? radius;
}

class NeonPainter extends CustomPainter {
  NeonPainter({
    required this.style,
    this.trace = 1,
    this.bloom = 1,
    this.sheen,
    this.spark,
    this.sparkColor = Colors.white,
    this.halo = 1,
    super.repaint,
  });

  final NeonStyle style;
  final double trace;
  final double bloom;
  final double? sheen;
  final double? spark;
  final Color sparkColor;
  final double halo;

  RRect shape(Size size, [double inset = 0]) {
    final r = style.radius ?? size.height / 2;
    return RRect.fromRectAndRadius((Offset.zero & size).deflate(inset), Radius.circular(math.max(0, r - inset)));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final body = shape(size);
    final rect = Offset.zero & size;
    final glow = style.halo;
    if (glow != null && halo > 0 && bloom > 0) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = glow.width
        ..color = glow.color.withValues(alpha: glow.color.a * halo * bloom)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow.blur);
      canvas.drawRRect(body.inflate(glow.spread), paint);
    }
    if (bloom > 0) {
      canvas.saveLayer(rect.inflate(2), Paint()..color = Colors.white.withValues(alpha: bloom.clamp(0.0, 1.0)));
      canvas.drawRRect(body, Paint()..shader = style.fill.createShader(rect));
      canvas.save();
      canvas.clipRRect(body);
      for (final overlay in style.overlays) {
        canvas.drawRect(rect, Paint()..shader = overlay.createShader(rect));
      }
      final inner = style.inner;
      if (inner != null) {
        canvas.drawRRect(
          body,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = inner.width
            ..color = inner.color
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, inner.blur),
        );
      }
      final s = sheen;
      if (s != null && s > -0.4 && s < 1.4) {
        final x = lerpDouble(-size.height, size.width + size.height, s);
        final band = Paint()
          ..shader = ui.Gradient.linear(
            Offset(x - 34, 0),
            Offset(x + 34, size.height * 0.35),
            [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.42),
              Colors.white.withValues(alpha: 0),
            ],
            const [0.0, 0.5, 1.0],
          );
        canvas.drawRect(rect, band);
      }
      canvas.restore();
      canvas.restore();
    }
    final rim = style.rim;
    if (rim != null && trace > 0) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.rimWidth
        ..shader = rim.createShader(rect);
      final line = shape(size, style.rimWidth / 2);
      if (trace >= 1) {
        canvas.drawRRect(line, paint);
      } else {
        final path = Path()..addRRect(line);
        final metric = path.computeMetrics().first;
        final start = metric.length * 0.75;
        final len = metric.length * trace;
        final head = Path()..addPath(metric.extractPath(start, math.min(metric.length, start + len)), Offset.zero);
        if (start + len > metric.length) {
          head.addPath(metric.extractPath(0, start + len - metric.length), Offset.zero);
        }
        canvas.drawPath(head, paint);
        final tip = metric.getTangentForOffset((start + len) % metric.length);
        if (tip != null) {
          canvas.drawCircle(
            tip.position,
            3.2,
            Paint()
              ..color = Colors.white
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
        }
      }
    }
    final sp = spark;
    if (sp != null && trace >= 1) {
      final path = Path()..addRRect(shape(size, style.rimWidth / 2));
      final metric = path.computeMetrics().first;
      for (var i = 0; i < 12; i++) {
        final d = ((sp - i * 0.006) % 1) * metric.length;
        final t = metric.getTangentForOffset(d);
        if (t == null) continue;
        final fade = 1 - i / 12;
        canvas.drawCircle(
          t.position,
          2.4 * fade + 0.6,
          Paint()
            ..color = sparkColor.withValues(alpha: 0.85 * fade)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.2 + 2 * (1 - fade)),
        );
      }
    }
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(NeonPainter old) =>
      old.trace != trace ||
      old.bloom != bloom ||
      old.sheen != sheen ||
      old.spark != spark ||
      old.halo != halo ||
      old.style != style;
}

class GlassStyle {
  const GlassStyle({
    required this.fill,
    required this.rim,
    this.rimWidth = 1.2,
    this.radius = 20,
    this.glow,
    this.gloss = 0.0,
  });

  final Gradient fill;
  final Gradient rim;
  final double rimWidth;
  final double radius;
  final Glow? glow;
  final double gloss;
}

class GlassPainter extends CustomPainter {
  const GlassPainter(this.style, {this.lit = 0});

  final GlassStyle style;
  final double lit;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = math.min(style.radius, size.height / 2);
    final body = RRect.fromRectAndRadius(rect, Radius.circular(r));
    final glow = style.glow;
    if (glow != null) {
      canvas.drawRRect(
        body.inflate(glow.spread),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = glow.width
          ..color = glow.color.withValues(alpha: glow.color.a * (1 + lit * 0.8).clamp(0.0, 1.0))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow.blur),
      );
    }
    canvas.drawRRect(body, Paint()..shader = style.fill.createShader(rect));
    if (style.gloss > 0) {
      canvas.save();
      canvas.clipRRect(body);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.5),
        Paint()
          ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height * 0.5), [
            Colors.white.withValues(alpha: style.gloss),
            Colors.white.withValues(alpha: 0),
          ]),
      );
      canvas.restore();
    }
    if (lit > 0) {
      canvas.save();
      canvas.clipRRect(body);
      canvas.drawRRect(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..color = const Color(0xFF4FD8FF).withValues(alpha: 0.35 * lit)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.restore();
    }
    canvas.drawRRect(
      body.deflate(style.rimWidth / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.rimWidth
        ..shader = style.rim.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(GlassPainter old) => old.style != style || old.lit != lit;
}

class Glass extends StatelessWidget {
  const Glass({super.key, required this.style, this.child, this.lit = 0});

  final GlassStyle style;
  final Widget? child;
  final double lit;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GlassPainter(style, lit: lit),
      child: child ?? const SizedBox.expand(),
    );
  }
}
