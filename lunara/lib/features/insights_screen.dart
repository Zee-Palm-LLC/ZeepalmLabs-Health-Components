import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/theme.dart';
import '../data/cycle.dart';
import '../widgets/surface.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key, required this.cycle, required this.enter, required this.pulse, required this.onAsk});

  final Cycle cycle;
  final Animation<double> enter;
  final Animation<double> pulse;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 25,
          top: 56,
          child: Staged(
            animation: enter,
            begin: 0,
            end: 0.45,
            offset: const Offset(-16, 0),
            child: Text('Insights', style: display(24, 600, color: Colors.white, height: 1)),
          ),
        ),
        Positioned(
          left: 26,
          top: 88,
          child: Staged(
            animation: enter,
            begin: 0.05,
            end: 0.5,
            child: Text('Learn your patterns', style: sans(12.5, 400, color: Colors.white70, height: 1)),
          ),
        ),
        Positioned(
          right: 22,
          top: 62,
          child: Staged(
            animation: enter,
            begin: 0,
            end: 0.45,
            offset: const Offset(16, 0),
            child: Pressable(
              onTap: onAsk,
              child: const SizedBox(
                width: 34,
                height: 28,
                child: Center(child: GlyphIcon(Glyph.sliders, size: 22, color: Colors.white, stroke: 1.9)),
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 120,
          width: 353,
          height: 222,
          child: Staged(
            animation: enter,
            begin: 0.1,
            end: 0.62,
            offset: const Offset(0, 34),
            scale: 0.97,
            child: _Overview(enter: enter, pulse: pulse),
          ),
        ),
        Positioned(
          left: 20,
          top: 348,
          width: 353,
          height: 180,
          child: Staged(
            animation: enter,
            begin: 0.2,
            end: 0.72,
            offset: const Offset(0, 34),
            scale: 0.97,
            child: _Patterns(enter: enter),
          ),
        ),
        Positioned(
          left: 20,
          top: 534,
          width: 353,
          height: 152,
          child: Staged(
            animation: enter,
            begin: 0.3,
            end: 0.82,
            offset: const Offset(0, 34),
            scale: 0.97,
            child: _Predictions(enter: enter),
          ),
        ),
        Positioned(
          left: 20,
          top: 692,
          width: 353,
          height: 84,
          child: Staged(
            animation: enter,
            begin: 0.4,
            end: 0.92,
            offset: const Offset(0, 30),
            scale: 0.97,
            child: _Ask(pulse: pulse, onTap: onAsk),
          ),
        ),
      ],
    );
  }
}

class _Titled extends StatelessWidget {
  const _Titled({required this.title, required this.caption, required this.child, this.gradient});

  final String title;
  final String? caption;
  final Widget child;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: gradient == null ? Hue.surface.withValues(alpha: 0.86) : null,
        gradient: gradient,
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: softShadow(0.8),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 11.5,
            child: Text(title, style: display(15, 600, color: Hue.ink, height: 1)),
          ),
          Positioned(
            left: 21.0 + _width(title),
            top: 12.5,
            child: const GlyphIcon(Glyph.info, size: 13, color: Hue.inkMuted, stroke: 1.7),
          ),
          if (caption != null)
            Positioned(
              left: 16,
              top: 34.5,
              child: Text(caption!, style: sans(11.5, 500, color: Hue.inkSoft, height: 1)),
            ),
          Positioned.fill(top: caption == null ? 36 : 52, child: child),
        ],
      ),
    );
  }

  static double _width(String title) {
    final painter = TextPainter(
      text: TextSpan(text: title, style: display(15, 600, height: 1)),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = painter.width;
    painter.dispose();
    return w;
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.enter, required this.pulse});

  final Animation<double> enter;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return _Titled(
      title: 'Your cycle overview',
      caption: null,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3C2459), Color(0xFF4A2C6B), Color(0xFF5B3474)],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 4,
            child: Text('Average cycle length', style: sans(12, 500, color: Hue.inkSoft, height: 1)),
          ),
          Positioned(
            left: 190,
            top: 4,
            child: Text('Cycle regularity', style: sans(12, 500, color: Hue.inkSoft, height: 1)),
          ),
          Positioned(
            left: 16,
            top: 20,
            child: _Stat(enter: enter, value: 29, unit: 'days', begin: 0.35),
          ),
          Positioned(
            left: 190,
            top: 20,
            child: _Stat(enter: enter, value: 92, unit: '%', begin: 0.42, footer: 'regular'),
          ),
          const Positioned(left: 174, top: 0, width: 1, height: 62, child: ColoredBox(color: Color(0x33A98BC0))),
          Positioned(
            left: 8,
            right: 8,
            top: 68,
            height: 98,
            child: _Chart(enter: enter, pulse: pulse),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.enter, required this.value, required this.unit, required this.begin, this.footer});

  final Animation<double> enter;
  final int value;
  final String unit;
  final double begin;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: enter,
      builder: (context, _) {
        final t = span(enter.value, begin, begin + 0.45, Curves.easeOutCubic);
        final shown = (value * t).round();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('$shown', style: display(28, 600, color: Hue.ink, height: 1)),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unit, style: sans(13, 600, color: Hue.inkSoft, height: 1)),
                if (footer != null) ...[
                  const SizedBox(height: 13),
                  Opacity(
                    opacity: t,
                    child: Text(footer!, style: sans(12, 500, color: Hue.inkSoft, height: 1)),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.enter, required this.pulse});

  final Animation<double> enter;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _ChartPainter(enter: enter, pulse: pulse),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.enter, required this.pulse}) : super(repaint: Listenable.merge([enter, pulse]));

  final Animation<double> enter;
  final Animation<double> pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final t = span(enter.value, 0.4, 1.0, gentle);
    if (t <= 0.01) return;
    final left = 12.0;
    final right = size.width - 52;
    final top = 4.0;
    final bottom = size.height - 26;
    final values = cycleLengths;
    final maxV = 33.0;
    final minV = 23.0;
    Offset at(int i) {
      final x = left + (right - left) * (i / (values.length - 1));
      final y = bottom - (bottom - top) * ((values[i] - minV) / (maxV - minV));
      return Offset(x, y);
    }

    final points = [for (var i = 0; i < values.length; i++) at(i)];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p = points[i];
      final n = points[i + 1];
      final c = (p.dx + n.dx) / 2;
      path.cubicTo(c, p.dy, c, n.dy, n.dx, n.dy);
    }

    for (var i = 0; i < 3; i++) {
      final x = left + (right - left) * (i / 2.6);
      canvas.drawLine(Offset(x, top), Offset(x, bottom), Paint()..color = Colors.white.withValues(alpha: 0.08));
    }
    canvas.drawLine(
      Offset(left - 6, bottom),
      Offset(right + 8, bottom),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );

    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * t);
    final area = Path.from(drawn)
      ..lineTo(metric.getTangentForOffset(metric.length * t)!.position.dx, bottom)
      ..lineTo(points.first.dx, bottom)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, top), Offset(0, bottom), [
          Hue.violet.withValues(alpha: 0.45),
          Hue.violet.withValues(alpha: 0.02),
        ]),
    );
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Hue.violet,
    );

    for (var i = 0; i < points.length; i++) {
      final appear = span(t, i / points.length * 0.8, i / points.length * 0.8 + 0.25, const Spring(bounce: 0.4));
      if (appear <= 0.02) continue;
      final p = points[i];
      canvas.drawCircle(p, 4.4 * appear, Paint()..color = Hue.deepCard);
      canvas.drawCircle(
        p,
        4.4 * appear,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Hue.violet,
      );
    }

    _label(canvas, '35', Offset(right + 26, top + 6), 11.5, Hue.inkSoft);
    _label(canvas, '21', Offset(right + 26, bottom - 18), 11.5, Hue.inkSoft);
    for (final (i, month) in ['Mar', 'Apr', 'May'].indexed) {
      _label(canvas, month, Offset(left + 12 + i * (right - left) * 0.42, bottom + 14), 11.5, Hue.inkSoft);
    }

    final tipT = span(enter.value, 0.78, 1.0, const Spring(bounce: 0.3));
    if (tipT > 0.02) {
      final anchor = points[4];
      final bob = math.sin(pulse.value * math.pi * 2) * 1.4;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: anchor + Offset(6, 34 + bob), width: 74 * tipT, height: 38 * tipT),
        const Radius.circular(11),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawRRect(rect, Paint()..color = Hue.lift);
      if (tipT > 0.6) {
        _label(canvas, '29 days', rect.center - const Offset(0, 8), 12.5, Hue.ink, weight: 700);
        _label(canvas, 'May 14', rect.center + const Offset(0, 8), 12, Hue.inkSoft);
      }
    }
  }

  void _label(Canvas canvas, String text, Offset centre, double size, Color colour, {int weight = 500}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: sans(size, weight, color: colour, height: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, centre - Offset(painter.width / 2, painter.height / 2));
    painter.dispose();
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) => false;
}

class _Patterns extends StatelessWidget {
  const _Patterns({required this.enter});

  final Animation<double> enter;

  static const _icons = [Glyph.zap, Glyph.droplet, Glyph.activity, Glyph.moon];

  @override
  Widget build(BuildContext context) {
    return _Titled(
      title: 'Symptom patterns',
      caption: 'When your symptoms tend to show up',
      child: Stack(
        children: [
          for (final (i, pattern) in symptomPatterns.indexed) ...[
            Positioned(
              left: 8,
              top: 2.0 + i * 25.5,
              width: 26,
              height: 26,
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
                child: Center(child: GlyphIcon(_icons[i], size: 13, color: Hue.inkSoft, stroke: 1.8)),
              ),
            ),
            Positioned(
              left: 42,
              top: 9.0 + i * 25.5,
              child: Text(pattern.label, style: sans(12.5, 600, color: Hue.ink, height: 1)),
            ),
            Positioned(
              left: 120,
              top: 5.0 + i * 25.5,
              width: 217,
              height: 18,
              child: _Bar(spread: pattern.spread, enter: enter, begin: 0.35 + i * 0.07),
            ),
          ],
          Positioned(
            left: 8,
            right: 8,
            top: 108,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final phase in phaseTable)
                  Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(color: phase.colour, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(phase.name, style: sans(11, 500, color: Hue.inkSoft, height: 1)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.spread, required this.enter, required this.begin, this.radius = 9});

  final List<double> spread;
  final Animation<double> enter;
  final double begin;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: enter,
      builder: (context, _) {
        final t = span(enter.value, begin, begin + 0.45, gentle);
        return CustomPaint(
          painter: _BarPainter(spread: spread, grow: t, radius: radius),
        );
      },
    );
  }
}

class _BarPainter extends CustomPainter {
  const _BarPainter({required this.spread, required this.grow, required this.radius});

  final List<double> spread;
  final double grow;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (grow <= 0.01) return;
    const gap = 3.0;
    final total = spread.fold<double>(0, (a, b) => a + b);
    final usable = size.width - gap * (spread.where((s) => s > 0).length - 1);
    var x = 0.0;
    for (var i = 0; i < spread.length; i++) {
      if (spread[i] <= 0) continue;
      final w = usable * (spread[i] / total);
      final segment = span(grow, i * 0.12, i * 0.12 + 0.6, gentle);
      if (segment > 0.01) {
        final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, 0, w * segment, size.height), Radius.circular(radius));
        canvas.drawRRect(
          rect,
          Paint()
            ..shader = ui.Gradient.linear(Offset(x, 0), Offset(x + w, size.height), [
              phaseTable[i].colour,
              phaseTable[i].tail,
            ]),
        );
        canvas.drawRRect(
          rect,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.28)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
      }
      x += w + gap;
    }
  }

  @override
  bool shouldRepaint(_BarPainter oldDelegate) => oldDelegate.grow != grow;
}

class _Predictions extends StatelessWidget {
  const _Predictions({required this.enter});

  final Animation<double> enter;

  @override
  Widget build(BuildContext context) {
    return _Titled(
      title: 'Next 3 cycles',
      caption: 'Predicted phases',
      child: Stack(
        children: [
          for (final (i, prediction) in predictions.indexed) ...[
            Positioned(
              left: 8,
              top: 7.0 + i * 23,
              child: Text(prediction.$1, style: sans(12.5, 700, color: Hue.ink, height: 1)),
            ),
            Positioned(
              left: 132,
              top: 3.0 + i * 23,
              width: 205,
              height: 16,
              child: _Bar(spread: prediction.$2, enter: enter, begin: 0.45 + i * 0.08, radius: 8),
            ),
          ],
          Positioned(
            left: 8,
            right: 40,
            top: 82,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final phase in phaseTable)
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [phase.colour, phase.tail]),
                        ),
                        alignment: Alignment.center,
                        child: Text(phase.name[0], style: sans(9.5, 800, color: Colors.white, height: 1)),
                      ),
                      const SizedBox(width: 6),
                      Text(phase.name[0], style: sans(11.5, 600, color: Hue.inkSoft, height: 1)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ask extends StatelessWidget {
  const _Ask({required this.pulse, required this.onTap});

  final Animation<double> pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF412764), Color(0xFF58347C)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          boxShadow: softShadow(0.8),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 12,
              child: AnimatedBuilder(
                animation: pulse,
                builder: (context, child) =>
                    Transform.scale(scale: 0.85 + 0.2 * math.sin(pulse.value * math.pi * 2).abs(), child: child),
                child: const GlyphIcon(
                  Glyph.sparkles,
                  size: 20,
                  color: Hue.violet,
                  stroke: 1.8,
                  fill: Color(0x339961B9),
                ),
              ),
            ),
            Positioned(
              left: 45,
              top: 10,
              child: Text('Ask Lunara', style: display(16, 600, color: Hue.ink, height: 1)),
            ),
            Positioned(
              right: 14,
              top: 10,
              child: Opacity(
                opacity: 0.75,
                child: CustomPaint(size: const Size(34, 34), painter: const SprigPainter(Hue.violet)),
              ),
            ),
            Positioned(
              left: 16,
              top: 36,
              child: Text("Got a question? I'm here to help.", style: sans(12, 500, color: Hue.inkSoft, height: 1)),
            ),
            Positioned(
              left: 14,
              right: 14,
              top: 56,
              height: 30,
              child: Shimmer(
                animation: pulse,
                tint: Colors.white,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white.withValues(alpha: 0.10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 12,
                        top: 9.5,
                        child: Text(
                          'Why do I get headaches before my period?',
                          style: sans(11.5, 600, color: Hue.amber, height: 1),
                        ),
                      ),
                      const Positioned(
                        right: 10,
                        top: 8,
                        child: GlyphIcon(Glyph.chevronRight, size: 14, color: Hue.amber, stroke: 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
