import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../sound/sounds.dart';
import 'clock.dart';

const orbHalo = 1.42;

class Orb extends StatefulWidget {
  const Orb({
    super.key,
    required this.sound,
    required this.diameter,
    this.glow = 1,
    this.life = 1,
    this.seed,
  });

  final Sound sound;
  final double diameter;
  final double glow;
  final double life;
  final double? seed;

  @override
  State<Orb> createState() => _OrbState();
}

class _OrbState extends State<Orb> {
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _shader = Shaders.orb?.fragmentShader();
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.diameter,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: OrbPainter(
            sound: widget.sound,
            shader: _shader,
            glow: widget.glow,
            life: widget.life,
            seed: widget.seed ?? widget.sound.index * 0.137,
          ),
        ),
      ),
    );
  }
}

class OrbPainter extends CustomPainter {
  OrbPainter({
    required this.sound,
    required this.shader,
    required this.glow,
    required this.life,
    required this.seed,
  }) : super(repaint: SceneClock.instance);

  final Sound sound;
  final ui.FragmentShader? shader;
  final double glow;
  final double life;
  final double seed;

  @override
  void paint(Canvas canvas, Size size) {
    final d = size.shortestSide;
    final full = d * orbHalo;
    final m = (full - d) / 2;
    final shader = this.shader;
    if (shader == null) {
      _fallback(canvas, size);
      return;
    }
    canvas.save();
    canvas.translate((size.width - d) / 2 - m, (size.height - d) / 2 - m);
    var i = 0;
    shader
      ..setFloat(i++, full)
      ..setFloat(i++, full)
      ..setFloat(i++, SceneClock.instance.value)
      ..setFloat(i++, sound.kind.toDouble())
      ..setFloat(i++, seed)
      ..setFloat(i++, glow)
      ..setFloat(i++, life);
    for (final c in [sound.deep, sound.mid, sound.hi]) {
      shader
        ..setFloat(i++, c.r)
        ..setFloat(i++, c.g)
        ..setFloat(i++, c.b);
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, full, full), Paint()..shader = shader);
    canvas.restore();
  }

  void _fallback(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(
      c,
      r * orbHalo,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          r * orbHalo,
          [
            sound.glow.withValues(alpha: 0.45 * glow),
            sound.glow.withValues(alpha: 0),
          ],
          [r / (r * orbHalo), 1],
        ),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          c + Offset(-r * 0.3, -r * 0.3),
          r * 1.3,
          [sound.hi, sound.mid, sound.deep],
          [0, 0.45, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(OrbPainter old) =>
      old.sound != sound ||
      old.glow != glow ||
      old.life != life ||
      old.shader != shader ||
      old.seed != seed;
}
