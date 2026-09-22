import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../sound/sounds.dart';
import 'clock.dart';

class NebulaMix {
  NebulaMix(this.colors, this.weights);

  final List<Color> colors;
  final List<double> weights;

  static NebulaMix of(List<Sound> sounds, double Function(Sound) volume) {
    final colors = <Color>[];
    final weights = <double>[];
    for (var i = 0; i < 4; i++) {
      if (i < sounds.length) {
        colors.add(sounds[i].tint);
        weights.add(0.15 + volume(sounds[i]) * 0.95);
      } else {
        colors.add(const Color(0xFF6F6AD8));
        weights.add(0);
      }
    }
    return NebulaMix(colors, weights);
  }
}

class NebulaDriver extends ChangeNotifier {
  NebulaDriver(NebulaMix initial, {double fill = 0, double energy = 1})
    : _colors = initial.colors.toList(),
      _weights = initial.weights.toList(),
      _targetColors = initial.colors.toList(),
      _targetWeights = initial.weights.toList(),
      _fill = fill,
      _targetFill = fill,
      _energy = energy,
      _targetEnergy = energy {
    SceneClock.instance.addListener(_tick);
    _last = SceneClock.instance.value;
  }

  final List<Color> _colors;
  final List<double> _weights;
  final List<Color> _targetColors;
  List<double> _targetWeights;
  double _fill;
  double _targetFill;
  double _energy;
  double _targetEnergy;
  double _last = 0;
  double fillRate = 0.45;

  List<Color> get colors => _colors;
  List<double> get weights => _weights;
  double get fill => _fill;
  double get energy => _energy;

  void retarget(NebulaMix mix, {double? fill, double? energy}) {
    for (var i = 0; i < 4; i++) {
      if (mix.weights[i] > 0.001 || _weights[i] < 0.01) {
        _targetColors[i] = mix.colors[i];
      }
    }
    _targetWeights = mix.weights.toList();
    if (fill != null) _targetFill = fill;
    if (energy != null) _targetEnergy = energy;
  }

  void _tick() {
    final now = SceneClock.instance.value;
    final dt = (now - _last).clamp(0.0, 0.1);
    _last = now;
    final k = 1 - math.exp(-dt * 3.2);
    for (var i = 0; i < 4; i++) {
      _weights[i] += (_targetWeights[i] - _weights[i]) * k;
      _colors[i] = Color.lerp(_colors[i], _targetColors[i], k)!;
    }
    final df = _targetFill - _fill;
    _fill += df.clamp(-dt * fillRate * 1.6, dt * fillRate);
    _energy += (_targetEnergy - _energy) * k;
  }

  @override
  void dispose() {
    SceneClock.instance.removeListener(_tick);
    super.dispose();
  }
}

class VesselGeometry {
  const VesselGeometry(this.center, this.radius);

  final Offset center;
  final double radius;

  static const lipY = -0.815;
  static const lipTop = -0.885;
  static const lipHalf = 0.575;

  Offset get mouth => center + Offset(0, lipTop * radius);
  double get mouthHalf => lipHalf * radius;
}

class Vessel extends StatefulWidget {
  const Vessel({super.key, required this.driver, required this.geometry});

  final NebulaDriver driver;
  final VesselGeometry geometry;

  @override
  State<Vessel> createState() => _VesselState();
}

class _VesselState extends State<Vessel> {
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _shader = Shaders.vessel?.fragmentShader();
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: VesselPainter(
          driver: widget.driver,
          geometry: widget.geometry,
          shader: _shader,
        ),
      ),
    );
  }
}

class VesselPainter extends CustomPainter {
  VesselPainter({
    required this.driver,
    required this.geometry,
    required this.shader,
  }) : super(repaint: SceneClock.instance);

  final NebulaDriver driver;
  final VesselGeometry geometry;
  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = this.shader;
    if (shader == null) {
      _fallback(canvas);
      return;
    }
    _bind(shader, size, geometry.center, geometry.radius, 0, driver);
    final r = geometry.radius;
    final rect = Rect.fromLTRB(
      0,
      geometry.center.dy - r * 1.35,
      size.width,
      geometry.center.dy + r * 1.4,
    );
    canvas.drawRect(rect, Paint()..shader = shader);
  }

  void _fallback(Canvas canvas) {
    final c = geometry.center;
    final r = geometry.radius;
    final colors = driver.colors;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          r,
          [colors[0], colors[1], const Color(0xFF0B1030)],
          [0, 0.55, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(VesselPainter old) =>
      old.geometry.center != geometry.center ||
      old.geometry.radius != geometry.radius ||
      old.driver != driver;
}

void _bind(
  ui.FragmentShader shader,
  Size size,
  Offset center,
  double radius,
  double mode,
  NebulaDriver driver,
) {
  var i = 0;
  shader
    ..setFloat(i++, size.width)
    ..setFloat(i++, size.height)
    ..setFloat(i++, center.dx)
    ..setFloat(i++, center.dy)
    ..setFloat(i++, radius)
    ..setFloat(i++, SceneClock.instance.value)
    ..setFloat(i++, mode)
    ..setFloat(i++, driver.fill)
    ..setFloat(i++, driver.energy);
  for (final w in driver.weights) {
    shader.setFloat(i++, w);
  }
  for (final c in driver.colors) {
    shader
      ..setFloat(i++, c.r)
      ..setFloat(i++, c.g)
      ..setFloat(i++, c.b);
  }
}

class NebulaArt extends StatefulWidget {
  const NebulaArt({super.key, required this.driver, this.radius = 16});

  final NebulaDriver driver;
  final double radius;

  @override
  State<NebulaArt> createState() => _NebulaArtState();
}

class _NebulaArtState extends State<NebulaArt> {
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _shader = Shaders.vessel?.fragmentShader();
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ArtPainter(widget.driver, _shader),
        ),
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  _ArtPainter(this.driver, this.shader) : super(repaint: SceneClock.instance);

  final NebulaDriver driver;
  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = this.shader;
    final rect = Offset.zero & size;
    if (shader == null) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.radial(
            rect.center,
            size.shortestSide * 0.7,
            [driver.colors[0], driver.colors[1], const Color(0xFF0B1030)],
            [0, 0.5, 1],
          ),
      );
      return;
    }
    _bind(shader, size, rect.center, size.shortestSide / 2, 1, driver);
    canvas.drawRect(rect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_ArtPainter old) =>
      old.driver != driver || old.shader != shader;
}

HeroFlightShuttleBuilder nebulaFlight(
  NebulaDriver driver,
  double cornerRadius,
) {
  return (context, animation, direction, from, to) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => LayoutBuilder(
        builder: (context, box) {
          final t = animation.value;
          final round = box.biggest.shortestSide / 2;
          final shape = Curves.easeInCubic.transform(t);
          final radius = round + (cornerRadius - round) * shape;
          return Opacity(
            opacity: Curves.easeOut.transform((t * 1.6).clamp(0.0, 1.0)),
            child: NebulaArt(driver: driver, radius: radius),
          );
        },
      ),
    );
  };
}
