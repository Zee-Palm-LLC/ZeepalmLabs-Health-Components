import 'dart:math' as math;
import 'dart:ui';

import 'figure.dart';
import 'renderer.dart';
import 'vec.dart';

/// Paints eyes, brows, nose shadow and lips onto the head by projecting
/// points on the face surface, so they turn, foreshorten and hide with the
/// mesh (vertex colours are too coarse for features this small).
void drawFace(Canvas canvas, BodyView v, Pose p, {bool male = false, Color hair = const Color(0xFF2E2420)}) {
  final hc = p.headC, hu = p.headUp.norm, hf = p.headFront.norm;
  final hl = hu.cross(hf).norm;
  final px = (v.project(hc + hu).$1 - v.project(hc).$1).distance; // px per cm

  double vis(V3 n) {
    final f = v.project(hc, n).$2;
    return ((f - 0.05) / 0.3).clamp(0.0, 1.0);
  }

  V3 at(double u, double lat, double depth) => hc + hu * u + hl * lat + hf * depth;

  Path curve(List<V3> pts) {
    final o = pts.map((q) => v.project(q).$1).toList();
    final path = Path()..moveTo(o[0].dx, o[0].dy);
    if (o.length == 3) {
      // pass through the middle point
      final c = o[1] * 2 - (o[0] + o[2]) / 2;
      path.quadraticBezierTo(c.dx, c.dy, o[2].dx, o[2].dy);
    } else {
      for (final q in o.skip(1)) {
        path.lineTo(q.dx, q.dy);
      }
    }
    return path;
  }

  for (final s in [-1.0, 1.0]) {
    final a = vis((hf * 0.8 + hl * (0.6 * s)).norm);
    if (a <= 0) continue;
    // Eye: almond shape around a projected ellipse.
    final c = at(0.9, 2.85 * s, 8.45);
    final pts = <Offset>[];
    for (var i = 0; i < 12; i++) {
      final t = i / 12 * math.pi * 2;
      final q = c + hl * (0.68 * math.cos(t)) + hu * (0.4 * math.sin(t) * (math.sin(t) > 0 ? 1.0 : 0.75)) + hf * (-0.25 * math.cos(t).abs());
      pts.add(v.project(q).$1);
    }
    canvas.drawPath(Path()..addPolygon(pts, true), Paint()..color = const Color(0xFF2E2320).withValues(alpha: 0.92 * a));
    // catch-light
    canvas.drawCircle(v.project(c + hu * 0.12 + hl * (-0.18 * s)).$1, math.max(0.6, px * 0.13),
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.7 * a));
    // Brow.
    canvas.drawPath(
      curve([at(2.55, 1.4 * s, 8.95), at(2.95, 2.9 * s, 8.5), at(2.6, 4.3 * s, 7.4)]),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = px * (male ? 0.55 : 0.4)
        ..color = Color.lerp(hair, const Color(0xFF6B5446), 0.25)!.withValues(alpha: 0.85 * a),
    );
  }

  final front = vis(hf);
  if (front <= 0) return;
  // Nose: soft shadow under the tip + a side contour.
  canvas.drawPath(
    curve([at(-3.8, -1.05, 9.0), at(-4.05, 0, 9.5), at(-3.8, 1.05, 9.0)]),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = px * 0.3
      ..color = const Color(0xFF9C5F4A).withValues(alpha: 0.3 * front),
  );
  // Lips with a slight smile.
  final lip = male ? const Color(0xFF9A5E50) : const Color(0xFFC0786C);
  canvas.drawPath(
    curve([at(-5.35, -1.9, 8.6), at(-5.75, 0, 9.0), at(-5.35, 1.9, 8.6)]),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = px * (male ? 0.38 : 0.55)
      ..color = lip.withValues(alpha: 0.9 * front),
  );
}
