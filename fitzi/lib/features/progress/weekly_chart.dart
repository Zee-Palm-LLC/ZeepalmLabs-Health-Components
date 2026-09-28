import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/motion.dart';
import '../../core/type.dart';

class Bar {
  const Bar(this.day, this.cx, this.top, this.shades, this.kcal, {this.fluid});

  final String day;
  final double cx;
  final double top;
  final List<int> shades;
  final int kcal;
  final double? fluid;
}

const bars = [
  Bar('Mon', 60.7, 403.7, [0xC2E9E7, 0xB0E5E3, 0xA8E9A7, 0x93DACE, 0x73C6DE, 0x61B2E3, 0x4793CA], 120),
  Bar('Tue', 109.7, 393.0, [0xBAAFF8, 0xB0A4F9, 0xA397FB, 0x9488FA, 0x897DF7, 0x8175F4, 0x7A6EF0], 160, fluid: 427.5),
  Bar('Wed', 159.2, 393.3, [0xD2C2F7, 0xCDBCFD, 0xC6C2DA, 0xBFEA76, 0x9DD7AC, 0x6BB4CC, 0x5895C3], 150),
  Bar('Thu', 208.5, 375.0, [0xD5B5FF, 0xC8ABFB, 0xBDA3FB, 0xB29CF9, 0xA895F6, 0x9E8EF3, 0x9488F0], 190, fluid: 414.5),
  Bar('Fri', 257.7, 355.0, [0xC7AAF7, 0xC8A2FA, 0xBA99F9, 0xAB93F8, 0x9286F7, 0x7E7CF5, 0x6C6DE1], 210),
  Bar('Sat', 306.0, 402.7, [0xC0E9E9, 0xB6E6E4, 0xBFEDAD, 0xB6EA8A, 0x85CEC2, 0x67BFCE, 0x54A2BE], 120),
  Bar('Sun', 354.2, 394.7, [0xC2E9E3, 0xB6E7E4, 0xB8ECBE, 0xA7E7AA, 0x7DCBCF, 0x60B8D8, 0x52A1C6], 150),
];

class WeeklyChart extends StatefulWidget {
  const WeeklyChart({super.key, required this.entrance, required this.origin});

  final Animation<double> entrance;
  final double origin;

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> with SingleTickerProviderStateMixin {
  int _selected = 4;
  late int _previous = 4;
  late final AnimationController _move;

  @override
  void initState() {
    super.initState();
    _move = AnimationController(vsync: this, duration: const Duration(milliseconds: 620), value: 1);
  }

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  void _pick(int i) {
    if (i == _selected) return;
    HapticFeedback.selectionClick();
    setState(() {
      _previous = _selected;
      _selected = i;
    });
    _move.forward(from: 0);
  }

  void _at(Offset local) {
    var best = 0;
    var d = double.infinity;
    for (var i = 0; i < bars.length; i++) {
      final dd = (bars[i].cx - local.dx).abs();
      if (dd < d) {
        d = dd;
        best = i;
      }
    }
    _pick(best);
  }

  @override
  Widget build(BuildContext context) {
    final label = inter(12.8, 400, color: const Color(0xFF727273), track: -0.04);
    final active = inter(12.8, 400, color: const Color(0xFF45445A), track: -0.04);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => _at(d.localPosition + Offset(0, widget.origin)),
      onHorizontalDragUpdate: (d) => _at(d.localPosition + Offset(0, widget.origin)),
      child: Tick(
        builder: (context, seconds, _) => AnimatedBuilder(
          animation: Listenable.merge([widget.entrance, _move]),
          builder: (context, _) {
            final m = spring(_move.value, bounce: 0.35, freq: 2.4);
            final tipX = lerp(bars[_previous].cx, bars[_selected].cx, m);
            final tipTop = lerp(bars[_previous].top, bars[_selected].top, m);
            final kcal = lerp(bars[_previous].kcal.toDouble(), bars[_selected].kcal.toDouble(), Curves.easeOut.transform(_move.value)).round();
            final tipIn = spring(span(widget.entrance.value, 0.72, 1.0, Curves.linear), bounce: 0.6, freq: 2.6);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _Bars(widget.entrance.value, seconds, _selected, _move.value, widget.origin),
                  ),
                ),
                for (var i = 0; i < bars.length; i++)
                  Positioned(
                    left: bars[i].cx - 30,
                    width: 60,
                    top: 464.33 - widget.origin,
                    child: Opacity(
                      opacity: span(widget.entrance.value, 0.3 + i * 0.04, 0.6 + i * 0.04, Curves.linear),
                      child: Center(child: Cap(bars[i].day, i == _selected ? active : label, align: TextAlign.center)),
                    ),
                  ),
                Positioned(
                  left: tipX - 34.7,
                  top: tipTop - 35.5 - widget.origin - (1 - tipIn) * 10,
                  child: Opacity(
                    opacity: tipIn.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: lerp(0.6, 1, tipIn),
                      alignment: Alignment.bottomCenter,
                      child: _Tip(text: '$kcal kcal'),
                    ),
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

class _Tip extends StatelessWidget {
  const _Tip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = inter(12.6, 500, color: const Color(0xFFF3F4F7), track: 0.02);
    return SizedBox(
      width: 69.4,
      height: 28,
      child: CustomPaint(
        painter: const _TipShape(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Center(child: Text(text, style: style, softWrap: false)),
        ),
      ),
    );
  }
}

class _TipShape extends CustomPainter {
  const _TipShape();

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromLTRBR(0, 0, size.width, 24.3, const Radius.circular(12.15));
    final path = Path()
      ..addRRect(body)
      ..moveTo(size.width / 2 - 4.5, 24)
      ..lineTo(size.width / 2, 28)
      ..lineTo(size.width / 2 + 4.5, 24)
      ..close();
    canvas.drawShadow(path, const Color(0xFF1C1E29), 6, false);
    canvas.drawPath(path, Paint()..color = const Color(0xFF1C1E29));
  }

  @override
  bool shouldRepaint(_TipShape old) => false;
}

class _Bars extends CustomPainter {
  _Bars(this.t, this.seconds, this.selected, this.move, this.origin);

  final double t;
  final double seconds;
  final int selected;
  final double move;
  final double origin;

  static const bottom = 454.0;
  static const half = 13.5;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0, -origin);
    for (var i = 0; i < bars.length; i++) {
      final b = bars[i];
      final g = spring(span(t, 0.18 + i * 0.05, 0.7 + i * 0.05, Curves.linear), bounce: 0.35, freq: 2.2);
      if (g <= 0) continue;
      final h = (bottom - b.top) * g;
      final top = bottom - h;
      final rect = Rect.fromLTRB(b.cx - half, top, b.cx + half, bottom);
      final capsule = RRect.fromRectAndRadius(rect, const Radius.circular(half));
      if (i == selected && move < 1) {
        canvas.drawRRect(
          capsule.inflate(3),
          Paint()
            ..color = const Color(0xFF7E7CF5).withValues(alpha: 0.32 * math.sin(move * math.pi))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
        );
      }
      final stops = List.generate(b.shades.length, (k) => 0.04 + 0.92 * k / (b.shades.length - 1));
      canvas.save();
      canvas.clipRRect(capsule);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(
            rect.topCenter,
            rect.bottomCenter,
            [for (final s in b.shades) Color(0xFF000000 | s)],
            stops,
          ),
      );
      if (b.fluid != null) {
        final full = bottom - b.fluid!;
        final level = bottom - full * g;
        final slosh = math.sin(seconds * 2.4 + i) * 1.4;
        final path = Path()..moveTo(rect.left, bottom);
        path.lineTo(rect.left, level + half * 0.55);
        for (var x = 0.0; x <= 1.0001; x += 0.05) {
          final px = rect.left + x * rect.width;
          final dome = math.sqrt(math.max(0.0, 1 - math.pow(2 * x - 1, 2))) * half * 0.55;
          final ripple = math.sin(x * math.pi * 2 + seconds * 3.1 + i) * 1.1;
          path.lineTo(px, level + half * 0.55 - dome + ripple * (x * (1 - x) * 4) + slosh * (x - 0.5));
        }
        path.lineTo(rect.right, bottom);
        path.close();
        canvas.drawPath(
          path,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, level),
              const Offset(0, bottom),
              const [Color(0xFFE3F595), Color(0xFFD6F056), Color(0xFFCFE36F)],
              const [0, 0.5, 1],
            ),
        );
      }
      final shine = (seconds * 0.35 + i * 0.13) % 1.0;
      final sy = lerp(bottom + 10, top - 10, shine);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, sy - 14),
            Offset(0, sy + 14),
            const [Color(0x00FFFFFF), Color(0x2EFFFFFF), Color(0x00FFFFFF)],
            const [0, 0.5, 1],
          ),
      );
      for (var k = 0; k < 3; k++) {
        final p = ((seconds * (0.22 + k * 0.07)) + i * 0.31 + k * 0.37) % 1.0;
        final by = lerp(bottom - 4, top + 6, p);
        final bx = b.cx + math.sin(p * math.pi * 3 + k + i) * 5;
        canvas.drawCircle(
          Offset(bx, by),
          1.1 + k * 0.35,
          Paint()..color = Color.fromRGBO(255, 255, 255, 0.35 * math.sin(p * math.pi)),
        );
      }
      canvas.drawRRect(
        capsule.deflate(0.4),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..shader = ui.Gradient.linear(
            rect.centerLeft,
            rect.centerRight,
            const [Color(0x33FFFFFF), Color(0x00FFFFFF), Color(0x1AFFFFFF)],
            const [0, 0.5, 1],
          ),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_Bars old) => true;
}
