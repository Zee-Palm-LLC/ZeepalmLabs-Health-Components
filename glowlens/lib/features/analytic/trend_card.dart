import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';

class TrendCard extends StatefulWidget {
  const TrendCard({super.key, required this.progress, required this.clock});

  final Animation<double> progress;
  final ValueNotifier<double> clock;

  static const values = [58, 61, 60, 66, 71, 74, 78];

  @override
  State<TrendCard> createState() => _TrendCardState();
}

class _TrendCardState extends State<TrendCard> {
  int? _focus;

  void _pick(Offset local, Size size) {
    final count = TrendCard.values.length;
    final step = (size.width - 36) / (count - 1);
    final i = ((local.dx - 18) / step).round().clamp(0, count - 1);
    if (i != _focus) setState(() => _focus = i);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(19, 20, 19, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0F7A4FA0), blurRadius: 24, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Wrinkle Trend', style: inter(15, 600, spacing: -0.3))),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
                decoration: BoxDecoration(color: const Color(0xFFE6F6EE), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Transform.rotate(
                      angle: -math.pi / 2,
                      child: const GlyphIcon(Glyph.arrowRight, size: 13, color: Palette.good, stroke: 2),
                    ),
                    const SizedBox(width: 3),
                    Text('+20 in 7 weeks', style: inter(11, 600, color: Palette.good, spacing: 0)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Your score climbs as lines soften.', style: inter(12, 400, color: Palette.muted)),
          const SizedBox(height: 14),
          SizedBox(
            height: 128,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, 128);
                return GestureDetector(
                  onPanDown: (d) => _pick(d.localPosition, size),
                  onPanUpdate: (d) => _pick(d.localPosition, size),
                  onPanEnd: (_) => setState(() => _focus = null),
                  onPanCancel: () => setState(() => _focus = null),
                  child: MouseRegion(
                    onHover: (e) => _pick(e.localPosition, size),
                    onExit: (_) => setState(() => _focus = null),
                    child: CustomPaint(
                      size: size,
                      painter: _TrendPainter(progress: widget.progress, clock: widget.clock, focus: _focus),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({required this.progress, required this.clock, required this.focus})
    : super(repaint: Listenable.merge([progress, clock]));

  final Animation<double> progress;
  final ValueNotifier<double> clock;
  final int? focus;

  @override
  void paint(Canvas canvas, Size size) {
    const values = TrendCard.values;
    final t = progress.value;
    const left = 18.0;
    final right = size.width - 18;
    const top = 22.0;
    final bottom = size.height - 22;
    const low = 50.0;
    const high = 85.0;
    Offset at(int i) {
      final x = lerp(left, right, i / (values.length - 1));
      final y = lerp(bottom, top, (values[i] - low) / (high - low));
      return Offset(x, y);
    }

    final grid = Paint()
      ..color = Palette.hairline
      ..strokeWidth = 1;
    for (var k = 0; k < 4; k++) {
      final y = lerp(top, bottom, k / 3);
      for (var x = left; x < right; x += 6) {
        canvas.drawLine(Offset(x, y), Offset(x + 3, y), grid);
      }
    }

    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      final a = at(i - 1);
      final b = at(i);
      final mid = (b.dx - a.dx) / 2;
      line.cubicTo(a.dx + mid, a.dy, b.dx - mid, b.dy, b.dx, b.dy);
    }
    final metric = line.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * Curves.easeInOutCubic.transform(window(t, 0, 0.8)));
    final reach = metric.getTangentForOffset(metric.length * Curves.easeInOutCubic.transform(window(t, 0, 0.8)));

    final fillEnd = reach?.position.dx ?? left;
    final area = Path.from(drawn)
      ..lineTo(fillEnd, bottom + 22)
      ..lineTo(left, bottom + 22)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(0, top), Offset(0, bottom + 22), [
          Palette.rose.withValues(alpha: 0.28),
          Palette.violet.withValues(alpha: 0.02),
        ]),
    );
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x33E583C0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          const Offset(left, 0),
          Offset(right, 0),
          const [Palette.violet, Palette.rose, Palette.coral],
          const [0, 0.6, 1],
        ),
    );

    final labels = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < values.length; i++) {
      final p = at(i);
      final pop = Curves.elasticOut.transform(window(t, 0.1 + i * 0.1, 0.45 + i * 0.1));
      if (pop > 0) {
        final active = focus == i || (focus == null && i == values.length - 1);
        canvas.drawCircle(p, (active ? 6.5 : 4.5) * pop, Paint()..color = Colors.white);
        canvas.drawCircle(
          p,
          (active ? 4 : 2.6) * pop,
          Paint()..shader = Palette.brand.createShader(Rect.fromCircle(center: p, radius: 5)),
        );
        if (active && pop > 0.5) {
          final pulse = (clock.value / 1.6) % 1;
          canvas.drawCircle(
            p,
            6 + pulse * 12,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4
              ..color = Palette.rose.withValues(alpha: 0.5 * (1 - pulse)),
          );
          labels.text = TextSpan(
            text: '${values[i]}',
            style: inter(11, 700, color: Colors.white, spacing: 0),
          );
          labels.layout();
          final bubble = RRect.fromRectAndRadius(
            Rect.fromCenter(center: p - const Offset(0, 22), width: labels.width + 16, height: 20),
            const Radius.circular(10),
          );
          canvas.drawRRect(bubble, Paint()..shader = Palette.brand.createShader(bubble.outerRect));
          labels.paint(canvas, bubble.center - Offset(labels.width / 2, labels.height / 2));
        }
      }
      labels.text = TextSpan(
        text: 'W${i + 1}',
        style: inter(10, 500, color: Palette.faint, spacing: 0),
      );
      labels.layout();
      labels.paint(canvas, Offset(p.dx - labels.width / 2, size.height - 13));
    }
  }

  @override
  bool shouldRepaint(_TrendPainter oldDelegate) => oldDelegate.focus != focus;
}
