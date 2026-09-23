import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';

const navGlyphs = [Glyph.home, Glyph.book, Glyph.sparkles, Glyph.person];

class LiquidNav extends StatefulWidget {
  const LiquidNav({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onCompose,
    required this.seconds,
    required this.composing,
    this.skirt = 0,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onCompose;
  final double seconds;
  final double composing;
  final double skirt;

  static const fabX = 196.0;
  static const height = 104.0;

  @override
  State<LiquidNav> createState() => _LiquidNavState();
}

class _LiquidNavState extends State<LiquidNav> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late double _from;
  late double _to;

  static const slots = [66.0, 138.0, 254.0, 326.0];
  static const barLeft = 12.0;
  static const barRight = 381.0;
  static const fabCentre = 196.0;
  static const fabRadius = 32.0;

  @override
  void initState() {
    super.initState();
    _from = _to = widget.selected.toDouble();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 660), value: 1);
  }

  @override
  void didUpdateWidget(LiquidNav old) {
    super.didUpdateWidget(old);
    if (widget.selected.toDouble() != _to) {
      _from = _to;
      _to = widget.selected.toDouble();
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final lead = Curves.easeOutQuint.transform(t);
        final trail = Curves.easeInOutCubic.transform(math.pow(t, 1.5).toDouble());
        final fromX = slots[_from.round()];
        final toX = slots[_to.round()];
        final a = lerp(fromX, toX, toX > fromX ? trail : lead);
        final b = lerp(fromX, toX, toX > fromX ? lead : trail);
        final blob = Rect.fromLTRB(
          math.min(a, b) - 28,
          17 - 3 * (1 - t),
          math.max(a, b) + 28,
          55 + 3 * (1 - t),
        );
        return SizedBox(
          width: 393,
          height: LiquidNav.height + widget.skirt,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 32,
                height: 72 + widget.skirt,
                child: CustomPaint(
                  painter: _BarPainter(seconds: widget.seconds, blob: blob),
                ),
              ),
              for (var i = 0; i < navGlyphs.length; i++)
                Positioned(
                  left: slots[i] - 26,
                  top: 32 + 8,
                  width: 52,
                  height: 52,
                  child: Pressable(
                    scale: 0.86,
                    onTap: () => widget.onSelect(i),
                    child: _NavIcon(
                      glyph: navGlyphs[i],
                      on: (1 - (lerp(_from, _to, Curves.easeInOut.transform(t)) - i).abs()).clamp(0.0, 1.0),
                      blob: blob.translate(-(slots[i] - 26), 0),
                    ),
                  ),
                ),
              Positioned(
                left: fabCentre - fabRadius,
                top: 0,
                width: fabRadius * 2,
                height: fabRadius * 2,
                child: Pressable(
                  scale: 0.9,
                  onTap: widget.onCompose,
                  child: _Fab(seconds: widget.seconds, open: widget.composing),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Path navBarPath(Size size) {
  const left = _LiquidNavState.barLeft;
  const right = _LiquidNavState.barRight;
  const cx = _LiquidNavState.fabCentre;
  const notch = 52.0;
  final path = Path()
    ..moveTo(left + 30, 0)
    ..lineTo(cx - notch, 0)
    ..cubicTo(cx - notch * 0.44, 0, cx - notch * 0.52, 22, cx, 22)
    ..cubicTo(cx + notch * 0.52, 22, cx + notch * 0.44, 0, cx + notch, 0)
    ..lineTo(right - 30, 0)
    ..quadraticBezierTo(right, 0, right, 30)
    ..lineTo(right, size.height)
    ..lineTo(left, size.height)
    ..lineTo(left, 30)
    ..quadraticBezierTo(left, 0, left + 30, 0)
    ..close();
  return path;
}

class _BarPainter extends CustomPainter {
  const _BarPainter({required this.seconds, required this.blob});

  final double seconds;
  final Rect blob;

  @override
  void paint(Canvas canvas, Size size) {
    final path = navBarPath(size);
    canvas.drawPath(
      path.shift(const Offset(0, -6)),
      Paint()
        ..color = const Color(0x59000000)
        ..maskFilter = const ui.MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawPath(path, Paint()..color = const Color(0xFF080302).withValues(alpha: 0.94));
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, 72), const [
          Color(0x1FFFD4A0),
          Color(0x00FFD4A0),
        ]),
    );

    canvas.save();
    canvas.clipPath(path);
    final shape = RRect.fromRectAndRadius(blob, Radius.circular(blob.height / 2));
    canvas.drawRRect(
      shape,
      Paint()
        ..color = Ember.amber.withValues(alpha: 0.34)
        ..maskFilter = const ui.MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawRRect(shape, Paint()..shader = fabGradient.createShader(blob));
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), const [
          Color(0x3DFFE2C4),
          Color(0x0AFFE2C4),
        ]),
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.blob != blob || old.seconds != seconds;
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.glyph, required this.on, required this.blob});

  final Glyph glyph;
  final double on;
  final Rect blob;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NavIconPainter(glyph: glyph, on: on, blob: blob),
    );
  }
}

class _NavIconPainter extends CustomPainter {
  const _NavIconPainter({required this.glyph, required this.on, required this.blob});

  final Glyph glyph;
  final double on;
  final Rect blob;

  void _draw(Canvas canvas, Size size, Color color, double scale) {
    final path = glyphPath(glyph);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(23 * scale / 24);
    canvas.translate(-12, -12);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = {Glyph.book, Glyph.sparkles}.contains(glyph) ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1.75 * 24 / (23 * scale)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = 1 + 0.06 * on;
    _draw(canvas, size, Ember.ash.withValues(alpha: 0.62 + 0.20 * on), scale);
    if (blob.right < 0 || blob.left > size.width) return;
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(blob, Radius.circular(blob.height / 2)));
    _draw(canvas, size, const Color(0xFF3F1C05), scale);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_NavIconPainter old) => old.on != on || old.blob != blob;
}

class _Fab extends StatelessWidget {
  const _Fab({required this.seconds, required this.open});

  final double seconds;
  final double open;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FabPainter(seconds: seconds, open: open),
    );
  }
}

class _FabPainter extends CustomPainter {
  const _FabPainter({required this.seconds, required this.open});

  final double seconds;
  final double open;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final r = size.width / 2;
    final pulse = 0.5 + 0.5 * math.sin(seconds * 1.9);

    for (var i = 0; i < 2; i++) {
      final phase = (seconds * 0.55 + i * 0.5) % 1.0;
      canvas.drawCircle(
        centre,
        r * (1 + phase * 0.55),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Ember.gold.withValues(alpha: 0.24 * (1 - phase)),
      );
    }

    canvas.drawCircle(
      centre.translate(0, 5),
      r,
      Paint()
        ..color = Ember.amber.withValues(alpha: 0.42 + 0.14 * pulse)
        ..maskFilter = const ui.MaskFilter.blur(BlurStyle.normal, 20),
    );
    canvas.drawCircle(
      centre,
      r,
      Paint()..shader = fabGradient.createShader(Rect.fromCircle(center: centre, radius: r)),
    );
    canvas.drawCircle(
      centre,
      r - 0.6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = const Color(0x8CFFF0C0),
    );

    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(open * math.pi * 0.75);
    final arm = 8.4;
    final ink = Paint()
      ..color = const Color(0xFF52260A)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-arm, 0), Offset(arm, 0), ink);
    canvas.drawLine(Offset(0, -arm), Offset(0, arm), ink);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FabPainter old) => old.seconds != seconds || old.open != open;
}
