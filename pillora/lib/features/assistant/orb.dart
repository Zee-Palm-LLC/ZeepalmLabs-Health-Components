import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../core/shaders.dart';

class OrbPainter extends CustomPainter {
  OrbPainter({required this.clock, required this.energy, required this.pulse, required this.tilt, this.radius = 0.257})
    : super(repaint: Listenable.merge([clock, energy, pulse, tilt]));

  final ValueListenable<double> clock;
  final ValueListenable<double> energy;
  final ValueListenable<double> pulse;
  final ValueListenable<Offset> tilt;
  final double radius;

  ui.FragmentShader? _shader;

  @override
  void paint(Canvas canvas, Size size) {
    final program = Shaders.orb;
    if (program == null) {
      _fallback(canvas, size);
      return;
    }
    final shader = _shader ??= program.fragmentShader();
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, clock.value)
      ..setFloat(3, energy.value)
      ..setFloat(4, radius)
      ..setFloat(5, tilt.value.dx)
      ..setFloat(6, tilt.value.dy)
      ..setFloat(7, pulse.value);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  void _fallback(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final r = size.shortestSide * radius;
    canvas.drawCircle(
      centre,
      r * 1.9,
      Paint()..shader = ui.Gradient.radial(centre, r * 1.9, const [Color(0x88A8E3D6), Color(0x00A8E3D6)]),
    );
    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          centre,
          r,
          const [Color(0xFFA9E2D6), Color(0xFF6FA79E), Color(0xFF5E8F88)],
          const [0, 0.75, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(OrbPainter oldDelegate) => oldDelegate.radius != radius;
}
