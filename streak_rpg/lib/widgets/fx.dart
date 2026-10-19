import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/motion.dart';
import '../core/style.dart';

/// Deterministic per-index randomness so ambient particles never pop on rebuild.
double hash(int i, [int salt = 0]) {
  var x = (i * 374761393 + salt * 668265263) & 0x7fffffff;
  x = ((x ^ (x >> 13)) * 1274126177) & 0x7fffffff;
  return (x & 0xffff) / 0xffff;
}

/// Glowing motes that drift upward and wink out — fireflies, embers, magic dust.
class Motes extends StatelessWidget {
  const Motes({
    super.key,
    required this.count,
    this.colors = const [Color(0xFFFFD86B), Color(0xFFFFB24A)],
    this.size = const (1.0, 2.6),
    this.speed = 14,
    this.sway = 10,
    this.glow = 4,
    this.seed = 0,
    this.life = 7,
  });

  final int count;
  final List<Color> colors;
  final (double, double) size;
  final double speed;
  final double sway;
  final double glow;
  final int seed;
  final double life;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: Tick(
          builder: (context, s, _) => CustomPaint(painter: _MotesPainter(this, s), size: Size.infinite),
        ),
      ),
    );
  }
}

class _MotesPainter extends CustomPainter {
  _MotesPainter(this.m, this.s);

  final Motes m;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final core = Paint();
    final halo = Paint()..maskFilter = MaskFilter.blur(BlurStyle.normal, m.glow);
    for (var i = 0; i < m.count; i++) {
      final life = m.life * (0.7 + hash(i, m.seed + 1) * 0.6);
      final t = cycle(s, life, hash(i, m.seed + 2));
      final x = hash(i, m.seed + 3) * size.width + math.sin((s / life + hash(i, m.seed + 4)) * math.pi * 2) * m.sway;
      final y = size.height * (1 - hash(i, m.seed + 5) * 0.35) - t * m.speed * life;
      final wrapped = ((y % size.height) + size.height) % size.height;
      final r = lerp(m.size.$1, m.size.$2, hash(i, m.seed + 6));
      final a = math.sin(t * math.pi) * (0.55 + 0.45 * math.sin(s * 3 + i));
      if (a <= 0.02) continue;
      final c = m.colors[i % m.colors.length];
      halo.color = c.withValues(alpha: a * 0.55);
      canvas.drawCircle(Offset(x, wrapped), r * 2.6, halo);
      core.color = Color.lerp(c, Colors.white, 0.5)!.withValues(alpha: a);
      canvas.drawCircle(Offset(x, wrapped), r * 0.8, core);
    }
  }

  @override
  bool shouldRepaint(_MotesPainter old) => old.s != s;
}

/// Four-point star glints that twinkle in place.
class Twinkles extends StatelessWidget {
  const Twinkles({super.key, required this.points, this.color = const Color(0xFFFFF4C2), this.period = 2.6});

  /// (x, y, size) in local coordinates.
  final List<(double, double, double)> points;
  final Color color;
  final double period;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Tick(
        builder: (context, s, _) => CustomPaint(painter: _TwinklePainter(points, color, period, s), size: Size.infinite),
      ),
    );
  }
}

class _TwinklePainter extends CustomPainter {
  _TwinklePainter(this.points, this.color, this.period, this.s);

  final List<(double, double, double)> points;
  final Color color;
  final double period;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < points.length; i++) {
      final (x, y, r) = points[i];
      final t = cycle(s, period * (0.8 + hash(i, 9) * 0.6), hash(i, 7));
      final a = math.pow(math.sin(t * math.pi), 3).toDouble();
      if (a < 0.02) continue;
      star(canvas, Offset(x, y), r * (0.4 + 0.6 * a), color.withValues(alpha: a), rotation: s * 0.6 + i);
    }
  }

  @override
  bool shouldRepaint(_TwinklePainter old) => old.s != s;
}

void star(Canvas canvas, Offset c, double r, Color color, {double rotation = 0}) {
  final glow = Paint()
    ..color = color.withValues(alpha: color.a * 0.6)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.7);
  canvas.drawCircle(c, r * 0.7, glow);
  final p = Path();
  for (var k = 0; k < 8; k++) {
    final ang = rotation + k * math.pi / 4;
    final rr = k.isEven ? r : r * 0.18;
    final pt = c + Offset(math.cos(ang), math.sin(ang)) * rr;
    k == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
  }
  p.close();
  canvas.drawPath(p, Paint()..color = color);
}

/// A slowly turning sunburst, faded at the edges.
class GodRays extends StatelessWidget {
  const GodRays({super.key, this.color = const Color(0xFFFFC94A), this.rays = 14, this.speed = 0.08, this.opacity = 0.5, this.spread = 0.5});

  final Color color;
  final int rays;
  final double speed;
  final double opacity;
  final double spread;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Tick(
        builder: (context, s, _) => CustomPaint(painter: _RaysPainter(this, s), size: Size.infinite),
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  _RaysPainter(this.g, this.s);

  final GodRays g;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final paint = Paint()
      ..shader = ui.Gradient.radial(c, r, [g.color.withValues(alpha: g.opacity), g.color.withValues(alpha: 0)])
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final step = math.pi * 2 / g.rays;
    for (var i = 0; i < g.rays; i++) {
      final a = s * g.speed * math.pi * 2 + i * step;
      final w = step * g.spread * (0.6 + 0.4 * math.sin(s * 1.3 + i * 1.7));
      final p = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + math.cos(a - w / 2) * r, c.dy + math.sin(a - w / 2) * r)
        ..lineTo(c.dx + math.cos(a + w / 2) * r, c.dy + math.sin(a + w / 2) * r)
        ..close();
      canvas.drawPath(p, paint);
    }
  }

  @override
  bool shouldRepaint(_RaysPainter old) => old.s != s;
}

/// A soft radial glow.
class Glow extends StatelessWidget {
  const Glow({super.key, required this.color, this.opacity = 1, this.stop = 0.0});

  final Color color;
  final double opacity;
  final double stop;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: color.a * opacity),
              color.withValues(alpha: color.a * opacity * 0.45),
              color.withValues(alpha: 0),
            ],
            stops: [stop, lerp(stop, 1, 0.45), 1],
          ),
        ),
      ),
    );
  }
}

/// A diagonal band of light that sweeps across the child every [period] seconds.
class Sheen extends StatelessWidget {
  const Sheen({super.key, required this.child, this.period = 3.2, this.width = 0.22, this.strength = 0.55, this.delay = 0, this.angle = 0.35});

  final Widget child;
  final double period;
  final double width;
  final double strength;
  final double delay;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Tick(
      child: child,
      builder: (context, s, child) {
        final t = cycle(s - delay, period);
        final pass = span(t, 0, 0.42, glide);
        final x = lerp(-1.0 - width * 4, 1.0 + width * 4, pass);
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (r) => LinearGradient(
            begin: Alignment(x - 1, -1 + angle),
            end: Alignment(x + 1, 1 - angle),
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: strength),
              Colors.white.withValues(alpha: 0),
            ],
            stops: [0.5 - width / 2, 0.5, 0.5 + width / 2],
          ).createShader(r),
          child: child,
        );
      },
    );
  }
}

/// Floats a child on a sine wave, optionally with a slight tilt.
class Bob extends StatelessWidget {
  const Bob({super.key, required this.child, this.amplitude = 4, this.period = 3, this.phase = 0, this.tilt = 0, this.dx = 0});

  final Widget child;
  final double amplitude;
  final double period;
  final double phase;
  final double tilt;
  final double dx;

  @override
  Widget build(BuildContext context) {
    return Tick(
      child: child,
      builder: (context, s, child) {
        final w = wave(s, period, phase);
        return Transform.translate(
          offset: Offset(dx * wave(s, period * 1.7, phase + 0.2), w * amplitude),
          child: tilt == 0 ? child : Transform.rotate(angle: wave(s, period * 1.3, phase + 0.4) * tilt, child: child),
        );
      },
    );
  }
}

/// Drifting light fog made of large blurred blobs.
class Fog extends StatelessWidget {
  const Fog({super.key, this.colors = const [Color(0x337A5CFF), Color(0x2648C6FF)], this.blobs = 6, this.seed = 0, this.speed = 1});

  final List<Color> colors;
  final int blobs;
  final int seed;
  final double speed;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: Tick(
          builder: (context, s, _) => CustomPaint(painter: _FogPainter(this, s), size: Size.infinite),
        ),
      ),
    );
  }
}

class _FogPainter extends CustomPainter {
  _FogPainter(this.f, this.s);

  final Fog f;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < f.blobs; i++) {
      final cx = (hash(i, f.seed) + s * f.speed * 0.01 * (0.5 + hash(i, f.seed + 1))) % 1.4 - 0.2;
      final cy = hash(i, f.seed + 2) + wave(s, 9 + i * 1.3) * 0.04;
      final r = size.width * (0.25 + hash(i, f.seed + 3) * 0.25);
      final c = f.colors[i % f.colors.length];
      final p = Paint()
        ..color = c
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx * size.width, cy * size.height), width: r * 2.2, height: r), p);
    }
  }

  @override
  bool shouldRepaint(_FogPainter old) => old.s != s;
}

// ---------------------------------------------------------------------------
// One-shot bursts: particle explosions, shockwave rings and floating text.

class _Spark {
  _Spark(this.origin, this.velocity, this.color, this.size, this.life, this.kind, this.spin);

  final Offset origin;
  final Offset velocity;
  final Color color;
  final double size;
  final double life;
  final int kind;
  final double spin;
}

class _Ring {
  _Ring(this.center, this.color, this.radius, this.life, this.squash);

  final Offset center;
  final Color color;
  final double radius;
  final double life;
  final double squash;
}

class _Float {
  _Float(this.at, this.text, this.style, this.rise);

  final Offset at;
  final String text;
  final TextStyle style;
  final double rise;
}

class _Event<T> {
  _Event(this.item, this.born);

  final T item;
  final double born;
}

/// Overlay that renders bursts; trigger with `FxLayer.of(context).burst(...)`.
class FxLayer extends StatefulWidget {
  const FxLayer({super.key, required this.child});

  final Widget child;

  static FxLayerState of(BuildContext context) => context.findAncestorStateOfType<FxLayerState>()!;

  @override
  State<FxLayer> createState() => FxLayerState();
}

class FxLayerState extends State<FxLayer> with SingleTickerProviderStateMixin {
  final _sparks = <_Event<_Spark>>[];
  final _rings = <_Event<_Ring>>[];
  final _floats = <_Event<_Float>>[];
  final _rand = math.Random(7);
  final _now = ValueNotifier<double>(0);
  late final Ticker _ticker;
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((d) {
      _now.value = d.inMicroseconds / 1e6;
      _sparks.removeWhere((e) => _now.value - e.born > e.item.life);
      _rings.removeWhere((e) => _now.value - e.born > e.item.life);
      _floats.removeWhere((e) => _now.value - e.born > 1.3);
      if (_sparks.isEmpty && _rings.isEmpty && _floats.isEmpty) _ticker.stop();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _now.dispose();
    super.dispose();
  }

  void _wake() {
    if (!_ticker.isActive) {
      _ticker.start();
      _now.value = 0;
    }
  }

  double get _t => _ticker.isActive ? _now.value : 0;

  /// Converts a point in [from]'s coordinates to this layer's.
  Offset local(BuildContext from, Offset point) {
    final box = from.findRenderObject() as RenderBox?;
    final me = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || me == null) return point;
    return me.globalToLocal(box.localToGlobal(point));
  }

  void burst(Offset at, {int count = 26, List<Color> colors = const [Tone.goldHi, Tone.gold, Colors.white], double power = 160, double size = 3.2, double gravity = 1, bool stars = true}) {
    _wake();
    final born = _t;
    for (var i = 0; i < count; i++) {
      final a = _rand.nextDouble() * math.pi * 2;
      final v = power * (0.35 + _rand.nextDouble() * 0.75);
      _sparks.add(
        _Event(
          _Spark(
            at,
            Offset(math.cos(a) * v, math.sin(a) * v - power * 0.35 * gravity),
            colors[i % colors.length],
            size * (0.5 + _rand.nextDouble()),
            0.7 + _rand.nextDouble() * 0.6,
            stars && i % 3 == 0 ? 1 : 0,
            (_rand.nextDouble() - 0.5) * 12,
          ),
          born,
        ),
      );
    }
  }

  void ring(Offset at, {Color color = Tone.goldHi, double radius = 80, double life = 0.7, double squash = 1}) {
    _wake();
    _rings.add(_Event(_Ring(at, color, radius, life, squash), _t));
  }

  void float(Offset at, String text, {TextStyle? style, double rise = 46}) {
    _wake();
    _floats.add(_Event(_Float(at, text, style ?? Typo.toast, rise), _t));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _key,
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          child: ValueListenableBuilder<double>(
            valueListenable: _now,
            builder: (context, now, _) => CustomPaint(painter: _FxPainter(this, now)),
          ),
        ),
      ],
    );
  }
}

class _FxPainter extends CustomPainter {
  _FxPainter(this.s, this.now);

  final FxLayerState s;
  final double now;

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in s._rings) {
      final r = e.item;
      final t = ((now - e.born) / r.life).clamp(0.0, 1.0);
      final k = Curves.easeOutCubic.transform(t);
      final rect = Rect.fromCenter(center: r.center, width: r.radius * 2 * k, height: r.radius * 2 * k * r.squash);
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 * (1 - t) + 0.5
          ..color = r.color.withValues(alpha: (1 - t) * 0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }
    for (final e in s._sparks) {
      final p = e.item;
      final age = now - e.born;
      final t = (age / p.life).clamp(0.0, 1.0);
      final drag = (1 - math.exp(-2.6 * age)) / 2.6;
      final pos = p.origin + p.velocity * drag + Offset(0, 140 * age * age);
      final a = (1 - t) * (t < 0.1 ? t * 10 : 1);
      if (p.kind == 1) {
        star(canvas, pos, p.size * 2.2 * (1 - t * 0.5), p.color.withValues(alpha: a), rotation: p.spin * age);
      } else {
        canvas.drawCircle(
          pos,
          p.size * 2.2,
          Paint()
            ..color = p.color.withValues(alpha: a * 0.35)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 1.5),
        );
        canvas.drawCircle(pos, p.size * (1 - t * 0.6), Paint()..color = Color.lerp(p.color, Colors.white, 0.35)!.withValues(alpha: a));
      }
    }
    for (final e in s._floats) {
      final f = e.item;
      final t = ((now - e.born) / 1.3).clamp(0.0, 1.0);
      final rise = Curves.easeOutCubic.transform(t) * f.rise;
      final scale = t < 0.15 ? Curves.easeOutBack.transform(t / 0.15) : 1.0;
      final a = t > 0.65 ? 1 - (t - 0.65) / 0.35 : 1.0;
      final tp = TextPainter(
        text: TextSpan(
          text: f.text,
          style: f.style.copyWith(color: f.style.color!.withValues(alpha: a)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(f.at.dx, f.at.dy - rise);
      canvas.scale(scale);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FxPainter old) => true;
}
