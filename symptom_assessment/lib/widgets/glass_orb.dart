import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../core/palette.dart';
import '../core/shaders.dart';

/// The mascot: a glass orb rendered by a fragment shader, sitting in two
/// soft halo rings.
///
/// It is alive in three ways. The inner bubbles drift on their own. Dragging
/// tilts it, and the bubbles parallax by depth, then a spring carries it
/// back. Tapping squashes it against its base and it pops back up. All three
/// are uniforms; the shader does the rest at whatever resolution it is drawn.
class GlassOrb extends StatefulWidget {
  const GlassOrb({
    super.key,
    required this.size,
    this.interactive = true,
    this.halo = true,
    this.haloScale = 1,
    this.appear = 1,
    this.excited = false,
  });

  final double size;
  final bool interactive;
  final bool halo;

  /// While the mic is held the orb listens: time runs faster and it sways.
  final bool excited;

  /// Entrance progress for the halo rings; may overshoot.
  final double haloScale;

  /// Entrance progress for the orb itself; may overshoot.
  final double appear;

  @override
  State<GlassOrb> createState() => _GlassOrbState();
}

class _GlassOrbState extends State<GlassOrb>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  ui.FragmentShader? _shader;

  double _time = 0;
  Offset _tilt = Offset.zero;
  Offset _tiltVelocity = Offset.zero;
  double _squash = 0;
  double _squashVelocity = 0;
  bool _dragging = false;
  bool _pressed = false;
  Duration _last = Duration.zero;

  static const SpringDescription _tiltSpring =
      SpringDescription(mass: 1, stiffness: 120, damping: 9);
  static const SpringDescription _squashDown =
      SpringDescription(mass: 1, stiffness: 700, damping: 40);
  static const SpringDescription _squashUp =
      SpringDescription(mass: 1, stiffness: 260, damping: 11);

  @override
  void initState() {
    super.initState();
    _shader = Shaders.orb();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _shader?.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 1 / 60
        : ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 20);
    _last = elapsed;
    _time += dt * (widget.excited ? 3.2 : 1.0);

    // Integrate the two springs by hand each frame - simple semi-implicit
    // Euler is plenty for a critically-ish damped spring at 60-120 Hz, and it
    // lets a drag hand off to the spring with its live velocity.
    if (widget.excited && !_dragging) {
      // Sway: the spring chases a moving target instead of the origin.
      final target = Offset(
        math.sin(_time * 1.9) * 0.35,
        math.cos(_time * 1.3) * 0.22,
      );
      _tilt = _step2(_tilt - target, _tiltSpring, dt) + target;
    } else if (!_dragging) {
      _tilt = _step2(_tilt, _tiltSpring, dt);
    }
    final targetSquash = _pressed ? 1.0 : 0.0;
    final spring = _pressed ? _squashDown : _squashUp;
    final acc = -spring.stiffness * (_squash - targetSquash) -
        spring.damping * _squashVelocity;
    _squashVelocity += acc * dt;
    _squash += _squashVelocity * dt;

    setState(() {});
  }

  Offset _step2(Offset x, SpringDescription s, double dt) {
    final acc = Offset(
      -s.stiffness * x.dx - s.damping * _tiltVelocity.dx,
      -s.stiffness * x.dy - s.damping * _tiltVelocity.dy,
    );
    _tiltVelocity += acc * dt;
    return x + _tiltVelocity * dt;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final k = 1.6 / widget.size;
    final next = Offset(
      (_tilt.dx + d.delta.dx * k).clamp(-1.0, 1.0),
      (_tilt.dy - d.delta.dy * k).clamp(-1.0, 1.0),
    );
    _tiltVelocity = (next - _tilt) / (1 / 60);
    _tilt = next;
    _dragging = true;
  }

  void _onPanEnd(DragEndDetails d) {
    _dragging = false;
    final k = 1.6 / widget.size;
    _tiltVelocity = Offset(
      d.velocity.pixelsPerSecond.dx * k,
      -d.velocity.pixelsPerSecond.dy * k,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appear = widget.appear;
    final orb = SizedBox(
      width: widget.size,
      height: widget.size,
      child: _shader == null
          ? _FallbackOrb(size: widget.size)
          : CustomPaint(
              painter: _OrbPainter(
                shader: _shader!,
                time: _time,
                tilt: _tilt,
                squash: _squash,
                alpha: appear.clamp(0.0, 1.0),
              ),
            ),
    );

    Widget body = Transform.scale(
      scale: appear <= 0 ? 0.001 : appear,
      child: orb,
    );

    if (widget.interactive) {
      body = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          HapticFeedback.selectionClick();
          setState(() => _pressed = true);
        },
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onPanStart: (_) => setState(() => _pressed = true),
        onPanUpdate: _onPanUpdate,
        onPanEnd: (DragEndDetails d) {
          _onPanEnd(d);
          setState(() => _pressed = false);
        },
        onPanCancel: () => setState(() {
          _dragging = false;
          _pressed = false;
        }),
        child: body,
      );
    }

    if (!widget.halo) return body;

    final outer = widget.size * 2.1;
    final inner = widget.size * 1.59;
    final hs = widget.haloScale;
    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Transform.scale(
            scale: hs <= 0 ? 0.001 : hs,
            child: Container(
              width: outer,
              height: outer,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[Paper.halo, Color(0xFFEBF4F5)],
                ),
              ),
            ),
          ),
          Transform.scale(
            scale: hs <= 0 ? 0.001 : (0.4 + 0.6 * hs),
            child: Container(
              width: inner,
              height: inner,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Paper.haloInner,
              ),
            ),
          ),
          body,
        ],
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.shader,
    required this.time,
    required this.tilt,
    required this.squash,
    required this.alpha,
  });

  final ui.FragmentShader shader;
  final double time;
  final Offset tilt;
  final double squash;
  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, tilt.dx)
      ..setFloat(4, tilt.dy)
      ..setFloat(5, squash.clamp(0.0, 1.2))
      ..setFloat(6, alpha);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_OrbPainter old) => true;
}

/// Painted stand-in for platforms where the program failed to compile. Same
/// silhouette and palette, no life in it.
class _FallbackOrb extends StatelessWidget {
  const _FallbackOrb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _FallbackPainter());
  }
}

class _FallbackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.43;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          c + Offset(-r * 0.3, -r * 0.35),
          r * 1.4,
          <Color>[const Color(0xFFEAF5EA), const Color(0xFFC3DEC3), const Color(0xFF6E9A6E)],
          <double>[0, 0.6, 1],
        ),
    );
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.14
      ..color = const Color(0xFF3F5F3F).withValues(alpha: 0.7);
    canvas.drawCircle(c + Offset(r * 0.28, r * 0.05), r * 0.44, rim);
    canvas.drawCircle(c + Offset(-r * 0.30, -r * 0.15), r * 0.28, rim);
    canvas.drawCircle(
      c + Offset(-r * 0.35, -r * 0.42),
      r * 0.16,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(_FallbackPainter old) => false;
}

/// Utility used by the report screen to phase the small orb's halo.
double haloPhase(double t) => 0.5 + 0.5 * math.sin(t);
