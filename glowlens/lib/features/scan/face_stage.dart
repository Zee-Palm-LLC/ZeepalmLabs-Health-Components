import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/motion.dart';
import '../../data/catalog.dart';

class MeshState {
  MeshState({
    required this.intro,
    required this.scan,
    required this.zones,
    required this.clock,
    required this.ripple,
    required this.tilt,
  });

  final Animation<double> intro;
  final Animation<double> scan;
  final Animation<double> zones;
  final ValueNotifier<double> clock;
  final ValueNotifier<(Offset, double)?> ripple;
  final ValueNotifier<Offset> tilt;

  Listenable get all => Listenable.merge([intro, scan, zones, clock, ripple, tilt]);
}

class FaceMeshPainter extends CustomPainter {
  FaceMeshPainter(this.state, {this.scanning = false}) : super(repaint: state.all);

  final MeshState state;
  final bool scanning;

  static final List<double> _delays = () {
    var far = 0.0;
    for (final p in meshPoints) {
      far = math.max(far, (p - meshCentre).distance);
    }
    return [for (final p in meshPoints) (p - meshCentre).distance / far];
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final t = state.intro.value;
    final s = state.clock.value;
    final scan = state.scan.value;
    final zones = state.zones.value;
    final tilt = state.tilt.value;

    Offset place(int i) {
      final n = meshPoints[i];
      final depth = 1 - ((n - meshCentre).distance * 2.2).clamp(0.0, 1.0);
      var p = Offset(n.dx * size.width, n.dy * size.height) + Offset(tilt.dx * 10 * depth, tilt.dy * 8 * depth);
      final ripple = state.ripple.value;
      if (ripple != null) {
        final (origin, age) = ripple;
        final d = p - origin;
        final dist = d.distance;
        if (dist > 0.1) {
          final front = age * 520;
          final wave = math.exp(-math.pow((dist - front) / 38, 2)) * (1 - age).clamp(0.0, 1.0);
          p += d / dist * wave * 9;
        }
      }
      return p;
    }

    double appear(int i) {
      final start = 0.08 + _delays[i] * 0.55;
      return Curves.elasticOut.transform(window(t, start, start + 0.3));
    }

    final beamY = _beamY(scan, size);

    _brackets(canvas, size, t, s, scan);

    final edgePaint = Paint()
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    for (final (a, b) in meshEdges) {
      final start = 0.08 + math.max(_delays[a], _delays[b]) * 0.55 + 0.06;
      final grow = window(t, start, start + 0.22, Curves.easeOutCubic);
      if (grow <= 0) continue;
      final first = _delays[a] <= _delays[b] ? a : b;
      final second = first == a ? b : a;
      final pa = place(first);
      final pb = place(second);
      final end = Offset.lerp(pa, pb, grow)!;
      var alpha = 0.62 + 0.12 * math.sin(s * 1.6 + a * 0.7);
      var color = const Color(0xFFFFF1E6);
      if (scanning && beamY != null) {
        final mid = (pa.dy + pb.dy) / 2;
        final near = math.exp(-math.pow((mid - beamY) / 26, 2));
        color = Color.lerp(color, const Color(0xFFF7A8C4), near)!;
        alpha = math.min(1, alpha + near * 0.4);
      }
      edgePaint.color = color.withValues(alpha: alpha);
      canvas.drawLine(pa, end, edgePaint);
    }

    if (t >= 1 && !scanning) _comets(canvas, s, place);

    for (var i = 0; i < meshPoints.length; i++) {
      final pop = appear(i);
      if (pop <= 0) continue;
      final p = place(i);
      var radius = 2.5 * pop * (1 + 0.18 * math.sin(s * 2.4 + i * 1.3));
      var glow = 0.35;
      var color = Colors.white;
      if (scanning && beamY != null) {
        final near = math.exp(-math.pow((p.dy - beamY) / 18, 2));
        radius += near * 2.2;
        glow += near * 0.6;
        color = Color.lerp(Colors.white, const Color(0xFFFFD6E6), near)!;
      }
      canvas.drawCircle(
        p,
        radius * 2.6,
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: glow * 0.35 * pop.clamp(0.0, 1.0))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(p, radius, Paint()..color = color);
    }

    if (scanning && beamY != null) _beam(canvas, size, beamY, scan);
    if (zones > 0) _zones(canvas, size, zones, s);
  }

  double? _beamY(double scan, Size size) {
    if (scan <= 0 || scan >= 1) return null;
    final top = faceBounds.top * size.height - 16;
    final bottom = faceBounds.bottom * size.height + 16;
    final phase = scan < 0.55 ? scan / 0.55 : 1 - (scan - 0.55) / 0.45;
    return lerp(top, bottom, Curves.easeInOutSine.transform(phase));
  }

  void _beam(Canvas canvas, Size size, double y, double scan) {
    final left = faceBounds.left * size.width - 30;
    final right = faceBounds.right * size.width + 30;
    final band = Rect.fromLTRB(left, y - 70, right, y + 6);
    final goingDown = scan < 0.55;
    canvas.drawRect(
      goingDown ? band : Rect.fromLTRB(left, y - 6, right, y + 70),
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, goingDown ? band.top : y + 70), Offset(0, y), [
          const Color(0x00C274EB),
          const Color(0x40E47EC6),
        ]),
    );
    final line = Paint()
      ..shader = ui.Gradient.linear(
        Offset(left, y),
        Offset(right, y),
        const [Color(0x00FFFFFF), Color(0xFFF7A8C4), Color(0xFFFFFFFF), Color(0xFFD69BF3), Color(0x00FFFFFF)],
        const [0, 0.2, 0.5, 0.8, 1],
      )
      ..strokeWidth = 2.2;
    canvas.drawLine(
      Offset(left, y),
      Offset(right, y),
      Paint()
        ..color = const Color(0xAAF3A2D0)
        ..strokeWidth = 10
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawLine(Offset(left, y), Offset(right, y), line);
  }

  void _brackets(Canvas canvas, Size size, double t, double s, double scan) {
    final show = window(t, 0, 0.3, Curves.easeOutCubic);
    if (show <= 0) return;
    final breathe = 3 * math.sin(s * 1.6);
    final squeeze = scan > 0 && scan < 1 ? 10 * math.sin(scan * math.pi) : 0.0;
    final box = Rect.fromLTRB(
      faceBounds.left * size.width - 18,
      faceBounds.top * size.height + 10,
      faceBounds.right * size.width + 18,
      faceBounds.bottom * size.height + 18,
    ).inflate(breathe - squeeze + (1 - show) * 30);
    final arm = 34.0 * show;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95 * show)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final (corner, dx, dy) in [
      (box.topLeft, 1.0, 1.0),
      (box.topRight, -1.0, 1.0),
      (box.bottomLeft, 1.0, -1.0),
      (box.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx, corner.dy + arm * dy)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx + arm * dx, corner.dy),
        paint,
      );
    }
  }

  void _comets(Canvas canvas, double s, Offset Function(int) place) {
    for (var k = 0; k < 7; k++) {
      final cycle = s * 0.55 + k * 0.37;
      final index = (cycle.floor() * 7919 + k * 104729) % meshEdges.length;
      final (a, b) = meshEdges[index];
      final f = cycle - cycle.floor();
      final pa = place(a);
      final pb = place(b);
      final head = Offset.lerp(pa, pb, Curves.easeInOut.transform(f))!;
      final tail = Offset.lerp(pa, pb, Curves.easeInOut.transform(math.max(0, f - 0.25)))!;
      final fade = math.sin(f * math.pi);
      canvas.drawLine(
        tail,
        head,
        Paint()
          ..shader = ui.Gradient.linear(tail, head, [
            const Color(0x00F7A8C4),
            const Color(0xFFF7A8C4).withValues(alpha: fade),
          ])
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        head,
        3.4,
        Paint()
          ..color = const Color(0xFFFFE1EE).withValues(alpha: fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }
  }

  void _zones(Canvas canvas, Size size, double zones, double s) {
    for (var i = 0; i < 3; i++) {
      final area = Analysis.areas[i];
      final show = Curves.easeOutBack.transform(window(zones, i * 0.18, 0.5 + i * 0.18));
      if (show <= 0) continue;
      final centres = i == 2 ? [area.focus, Offset(meshCentre.dx * 2 - area.focus.dx, area.focus.dy)] : [area.focus];
      for (final focus in centres) {
        final c = Offset(focus.dx * size.width, focus.dy * size.height);
        final r = area.radius * size.width * show * (1 + 0.05 * math.sin(s * 3 + i));
        canvas.drawOval(
          Rect.fromCenter(center: c, width: r * 2.2, height: r * (i == 0 ? 0.9 : 1.6)),
          Paint()
            ..shader = ui.Gradient.radial(
              c,
              r * 1.1,
              [
                const Color(0xFFE77FC5).withValues(alpha: 0.42),
                const Color(0xFFC274EB).withValues(alpha: 0.14),
                const Color(0x00C274EB),
              ],
              const [0, 0.55, 1],
            ),
        );
        final ring = Rect.fromCenter(center: c, width: r * 2.2, height: r * (i == 0 ? 0.9 : 1.6));
        final dash = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.white.withValues(alpha: 0.9 * show.clamp(0.0, 1.0));
        const segments = 18;
        for (var k = 0; k < segments; k++) {
          final a0 = k * math.pi * 2 / segments + s * 0.6;
          canvas.drawArc(ring, a0, math.pi / segments, false, dash);
        }
      }
    }
  }

  @override
  bool shouldRepaint(FaceMeshPainter oldDelegate) => oldDelegate.scanning != scanning;
}
