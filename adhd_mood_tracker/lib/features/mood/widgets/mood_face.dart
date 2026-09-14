import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design.dart';
import '../../../core/mood.dart';

/// Draws the two eyes and the mouth for an interpolated [FaceShape].
///
/// The whole face is one path pair, so a mood change is a continuous morph:
/// the eyes collapse from circles into a squint and the mouth's control point
/// travels through flat on its way from a frown to a smile. That asymmetric
/// mid-frame is the effect the reference recording gets by tweening geometry
/// rather than swapping three static faces.
class MoodFace extends StatelessWidget {
  const MoodFace({super.key, required this.shape, this.ink = kInk});

  final FaceShape shape;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(Design.width, Design.height),
      painter: _FacePainter(shape: shape, ink: ink),
      isComplex: false,
    );
  }
}

/// The same face, shrunk to fit a box — used for the picker circles.
///
/// It reuses the full-size geometry and scales the canvas rather than keeping
/// a second set of small-face numbers, so the icons can never drift out of
/// sync with the face they stand for.
class MoodFaceIcon extends StatelessWidget {
  const MoodFaceIcon({
    super.key,
    required this.shape,
    required this.size,
    required this.ink,
  });

  final FaceShape shape;
  final double size;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _FacePainter(shape: shape, ink: ink, fitToBox: true),
      isComplex: false,
    );
  }
}

/// Bounding box of a face in design coordinates.
Rect faceBounds(FaceShape shape) {
  final width = math.max(
    shape.eyeWidth * 2 + shape.eyeGap,
    shape.mouthWidth + Design.faceMouthStroke,
  );
  const top = Design.faceEyeTop;
  final bottom = shape.mouthCenterY +
      shape.mouthArc.abs() / 2 +
      Design.faceMouthStroke / 2;

  return Rect.fromCenter(
    center: Offset(Design.faceCenterX, (top + bottom) / 2),
    width: width,
    height: bottom - top,
  );
}

class _FacePainter extends CustomPainter {
  _FacePainter({
    required this.shape,
    required this.ink,
    this.fitToBox = false,
  });

  final FaceShape shape;
  final Color ink;

  /// When true the face is scaled and centred into [size] instead of being
  /// drawn at its design coordinates.
  final bool fitToBox;

  @override
  void paint(Canvas canvas, Size size) {
    if (fitToBox) {
      final bounds = faceBounds(shape);
      final target = size.shortestSide * Design.moodDotFaceFit;
      final scale = math.min(target / bounds.width, target / bounds.height);

      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.scale(scale);
      canvas.translate(-bounds.center.dx, -bounds.center.dy);
      // The canvas scale would take the mouth below a hairline on the
      // wide-eyed moods, where the mouth is a quarter of the eye width — it
      // disappears and the icon reads as two dots. Hold it to a floor in
      // on-screen units by dividing the floor back out through the scale.
      _paintFace(canvas, minMouthStroke: Design.moodDotMinStroke / scale);
      canvas.restore();
      return;
    }
    _paintFace(canvas);
  }

  void _paintFace(Canvas canvas, {double minMouthStroke = 0}) {
    final fill = Paint()
      ..color = ink
      ..isAntiAlias = true;

    // --- Eyes -------------------------------------------------------------
    // The brow line is fixed: eyes always start at faceEyeTop and grow down,
    // so a squint collapses toward the brow instead of toward its own centre.
    final halfGap = shape.eyeGap / 2;
    final radius = Radius.circular(
      math.min(shape.eyeWidth, shape.eyeHeight) / 2,
    );

    for (final sign in const <double>[-1, 1]) {
      final inner = Design.faceCenterX + sign * halfGap;
      final outer = inner + sign * shape.eyeWidth;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            sign < 0 ? outer : inner,
            Design.faceEyeTop,
            sign < 0 ? inner : outer,
            Design.faceEyeTop + shape.eyeHeight,
          ),
          radius,
        ),
        fill,
      );
    }

    // --- Mouth ------------------------------------------------------------
    // A single quadratic. `mouthArc` is the signed sagitta, so the control
    // point sits at 1.5x the arc to put the curve's midpoint exactly there.
    final cx = Design.faceCenterX;
    final cy = shape.mouthCenterY;
    final half = shape.mouthWidth / 2;
    final chordY = cy - shape.mouthArc / 2;

    final mouth = Path()
      ..moveTo(cx - half, chordY)
      ..quadraticBezierTo(cx, cy + shape.mouthArc * 1.5, cx + half, chordY);

    canvas.drawPath(
      mouth,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(Design.faceMouthStroke, minMouthStroke)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_FacePainter old) =>
      old.shape != shape || old.ink != ink || old.fitToBox != fitToBox;
}
