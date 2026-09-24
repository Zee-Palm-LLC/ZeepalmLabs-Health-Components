import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../data/route_path.dart';
import 'route_geometry.dart';
import '../../core/phosphor.dart';

class RouteLayer extends CustomPainter {
  RouteLayer({required this.draw, required this.journey, required this.seconds, required this.zoom});

  final double draw;
  final double journey;
  final double seconds;
  final double zoom;

  static const _dotGap = 23.0;

  @override
  void paint(Canvas canvas, Size size) {
    final g = RouteGeometry.instance;
    if (draw <= 0) return;
    final w = 1 / zoom.clamp(1.0, 3.0);
    final north = g.northPart(draw);
    final south = g.southPart(draw);
    final shadow = Paint()
      ..color = const Color(0x40082046)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9 * w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2.4 * w);
    final casing = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.6 * w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final core = Paint()
      ..color = Palette.route
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.6 * w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final part in [north, south]) {
      canvas.drawPath(part.shift(Offset(0, 1.2 * w)), shadow);
    }
    for (final part in [north, south]) {
      canvas.drawPath(part, casing);
    }
    for (final part in [north, south]) {
      canvas.drawPath(part, core);
    }

    final dot = Paint()..color = Colors.white;
    void dots(double length, Offset Function(double) at) {
      final head = length * draw;
      for (var d = _dotGap * 0.62; d < length - 8; d += _dotGap) {
        final behind = (head - d) / 26;
        if (behind <= 0) break;
        final s = spring(behind.clamp(0.0, 1.0), bounce: 0.6, freq: 2.8);
        canvas.drawCircle(at(d), 1.75 * s * w, dot);
      }
    }

    dots(g.northLength, g.northAt);
    dots(g.southLength, g.southAt);

    if (journey > 0) {
      final done = g.loopPart(journey);
      canvas.drawPath(
        done,
        Paint()
          ..color = const Color(0xFF00C28C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.6 * w
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      final tangent = g.loopAt(journey);
      final p = tangent.position;
      final ring = (seconds % 1.4) / 1.4;
      canvas.drawCircle(p, (9 + 14 * ring) * w, Paint()..color = const Color(0xFF00C28C).withValues(alpha: 0.35 * (1 - ring)));
      canvas.drawCircle(
        p,
        8.2 * w,
        Paint()
          ..color = const Color(0x55000000)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * w),
      );
      canvas.drawCircle(p, 7.4 * w, Paint()..color = Colors.white);
      canvas.drawCircle(p, 5 * w, Paint()..color = const Color(0xFF00B486));
      final dir = tangent.vector;
      final nose = p + Offset(dir.dx, dir.dy) * 2.2 * w;
      canvas.drawCircle(nose, 1.6 * w, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(RouteLayer old) =>
      old.draw != draw || old.journey != journey || old.seconds != seconds || old.zoom != zoom;
}

Path pinPath(Offset center, double radius, double tipY) {
  final d = tipY - center.dy;
  final phi = math.acos((radius / d).clamp(-1.0, 1.0));
  final start = math.pi / 2 + phi;
  final sweep = 2 * math.pi - 2 * phi;
  final tip = Offset(center.dx, tipY);
  final bend = Offset(center.dx, tipY - (d - radius) * 0.18);
  final right = center + Offset(math.cos(math.pi / 2 - phi), math.sin(math.pi / 2 - phi)) * radius;
  return Path()
    ..moveTo(tip.dx, tip.dy)
    ..quadraticBezierTo(bend.dx - radius * 0.08, bend.dy, center.dx + math.cos(start) * radius, center.dy + math.sin(start) * radius)
    ..arcTo(Rect.fromCircle(center: center, radius: radius), start, sweep, false)
    ..lineTo(right.dx, right.dy)
    ..quadraticBezierTo(bend.dx + radius * 0.08, bend.dy, tip.dx, tip.dy)
    ..close();
}

class StartPinPainter extends CustomPainter {
  StartPinPainter({required this.pop});

  final double pop;

  static const center = Offset(112.9, 100.85);

  @override
  void paint(Canvas canvas, Size size) {
    if (pop <= 0) return;
    canvas.save();
    canvas.translate(RoutePath.start.dx, 123.6);
    canvas.scale(pop, pop);
    canvas.translate(-RoutePath.start.dx, -123.6);
    final outline = pinPath(center, 15.95, 123.6);
    canvas.drawShadow(outline, const Color(0xFF02281E), 3, false);
    canvas.drawPath(outline, Paint()..color = Colors.white);
    final body = pinPath(center, 14.3, 121.4);
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF13AE7B), Color(0xFF079A69)],
        ).createShader(Rect.fromCircle(center: center, radius: 16)),
    );
    paintIcon(canvas, PhosphorFill.personSimpleWalk, center, 17, Colors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(StartPinPainter old) => old.pop != pop;
}

class FinishPinPainter extends CustomPainter {
  FinishPinPainter({required this.drop, required this.ripple});

  final double drop;
  final double ripple;

  static const center = Offset(308.75, 244.4);

  @override
  void paint(Canvas canvas, Size size) {
    final tip = RoutePath.finish;
    if (ripple > 0 && ripple < 1) {
      final r = Curves.easeOut.transform(ripple);
      canvas.drawOval(
        Rect.fromCenter(center: tip, width: 12 + 60 * r, height: 5 + 22 * r),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * (1 - r) + 0.5
          ..color = Palette.cobalt.withValues(alpha: 0.7 * (1 - r)),
      );
    }
    if (drop <= 0) return;
    final land = span(drop, 0.0, 0.55, gravity);
    final settle = span(drop, 0.55, 1.0, Curves.linear);
    final squash = settle == 0 ? 0.0 : math.sin(settle * math.pi * 2.2) * math.exp(-4 * settle);
    canvas.drawCircle(tip, 6.4 * span(drop, 0.5, 0.7, Curves.easeOut), Paint()..color = Colors.white);
    canvas.drawCircle(tip, 6.4 * span(drop, 0.5, 0.7, Curves.easeOut), Paint()
      ..color = const Color(0x22000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6);
    canvas.save();
    canvas.translate(0, lerp(-140, 0, land));
    canvas.translate(tip.dx, 268.5);
    canvas.scale(1 + squash * 0.14, 1 - squash * 0.18);
    canvas.translate(-tip.dx, -268.5);
    final body = pinPath(center, 18, 268.5);
    canvas.drawShadow(body, const Color(0xFF021A44), 3, false);
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E7BFA), Color(0xFF0762E8)],
        ).createShader(Rect.fromCircle(center: center, radius: 18)),
    );
    paintIcon(canvas, PhosphorFill.flagCheckered, center, 19, Colors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(FinishPinPainter old) => old.drop != drop || old.ripple != ripple;
}

void paintIcon(Canvas canvas, IconData icon, Offset center, double size, Color color) {
  final painter = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(fontFamily: icon.fontFamily, package: icon.fontPackage, fontSize: size, height: 1, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
}
