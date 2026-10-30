import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'theme.dart';

/// The part of `assets/images/body.png` (1280 × 720) the figure shows.
const figureSrc = Rect.fromLTRB(300, 0, 1000, 712);

/// Hand-traced contour strokes of the figure, in source-image pixels. The
/// splash draws them one after another; they line up with the illustration
/// so the drawing dissolves straight into it.
final List<Path> figureStrokes = [
  // Head and face.
  Path()
    ..moveTo(588, 198)
    ..cubicTo(570, 160, 560, 110, 568, 70)
    ..cubicTo(580, 25, 625, 10, 660, 14)
    ..cubicTo(705, 18, 740, 40, 735, 75)
    ..cubicTo(732, 100, 728, 118, 730, 140)
    ..cubicTo(738, 152, 734, 162, 724, 170)
    ..cubicTo(722, 192, 712, 206, 690, 212),
  // Left contour: trapezius, shoulder, outer arm.
  Path()
    ..moveTo(586, 202)
    ..cubicTo(560, 230, 515, 245, 470, 262)
    ..cubicTo(430, 276, 405, 300, 398, 345)
    ..cubicTo(392, 400, 392, 450, 378, 510)
    ..cubicTo(362, 575, 350, 640, 344, 715),
  // Right contour.
  Path()
    ..moveTo(690, 214)
    ..cubicTo(712, 236, 760, 250, 810, 266)
    ..cubicTo(850, 280, 870, 305, 875, 345)
    ..cubicTo(880, 400, 882, 450, 893, 510)
    ..cubicTo(905, 575, 915, 640, 920, 715),
  // Left inner arm and flank.
  Path()
    ..moveTo(432, 712)
    ..cubicTo(436, 640, 452, 560, 468, 495)
    ..cubicTo(476, 460, 482, 432, 492, 418)
    ..cubicTo(505, 470, 520, 540, 522, 600)
    ..cubicTo(522, 650, 505, 690, 498, 716),
  // Right inner arm and flank.
  Path()
    ..moveTo(852, 712)
    ..cubicTo(846, 640, 826, 560, 808, 495)
    ..cubicTo(798, 460, 792, 432, 785, 418)
    ..cubicTo(772, 470, 760, 540, 758, 600)
    ..cubicTo(758, 650, 772, 690, 780, 716),
  // Spine.
  Path()
    ..moveTo(632, 218)
    ..cubicTo(634, 380, 630, 540, 632, 690),
  // Shoulder blades and lats.
  Path()
    ..moveTo(548, 292)
    ..cubicTo(536, 340, 552, 400, 600, 444)
    ..moveTo(520, 432)
    ..cubicTo(560, 500, 600, 560, 632, 625),
  Path()
    ..moveTo(718, 292)
    ..cubicTo(730, 340, 714, 400, 666, 444)
    ..moveTo(748, 432)
    ..cubicTo(708, 500, 668, 560, 632, 625),
];

/// Pain hotspots in source-image pixels: shoulder, elbow, lower back.
const figureHotspots = [Offset(805, 322), Offset(870, 548), Offset(606, 606)];

/// Paints the figure into [rect]: the traced strokes drawn up to [draw]
/// (0..1 over all strokes), the illustration at [image] opacity, and pulsing
/// hotspots scaled in by [hot].
class FigurePainter extends CustomPainter {
  FigurePainter({
    required this.rect,
    required this.img,
    required this.draw,
    required this.lines,
    required this.image,
    required this.hot,
    required this.time,
  });

  final Rect rect;
  final ui.Image? img;
  final double draw, lines, image, hot, time;

  // Keys the white backdrop of the render to transparent: alpha from redness,
  // so the pale glass highlights stay translucent.
  static const _key = ColorFilter.matrix([
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    -2.7, 0, 0, 0, 2.7 * 255,
  ]);

  @override
  void paint(Canvas canvas, Size size) {
    final k = rect.width / figureSrc.width;
    final toRect = Matrix4.identity()
      ..translateByDouble(rect.left, rect.top, 0, 1)
      ..scaleByDouble(k, rect.height / figureSrc.height, 1, 1)
      ..translateByDouble(-figureSrc.left, -figureSrc.top, 0, 1);

    if (img != null && image > 0) {
      canvas.saveLayer(rect.inflate(2), Paint()..color = Color.fromRGBO(0, 0, 0, image));
      canvas.drawImageRect(
        img!,
        figureSrc,
        rect,
        Paint()
          ..colorFilter = _key
          ..filterQuality = FilterQuality.medium,
      );
      // Fade the hips out into the page, as in the design.
      canvas.drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.dstIn
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white, Color(0x00FFFFFF)],
            stops: [0, 0.78, 1],
          ).createShader(rect),
      );
      canvas.restore();
    }

    if (lines > 0 && draw > 0) {
      final n = figureStrokes.length;
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 7
        ..color = C.sky.withValues(alpha: 0.45 * lines)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      final pen = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 2.2
        ..color = C.blue.withValues(alpha: lines);
      final heads = <Offset>[];
      for (var i = 0; i < n; i++) {
        // Strokes overlap in time so the hand never stops.
        final local = clamp01(draw * (n * 0.55 + 0.45) - i * 0.55);
        if (local <= 0) continue;
        final path = figureStrokes[i].transform(toRect.storage);
        final part = Path();
        for (final m in path.computeMetrics()) {
          final len = m.length * Curves.easeInOutCubic.transform(local);
          part.addPath(m.extractPath(0, len), Offset.zero);
          if (local < 1) heads.add(m.getTangentForOffset(len)?.position ?? Offset.zero);
        }
        canvas.drawPath(part, glow);
        canvas.drawPath(part, pen);
      }
      // Bright pen tips while drawing.
      for (final h in heads) {
        canvas.drawCircle(
          h,
          7,
          Paint()
            ..color = C.sky.withValues(alpha: 0.5 * lines)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
        canvas.drawCircle(h, 2.6, Paint()..color = Colors.white.withValues(alpha: lines));
      }
    }

    if (hot > 0) {
      for (var i = 0; i < figureHotspots.length; i++) {
        final p = MatrixUtils.transformPoint(toRect, figureHotspots[i]);
        final s = Curves.elasticOut.transform(clamp01(hot * 1.6 - i * 0.3));
        if (s <= 0) continue;
        final pulse = 0.5 + 0.5 * math.sin(time * 3 + i * 1.7);
        final r = rect.width * (i == 0 ? 0.075 : 0.06) * s;
        canvas.drawCircle(
          p,
          r * (2.1 + 0.35 * pulse),
          Paint()
            ..shader = RadialGradient(
              colors: [C.orange.withValues(alpha: 0.42), C.orange.withValues(alpha: 0.12), C.orange.withValues(alpha: 0)],
              stops: const [0, 0.45, 1],
            ).createShader(Rect.fromCircle(center: p, radius: r * 2.5)),
        );
        canvas.drawCircle(
          p,
          r,
          Paint()
            ..shader = const RadialGradient(
              colors: [Color(0xFFFFF4D6), Color(0xFFFFB347), Color(0x00FF8A1F)],
              stops: [0, 0.4, 1],
            ).createShader(Rect.fromCircle(center: p, radius: r)),
        );
        // Expanding ring.
        final ring = (time * 0.7 + i * 0.33) % 1;
        canvas.drawCircle(
          p,
          r * (0.8 + ring * 1.8),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = const Color(0xFFFFB347).withValues(alpha: 0.55 * (1 - ring) * s.clamp(0, 1)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(FigurePainter old) => true;
}
