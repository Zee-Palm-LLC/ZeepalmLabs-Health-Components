import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'motion.dart';
import 'palette.dart';

class EmberBackdrop extends StatelessWidget {
  const EmberBackdrop({
    super.key,
    required this.seconds,
    this.intensity = 1.0,
    this.tint = Ember.gold,
    this.focus = 0.0,
  });

  final double seconds;
  final double intensity;
  final Color tint;
  final double focus;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _EmberPainter(seconds: seconds, intensity: intensity, tint: tint, focus: focus),
        isComplex: true,
        willChange: true,
      ),
    );
  }
}

class _Blob {
  const _Blob(
    this.ox,
    this.oy,
    this.rx,
    this.ry,
    this.radius,
    this.period,
    this.phase,
    this.color,
    this.alpha,
  );

  final double ox;
  final double oy;
  final double rx;
  final double ry;
  final double radius;
  final double period;
  final double phase;
  final Color color;
  final double alpha;
}

const _blobs = [
  _Blob(0.20, 0.44, 0.08, 0.06, 0.74, 21, 0.0, Color(0xFFE8801A), 0.26),
  _Blob(0.50, 0.32, 0.12, 0.09, 0.52, 27, 0.35, Color(0xFFD9620F), 0.18),
  _Blob(0.12, 0.70, 0.06, 0.10, 0.48, 18, 0.62, Color(0xFFE99A2E), 0.14),
  _Blob(0.80, 0.60, 0.10, 0.08, 0.40, 33, 0.18, Color(0xFF7A1D06), 0.30),
];

final _grain = _buildGrain();

Float32List _buildGrain() {
  final rand = math.Random(20260923);
  final pts = Float32List(2400 * 2);
  for (var i = 0; i < 2400; i++) {
    pts[i * 2] = rand.nextDouble();
    pts[i * 2 + 1] = rand.nextDouble();
  }
  return pts;
}

class _EmberPainter extends CustomPainter {
  _EmberPainter({required this.seconds, required this.intensity, required this.tint, required this.focus});

  final double seconds;
  final double intensity;
  final Color tint;
  final double focus;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = Ember.void_);

    final pulse = 1 + 0.035 * wave(seconds, 9.5) + 0.02 * wave(seconds, 4.1, 0.3);
    final drift = Offset(wave(seconds, 23, 0.1) * 0.018, wave(seconds, 31, 0.6) * 0.022);
    final centre = Offset((0.205 + drift.dx) * size.width, (0.500 + drift.dy) * size.height);
    final rx = 0.94 * size.width * pulse * (1 + 0.10 * intensity - 0.10);
    final ry = 0.80 * size.height * pulse * (1 + 0.10 * intensity - 0.10);

    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.scale(1, ry / rx);
    canvas.translate(-centre.dx, -centre.dy);
    canvas.drawCircle(
      centre,
      rx * 1.6,
      Paint()
        ..shader = ui.Gradient.radial(
          centre,
          rx,
          const [
            Color(0xFFD88A22),
            Color(0xFFCC8020),
            Color(0xFFBE651A),
            Color(0xFFA85115),
            Color(0xFF8F3A10),
            Color(0xFF7E280C),
            Color(0xFF501508),
            Color(0xFF190703),
          ],
          const [0.0, 0.18, 0.32, 0.46, 0.62, 0.80, 0.92, 1.0],
        ),
    );
    canvas.restore();

    for (final b in _blobs) {
      final t = seconds / b.period + b.phase;
      final at = Offset(
        (b.ox + math.cos(t * math.pi * 2) * b.rx) * size.width,
        (b.oy + math.sin(t * math.pi * 2 * 0.73) * b.ry) * size.height,
      );
      final r = b.radius * size.width * (1 + 0.12 * math.sin(t * math.pi * 2 * 1.31));
      canvas.drawCircle(
        at,
        r,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = ui.Gradient.radial(
            at,
            r,
            [
              b.color.withValues(alpha: b.alpha * intensity * 0.5),
              b.color.withValues(alpha: b.alpha * intensity * 0.16),
              const Color(0x00000000),
            ],
            const [0.0, 0.45, 1.0],
          ),
      );
    }

    if (focus > 0.004) {
      final at = Offset(size.width * 0.5, size.height * 0.42);
      canvas.drawCircle(
        at,
        size.width * (0.35 + 0.95 * focus),
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = ui.Gradient.radial(
            at,
            size.width * (0.35 + 0.95 * focus),
            [
              tint.withValues(alpha: 0.42 * focus),
              tint.withValues(alpha: 0.10 * focus),
              const Color(0x00000000),
            ],
            const [0.0, 0.5, 1.0],
          ),
      );
    }

    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height * 0.34),
          const [Color(0xB4050201), Color(0x8C050201), Color(0x00050201)],
          const [0.0, 0.38, 1.0],
        ),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, size.height * 0.72),
          Offset(0, size.height),
          const [Color(0x00090301), Color(0x30090301), Color(0x8A090301)],
          const [0.0, 0.55, 1.0],
        ),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(size.width * 0.62, 0),
          Offset(size.width, 0),
          const [Color(0x00080301), Color(0x3D080301)],
          const [0.0, 1.0],
        ),
    );

    final pts = Float32List(_grain.length);
    for (var i = 0; i < _grain.length; i += 2) {
      pts[i] = _grain[i] * size.width;
      pts[i + 1] = _grain[i + 1] * size.height;
    }
    canvas.drawRawPoints(
      ui.PointMode.points,
      pts,
      Paint()
        ..color = const Color(0x0CFFFFFF)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_EmberPainter old) =>
      old.seconds != seconds || old.intensity != intensity || old.focus != focus || old.tint != tint;
}
