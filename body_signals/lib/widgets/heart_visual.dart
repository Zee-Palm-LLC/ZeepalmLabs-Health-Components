import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_colors.dart';

const _heartAsset = 'assets/images/heart.png';

class HeartVisual extends StatefulWidget {
  const HeartVisual({super.key, this.size = 220});

  final double size;

  @override
  State<HeartVisual> createState() => _HeartVisualState();
}

class _HeartVisualState extends State<HeartVisual>
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 36),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heartSize = widget.size * 0.64;

    return SizedBox.square(
      dimension: widget.size,
      child: RepaintBoundary(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _spin,
              builder: (_, _) => CustomPaint(
                size: Size.square(widget.size),
                painter: _RingsPainter(turn: _spin.value),
              ),
            ),
            AnimatedBuilder(
              animation: _pulse,
              child: SizedBox.square(
                dimension: heartSize,
                child: Image.asset(
                  _heartAsset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => CustomPaint(
                    size: Size.square(heartSize),
                    painter: _HeartPainter(glow: 0.9),
                  ),
                ),
              ),
              builder: (_, child) {
                final beat = Curves.easeInOut.transform(_pulse.value);
                return Transform.scale(
                  scale: 0.97 + beat * 0.06,
                  child: child,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({required this.turn});

  final double turn;

  static const _tickCount = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final sweepStart = turn * 2 * math.pi;

    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.violet.withValues(alpha: 0.26),
            AppColors.indigo.withValues(alpha: 0.10),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(
          Rect.fromCircle(center: center, radius: radius * 0.72),
        ),
    );

    for (final ring in const [0.98, 0.80, 0.62]) {
      canvas.drawCircle(
        center,
        radius * ring,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: ring == 0.98 ? 0.07 : 0.05),
      );
    }

    final outer = Rect.fromCircle(center: center, radius: radius * 0.98);
    canvas.drawArc(
      outer,
      sweepStart,
      math.pi * 0.55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: sweepStart,
          endAngle: sweepStart + math.pi * 0.55,
          colors: [
            AppColors.cyan.withValues(alpha: 0.0),
            AppColors.cyan.withValues(alpha: 0.85),
          ],
        ).createShader(outer),
    );

    for (var i = 0; i < _tickCount; i++) {
      final angle = (i / _tickCount) * 2 * math.pi;
      final major = i % 5 == 0;
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * (radius * 0.80),
        major ? 1.3 : 0.7,
        Paint()..color = Colors.white.withValues(alpha: major ? 0.22 : 0.10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) => old.turn != turn;
}

class _HeartPainter extends CustomPainter {
  _HeartPainter({required this.glow});

  final double glow;

  static const _grid = Size(200, 220);

  static const _coronaries = <List<double>>[
    [0.56, 0.26, 0.50, 0.52, 0.37, 0.92],
    [0.54, 0.34, 0.68, 0.44, 0.74, 0.66],
    [0.52, 0.44, 0.40, 0.58, 0.30, 0.74],
    [0.60, 0.30, 0.78, 0.40, 0.82, 0.56],
    [0.50, 0.60, 0.58, 0.74, 0.54, 0.90],
  ];

  Offset Function(double, double) _mapper(Size s) {
    final sx = s.width / _grid.width;
    final sy = s.height / _grid.height;
    return (x, y) => Offset(x * sx, y * sy);
  }

  Path _muscle(Size s) {
    final at = _mapper(s);
    void curve(Path p, List<double> v) => p.cubicTo(
          at(v[0], v[1]).dx, at(v[0], v[1]).dy,
          at(v[2], v[3]).dx, at(v[2], v[3]).dy,
          at(v[4], v[5]).dx, at(v[4], v[5]).dy,
        );

    final path = Path()..moveTo(at(74, 212).dx, at(74, 212).dy);
    curve(path, [40, 190, 26, 148, 34, 106]);
    curve(path, [40, 78, 58, 62, 84, 60]);
    curve(path, [112, 57, 146, 62, 162, 84]);
    curve(path, [182, 112, 172, 160, 136, 186]);
    curve(path, [112, 202, 92, 212, 74, 212]);
    return path..close();
  }

  List<({Path path, double weight})> _vessels(Size s) {
    final at = _mapper(s);
    void curve(Path p, List<double> v) => p.cubicTo(
          at(v[0], v[1]).dx, at(v[0], v[1]).dy,
          at(v[2], v[3]).dx, at(v[2], v[3]).dy,
          at(v[4], v[5]).dx, at(v[4], v[5]).dy,
        );

    final aorta = Path()..moveTo(at(114, 68).dx, at(114, 68).dy);
    curve(aorta, [118, 24, 162, 14, 176, 46]);
    curve(aorta, [182, 62, 180, 72, 177, 84]);

    final pulmonary = Path()..moveTo(at(92, 68).dx, at(92, 68).dy);
    curve(pulmonary, [84, 42, 68, 32, 56, 44]);

    final vena = Path()..moveTo(at(150, 70).dx, at(150, 70).dy);
    curve(vena, [158, 48, 156, 32, 146, 24]);

    return [
      (path: aorta, weight: 1.0),
      (path: pulmonary, weight: 0.80),
      (path: vena, weight: 0.62),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final pivot = size.center(Offset.zero);

    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(-0.10);
    canvas.translate(-pivot.dx, -pivot.dy);

    final heart = _muscle(size);
    final bounds = heart.getBounds();

    canvas.drawPath(
      heart,
      Paint()
        ..color = AppColors.rose.withValues(alpha: 0.45 * glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 34 * glow),
    );
    canvas.drawPath(
      heart,
      Paint()
        ..color = AppColors.magenta.withValues(alpha: 0.40 * glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * glow),
    );

    final vessels = _vessels(size);
    for (final v in vessels) {
      canvas.drawPath(
        v.path,
        _tubeStroke(w * 0.16 * v.weight)
          ..color = AppColors.violet.withValues(alpha: 0.26 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawPath(
        v.path,
        _tubeStroke(w * 0.115 * v.weight)
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6D28D9), Color(0xFF9F3A8E)],
          ).createShader(bounds),
      );
    }
    for (final v in vessels) {
      canvas.drawPath(
        v.path,
        _tubeStroke(w * 0.030 * v.weight)
          ..color = const Color(0xFFC4B5FD).withValues(alpha: 0.30),
      );
    }

    canvas.drawPath(
      heart,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.20, -0.35),
          radius: 1.15,
          colors: [
            Color(0xFFFF8FB0),
            Color(0xFFEF2D5E),
            Color(0xFFA8134F),
            Color(0xFF5A0F3C),
          ],
          stops: [0.0, 0.32, 0.66, 1.0],
        ).createShader(bounds),
    );

    canvas.save();
    canvas.clipPath(heart);

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.56, h * 0.26)
        ..cubicTo(w * 0.50, h * 0.52, w * 0.44, h * 0.72, w * 0.36, h * 0.94),
      _tubeStroke(w * 0.085)
        ..color = const Color(0xFF4A0B31).withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.035),
    );

    for (var i = 0; i < _coronaries.length; i++) {
      final b = _coronaries[i];
      canvas.drawPath(
        Path()
          ..moveTo(w * b[0], h * b[1])
          ..quadraticBezierTo(w * b[2], h * b[3], w * b[4], h * b[5]),
        _tubeStroke(w * (i == 0 ? 0.022 : 0.013))
          ..color = const Color(0xFFFFB3C8).withValues(alpha: 0.52),
      );
    }

    canvas.drawCircle(
      Offset(w * 0.34, h * 0.30),
      w * 0.22,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.18),
    );
    canvas.drawCircle(
      Offset(w * 0.86, h * 0.82),
      w * 0.28,
      Paint()
        ..color = const Color(0xFF2E0620).withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.20),
    );
    canvas.restore();

    canvas.drawPath(
      heart,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFFFFC9DA).withValues(alpha: 0.60),
    );

    canvas.restore();
  }

  Paint _tubeStroke(double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = width;

  @override
  bool shouldRepaint(covariant _HeartPainter old) => old.glow != glow;
}
