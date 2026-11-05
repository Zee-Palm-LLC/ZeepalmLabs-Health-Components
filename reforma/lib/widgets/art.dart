import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../three/face.dart';
import '../three/figure.dart';
import '../three/figures.dart';
import '../three/renderer.dart';
import '../three/vec.dart';

/// Reforma sprout mark.
class LeafLogo extends StatelessWidget {
  const LeafLogo({super.key, this.size = 30, this.color = C.teal});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size * 1.1), painter: _LeafPainter(color));
}

class _LeafPainter extends CustomPainter {
  _LeafPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 30;
    canvas.scale(s);
    final fill = Paint()..color = color;
    final light = Paint()..color = Color.lerp(color, Colors.white, 0.28)!;
    Path leaf(Offset base, double angle, double len, double wid) {
      final p = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(wid, -len * 0.45, 0, -len)
        ..quadraticBezierTo(-wid, -len * 0.45, 0, 0)
        ..close();
      final m = Matrix4.identity()
        ..translateByDouble(base.dx, base.dy, 0, 1)
        ..rotateZ(angle);
      return p.transform(m.storage);
    }

    canvas.drawPath(leaf(const Offset(15, 22), 0, 20, 6.2), fill);
    canvas.drawPath(leaf(const Offset(14.2, 23), -0.95, 14, 5.2), light);
    canvas.drawPath(leaf(const Offset(15.8, 23), 0.95, 14, 5.2), light);
    canvas.drawPath(leaf(const Offset(14, 28), -1.75, 9, 3.6), fill);
    canvas.drawPath(leaf(const Offset(16, 28), 1.75, 9, 3.6), fill);
    canvas.drawLine(
      const Offset(15, 21),
      const Offset(15, 32),
      Paint()
        ..color = color
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_LeafPainter old) => old.color != color;
}

/// Little sun next to the greeting; rays turn slowly.
class SunPainter extends CustomPainter {
  SunPainter(this.spin) : super(repaint: spin);

  final Animation<double> spin;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.24;
    final ray = Paint()
      ..color = const Color(0xFFF6B73C)
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round;
    final a0 = spin.value * math.pi * 2 / 8;
    for (var i = 0; i < 8; i++) {
      final a = a0 + i * math.pi / 4;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + d * (r * 1.45), c + d * (r * 1.95), ray);
    }
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(colors: [Color(0xFFFFD45A), Color(0xFFF6A92D)])
            .createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(SunPainter old) => false;
}

// ---------------------------------------------------------------------------
// Soft sky art

void _cloud(Canvas canvas, Offset c, double w, double alpha, {double blur = 6}) {
  final p = Paint()
    ..color = Colors.white.withValues(alpha: alpha)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
  final h = w * 0.32;
  canvas.drawOval(Rect.fromCenter(center: c, width: w, height: h), p);
  canvas.drawCircle(c + Offset(-w * 0.18, -h * 0.35), h * 0.62, p);
  canvas.drawCircle(c + Offset(w * 0.12, -h * 0.5), h * 0.75, p);
  canvas.drawCircle(c + Offset(w * 0.32, -h * 0.12), h * 0.5, p);
}

/// Pastel sky with a misty peak, behind "Movement & recovery".
class SkyPainter extends CustomPainter {
  const SkyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1E9F6), Color(0xFFE9DDF4), Color(0xFFF2DDEC)],
        ).createShader(r),
    );
    final w = size.width, h = size.height;
    // distant ridge
    final far = Path()
      ..moveTo(0, h * 0.62)
      ..cubicTo(w * 0.2, h * 0.5, w * 0.32, h * 0.56, w * 0.45, h * 0.44)
      ..cubicTo(w * 0.55, h * 0.36, w * 0.62, h * 0.42, w * 0.7, h * 0.4)
      ..cubicTo(w * 0.82, h * 0.36, w * 0.92, h * 0.46, w, h * 0.42)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      far,
      Paint()
        ..color = const Color(0xFFDCCDEE).withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    // main peak
    final peak = Path()
      ..moveTo(w * 0.28, h * 0.78)
      ..lineTo(w * 0.47, h * 0.3)
      ..quadraticBezierTo(w * 0.535, h * 0.12, w * 0.6, h * 0.22)
      ..lineTo(w * 0.66, h * 0.3)
      ..lineTo(w * 0.7, h * 0.27)
      ..lineTo(w * 0.86, h * 0.6)
      ..lineTo(w * 0.95, h * 0.78)
      ..close();
    final pr = peak.getBounds();
    canvas.drawPath(
      peak,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFBF8FD), Color(0xFFE2D4F1), Color(0x00E8DAF2)],
          stops: [0, 0.55, 1],
        ).createShader(pr)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
    );
    // shadow face of the peak
    final shade = Path()
      ..moveTo(w * 0.535, h * 0.16)
      ..lineTo(w * 0.6, h * 0.22)
      ..lineTo(w * 0.66, h * 0.3)
      ..lineTo(w * 0.7, h * 0.27)
      ..lineTo(w * 0.86, h * 0.6)
      ..lineTo(w * 0.62, h * 0.7)
      ..close();
    canvas.drawPath(
      shade,
      Paint()
        ..color = const Color(0xFFCDB9E6).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // mist
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.55, w, h * 0.45),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.55)],
        ).createShader(Rect.fromLTWH(0, h * 0.55, w, h * 0.45)),
    );
  }

  @override
  bool shouldRepaint(SkyPainter old) => false;
}

/// Cloud bank that drifts in front of the peak (translated by the compositor).
class CloudPainter extends CustomPainter {
  const CloudPainter({this.dense = false});

  final bool dense;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    _cloud(canvas, Offset(w * 0.12, h * 0.66), w * 0.42, 0.75, blur: 7);
    _cloud(canvas, Offset(w * 0.55, h * 0.72), w * 0.5, 0.7, blur: 8);
    _cloud(canvas, Offset(w * 0.92, h * 0.6), w * 0.4, 0.65, blur: 7);
    _cloud(canvas, Offset(w * 0.35, h * 0.86), w * 0.6, 0.8, blur: 9);
    if (dense) _cloud(canvas, Offset(w * 0.8, h * 0.9), w * 0.5, 0.75, blur: 9);
  }

  @override
  bool shouldRepaint(CloudPainter old) => false;
}

/// Lavender sky behind the shoulder-mobility hero.
class HeroSkyPainter extends CustomPainter {
  const HeroSkyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDCCDF0), Color(0xFFCDB7EA), Color(0xFFE6CFEA), Color(0xFFF1E1EE)],
          stops: [0, 0.35, 0.72, 1],
        ).createShader(r),
    );
    final w = size.width, h = size.height;
    _cloud(canvas, Offset(w * 0.1, h * 0.3), w * 0.5, 0.45, blur: 14);
    _cloud(canvas, Offset(w * 0.55, h * 0.18), w * 0.45, 0.35, blur: 14);
    _cloud(canvas, Offset(w * 0.25, h * 0.62), w * 0.7, 0.55, blur: 16);
    _cloud(canvas, Offset(w * 0.75, h * 0.8), w * 0.8, 0.65, blur: 16);
    _cloud(canvas, Offset(w * 0.15, h * 0.95), w * 0.7, 0.75, blur: 14);
  }

  @override
  bool shouldRepaint(HeroSkyPainter old) => false;
}

// ---------------------------------------------------------------------------
// 3D-rendered "photos": thumbnails, avatar.

enum ThumbKind { glute, hip, wall, roll, band, avatar }

class ThumbArt extends StatelessWidget {
  const ThumbArt(this.kind, {super.key});

  /// Records every thumbnail up front so no screen builds a mesh mid-transition.
  static void prewarm() {
    for (final k in ThumbKind.values) {
      _ThumbPainter.picture(k);
    }
  }

  final ThumbKind kind;

  @override
  Widget build(BuildContext context) => RepaintBoundary(child: CustomPaint(painter: _ThumbPainter(kind)));
}

class _ThumbPainter extends CustomPainter {
  _ThumbPainter(this.kind);

  final ThumbKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.clipRect(r);
    // Studio backdrop.
    final bg = switch (kind) {
      ThumbKind.glute || ThumbKind.hip => const [Color(0xFFEFEDF1), Color(0xFFDCD8DF)],
      ThumbKind.wall => const [Color(0xFFDCCFEF), Color(0xFFEBDDF0)],
      ThumbKind.avatar => const [Color(0xFFE9E4DE), Color(0xFFD3CCC4)],
      _ => const [Color(0xFFE8E6EC), Color(0xFFD7D3DC)],
    };
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: bg).createShader(r),
    );
    if (kind == ThumbKind.glute || kind == ThumbKind.hip) {
      canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.72, size.width, size.height * 0.28),
        Paint()..color = const Color(0xFFCFCAD3),
      );
    }
    // Pictures are recorded once at a reference size and scaled (they are vectors).
    final ref = refSize(kind);
    canvas.scale(size.width / ref.width, size.height / ref.height);
    canvas.drawPicture(picture(kind));
  }

  static Size refSize(ThumbKind k) => switch (k) {
        ThumbKind.glute || ThumbKind.hip => const Size(169, 91),
        ThumbKind.avatar => const Size(66, 66),
        _ => const Size(79, 72),
      };

  static ui.Picture picture(ThumbKind k) => Figures.still(k.name, () => _render(k, refSize(k)));

  static ui.Picture _render(ThumbKind kind, Size size) {
    final box = Offset.zero & size;
    switch (kind) {
      case ThumbKind.glute:
        return renderStill(
          Figures.mesh('glute'),
          box: box,
          yaw: -0.32,
          pitch: 0.16,
          fill: 0.92,
          fitWidth: true,
          align: const Alignment(0, 0.9),
          under: (c, v) => _floorQuad(c, v, -82, 66, 30, const Color(0xFF9D93AE)),
          over: (c, v) => drawFace(c, v, Pose.gluteBridge),
        );
      case ThumbKind.hip:
        return renderStill(
          Figures.mesh('hip'),
          box: box,
          yaw: -0.34,
          pitch: 0.14,
          fill: 0.95,
          fitWidth: true,
          align: const Alignment(0.1, 0.9),
          under: (c, v) => _bench(c, v),
          over: (c, v) => drawFace(c, v, Pose.hipThrust),
        );
      case ThumbKind.wall:
        return renderStill(
          Figures.heroLow,
          box: box,
          yaw: 2.05,
          pitch: 0.05,
          frame: const [V3(0, 192, 0), V3(0, 70, 0)],
          fill: 0.98,
          under: (c, v) => _wall(c, v, box),
        );
      case ThumbKind.roll:
        return renderStill(
          Figures.mesh('roll'),
          box: box,
          yaw: 0.3,
          frame: const [V3(0, 172, 0), V3(0, 100, 0)],
          fill: 1.05,
          over: (c, v) => drawFace(c, v, Pose.standing),
        );
      case ThumbKind.band:
        return renderStill(
          Figures.mesh('band'),
          box: box,
          yaw: 0.42,
          pitch: 0.06,
          frame: const [V3(0, 172, 0), V3(0, 88, 0)],
          fill: 1.0,
          over: (c, v) {
            _band(c, v);
            drawFace(c, v, Pose.standing);
          },
        );
      case ThumbKind.avatar:
        return renderStill(
          Figures.mesh('man'),
          box: box,
          yaw: -0.22,
          pitch: -0.04,
          frame: const [V3(0, 171, 0), V3(0, 124, 0)],
          fill: 1.12,
          frameDx: 0.02,
          rim: const Color(0xFFFFFFFF),
          rimAmt: 0.25,
          over: (c, v) => drawFace(c, v, Pose.standing, male: true, hair: Palette.man.hair),
        );
    }
  }

  static void _floorQuad(Canvas c, BodyView v, double x0, double x1, double z, Color color) {
    final pts = [V3(x0, 0, -z), V3(x1, 0, -z), V3(x1, 0, z), V3(x0, 0, z)].map((p) => v.project(p).$1).toList();
    c.drawPath(Path()..addPolygon(pts, true), Paint()..color = color);
    // contact shadow
    final (o, _) = v.project(const V3(-10, 0, 0));
    c.drawOval(
      Rect.fromCenter(center: o, width: (pts[1] - pts[0]).distance * 0.8, height: 8),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  static void _bench(Canvas c, BodyView v) {
    const x0 = -48.0, x1 = -20.0, y0 = 0.0, y1 = 44.0, z = 26.0;
    Offset p(double x, double y, double zz) => v.project(V3(x, y, zz)).$1;
    final top = [p(x0, y1, -z), p(x1, y1, -z), p(x1, y1, z), p(x0, y1, z)];
    final front = [p(x0, y1, z), p(x1, y1, z), p(x1, y0, z), p(x0, y0, z)];
    final side = [p(x1, y1, -z), p(x1, y1, z), p(x1, y0, z), p(x1, y0, -z)];
    c.drawPath(Path()..addPolygon(side, true), Paint()..color = const Color(0xFF2E3138));
    c.drawPath(Path()..addPolygon(front, true), Paint()..color = const Color(0xFF3A3E46));
    c.drawPath(Path()..addPolygon(top, true), Paint()..color = const Color(0xFF4D525B));
  }

  static void _wall(Canvas c, BodyView v, Rect box) {
    final (a, _) = v.project(const V3(0, 150, 19.5));
    c.drawRect(
      Rect.fromLTRB(a.dx - 2, box.top, box.right, box.bottom),
      Paint()
        ..shader = const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF1EAF6)])
            .createShader(Rect.fromLTRB(a.dx, box.top, box.right, box.bottom)),
    );
  }

  static void _band(Canvas c, BodyView v) {
    final (l, _) = v.project(Pose.bandPull(0.75).armL[3] + const V3(-1, -1, 0));
    final (r, _) = v.project(Pose.bandPull(0.75).armR[3] + const V3(1, -1, 0));
    c.drawLine(
      l,
      r,
      Paint()
        ..color = const Color(0xFF5FA88A)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ThumbPainter old) => old.kind != kind;
}
