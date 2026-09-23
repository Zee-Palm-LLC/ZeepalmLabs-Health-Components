import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/run_stats.dart';
import '../../../utils/formatters.dart';

class PaceChart extends StatefulWidget {
  const PaceChart({
    super.key,
    required this.splits,
    required this.averagePace,
    this.height = 158,
  });

  final List<RunSplit> splits;
  final int averagePace;
  final double height;

  @override
  State<PaceChart> createState() => _PaceChartState();
}

class _PaceChartState extends State<PaceChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 260), () {
      if (mounted) _draw.forward();
    });
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _draw,
        builder: (context, _) => CustomPaint(
          painter: _PaceChartPainter(
            splits: widget.splits,
            averagePace: widget.averagePace,
            reveal: Curves.easeOutCubic.transform(_draw.value),
          ),
        ),
      ),
    );
  }
}

class _PaceChartPainter extends CustomPainter {
  _PaceChartPainter({
    required this.splits,
    required this.averagePace,
    required this.reveal,
  });

  final List<RunSplit> splits;
  final int averagePace;
  final double reveal;

  static const double _gutterLeft = 40;
  static const double _gutterBottom = 20;
  static const double _gutterTop = 8;

  @override
  void paint(Canvas canvas, Size size) {
    if (splits.isEmpty) return;

    final plot = Rect.fromLTRB(
      _gutterLeft,
      _gutterTop,
      size.width,
      size.height - _gutterBottom,
    );

    final paces = splits.map((s) => s.paceSeconds.toDouble()).toList();
    var fastest = paces.reduce(math.min);
    var slowest = paces.reduce(math.max);
    final pad = math.max(8.0, (slowest - fastest) * 0.35);
    fastest -= pad;
    slowest += pad;

    double yFor(double pace) {
      final norm = (pace - fastest) / math.max(1, slowest - fastest);
      return plot.top + norm * plot.height;
    }

    double xFor(int index) {
      if (splits.length == 1) return plot.center.dx;
      return plot.left + plot.width * (index / (splits.length - 1));
    }

    final gridPaces = <double>[
      fastest + (slowest - fastest) * 0.12,
      (fastest + slowest) / 2,
      slowest - (slowest - fastest) * 0.12,
    ];
    for (final pace in gridPaces) {
      final y = yFor(pace);
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        Paint()
          ..strokeWidth = 1
          ..color = Night.hairlineSoft,
      );
      _text(
        canvas,
        formatPace(pace),
        Offset(0, y - 6),
        Typo.text(9.5, weight: 500, color: Tone.faint, height: 1.0),
      );
    }

    final averageY = yFor(averagePace.toDouble());
    _dashed(canvas, Offset(plot.left, averageY), Offset(plot.right, averageY));

    final points = List<Offset>.generate(
      splits.length,
      (i) => Offset(xFor(i), yFor(paces[i])),
    );

    final line = _smoothPath(points);
    final metric = line.computeMetrics().first;
    final visible = metric.extractPath(0, metric.length * reveal);

    final fill = Path.from(visible)
      ..lineTo(
        points.first.dx + (points.last.dx - points.first.dx) * reveal,
        plot.bottom,
      )
      ..lineTo(points.first.dx, plot.bottom)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, plot.top),
          Offset(0, plot.bottom),
          <Color>[
            Spectrum.cyan.withValues(alpha: 0.26),
            Spectrum.blue.withValues(alpha: 0.08),
            const Color(0x00000000),
          ],
          const <double>[0.0, 0.55, 1.0],
        ),
    );

    canvas.drawPath(
      visible,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = Spectrum.cyan.withValues(alpha: 0.30),
    );

    canvas.drawPath(
      visible,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = ui.Gradient.linear(
          Offset(plot.left, 0),
          Offset(plot.right, 0),
          const <Color>[
            Spectrum.deep,
            Spectrum.blue,
            Spectrum.cyan,
            Spectrum.teal,
          ],
          const <double>[0.0, 0.35, 0.72, 1.0],
        ),
    );

    var fastestIndex = 0;
    for (var i = 1; i < paces.length; i++) {
      if (paces[i] < paces[fastestIndex]) fastestIndex = i;
    }

    for (var i = 0; i < points.length; i++) {
      final appear = ((reveal * points.length) - i).clamp(0.0, 1.0);
      if (appear <= 0) continue;
      final p = points[i];
      final isFastest = i == fastestIndex;
      final color = isFastest ? Spectrum.amber : Spectrum.cyan;
      canvas.drawCircle(
        p,
        (isFastest ? 8.0 : 5.0) * appear,
        Paint()
          ..color = color.withValues(alpha: 0.35 * appear)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(p, 3.0 * appear, Paint()..color = Colors.white);

      if (i % math.max(1, (splits.length / 8).ceil()) == 0 ||
          i == splits.length - 1) {
        _text(
          canvas,
          '${splits[i].kilometre}',
          Offset(p.dx - 4, plot.bottom + 7),
          Typo.text(9.5, weight: 500, color: Tone.faint, height: 1.0),
        );
      }
    }

    _text(
      canvas,
      'KM',
      Offset(plot.left - 30, plot.bottom + 7),
      Typo.label(8, color: Tone.faint, letterSpacing: 1.2),
    );
  }

  Path _smoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    if (points.length < 3) {
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      return path;
    }
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final dx = (next.dx - current.dx) * 0.42;
      path.cubicTo(
        current.dx + dx,
        current.dy,
        next.dx - dx,
        next.dy,
        next.dx,
        next.dy,
      );
    }
    return path;
  }

  void _dashed(Canvas canvas, Offset a, Offset b) {
    const dash = 5.0;
    const gap = 5.0;
    final paint = Paint()
      ..strokeWidth = 1
      ..color = Spectrum.amber.withValues(alpha: 0.30);
    var x = a.dx;
    while (x < b.dx) {
      canvas.drawLine(
        Offset(x, a.dy),
        Offset(math.min(x + dash, b.dx), a.dy),
        paint,
      );
      x += dash + gap;
    }
  }

  void _text(Canvas canvas, String text, Offset at, TextStyle style) {
    TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(_PaceChartPainter old) => old.reveal != reveal;
}
