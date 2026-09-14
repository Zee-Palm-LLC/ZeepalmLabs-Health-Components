import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// The sprinting figure, drawn rather than shipped as an asset.
///
/// Traced off the reference: two nested chevrons and a head, all built on a
/// 100 x 100 box so the whole mark scales from a 24-unit tab icon to a
/// full-screen splash with no second copy and no raster edges.
///
/// The stroke geometry is the *point* of doing it this way — because the mark
/// is a set of centrelines rather than an outline, it can be drawn on with
/// [ui.PathMetric], which is what the splash animation does.
class InnurMark extends StatelessWidget {
  const InnurMark({
    super.key,
    required this.size,
    this.progress = 1,
    this.color = const Color(0xFFFFFFFF),
  });

  final double size;

  /// 0 is an empty box, 1 is the finished mark. In between, the strokes are
  /// part-drawn in order.
  final double progress;

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _MarkPainter(progress: progress, color: color),
        ),
      );
}

/// Geometry of the mark, in its own 100 x 100 space.
class MarkGeometry {
  const MarkGeometry._();

  static const double box = 100;

  /// Every limb is the same weight; that even stroke is what holds the mark
  /// together as one figure rather than three shapes.
  static const double stroke = 19;

  /// Back and leading arm: down-left, up to the shoulder, down to the hand.
  static const List<Offset> upper = <Offset>[
    Offset(2, 82),
    Offset(53, 31),
    Offset(93, 67),
  ];

  /// Trailing leg: along the ground, then up behind.
  static const List<Offset> lower = <Offset>[
    Offset(10, 90),
    Offset(33, 90),
    Offset(65, 62),
  ];

  static const Offset head = Offset(86, 13);
  static const double headRadius = 13;

  /// The upper chevron's trailing end is cut flat and horizontal rather than
  /// capped round — it reads as speed. Everything below this line, left of
  /// [cutRight], is erased after the stroke is laid down.
  static const double cutY = 71.5;
  static const double cutRight = 46;

  static Path pathFor(List<Offset> points) {
    final p = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      p.lineTo(point.dx, point.dy);
    }
    return p;
  }

  /// Length of a polyline, used to weight each stroke's share of the draw.
  static double lengthOf(List<Offset> points) {
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += (points[i] - points[i - 1]).distance;
    }
    return total;
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  /// The three strokes are drawn in sequence, each taking a share of the
  /// timeline proportional to its own length — so the pen moves at a constant
  /// speed instead of racing through the short strokes.
  static final double _upperLen = MarkGeometry.lengthOf(MarkGeometry.upper);
  static final double _lowerLen = MarkGeometry.lengthOf(MarkGeometry.lower);
  static final double _headLen = 2 * math.pi * MarkGeometry.headRadius / 2;
  static final double _total = _upperLen + _lowerLen + _headLen;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final scale = size.width / MarkGeometry.box;
    canvas.save();
    canvas.scale(scale);

    // Each stroke's window on the shared timeline. They overlap slightly, so
    // the next limb starts before the last one finishes and the mark never
    // looks like three separate events.
    const overlap = 0.08;
    final upperEnd = _upperLen / _total;
    final lowerEnd = upperEnd + _lowerLen / _total;

    _drawStroke(canvas, MarkGeometry.upper,
        _window(0, upperEnd), clipTail: true);
    _drawStroke(canvas, MarkGeometry.lower,
        _window(upperEnd - overlap, lowerEnd));
    _drawHead(canvas, _window(lowerEnd - overlap, 1));

    canvas.restore();
  }

  /// Maps overall [progress] onto one stroke's slice of it.
  double _window(double from, double to) {
    if (to <= from) return progress >= to ? 1 : 0;
    return ((progress - from) / (to - from)).clamp(0.0, 1.0);
  }

  void _drawStroke(
    Canvas canvas,
    List<Offset> points,
    double t, {
    bool clipTail = false,
  }) {
    if (t <= 0) return;

    final full = MarkGeometry.pathFor(points);
    final drawn = t >= 1 ? full : _partial(full, t);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = MarkGeometry.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    if (!clipTail) {
      canvas.drawPath(drawn, paint);
      return;
    }

    // Lay the stroke down in its own layer, then erase the corner below the
    // cut. Doing it with dstOut rather than a clip means the erase follows the
    // stroke while it is still being drawn, so the flat tail is there from the
    // first frame instead of snapping in at the end.
    canvas.saveLayer(
      const Rect.fromLTWH(-20, -20, MarkGeometry.box + 40, MarkGeometry.box + 40),
      Paint(),
    );
    canvas.drawPath(drawn, paint);
    canvas.drawRect(
      const Rect.fromLTRB(
        -20,
        MarkGeometry.cutY,
        MarkGeometry.cutRight,
        MarkGeometry.box + 20,
      ),
      Paint()..blendMode = BlendMode.dstOut,
    );
    canvas.restore();
  }

  /// The head is drawn as a sweep rather than popped in: an arc at half the
  /// radius, stroked at the full radius, fills the disc as it goes round.
  void _drawHead(Canvas canvas, double t) {
    if (t <= 0) return;

    final r = MarkGeometry.headRadius;
    canvas.drawArc(
      Rect.fromCircle(center: MarkGeometry.head, radius: r / 2),
      -math.pi / 2,
      math.pi * 2 * t,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = r
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );
  }

  static Path _partial(Path path, double t) {
    final out = Path();
    for (final metric in path.computeMetrics()) {
      out.addPath(metric.extractPath(0, metric.length * t), Offset.zero);
    }
    return out;
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.progress != progress || old.color != color;
}
