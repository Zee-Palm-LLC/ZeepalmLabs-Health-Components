import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../core/art.dart';

class PlanetSpin extends StatefulWidget {
  const PlanetSpin({super.key, this.onSpin});

  static const center = Offset(209.4, 485.6);
  static const radius = 188.0;

  final ValueChanged<double>? onSpin;

  @override
  State<PlanetSpin> createState() => PlanetSpinState();
}

class PlanetSpinState extends State<PlanetSpin> with SingleTickerProviderStateMixin {
  static ui.FragmentProgram? _program;
  static ui.Image? _texture;

  late final Ticker _ticker;
  double _yaw = 0;
  double _pitch = 0;
  double _vYaw = 0;
  double _vPitch = 0;
  bool _dragging = false;
  Duration _last = Duration.zero;

  double get motion => (_yaw.abs() + _pitch.abs()).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _load();
  }

  Future<void> _load() async {
    _program ??= await ui.FragmentProgram.fromAsset('shaders/planet.frag');
    if (_texture == null) {
      final data = await rootBundle.load('assets/art/planet_tex.webp');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      _texture = (await codec.getNextFrame()).image;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void nudge(double impulse) {
    _vYaw += impulse;
    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void _tick(Duration now) {
    final dt = _last == Duration.zero ? 1 / 60 : ((now - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 20);
    _last = now;
    if (!_dragging) {
      const twoPi = math.pi * 2;
      final target = (_yaw / twoPi).roundToDouble() * twoPi;
      final speed = _vYaw.abs();
      final pull = speed > 2.2 ? 0.0 : 18.0;
      _vYaw += ((target - _yaw) * pull - _vYaw * (speed > 2.2 ? 0.9 : 6.5)) * dt;
      _vPitch += (-_pitch * 40 - _vPitch * 9) * dt;
      _yaw += _vYaw * dt;
      _pitch += _vPitch * dt;
      if ((target - _yaw).abs() < 0.0005 && _vYaw.abs() < 0.002 && _pitch.abs() < 0.0005 && _vPitch.abs() < 0.002) {
        _yaw = 0;
        _pitch = 0;
        _vYaw = 0;
        _vPitch = 0;
        _ticker.stop();
      }
    }
    widget.onSpin?.call(motion);
    setState(() {});
  }

  void _start(DragStartDetails d) {
    _dragging = true;
    HapticFeedback.selectionClick();
    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void _update(DragUpdateDetails d) {
    const r = PlanetSpin.radius;
    _yaw += d.delta.dx / r;
    _pitch = (_pitch + d.delta.dy / r).clamp(-0.45, 0.45);
  }

  void _end(DragEndDetails d) {
    _dragging = false;
    _vYaw = d.velocity.pixelsPerSecond.dx / PlanetSpin.radius;
    _vPitch = d.velocity.pixelsPerSecond.dy / PlanetSpin.radius * 0.3;
  }

  @override
  Widget build(BuildContext context) {
    const c = PlanetSpin.center;
    const r = PlanetSpin.radius;
    final rest = 1 - Curves.easeOut.transform((motion / 0.12).clamp(0.0, 1.0));
    final ready = _program != null && _texture != null;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (ready && rest < 1)
          Positioned(
            left: c.dx - r,
            top: c.dy - r,
            width: r * 2,
            height: r * 2,
            child: IgnorePointer(
              child: CustomPaint(painter: _SpherePainter(_program!, _texture!, _yaw, _pitch)),
            ),
          ),
        Place(
          Art.planet,
          child: IgnorePointer(child: Opacity(opacity: rest, child: Art.planet.image())),
        ),
        Positioned(
          left: c.dx - r,
          top: c.dy - r,
          width: r * 2,
          height: r * 2,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: _start,
            onPanUpdate: _update,
            onPanEnd: _end,
          ),
        ),
      ],
    );
  }
}

class _SpherePainter extends CustomPainter {
  _SpherePainter(this.program, this.texture, this.yaw, this.pitch);

  final ui.FragmentProgram program;
  final ui.Image texture;
  final double yaw;
  final double pitch;

  @override
  void paint(Canvas canvas, Size size) {
    final s = program.fragmentShader()
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, yaw)
      ..setFloat(3, pitch)
      ..setFloat(4, 1)
      ..setImageSampler(0, texture);
    canvas.drawRect(Offset.zero & size, Paint()..shader = s);
  }

  @override
  bool shouldRepaint(_SpherePainter old) => old.yaw != yaw || old.pitch != pitch;
}
