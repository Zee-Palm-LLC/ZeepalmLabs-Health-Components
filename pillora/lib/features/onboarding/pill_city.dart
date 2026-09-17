import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../core/motion/motion.dart';
import '../../core/shaders.dart';

class PillCityPainter extends CustomPainter {
  PillCityPainter({required this.intro, required this.clock, required this.look, required this.exit})
    : super(repaint: Listenable.merge([intro, clock, look, exit]));

  final Animation<double> intro;
  final ValueListenable<double> clock;
  final ValueListenable<Offset> look;
  final Animation<double> exit;

  static ui.FragmentShader? _grainShader;

  static const designWidth = 390.0;
  static const designHeight = 565.0;

  late double _t;
  late double _sec;
  late Offset _look;

  @override
  void paint(Canvas canvas, Size size) {
    _t = intro.value;
    _sec = clock.value;
    _look = look.value + Offset(wave(_sec, 13) * 0.35, wave(_sec, 10, 0.3) * 0.25);

    final full = Offset.zero & size;
    canvas.save();
    canvas.clipRect(full);

    final zoom = 1 + exit.value * 0.12;
    canvas.translate(size.width / 2, size.height * 0.62);
    canvas.scale(zoom);
    canvas.translate(-size.width / 2, -size.height * 0.62);

    _sky(canvas, size);

    final unit = math.min(size.width / designWidth, size.height / designHeight);
    canvas.save();
    canvas.translate((size.width - designWidth * unit) / 2, size.height - designHeight * unit);
    canvas.scale(unit);

    _depth(canvas, 0.12, () => _bands(canvas));
    _depth(canvas, 0.22, () => _leaf(canvas));
    _depth(canvas, 0.38, () => _tablets(canvas));
    _depth(canvas, 0.45, () => _backClouds(canvas));
    _depth(canvas, 0.62, () {
      _capsule(canvas, _backTeal, 0.18);
      _capsule(canvas, _backPale, 0.24);
    });
    _depth(canvas, 0.7, () => _midClouds(canvas));
    _depth(canvas, 0.85, () {
      _capsule(canvas, _rightOrange, 0.44);
      _capsule(canvas, _center, 0.3);
      _capsule(canvas, _leftOrange, 0.38);
      _doors(canvas);
      _ladders(canvas);
    });
    _depth(canvas, 1, () {
      _ground(canvas);
      _truck(canvas);
      _people(canvas);
    });
    _depth(canvas, 0.8, () => _motes(canvas));
    canvas.restore();

    _fade(canvas, size, unit);
    _grain(canvas, size);

    if (exit.value > 0) {
      canvas.drawRect(full, Paint()..color = const Color(0xFF0E3033).withValues(alpha: exit.value * 0.45));
    }
    canvas.restore();
  }

  void _depth(Canvas canvas, double depth, VoidCallback draw) {
    canvas.save();
    final settle = 1 - window(_t, 0, 0.55, Curves.easeOutCubic);
    canvas.translate(_look.dx * depth * 12, _look.dy * depth * 7 + settle * depth * 26);
    draw();
    canvas.restore();
  }

  void _sky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          const [Color(0xFF64BEB2), Color(0xFF4FB2A5), Color(0xFF3B988E)],
          const [0, 0.55, 1],
        ),
    );
    final light = window(_t, 0, 0.5, Curves.easeOut);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width * (0.52 + _look.dx * 0.02), size.height * 0.06),
          size.width * 0.78,
          [
            const Color(0xFFB4DFD8).withValues(alpha: 0.95 * light),
            const Color(0xFFA3D5CE).withValues(alpha: 0.45 * light),
            const Color(0x00A3D5CE),
          ],
          const [0, 0.45, 1],
        ),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(Offset(size.width * 1.02, size.height * 0.5), size.width * 0.55, const [
          Color(0x557FCBBF),
          Color(0x007FCBBF),
        ]),
    );
  }

  void _bands(Canvas canvas) {
    final reveal = window(_t, 0.05, 0.5, Curves.easeOutCubic);
    if (reveal <= 0) return;
    final shift = wave(_sec, 16) * 6;
    final broad = Path()
      ..moveTo(420, 70 + shift)
      ..cubicTo(300, 120 + shift, 170, 190, -30, 330);
    canvas.drawPath(
      broad,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 74
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.075 * reveal)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    final lower = Path()
      ..moveTo(420, 205 - shift)
      ..cubicTo(380, 240, 350, 270, 318, 320);
    canvas.drawPath(
      lower,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 46
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.09 * reveal)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    final glint = (_sec / 7) % 1;
    final streak = Path()
      ..moveTo(368, 132)
      ..cubicTo(335, 150, 300, 170, 262, 196);
    final metric = streak.computeMetrics().first;
    final alpha = 0.22 * reveal * (0.6 + 0.4 * math.sin(glint * math.pi * 2).abs());
    canvas.drawPath(
      metric.extractPath(0, metric.length * reveal),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFE6F6F3).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2),
    );
  }

  void _leaf(Canvas canvas) {
    final grow = window(_t, 0.08, 0.5, Curves.easeOutBack);
    if (grow <= 0) return;
    canvas.save();
    canvas.translate(90, 350);
    canvas.rotate(wave(_sec, 17) * 0.02);
    canvas.scale(grow);
    canvas.translate(-90, -350);
    final leaf = Path()
      ..moveTo(18, 334)
      ..cubicTo(2, 256, 52, 190, 134, 194)
      ..cubicTo(196, 198, 214, 268, 186, 330)
      ..cubicTo(158, 384, 44, 404, 18, 334)
      ..close();
    canvas.drawPath(
      leaf,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(40, 200), const Offset(170, 380), const [
          Color(0xFF8ACFC3),
          Color(0xFF74C1B5),
        ]),
    );
    final ribbon = Path()
      ..moveTo(395, 230)
      ..cubicTo(365, 280, 345, 350, 352, 470)
      ..lineTo(395, 470)
      ..close();
    canvas.drawPath(ribbon, Paint()..color = const Color(0x5591D1C6));
    canvas.restore();
  }

  void _tablets(Canvas canvas) {
    final grow = window(_t, 0.12, 0.55, Curves.easeOutBack);
    if (grow <= 0) return;
    _tablet(canvas, const Offset(132, 322), 64, 80, -0.36 + wave(_sec, 15) * 0.035, grow, bob: wave(_sec, 9) * 2.2);
    _tablet(
      canvas,
      const Offset(382, 436),
      46,
      64,
      0.34 + wave(_sec, 12, 0.4) * 0.03,
      grow,
      bob: wave(_sec, 8, 0.5) * 1.8,
    );
  }

  void _tablet(Canvas canvas, Offset centre, double rx, double ry, double angle, double grow, {double bob = 0}) {
    canvas.save();
    canvas.translate(centre.dx, centre.dy + bob);
    canvas.rotate(angle);
    canvas.scale(grow);
    final face = Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2);
    canvas.drawOval(face.shift(const Offset(7, 5)), Paint()..color = const Color(0xFF8CCBC1));
    canvas.drawOval(
      face,
      Paint()
        ..shader = ui.Gradient.linear(
          face.topLeft,
          face.bottomRight,
          const [Color(0xFFEFFDFB), Color(0xFFD2F1EC), Color(0xFFABDCD4)],
          const [0, 0.5, 1],
        ),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(face));
    canvas.drawLine(
      Offset(0, -ry * 1.2),
      Offset(0, ry * 1.2),
      Paint()
        ..color = const Color(0xFF3F9A90)
        ..strokeWidth = 7,
    );
    canvas.drawLine(
      Offset(3.5, -ry * 1.2),
      Offset(3.5, ry * 1.2),
      Paint()
        ..color = const Color(0x66FFFFFF)
        ..strokeWidth = 1.2,
    );
    canvas.restore();
    canvas.drawOval(
      face.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0x88FFFFFF),
    );
    canvas.restore();
  }

  void _cloud(
    Canvas canvas,
    List<(double, double, double)> puffs,
    List<Color> colors,
    double top,
    double bottom, {
    double dx = 0,
    double alpha = 1,
  }) {
    final path = Path();
    for (final (x, y, r) in puffs) {
      path.addOval(Rect.fromCircle(center: Offset(x + dx, y), radius: r));
    }
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, top),
          Offset(0, bottom),
          [for (final c in colors) c.withValues(alpha: c.a * alpha)],
          [for (var i = 0; i < colors.length; i++) i / (colors.length - 1)],
        ),
    );
  }

  double _slide(double start, double from) {
    return (1 - window(_t, start, start + 0.42, Curves.easeOutCubic)) * from;
  }

  void _backClouds(Canvas canvas) {
    final drift = wave(_sec, 19) * 5;
    _cloud(
      canvas,
      const [(356, 330, 24), (380, 300, 30), (402, 336, 30), (346, 360, 20), (372, 356, 22)],
      const [Color(0xFFE8F6F3), Color(0xFFBFE2DB)],
      270,
      380,
      dx: drift + _slide(0.16, 90),
    );
    _cloud(
      canvas,
      const [(96, 424, 40), (132, 398, 34), (66, 452, 34), (128, 450, 30)],
      const [Color(0xFFDDF2EE), Color(0xFFA9D8CF)],
      360,
      480,
      dx: -drift * 0.8 + _slide(0.2, -110),
    );
  }

  void _midClouds(Canvas canvas) {
    final drift = wave(_sec, 21, 0.3) * 4;
    _cloud(
      canvas,
      const [(20, 446, 50), (62, 422, 38), (6, 404, 34), (84, 470, 34), (44, 486, 40)],
      const [Color(0xFFFDBE9C), Color(0xFFF67433), Color(0xFFDD5424)],
      372,
      520,
      dx: drift + _slide(0.2, -130),
    );
    _cloud(
      canvas,
      const [(332, 470, 30), (366, 452, 34), (398, 468, 32), (302, 492, 24), (350, 494, 28)],
      const [Color(0xFFF0FAF8), Color(0xFFC5E6E0)],
      420,
      520,
      dx: -drift + _slide(0.24, 120),
    );
  }

  static const _backTeal = _Capsule(
    left: 166,
    width: 58,
    top: 180,
    seam: 560,
    bottom: 560,
    cap: [Color(0xFF86CABF), Color(0xFF5BAEA3), Color(0xFF3F8E85)],
    body: [Color(0xFF86CABF), Color(0xFF5BAEA3), Color(0xFF3F8E85)],
  );
  static const _backPale = _Capsule(
    left: 252,
    width: 78,
    top: 152,
    seam: 262,
    bottom: 560,
    cap: [Color(0xFFF4FCFB), Color(0xFFD5F0EC), Color(0xFFA6D5CE)],
    body: [Color(0xFF55A39B), Color(0xFF2F7C75), Color(0xFF1F5B56)],
  );
  static const _center = _Capsule(
    left: 178,
    width: 117,
    top: 217,
    seam: 372,
    bottom: 560,
    cap: [Color(0xFFF5FDFC), Color(0xFFD9F4EF), Color(0xFFA3D6CE)],
    body: [Color(0xFF357570), Color(0xFF22605D), Color(0xFF153F40)],
  );
  static const _leftOrange = _Capsule(
    left: 98,
    width: 78,
    top: 317,
    seam: 427,
    bottom: 560,
    cap: [Color(0xFFFFF3E6), Color(0xFFF8D8BC), Color(0xFFE7AA86)],
    body: [Color(0xFFE56A36), Color(0xFFC54513), Color(0xFF8F2E0A)],
  );
  static const _rightOrange = _Capsule(
    left: 295,
    width: 50,
    top: 337,
    seam: 432,
    bottom: 560,
    cap: [Color(0xFFFFF3E6), Color(0xFFF8D8BC), Color(0xFFE7AA86)],
    body: [Color(0xFFE56A36), Color(0xFFC54513), Color(0xFF8F2E0A)],
  );

  void _capsule(Canvas canvas, _Capsule c, double start) {
    final grow = window(_t, start, start + 0.34, Curves.easeOutBack);
    if (grow <= 0) return;
    final rise = (1 - grow) * (c.bottom - c.top + 40);
    final capT = window(_t, start + 0.2, start + 0.5);
    final lift = capT <= 0 ? -22.0 : -22 * (1 - Curves.elasticOut.transform(capT));
    final breathe = wave(_sec, 6 + c.left / 100) * 1.2;

    canvas.save();
    canvas.translate(0, rise + breathe);
    final radius = c.width / 2;
    final bodyRect = Rect.fromLTRB(c.left, c.seam - 2, c.left + c.width, c.bottom);
    canvas.drawRect(bodyRect, Paint()..shader = _cylinder(bodyRect, c.body));
    canvas.drawRect(
      Rect.fromLTWH(c.left, c.seam + 1, c.width, 10),
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, c.seam + 1), Offset(0, c.seam + 11), const [
          Color(0x40000000),
          Color(0x00000000),
        ]),
    );
    canvas.drawRect(
      Rect.fromLTWH(c.left + 3, c.seam + 4, 1.6, c.bottom - c.seam - 4),
      Paint()..color = const Color(0x1FFFFFFF),
    );

    canvas.translate(0, lift);
    final capRect = Rect.fromLTRB(c.left - 1.5, c.top, c.left + c.width + 1.5, c.seam + 2);
    final cap = RRect.fromRectAndCorners(
      capRect,
      topLeft: Radius.circular(radius + 1.5),
      topRight: Radius.circular(radius + 1.5),
      bottomLeft: const Radius.circular(1.5),
      bottomRight: const Radius.circular(1.5),
    );
    canvas.drawRRect(cap, Paint()..shader = _cylinder(capRect, c.cap));
    canvas.save();
    canvas.clipRRect(cap);
    final glintX = c.left + c.width * (0.3 + 0.08 * wave(_sec, 9, c.left / 390));
    canvas.drawCircle(
      Offset(glintX, c.top + radius * 0.75),
      radius * 1.05,
      Paint()
        ..shader = ui.Gradient.radial(Offset(glintX, c.top + radius * 0.75), radius * 1.05, const [
          Color(0x66FFFFFF),
          Color(0x00FFFFFF),
        ]),
    );
    canvas.restore();
    canvas.drawArc(
      Rect.fromLTWH(c.left - 0.5, c.top + 1, c.width + 1, c.width),
      math.pi * 1.05,
      math.pi * 0.55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0x8CFFFFFF),
    );
    canvas.restore();
  }

  Shader _cylinder(Rect rect, List<Color> tones) {
    return ui.Gradient.linear(
      rect.centerLeft,
      rect.centerRight,
      [tones[0], tones[1], tones[1], tones[2]],
      const [0, 0.32, 0.58, 1],
    );
  }

  void _doors(Canvas canvas) {
    final open = window(_t, 0.66, 0.8, Curves.easeOutCubic);
    if (open <= 0) return;
    _door(canvas, _center, 214, 20, 32, const Color(0xFF0F3437), const Color(0xFF8DC3BB), open, 0.3);
    _door(canvas, _leftOrange, 150, 17, 27, const Color(0xFF6F240A), const Color(0xFFD27A4D), open, 0.38);
    _door(canvas, _rightOrange, 319, 12, 22, const Color(0xFF6F240A), const Color(0xFFD27A4D), open, 0.44);
  }

  void _door(
    Canvas canvas,
    _Capsule c,
    double x,
    double w,
    double h,
    Color inside,
    Color frame,
    double open,
    double start,
  ) {
    final breathe = wave(_sec, 6 + c.left / 100) * 1.2;
    final bottom = c.seam + breathe;
    final width = w * open;
    final rect = Rect.fromLTWH(x + (w - width) / 2, bottom - h, width, h);
    canvas.drawRect(rect.inflate(1.4), Paint()..color = frame);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
          inside,
          Color.lerp(inside, const Color(0xFF000000), 0.3)!,
        ]),
    );
    final light = 0.5 + 0.5 * wave(_sec, 3.4, x / 100);
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, rect.width, 3),
      Paint()..color = const Color(0xFFFFE9B8).withValues(alpha: 0.18 * light * open),
    );
  }

  void _ladders(Canvas canvas) {
    final extend = window(_t, 0.72, 0.9, Curves.easeOutCubic);
    if (extend <= 0) return;
    _ladder(canvas, const Offset(138, 562), const Offset(160, 452), extend);
    _ladder(canvas, const Offset(374, 530), const Offset(331, 436), extend);
  }

  void _ladder(Canvas canvas, Offset foot, Offset top, double extend) {
    final end = Offset.lerp(foot, top, extend)!;
    final along = end - foot;
    final length = along.distance;
    if (length < 1) return;
    final dir = along / length;
    final normal = Offset(-dir.dy, dir.dx) * 3.6;
    final rail = Paint()
      ..color = const Color(0xFFE4EEED)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(foot - normal, end - normal, rail);
    canvas.drawLine(foot + normal, end + normal, rail);
    final rung = Paint()
      ..color = const Color(0xCCE4EEED)
      ..strokeWidth = 1;
    for (var d = 4.0; d < length; d += 6.5) {
      final p = foot + dir * d;
      canvas.drawLine(p - normal, p + normal, rung);
    }
  }

  void _ground(Canvas canvas) {
    final rise = (1 - window(_t, 0, 0.4, Curves.easeOutCubic)) * 70;
    canvas.save();
    canvas.translate(0, rise);
    final back = Path()
      ..moveTo(-400, 522)
      ..lineTo(-20, 522)
      ..cubicTo(70, 500, 150, 522, 232, 536)
      ..cubicTo(300, 546, 338, 506, 410, 502)
      ..lineTo(800, 502)
      ..lineTo(800, 640)
      ..lineTo(-400, 640)
      ..close();
    canvas.drawPath(
      back,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(0, 500), const Offset(0, 580), const [
          Color(0xFF3B7C76),
          Color(0xFF235C58),
        ]),
    );
    final front = Path()
      ..moveTo(-400, 552)
      ..lineTo(-20, 552)
      ..cubicTo(110, 530, 250, 556, 410, 540)
      ..lineTo(800, 540)
      ..lineTo(800, 640)
      ..lineTo(-400, 640)
      ..close();
    canvas.drawPath(
      front,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(0, 535), const Offset(0, 600), const [
          Color(0xFF215A57),
          Color(0xFF164446),
        ]),
    );
    canvas.restore();
  }

  void _truck(Canvas canvas) {
    final drive = window(_t, 0.56, 0.88, Curves.easeOutCubic);
    if (drive <= 0) return;
    final x = 222 + (1 - drive) * 210;
    final bounce = math.sin(drive * math.pi * 7) * (1 - drive) * 1.6 + wave(_sec, 1.8) * 0.25;
    canvas.save();
    canvas.translate(x, 557);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(45, 1), width: 104, height: 7),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    final spin = (1 - drive) * 30;
    for (final wx in const [17.0, 70.0]) {
      canvas.drawCircle(Offset(wx, -5), 5.6, Paint()..color = const Color(0xFF172226));
      final hub = Offset(wx + math.cos(spin) * 1.2, -5 + math.sin(spin) * 1.2);
      canvas.drawCircle(hub, 1.9, Paint()..color = const Color(0xFF8C9B9D));
    }

    canvas.translate(0, bounce);
    final cab = RRect.fromRectAndCorners(
      const Rect.fromLTWH(0, -31, 27, 24),
      topLeft: const Radius.circular(7),
      bottomLeft: const Radius.circular(2),
    );
    canvas.drawRRect(
      cab,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(0, -31), const Offset(0, -7), const [
          Color(0xFFEE5B3A),
          Color(0xFFC23A1E),
        ]),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(const Rect.fromLTWH(3, -27.5, 13, 9), topLeft: const Radius.circular(4.5)),
      Paint()..color = const Color(0xFFBFE2E4),
    );
    final box = RRect.fromRectAndRadius(const Rect.fromLTWH(25, -35, 66, 28), const Radius.circular(1.5));
    canvas.drawRRect(
      box,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(0, -35), const Offset(0, -7), const [
          Color(0xFFE24B2C),
          Color(0xFFAF321A),
        ]),
    );
    canvas.drawRect(const Rect.fromLTWH(72, -31, 17, 19), Paint()..color = const Color(0xFFA9B6B5));
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(Rect.fromLTWH(74, -28.5 + i * 5.6, 13, 1.4), Paint()..color = const Color(0xFF7C8B8B));
    }
    canvas.drawRect(const Rect.fromLTWH(25, -16, 47, 1.6), Paint()..color = const Color(0xCCFFFFFF));
    canvas.drawRect(const Rect.fromLTWH(-1, -9, 93, 2.6), Paint()..color = const Color(0xFF3A2B28));

    if (drive >= 1) {
      final blink = (_sec * 1.6) % 1 < 0.5;
      final beacon = blink ? const Color(0xFFFF6B4A) : const Color(0xFFFFF4D6);
      canvas.drawCircle(
        const Offset(11, -33),
        6,
        Paint()
          ..color = beacon.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(7, -34.5, 8, 3.5), const Radius.circular(1.5)),
        Paint()..color = beacon,
      );
    }

    final raise = window(_t, 0.84, 1, Curves.easeOutBack);
    final angle = raise * 0.8 + (drive >= 1 ? wave(_sec, 7) * 0.025 : 0);
    canvas.save();
    canvas.translate(80, -36);
    canvas.drawRect(const Rect.fromLTWH(-6, -3, 12, 4), Paint()..color = const Color(0xFF8C9B9D));
    canvas.rotate(angle);
    final reach = 58 + raise * 36;
    final rail = Paint()
      ..color = const Color(0xFFD9E2E1)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final shade = Paint()
      ..color = const Color(0xFF9FB0B0)
      ..strokeWidth = 0.9;
    canvas.drawLine(Offset.zero, Offset(-reach, 0), rail);
    canvas.drawLine(const Offset(0, -7), Offset(-reach, -7), rail);
    var flip = false;
    for (var d = 0.0; d < reach - 6; d += 6) {
      canvas.drawLine(Offset(-d, flip ? 0 : -7), Offset(-d - 6, flip ? -7 : 0), shade);
      flip = !flip;
    }
    canvas.restore();
    canvas.restore();
  }

  void _people(Canvas canvas) {
    const ground = [
      (118.0, 548.0, 0.0),
      (156.0, 560.0, 0.6),
      (210.0, 552.0, 1.1),
      (386.0, 543.0, 1.7),
      (262.0, 562.0, 2.2),
    ];
    for (var i = 0; i < ground.length; i++) {
      final (x, y, phase) = ground[i];
      final pop = window(_t, 0.7 + i * 0.03, 0.86 + i * 0.03, Curves.easeOutBack);
      _person(canvas, Offset(x, y + wave(_sec, 1.1, phase) * 0.5), 11, pop);
    }
    final open = window(_t, 0.76, 0.9, Curves.easeOutBack);
    for (final (capsule, x) in [(_center, 224.0), (_leftOrange, 158.5), (_rightOrange, 325.0)]) {
      final breathe = wave(_sec, 6 + capsule.left / 100) * 1.2;
      _person(canvas, Offset(x, capsule.seam - 1 + breathe), 10, open);
    }
    if (_t >= 1) {
      final climb = (_sec / 8) % 1;
      final up = climb < 0.5 ? climb * 2 : 2 - climb * 2;
      final eased = Curves.easeInOut.transform(up);
      final p = Offset.lerp(const Offset(138, 560), const Offset(157, 468), eased)!;
      _person(canvas, p + Offset(0, math.sin(_sec * 9).abs() * -0.8), 9.5, 1);
      final walk = (_sec / 14) % 1;
      final there = walk < 0.5 ? walk * 2 : 2 - walk * 2;
      final wx = lerp(18, 84, Curves.easeInOut.transform(there));
      _person(canvas, Offset(wx, 554 + math.sin(_sec * 10).abs() * -0.6), 10, 1);
    }
  }

  void _person(Canvas canvas, Offset feet, double height, double pop) {
    if (pop <= 0) return;
    canvas.save();
    canvas.translate(feet.dx, feet.dy);
    canvas.scale(pop);
    final h = height;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 0.5), width: h * 0.7, height: 2),
      Paint()..color = const Color(0x44000000),
    );
    final coat = Path()
      ..moveTo(-h * 0.24, 0)
      ..lineTo(-h * 0.17, -h * 0.66)
      ..quadraticBezierTo(0, -h * 0.76, h * 0.17, -h * 0.66)
      ..lineTo(h * 0.24, 0)
      ..close();
    canvas.drawPath(
      coat,
      Paint()
        ..shader = ui.Gradient.linear(Offset(-h * 0.24, 0), Offset(h * 0.24, 0), const [
          Color(0xFFF4F8F7),
          Color(0xFFB9CBCA),
        ]),
    );
    canvas.drawCircle(Offset(0, -h * 0.84), h * 0.15, Paint()..color = const Color(0xFFE8C4A8));
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, -h * 0.86), radius: h * 0.15),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF2C3436),
    );
    canvas.restore();
  }

  void _motes(Canvas canvas) {
    if (_t < 0.5) return;
    final show = window(_t, 0.5, 1);
    for (var i = 0; i < 16; i++) {
      final seed = math.sin(i * 91.7) * 43758.5453;
      final r = seed - seed.floorToDouble();
      final speed = 9 + r * 14;
      final travel = (_sec * speed + r * 600) % 520;
      final y = 540 - travel;
      final x = (r * 997) % 390 + math.sin(_sec * 0.6 + i) * 8;
      final fade = math.sin(travel / 520 * math.pi);
      canvas.drawCircle(
        Offset(x, y),
        0.8 + r * 1.6,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.32 * fade * show),
      );
    }
  }

  void _fade(Canvas canvas, Size size, double unit) {
    final top = size.height - 30 * unit;
    canvas.drawRect(
      Rect.fromLTRB(0, top, size.width, size.height + 1),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, top),
          Offset(0, size.height),
          const [Color(0x00154044), Color(0xB3154044), Color(0xFF154044)],
          const [0, 0.55, 1],
        ),
    );
  }

  void _grain(Canvas canvas, Size size) {
    final program = Shaders.grain;
    if (program == null) return;
    final shader = (_grainShader ??= program.fragmentShader())
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, 7)
      ..setFloat(3, 0.085);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..blendMode = BlendMode.overlay,
    );
  }

  @override
  bool shouldRepaint(PillCityPainter oldDelegate) => false;
}

class _Capsule {
  const _Capsule({
    required this.left,
    required this.width,
    required this.top,
    required this.seam,
    required this.bottom,
    required this.cap,
    required this.body,
  });

  final double left;
  final double width;
  final double top;
  final double seam;
  final double bottom;
  final List<Color> cap;
  final List<Color> body;
}
