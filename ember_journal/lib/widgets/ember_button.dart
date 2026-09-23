import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';

class GoldButton extends StatefulWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.done,
    required this.onCommit,
    required this.seconds,
    this.height = 50,
  });

  final String label;
  final String done;
  final Future<void> Function() onCommit;
  final double seconds;
  final double height;

  @override
  State<GoldButton> createState() => GoldButtonState();
}

class GoldButtonState extends State<GoldButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1320));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _fire() async {
    if (_c.isAnimating) return;
    await _c.animateTo(0.74, duration: const Duration(milliseconds: 820), curve: Curves.easeOutCubic);
    if (!mounted) return;
    await widget.onCommit();
    if (!mounted) return;
    await _c.animateTo(1, duration: const Duration(milliseconds: 460), curve: Curves.easeOut);
    if (!mounted) return;
    _c.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: _fire,
      scale: 0.975,
      child: SizedBox(
        height: widget.height,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final label = 1 - span(t, 0.10, 0.30, Curves.easeIn);
            final done = span(t, 0.76, 0.96);
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: CustomPaint(painter: _GoldPainter(t, widget.seconds))),
                if (label > 0.02)
                  Opacity(
                    opacity: label,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - label)),
                      child: Text(widget.label, style: font(15.5, 600, color: const Color(0xFF52260A))),
                    ),
                  ),
                if (done > 0.02)
                  Opacity(
                    opacity: done,
                    child: Transform.translate(
                      offset: Offset(16 * (1 - done), 0),
                      child: Text(widget.done, style: font(15.5, 600, color: const Color(0xFF52260A))),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GoldPainter extends CustomPainter {
  const _GoldPainter(this.t, this.seconds);

  final double t;
  final double seconds;

  static final _sparks = List.generate(22, (i) {
    final r = math.Random(i * 53 + 9);
    return (r.nextDouble() * math.pi * 2, 0.5 + r.nextDouble(), 1.2 + r.nextDouble() * 2.4, r.nextBool());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2));

    canvas.drawRRect(
      shape.shift(const Offset(0, 9)),
      Paint()
        ..color = Ember.amber.withValues(alpha: 0.38)
        ..maskFilter = const ui.MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawRRect(shape, Paint()..shader = goldGradient.createShader(rect));

    canvas.save();
    canvas.clipRRect(shape);

    final fill = span(t, 0.0, 0.62, Curves.easeInOutCubic);
    if (fill > 0.002) {
      final level = size.height * (1 - fill);
      final wave = Path()..moveTo(0, level);
      for (var x = 0.0; x <= size.width; x += 4) {
        final y = level + math.sin((x / size.width * 2.6 + t * 5) * math.pi * 2) * 5 * (1 - fill);
        wave.lineTo(x, y);
      }
      wave
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        wave,
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, level), Offset(0, size.height), const [
            Color(0xFFFFE07A),
            Color(0xFFFFB52F),
          ]),
      );
    }

    if (t <= 0.02) {
      final sweep = (seconds / 2.6 % 1.0) * 1.7 - 0.35;
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(size.width * (sweep - 0.16), 0),
            Offset(size.width * (sweep + 0.16), size.height),
            const [Color(0x00FFFFFF), Color(0x54FFFFFF), Color(0x00FFFFFF)],
            const [0.0, 0.5, 1.0],
          ),
      );
    }
    canvas.restore();

    final tick = span(t, 0.48, 0.72, Curves.easeOutCubic);
    if (tick > 0.01) {
      final slide = span(t, 0.76, 0.96);
      final centre = Offset(size.width / 2 - 46 * slide, size.height / 2);
      final check = Path()
        ..moveTo(centre.dx - 9, centre.dy + 0.5)
        ..lineTo(centre.dx - 2.4, centre.dy + 7)
        ..lineTo(centre.dx + 10, centre.dy - 6.8);
      final metric = check.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * tick),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xFF52260A),
      );
    }

    final burst = span(t, 0.68, 1.0);
    if (burst > 0.01 && burst < 1) {
      final centre = Offset(size.width / 2, size.height / 2);
      for (final (angle, speed, radius, warm) in _sparks) {
        final at = centre + Offset(math.cos(angle) * 1.5, math.sin(angle) * 0.62) * burst * speed * 96;
        canvas.drawCircle(
          at,
          radius * (1 - burst),
          Paint()..color = (warm ? Ember.cream : Ember.gold).withValues(alpha: 0.9 * (1 - burst)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GoldPainter old) => old.t != t || old.seconds != seconds;
}

class GhostBar extends StatelessWidget {
  const GhostBar({
    super.key,
    required this.label,
    required this.onTap,
    required this.seconds,
    this.height = 46,
  });

  final String label;
  final VoidCallback onTap;
  final double seconds;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 2),
                  color: const Color(0x2B0A0402),
                  border: Border.all(color: hairline),
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(label, style: font(13.9, 500, color: Ember.cream.withValues(alpha: 0.92))),
              ),
            ),
            Positioned(
              left: 3,
              top: 3,
              child: _Knob(seconds: seconds, size: height - 6),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(child: _Chevrons(seconds: seconds)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Knob extends StatelessWidget {
  const _Knob({required this.seconds, required this.size});

  final double seconds;
  final double size;

  @override
  Widget build(BuildContext context) {
    final glow = 0.6 + 0.4 * math.sin(seconds * 2.4);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: fabGradient,
        boxShadow: [
          BoxShadow(
            color: Ember.amber.withValues(alpha: 0.45 * glow),
            blurRadius: 16 + 6 * glow,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Transform.translate(
          offset: const Offset(1, 0),
          child: const GlyphIcon(Glyph.chevron, size: 15, color: Color(0xFF52260A), stroke: 2.4),
        ),
      ),
    );
  }
}

class _Chevrons extends StatelessWidget {
  const _Chevrons({required this.seconds});

  final double seconds;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 44, height: 14, child: CustomPaint(painter: _ChevronPainter(seconds)));
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.seconds);

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    const count = 4;
    for (var i = 0; i < count; i++) {
      final phase = (seconds * 1.1 - i * 0.16) % 1.0;
      final alpha = (0.18 + 0.72 * math.pow(math.sin(phase * math.pi), 3).toDouble()).clamp(0.0, 1.0);
      final x = 6.0 + i * 10.0;
      canvas.drawPath(
        Path()
          ..moveTo(x, 2)
          ..lineTo(x + 5.6, size.height / 2)
          ..lineTo(x, size.height - 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.7
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Ember.gold.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.seconds != seconds;
}
