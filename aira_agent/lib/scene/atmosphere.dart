import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

class Shade {
  const Shade(this.box, this.sigma, this.color, {this.radius = 64});

  final Rect box;
  final double sigma;
  final Color color;
  final double radius;

  static Shade lerp(Shade a, Shade b, double t) {
    return Shade(
      Rect.lerp(a.box, b.box, t)!,
      ui.lerpDouble(a.sigma, b.sigma, t)!,
      Color.lerp(a.color, b.color, t)!,
      radius: ui.lerpDouble(a.radius, b.radius, t)!,
    );
  }
}

class Atmosphere {
  const Atmosphere({required this.sky, required this.core, required this.halo});

  final List<Color> sky;
  final Shade core;
  final Shade halo;

  static Atmosphere lerp(Atmosphere a, Atmosphere b, double t) {
    if (t <= 0) return a;
    if (t >= 1) return b;
    return Atmosphere(
      sky: [for (var i = 0; i < a.sky.length; i++) Color.lerp(a.sky[i], b.sky[i], t)!],
      core: Shade.lerp(a.core, b.core, t),
      halo: Shade.lerp(a.halo, b.halo, t),
    );
  }

  static List<Color> _hex(String codes) {
    return [for (final code in codes.split(' ')) Color(int.parse('FF$code', radix: 16))];
  }

  static final home = Atmosphere(
    sky: _hex(
      'D96C09 DA6D03 DA6C03 D96C02 DA6C02 DA6C02 D76602 D25801 C74401 B73501 A72B01 '
      '9B2501 972201 962301 8C1500 831300 7C1400 7A1F01 7B2201 7C2501 7E2601',
    ),
    core: const Shade(Rect.fromLTRB(0.089, 0.455, 0.9, 1.17), 26, Color(0xFF420000), radius: 70),
    halo: const Shade(Rect.fromLTRB(0.22, 0.3, 0.78, 0.5), 60, Color(0x59900000), radius: 120),
  );

  static final voice = Atmosphere(
    sky: _hex(
      'E87209 E26C03 E76702 E15602 D94702 CC3C02 BB3402 A72D02 922702 832301 792102 '
      '772002 761F02 771F02 751F01 7A2102 7D2402 812802 892E03 903103 933203',
    ),
    core: const Shade(Rect.fromLTRB(0.1, 0.339, 0.94, 0.995), 17, Color(0xFF000000), radius: 90),
    halo: const Shade(Rect.fromLTRB(0.08, 0.2, 0.92, 0.5), 60, Color(0xD9900000), radius: 120),
  );

  static final chat = Atmosphere(
    sky: _hex(
      'DC5908 D55501 C43E00 AD3100 992B00 8D2800 872700 872700 872700 872700 872700 '
      '872700 872700 882700 882700 882700 882700 882700 892800 943101 963201',
    ),
    core: const Shade(Rect.fromLTRB(0.075, 0.13, 0.925, 0.985), 16, Color(0xFF000000), radius: 70),
    halo: const Shade(Rect.fromLTRB(0.14, -0.1, 0.86, 1.0), 40, Color(0xD9900000), radius: 120),
  );

  static final dawn = Atmosphere(
    sky: home.sky,
    core: const Shade(Rect.fromLTRB(0.3, 0.9, 0.7, 1.3), 40, Color(0x00470000), radius: 70),
    halo: home.halo,
  );
}

class AtmospherePainter extends CustomPainter {
  AtmospherePainter(this.atmosphere, {this.breath = 0, super.repaint});

  final Atmosphere atmosphere;
  final double breath;

  static final List<double> _stops = [for (var i = 0; i <= 20; i++) i / 20];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          atmosphere.sky,
          _stops,
        ),
    );
    _shade(canvas, size, atmosphere.halo, 0);
    _shade(canvas, size, atmosphere.core, breath);
  }

  void _shade(Canvas canvas, Size size, Shade shade, double grow) {
    if (shade.color.a <= 0.001) return;
    final box = Rect.fromLTRB(
      shade.box.left * size.width,
      shade.box.top * size.height,
      shade.box.right * size.width,
      shade.box.bottom * size.height,
    ).inflate(grow);
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, Radius.circular(shade.radius)),
      Paint()
        ..color = shade.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shade.sigma),
    );
  }

  @override
  bool shouldRepaint(AtmospherePainter oldDelegate) {
    return !identical(oldDelegate.atmosphere, atmosphere) || oldDelegate.breath != breath;
  }
}

class Grain extends StatefulWidget {
  const Grain({super.key, this.opacity = 1});

  final double opacity;

  @override
  State<Grain> createState() => _GrainState();
}

class _GrainState extends State<Grain> {
  static ui.Image? _cache;
  static Future<ui.Image>? _pending;

  @override
  void initState() {
    super.initState();
    if (_cache == null) {
      _pending ??= _build();
      _pending!.then((image) {
        _cache = image;
        if (mounted) setState(() {});
      });
    }
  }

  static Future<ui.Image> _build() {
    const side = 128;
    final random = math.Random(7);
    final pixels = Uint8List(side * side * 4);
    for (var i = 0; i < side * side; i++) {
      final light = random.nextBool();
      final a = (random.nextDouble() * random.nextDouble() * 34).round();
      final v = light ? 255 : 0;
      pixels[i * 4] = (v * a / 255).round();
      pixels[i * 4 + 1] = (v * a / 255).round();
      pixels[i * 4 + 2] = (v * a / 255).round();
      pixels[i * 4 + 3] = a;
    }
    final done = Completer<ui.Image>();
    ui.decodeImageFromPixels(pixels, side, side, ui.PixelFormat.rgba8888, done.complete);
    return done.future;
  }

  @override
  Widget build(BuildContext context) {
    final image = _cache;
    if (image == null) return const SizedBox.expand();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(size: Size.infinite, painter: _GrainPainter(image, widget.opacity)),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter(this.image, this.opacity);

  final ui.Image image;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = Matrix4.diagonal3Values(0.5, 0.5, 1).storage;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Color.fromRGBO(0, 0, 0, opacity)
        ..shader = ImageShader(image, TileMode.repeated, TileMode.repeated, matrix),
    );
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) => oldDelegate.image != image || oldDelegate.opacity != opacity;
}
