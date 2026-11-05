import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../core/motion.dart';
import 'kit.dart';

/// Rounded pill columns: a track per day with a fill that grows from the
/// bottom. Dashed lines mark the personal range.
class PillBarsPainter extends CustomPainter {
  PillBarsPainter({
    required this.values,
    required this.min,
    required this.max,
    required this.fill,
    required this.track,
    required this.progress,
    this.gap = 6,
    this.rangeLow,
    this.rangeHigh,
    this.rangeColor,
    this.selected,
    this.selectedColor,
    this.maxBar = 18,
  });

  final List<int> values;
  final double min;
  final double max;
  final Color Function(int index, int value) fill;
  final Color track;
  final double progress;
  final double gap;
  final double? rangeLow;
  final double? rangeHigh;
  final Color? rangeColor;
  final int? selected;
  final Color? selectedColor;
  final double maxBar;

  static double barWidth(double width, int count, double gap, [double maxBar = 18]) => math.min((width - gap * (count - 1)) / count, maxBar);

  /// Distance between bar starts; bars narrower than their slot spread out.
  static double step(double width, int count, double gap, [double maxBar = 18]) =>
      count > 1 ? (width - barWidth(width, count, gap, maxBar)) / (count - 1) : 0;

  static double centerOf(int index, double width, int count, double gap, [double maxBar = 18]) =>
      index * step(width, count, gap, maxBar) + barWidth(width, count, gap, maxBar) / 2;

  double _y(double v, double h) => h * ((v - min) / (max - min)).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    final w = barWidth(size.width, n, gap, maxBar);
    final pitch = step(size.width, n, gap, maxBar);
    final r = Radius.circular(w / 2);
    final stagger = n > 1 ? 0.45 / (n - 1) : 0.0;
    for (var i = 0; i < n; i++) {
      final x = i * pitch;
      final rect = Rect.fromLTWH(x, 0, w, size.height);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, r), Paint()..color = track);
      final grow = span(progress, i * stagger, i * stagger + 0.55, swift);
      final h = math.max(_y(values[i].toDouble(), size.height) * grow, 0.0);
      if (h > 0) {
        final fr = Rect.fromLTWH(x, size.height - h, w, h);
        canvas.drawRRect(RRect.fromRectAndRadius(fr, Radius.circular(math.min(w / 2, h / 2))), Paint()..color = fill(i, values[i]));
      }
      if (i == selected && selectedColor != null) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(2.5), Radius.circular(w / 2 + 2.5)),
          Paint()
            ..color = selectedColor!
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
    if (rangeColor != null) {
      final fade = span(progress, 0.4, 1);
      final p = Paint()..color = rangeColor!.withValues(alpha: rangeColor!.a * fade);
      for (final v in [rangeLow, rangeHigh]) {
        if (v == null) continue;
        dashLine(canvas, Offset(0, size.height - _y(v, size.height)), size.width, p);
      }
    }
  }

  @override
  bool shouldRepaint(PillBarsPainter old) =>
      old.progress != progress || old.values != values || old.selected != selected || old.gap != gap || old.track != track;
}

/// Plays a 0→1 progress once per [trigger] value, so a chart regrows when its
/// data set changes.
class Grow extends StatelessWidget {
  const Grow({super.key, required this.trigger, required this.builder, this.delay = 0, this.duration = 900});

  final Object trigger;
  final Widget Function(BuildContext context, double t) builder;
  final int delay;
  final int duration;

  @override
  Widget build(BuildContext context) {
    final total = delay + duration;
    return TweenAnimationBuilder<double>(
      key: ValueKey(trigger),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      builder: (context, v, _) => builder(context, span(v, delay / total, 1, const Cubic(0.33, 0, 0.2, 1))),
    );
  }
}
