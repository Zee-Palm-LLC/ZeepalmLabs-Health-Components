import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

abstract final class OrbShader {
  static ui.FragmentProgram? program;
  static final Stopwatch clock = Stopwatch()..start();

  static double get now => clock.elapsedMicroseconds / 1e6;

  static Future<void> load() async {
    try {
      program = await ui.FragmentProgram.fromAsset('shaders/orb.frag');
    } catch (_) {
      program = null;
    }
  }
}

class Orb extends StatefulWidget {
  const Orb({super.key, required this.size, this.level, this.live = true, this.seed = 0, this.time});

  final double size;
  final ValueListenable<double>? level;
  final bool live;
  final double seed;
  final double? time;

  @override
  State<Orb> createState() => _OrbState();
}

class _OrbState extends State<Orb> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final ValueNotifier<double> _clock;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _clock = ValueNotifier(widget.time ?? OrbShader.now);
    _shader = OrbShader.program?.fragmentShader();
    _ticker = createTicker(_tick);
    if (widget.live) _ticker.start();
  }

  void _tick(Duration elapsed) {
    _clock.value = widget.time ?? OrbShader.now;
  }

  @override
  void didUpdateWidget(Orb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.live && !_ticker.isActive) _ticker.start();
    if (!widget.live && _ticker.isActive) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repaint = widget.level == null ? _clock : Listenable.merge([_clock, widget.level]);
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _OrbPainter(
          shader: _shader,
          clock: _clock,
          level: widget.level,
          seed: widget.seed,
          repaint: repaint,
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({required this.shader, required this.clock, required this.level, required this.seed, required Listenable repaint})
    : super(repaint: repaint);

  final ui.FragmentShader? shader;
  final ValueListenable<double> clock;
  final ValueListenable<double>? level;
  final double seed;

  @override
  void paint(Canvas canvas, Size size) {
    final energy = level?.value ?? 0;
    final shader = this.shader;
    if (shader == null) {
      _fallback(canvas, size, energy);
      return;
    }
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, clock.value)
      ..setFloat(3, energy)
      ..setFloat(4, seed);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  void _fallback(Canvas canvas, Size size, double energy) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final t = clock.value;
    final spot = c + Offset(math.cos(t * 0.7) * r * 0.22 - r * 0.2, math.sin(t * 0.9) * r * 0.18 - r * 0.25);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          spot,
          r * 1.5,
          const [Color(0xFFFCEBB8), Color(0xFFF49A34), Color(0xFFC8490A), Color(0xFF4A0E02)],
          const [0.0, 0.3, 0.62, 1.0],
        ),
    );
    canvas.drawCircle(
      c,
      r - 0.6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = ui.Gradient.linear(
          c - Offset(r, r),
          c + Offset(r, r),
          const [Color(0x00FF8A2A), Color(0xCCFF8A2A)],
        ),
    );
  }

  @override
  bool shouldRepaint(_OrbPainter oldDelegate) => oldDelegate.shader != shader || oldDelegate.seed != seed;
}
