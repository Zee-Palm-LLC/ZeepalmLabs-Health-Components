import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/art.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/fx.dart';
import '../widgets/model3d.dart';
import '../widgets/planet_spin.dart';

enum Hub { moon, sprout, heart, star }

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key, required this.onOpen});

  final ValueChanged<Hub> onOpen;

  @override
  State<WorldScreen> createState() => WorldScreenState();
}

class WorldScreenState extends State<WorldScreen>
    with TickerProviderStateMixin {
  static const tips = [
    ('Walk 800 more steps', 'to grow a new forest!'),
    ('Nice! A new forest', 'is sprouting up north.'),
    ('Drink 3 more glasses', 'to fill the ocean!'),
  ];

  late final AnimationController _intro;
  late final AnimationController _bubble;
  late final AnimationController _grow;
  late final AnimationController _night;
  final _planet = GlobalKey<PlanetSpinState>();
  int _tip = 0;
  int _steps = 7420;
  double _spin = 0;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
    _bubble = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      value: 0,
    );
    _grow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _night = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _bubble.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _bubble.dispose();
    _grow.dispose();
    _night.dispose();
    super.dispose();
  }

  void tap(Hub hub) {
    HapticFeedback.lightImpact();
    switch (hub) {
      case Hub.sprout:
        setState(() {
          _tip = (_tip + 1) % tips.length;
          _steps += 800;
        });
        _bubble.forward(from: 0);
        _grow.forward(from: 0);
        _planet.currentState?.nudge(6.3);
      case Hub.moon:
        _night.status == AnimationStatus.forward || _night.value > 0.5
            ? _night.reverse()
            : _night.forward();
      case Hub.heart:
      case Hub.star:
        widget.onOpen(hub);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tone.space,
      body: AnimatedBuilder(
        animation: Listenable.merge([_intro, _bubble, _grow, _night]),
        builder: (context, _) {
          final i = _intro.value;
          final n = Curves.easeInOut.transform(_night.value);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Plate('world'),
              IgnorePointer(
                child: Opacity(
                  opacity: n * 0.62,
                  child: const ColoredBox(
                    color: Color(0xFF14104A),
                    child: SizedBox.expand(),
                  ),
                ),
              ),
              Sparkles(
                area: const Rect.fromLTRB(10, 140, 392, 700),
                count: 18 + (n * 30).round(),
                seed: 8,
                opacity: 0.45 + 0.55 * n,
              ),
              _pills(i),
              _buddy(i),
              _speech(i),
              _planetLayer(i),
              _nav(i),
              Burst(
                t: _grow.value,
                center: const Offset(150, 360),
                color: const Color(0xFFB8FF8A),
                radius: 120,
                count: 26,
                seed: 4,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _pills(double i) {
    Widget pill(
      int k,
      Sprite icon,
      double left,
      double right,
      String label,
      Widget value,
      Color rim,
    ) {
      final t = span(i, 0.05 + k * 0.08, 0.45 + k * 0.08, Curves.linear);
      final s = spring(t, bounce: 0.35, freq: 2);
      const cy = 94.0;
      final r = icon.box.w / 2;
      return Positioned(
        left: left,
        top: cy - 34,
        width: right - left,
        height: 68,
        child: Opacity(
          opacity: span(t, 0, 0.3, Curves.linear),
          child: Transform.translate(
            offset: Offset(0, -30 * (1 - s)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 8,
                  right: 0,
                  top: 34 - 25,
                  height: 50,
                  child: GlassPill(
                    width: right - left - 8,
                    height: 50,
                    rim: rim,
                  ),
                ),
                Positioned(
                  left: icon.box.center.dx - left - r,
                  top: 34 - r,
                  width: r * 2,
                  height: r * 2,
                  child: icon.image(),
                ),
                Positioned(
                  left: icon.box.r - left + 10,
                  top: 34 - 9.5 - 13.3 * balooAscent,
                  child: Label(
                    label,
                    style: baloo(13.3, color: const Color(0xFFE8E6FF)),
                  ),
                ),
                Positioned(
                  left: icon.box.r - left + 10,
                  top: 34 + 15.1 - 21.6 * balooAscent,
                  child: value,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final count = span(i, 0.15, 0.75, Curves.linear);
    final valueStyle = baloo(21.6, weight: 800);
    return Stack(
      children: [
        pill(
          0,
          Art.steps,
          15,
          139,
          'Steps',
          CountUp(value: _steps, t: count, style: valueStyle),
          const Color(0xFF8BE36A),
        ),
        pill(
          1,
          Art.water,
          155,
          262,
          'Water',
          Label('${(5 * count).round()}/8', style: valueStyle),
          const Color(0xFFB79BFF),
        ),
        pill(
          2,
          Art.energy,
          278,
          388,
          'Energy',
          CountUp(value: 82, t: count, style: valueStyle, grouped: false),
          const Color(0xFFFFC66A),
        ),
      ],
    );
  }

  Widget _buddy(double i) {
    final t = span(i, 0.2, 0.6, Curves.linear);
    final s = spring(t, bounce: 0.4, freq: 2);
    return Place(
      Art.buddy,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _bubble.forward(from: 0);
        },
        child: Opacity(
          opacity: span(t, 0, 0.3, Curves.linear),
          child: Transform.translate(
            offset: Offset(-60 * (1 - s), 0),
            child: Float(
              dy: 6,
              dx: 2,
              period: 2.4,
              tilt: 0.07,
              child: Art.buddy.image(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _speech(double i) {
    final b = _bubble.value;
    final s = spring(span(b, 0, 0.55, Curves.linear), bounce: 0.35, freq: 2.2);
    final type = span(b, 0.25, 1, Curves.linear);
    final lines = tips[_tip];
    final all = lines.$1.length + lines.$2.length;
    final shown = (all * type).round();
    final l1 = lines.$1.substring(0, math.min(shown, lines.$1.length));
    final l2 = shown > lines.$1.length
        ? lines.$2.substring(0, shown - lines.$1.length)
        : '';
    final style = baloo(15.6, color: const Color(0xFF2D2A7C));
    return Positioned(
      left: 100,
      top: 158,
      width: 210,
      height: 76,
      child: Opacity(
        opacity: span(b, 0, 0.2, Curves.linear),
        child: Transform.scale(
          scale: lerp(0.5, 1, s),
          alignment: Alignment.centerLeft,
          child: CustomPaint(
            painter: _BubblePainter(),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 189.1 - 158 - 15.6 * balooAscent,
                  child: Center(
                    child: _Ghost(text: lines.$1, shown: l1, style: style),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 208.8 - 158 - 15.6 * balooAscent,
                  child: Center(
                    child: _Ghost(text: lines.$2, shown: l2, style: style),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _planetLayer(double i) {
    final t = span(i, 0.0, 0.6, Curves.linear);
    final s = spring(t, bounce: 0.25, freq: 1.6);
    const c = PlanetSpin.center;
    return Positioned.fill(
      child: Opacity(
        opacity: span(t, 0, 0.25, Curves.linear),
        child: Transform(
          alignment: Alignment((c.dx / 402) * 2 - 1, (c.dy / 874) * 2 - 1),
          transform: Matrix4.identity()
            ..scaleByDouble(lerp(0.45, 1, s), lerp(0.45, 1, s), 1, 1),
          child: Tick(
            builder: (context, sec, child) => Transform.translate(
              offset: Offset(0, 4 * wave(sec, 4.2) * (1 - _spin)),
              child: child,
            ),
            child: Model3D(
              src: 'assets/models/planet.glb',
              viewport: Rect.fromCenter(center: c + const Offset(-4, -14), width: 440, height: 440),
              onReady: (controller) {
                controller.setCameraOrbit(0, 72, 100);
                controller.startRotation(rotationSpeed: 8);
              },
              fallback: Stack(
                children: [
                  Positioned.fill(
                    child: PlanetSpin(key: _planet, onSpin: (v) => _spin = v),
                  ),
                  IgnorePointer(child: _Smoke(opacity: 1 - _spin)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nav(double i) {
    final t = span(i, 0.35, 0.85, Curves.linear);
    final items = [
      (Art.navMoon, Hub.moon, 0.0),
      (Art.navSprout, Hub.sprout, 0.15),
      (Art.navHeart, Hub.heart, 0.45),
      (Art.navStar, Hub.star, 0.6),
    ];
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: span(t, 0, 0.5, Curves.linear),
              child: Tick(
                builder: (context, sec, _) =>
                    CustomPaint(painter: _OrbitPainter(sec)),
              ),
            ),
          ),
        ),
        Place(
          Art.navWorld,
          child: Opacity(
            opacity: span(t, 0, 0.3, Curves.linear),
            child: Transform.scale(
              scale: spring(t, bounce: 0.4, freq: 2),
              child: Tick(
                builder: (context, sec, child) => Transform.scale(
                  scale: 1 + 0.03 * wave(sec, 2.4),
                  child: child,
                ),
                child: Art.navWorld.image(),
              ),
            ),
          ),
        ),
        for (final (k, (sprite, hub, delay)) in items.indexed)
          Place(
            sprite,
            child: Pressable(
              onTap: () => tap(hub),
              scale: 0.85,
              child: Opacity(
                opacity: span(t, delay, delay + 0.3, Curves.linear),
                child: Transform.scale(
                  scale: spring(
                    span(t, delay, delay + 0.5, Curves.linear),
                    bounce: 0.45,
                    freq: 2.2,
                  ),
                  child: Float(
                    dy: 3,
                    period: 2.8,
                    phase: k * 0.2,
                    child: sprite.image(),
                  ),
                ),
              ),
            ),
          ),
        At(
          baseline: 835.7,
          size: 19.9,
          center: 198.4,
          child: Opacity(
            opacity: span(t, 0.4, 0.9, Curves.linear),
            child: Label(
              'Your World',
              style: baloo(19.9, color: const Color(0xFFF4F1FF)),
            ),
          ),
        ),
        for (final x in const [112.5, 265.0])
          Positioned(
            left: x,
            top: 834,
            child: Opacity(
              opacity: span(t, 0.5, 1, Curves.linear) * 0.8,
              child: Container(
                width: 19,
                height: 3.6,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4E9FF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Ghost extends StatelessWidget {
  const _Ghost({required this.text, required this.shown, required this.style});

  final String text;
  final String shown;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: shown),
          TextSpan(
            text: text.substring(shown.length),
            style: const TextStyle(color: Color(0x00000000)),
          ),
        ],
      ),
      maxLines: 1,
      softWrap: false,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 4, size.width - 10, size.height - 10),
      const Radius.circular(26),
    );
    final tail = Path()
      ..moveTo(14, size.height * 0.42)
      ..quadraticBezierTo(0, size.height * 0.62, 2, size.height * 0.74)
      ..quadraticBezierTo(14, size.height * 0.64, 24, size.height * 0.6)
      ..close();
    final path = Path()
      ..addRRect(body)
      ..addPath(tail, Offset.zero);
    canvas.drawPath(
      path.shift(const Offset(0, 4)),
      Paint()
        ..color = const Color(0x332A1F7A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFEFEAFF)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_BubblePainter old) => false;
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (rx, ry, rot, a) in const [
      (166.0, 40.0, -0.06, 0.55),
      (148.0, 30.0, 0.04, 0.4),
    ]) {
      canvas.save();
      canvas.translate(203, 768);
      canvas.rotate(rot);
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: rx * 2,
        height: ry * 2,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = const Color(0xFFE6D8FF).withValues(alpha: a * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = const Color(0xFFFFFFFF).withValues(alpha: a),
      );
      final ang = t * 0.6 + rx;
      final p = Offset(math.cos(ang) * rx, math.sin(ang) * ry);
      canvas.drawCircle(
        p,
        2.2,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
      canvas.drawCircle(
        p,
        6,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.t != t;
}

class _Smoke extends StatelessWidget {
  const _Smoke({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, t, _) =>
          CustomPaint(painter: _SmokePainter(t, opacity), size: Size.infinite),
    );
  }
}

class _SmokePainter extends CustomPainter {
  _SmokePainter(this.t, this.opacity);

  final double t;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.01) return;
    const vent = Offset(338, 268);
    for (var i = 0; i < 7; i++) {
      final life = ((t * 0.35 + i / 7) % 1.0);
      final p =
          vent + Offset(14 * life + 4 * math.sin(t * 1.3 + i), -48 * life);
      final r = 6 + 16 * life;
      canvas.drawCircle(
        p,
        r,
        Paint()
          ..color = const Color(
            0xFF8E7A8E,
          ).withValues(alpha: 0.32 * (1 - life) * opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + 6 * life),
      );
    }
    for (var i = 0; i < 6; i++) {
      final life = ((t * 0.8 + i / 6) % 1.0);
      final a = i * 1.1 + t * 0.2;
      final p =
          vent + Offset(math.cos(a) * 18 * life, -26 * life + 30 * life * life);
      canvas.drawCircle(
        p,
        1.8 * (1 - life) + 0.6,
        Paint()
          ..color = const Color(
            0xFFFFB24A,
          ).withValues(alpha: (1 - life) * opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_SmokePainter old) => old.t != t || old.opacity != opacity;
}
