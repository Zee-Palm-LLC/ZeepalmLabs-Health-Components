import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../core/palette.dart';

/// Every small icon in the app, drawn with a painter rather than pulled from
/// an icon font, so their stroke weights match each other and the design.
enum Glyph {
  back,
  close,
  search,
  waveform,
  question,
  exclamation,
  chevronDown,
  branch,
  list,
  check,
  arrowRight,
}

class Icon2 extends StatelessWidget {
  const Icon2(
    this.glyph, {
    super.key,
    required this.size,
    this.color = Slate.secondary,
    this.strokeWidth,
    this.progress = 1,
  });

  final Glyph glyph;
  final double size;
  final Color color;
  final double? strokeWidth;

  /// Some glyphs animate: the chevron rotates, the check draws on.
  final double progress;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: GlyphPainter(
          glyph,
          color: color,
          strokeWidth: strokeWidth ?? size * 0.11,
          progress: progress,
        ),
      );
}

class GlyphPainter extends CustomPainter {
  const GlyphPainter(
    this.glyph, {
    required this.color,
    required this.strokeWidth,
    this.progress = 1,
  });

  final Glyph glyph;
  final Color color;
  final double strokeWidth;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final fill = Paint()
      ..color = color
      ..isAntiAlias = true;

    switch (glyph) {
      case Glyph.back:
        final l = s * 0.30;
        canvas.drawLine(c + Offset(l, 0), c + Offset(-l, 0), stroke);
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - l * 0.15, c.dy - l * 0.85)
            ..lineTo(c.dx - l, c.dy)
            ..lineTo(c.dx - l * 0.15, c.dy + l * 0.85),
          stroke,
        );
      case Glyph.arrowRight:
        final l = s * 0.30;
        canvas.drawLine(c + Offset(-l, 0), c + Offset(l, 0), stroke);
        canvas.drawPath(
          Path()
            ..moveTo(c.dx + l * 0.15, c.dy - l * 0.85)
            ..lineTo(c.dx + l, c.dy)
            ..lineTo(c.dx + l * 0.15, c.dy + l * 0.85),
          stroke,
        );
      case Glyph.close:
        final l = s * 0.24;
        canvas.drawLine(c + Offset(-l, -l), c + Offset(l, l), stroke);
        canvas.drawLine(c + Offset(l, -l), c + Offset(-l, l), stroke);
      case Glyph.search:
        // A solid lens with a short handle - the reference's is filled.
        final r = s * 0.27;
        final lens = c + Offset(-s * 0.06, -s * 0.06);
        canvas.drawCircle(lens, r, fill);
        canvas.drawLine(
          lens + Offset(r * 0.72, r * 0.72),
          c + Offset(s * 0.30, s * 0.30),
          stroke..strokeWidth = strokeWidth * 1.35,
        );
      case Glyph.waveform:
        // Five bars, the middle tallest, mirrored - a sound mark.
        const heights = <double>[0.22, 0.46, 0.72, 0.46, 0.22];
        final gap = s * 0.16;
        final w = strokeWidth * 1.2;
        for (var i = 0; i < 5; i++) {
          final x = c.dx + (i - 2) * gap;
          // progress animates them: each bar breathes on its own phase
          final breathe = progress >= 1
              ? 1.0
              : 0.55 + 0.45 * math.sin(progress * math.pi * 2 + i * 1.1).abs();
          final h = s * heights[i] * breathe;
          canvas.drawLine(
            Offset(x, c.dy - h / 2),
            Offset(x, c.dy + h / 2),
            stroke..strokeWidth = w,
          );
        }
      case Glyph.question:
        final r = s * 0.22;
        final top = c + Offset(0, -s * 0.10);
        canvas.drawArc(
          Rect.fromCircle(center: top, radius: r),
          math.pi * 1.05,
          math.pi * 1.35,
          false,
          stroke,
        );
        canvas.drawLine(
          top + Offset(r * math.cos(math.pi * 0.40), r * math.sin(math.pi * 0.40)),
          c + Offset(0, s * 0.16),
          stroke,
        );
        canvas.drawCircle(c + Offset(0, s * 0.34), strokeWidth * 0.75, fill);
      case Glyph.exclamation:
        canvas.drawLine(
          c + Offset(0, -s * 0.30),
          c + Offset(0, s * 0.10),
          stroke..strokeWidth = strokeWidth * 1.15,
        );
        canvas.drawCircle(c + Offset(0, s * 0.30), strokeWidth * 0.8, fill);
      case Glyph.chevronDown:
        final l = s * 0.22;
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(progress * math.pi);
        canvas.drawPath(
          Path()
            ..moveTo(-l, -l * 0.45)
            ..lineTo(0, l * 0.45)
            ..lineTo(l, -l * 0.45),
          stroke,
        );
        canvas.restore();
      case Glyph.branch:
        // A path that forks: one line down, a branch curling off to a node.
        final p = Path()
          ..moveTo(c.dx - s * 0.22, c.dy - s * 0.30)
          ..lineTo(c.dx - s * 0.22, c.dy + s * 0.30)
          ..moveTo(c.dx - s * 0.22, c.dy - s * 0.30)
          ..lineTo(c.dx + s * 0.06, c.dy - s * 0.30)
          ..quadraticBezierTo(
              c.dx + s * 0.22, c.dy - s * 0.30, c.dx + s * 0.22, c.dy - s * 0.12)
          ..lineTo(c.dx + s * 0.22, c.dy + s * 0.02);
        canvas.drawPath(p, stroke);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: c + Offset(s * 0.22, s * 0.18),
                width: s * 0.30,
                height: s * 0.26),
            Radius.circular(s * 0.07),
          ),
          fill,
        );
      case Glyph.list:
        final w = s * 0.56;
        final x0 = c.dx - w / 2;
        for (var i = 0; i < 3; i++) {
          final y = c.dy + (i - 1) * s * 0.20;
          final len = i == 2 ? w * 0.62 : w;
          canvas.drawLine(Offset(x0, y), Offset(x0 + len, y), stroke);
        }
        // a small tick at the end of the short line
        final t = Offset(c.dx + w * 0.34, c.dy + s * 0.20);
        canvas.drawPath(
          Path()
            ..moveTo(t.dx - s * 0.06, t.dy - s * 0.05)
            ..lineTo(t.dx, t.dy + s * 0.02)
            ..lineTo(t.dx + s * 0.09, t.dy - s * 0.08),
          stroke..strokeWidth = strokeWidth * 0.9,
        );
      case Glyph.check:
        final p = Path()
          ..moveTo(c.dx - s * 0.26, c.dy + s * 0.02)
          ..lineTo(c.dx - s * 0.06, c.dy + s * 0.22)
          ..lineTo(c.dx + s * 0.28, c.dy - s * 0.20);
        if (progress >= 1) {
          canvas.drawPath(p, stroke);
        } else {
          for (final m in p.computeMetrics()) {
            canvas.drawPath(m.extractPath(0, m.length * progress), stroke);
          }
        }
    }
  }

  @override
  bool shouldRepaint(GlyphPainter old) =>
      old.glyph != glyph ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.progress != progress;
}
