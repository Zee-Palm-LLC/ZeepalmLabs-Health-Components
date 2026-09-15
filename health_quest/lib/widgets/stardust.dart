import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../core/palette.dart';
import '../core/shaders.dart';

/// The atmosphere over the hero art: motes, light shafts, nebula shimmer, and
/// the ring that sweeps out when the call to action is charged.
///
/// Drawn additively over the plate so it only ever adds light. If the shader
/// did not compile, a painted mote field stands in.
class Stardust extends StatefulWidget {
  const Stardust({
    super.key,
    this.parallax = Offset.zero,
    this.intensity = 1,
    this.surge = 0,
  });

  final Offset parallax;
  final double intensity;
  final double surge;

  @override
  State<Stardust> createState() => _StardustState();
}

class _StardustState extends State<Stardust>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  ui.FragmentShader? _shader;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _shader = Shaders.stardust();
    _ticker = createTicker((Duration elapsed) {
      setState(() => _time = elapsed.inMicroseconds / 1e6);
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;
    return RepaintBoundary(
      child: CustomPaint(
        painter: shader == null
            ? _PaintedDust(
                time: _time,
                parallax: widget.parallax,
                intensity: widget.intensity,
              )
            : _ShaderDust(
                shader: shader,
                time: _time,
                parallax: widget.parallax,
                intensity: widget.intensity,
                surge: widget.surge,
              ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ShaderDust extends CustomPainter {
  _ShaderDust({
    required this.shader,
    required this.time,
    required this.parallax,
    required this.intensity,
    required this.surge,
  });

  final ui.FragmentShader shader;
  final double time;
  final Offset parallax;
  final double intensity;
  final double surge;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, parallax.dx)
      ..setFloat(4, parallax.dy)
      ..setFloat(5, intensity.clamp(0.0, 1.0))
      ..setFloat(6, surge.clamp(0.0, 1.0));
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..blendMode = BlendMode.plus,
    );
  }

  @override
  bool shouldRepaint(_ShaderDust old) => true;
}

/// Fallback: a handful of drifting motes, no shafts, no shimmer.
class _PaintedDust extends CustomPainter {
  _PaintedDust({
    required this.time,
    required this.parallax,
    required this.intensity,
  });

  final double time;
  final Offset parallax;
  final double intensity;

  static final List<_Mote> _motes = List<_Mote>.generate(46, (int i) {
    final r = math.Random(i * 7919);
    return _Mote(
      x: r.nextDouble(),
      y: r.nextDouble(),
      radius: 0.6 + r.nextDouble() * 1.7,
      speed: 0.004 + r.nextDouble() * 0.012,
      phase: r.nextDouble() * math.pi * 2,
      depth: 0.3 + r.nextDouble() * 0.7,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    for (final m in _motes) {
      final y = (m.y - time * m.speed) % 1.0;
      final twinkle = 0.45 + 0.55 * math.sin(time * 1.6 + m.phase).abs();
      final c = Color.lerp(Spectrum.violet, Spectrum.cyan, m.depth)!;
      canvas.drawCircle(
        Offset(
          m.x * size.width + parallax.dx * 14 * m.depth,
          y * size.height + parallax.dy * 14 * m.depth,
        ),
        m.radius * (0.8 + 0.4 * twinkle),
        Paint()
          ..color = c.withValues(alpha: 0.55 * twinkle * intensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
      );
    }
  }

  @override
  bool shouldRepaint(_PaintedDust old) => true;
}

class _Mote {
  const _Mote({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.depth,
  });

  final double x;
  final double y;
  final double radius;
  final double speed;
  final double phase;
  final double depth;
}
