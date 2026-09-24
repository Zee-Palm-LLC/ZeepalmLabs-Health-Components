import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/assets.dart';
import '../../core/canvas.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import 'wordmark.dart';
import '../../core/phosphor.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinish});

  final ValueChanged<Offset> onFinish;

  static const pinCenter = Offset(226.4, 99.6);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _sheen;
  late final AnimationController _tiltBack;
  late final AnimationController _hold;
  late final Clock _clock;
  Offset _tilt = Offset.zero;
  Offset _tiltFrom = Offset.zero;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2900));
    _sheen = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _tiltBack = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..addListener(() => setState(() => _tilt = _tiltFrom * (1 - Curves.elasticOut.transform(_tiltBack.value))));
    _hold = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _leave();
      });
    _clock = Clock(this);
    _intro.forward().whenComplete(() {
      if (!mounted) return;
      _sheen.forward(from: 0);
      _hold.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _sheen.dispose();
    _tiltBack.dispose();
    _hold.dispose();
    _clock.dispose();
    super.dispose();
  }

  void _leave() {
    if (_left || !mounted) return;
    _left = true;
    final scope = CanvasScope.of(context);
    widget.onFinish(SplashScreen.pinCenter.translate(0, scope.lift));
  }

  void _drag(DragUpdateDetails d) {
    _tiltBack.stop();
    setState(() {
      final next = _tilt + d.delta / 90;
      _tilt = Offset(next.dx.clamp(-1.0, 1.0), next.dy.clamp(-1.0, 1.0));
    });
  }

  void _release() {
    _tiltFrom = _tilt;
    _tiltBack.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final scope = CanvasScope.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_intro.value > 0.7) _leave();
        },
        onPanUpdate: _drag,
        onPanEnd: (_) => _release(),
        onPanCancel: _release,
        child: ColoredBox(
          color: const Color(0xFF6FA6E8),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: Plate(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_intro, _clock]),
                    builder: (context, _) => _Scenery(t: _intro.value, seconds: _clock.seconds, tilt: _tilt),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: scope.fromTop(320),
                child: AnimatedBuilder(
                  animation: _intro,
                  builder: (context, _) {
                    final dawn = 1 - span(_intro.value, 0.0, 0.55, Curves.easeOut);
                    return IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.55 * dawn),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 126,
                top: scope.fromTop(76),
                width: 130,
                height: 100,
                child: _Logo(intro: _intro, tilt: _tilt),
              ),
              Positioned(
                left: 79.2,
                top: scope.fromTop(222.5) - baselineOffset(font(47.5, 800)),
                child: Transform.translate(
                  offset: _tilt * -3,
                  child: Wordmark(rise: CurvedAnimation(parent: _intro, curve: const Interval(0.42, 0.86)), sheen: _sheen),
                ),
              ),
              _Tagline(intro: _intro, lift: scope.lift),
              _Pillars(intro: _intro, clock: _clock, drop: scope.drop),
            ],
          ),
        ),
      ),
    );
  }
}

class _Scenery extends StatelessWidget {
  const _Scenery({required this.t, required this.seconds, required this.tilt});

  final double t;
  final double seconds;
  final Offset tilt;

  @override
  Widget build(BuildContext context) {
    final dolly = span(t, 0.0, 0.78, const Cubic(0.18, 0.84, 0.26, 1.0));
    final settled = span(t, 0.8, 1.0, Curves.easeInOut);
    final drift = wave(seconds, 16) * 1.4 * settled;
    final reach = tilt.distance.clamp(0.0, 1.0);
    final backScale = lerp(1.16, 1.0, dolly) + 0.006 * settled + 0.028 * reach;
    final hikerScale = lerp(1.34, 1.0, dolly);
    final hikerRise = lerp(70, 0, dolly);
    final stride = wave(seconds, 1.15) * 0.6 * settled;
    return Stack(
      children: [
        Positioned.fill(
          child: Transform(
            alignment: const Alignment(0, -0.1),
            transform: Matrix4.identity()
              ..translateByDouble(drift - tilt.dx * 5, -tilt.dy * 4, 0, 1)
              ..scaleByDouble(backScale, backScale, 1, 1),
            child: Image.asset(Assets.splashBackdrop, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
          ),
        ),
        Positioned(
          left: 72,
          top: 336,
          width: 140,
          height: 406,
          child: Transform(
            alignment: const Alignment(0, 0.96),
            transform: Matrix4.identity()
              ..translateByDouble(tilt.dx * 4, hikerRise + stride - tilt.dy * 2, 0, 1)
              ..scaleByDouble(hikerScale, hikerScale, 1, 1),
            child: Image.asset(Assets.splashHiker, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.intro, required this.tilt});

  final Animation<double> intro;
  final Offset tilt;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: intro,
      builder: (context, _) {
        final t = intro.value;
        final ridge = spring(span(t, 0.16, 0.42, Curves.linear), bounce: 0.2, freq: 2.2);
        final peak = spring(span(t, 0.2, 0.48, Curves.linear), bounce: 0.24, freq: 2.2);
        final fall = span(t, 0.3, 0.43, gravity);
        final land = span(t, 0.43, 0.66, Curves.linear);
        final squash = land == 0 ? 0.0 : math.sin(land * math.pi * 2.4) * math.exp(-4.6 * land);
        final pinY = lerp(-150, 0, fall);
        final ripple = span(t, 0.43, 0.72, Curves.easeOut);
        return Transform.translate(
          offset: tilt * -6,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipRect(
                  clipper: const _GroundClip(),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(0, (1 - ridge) * 62),
                          child: Image.asset(Assets.logoRidge, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
                        ),
                      ),
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(0, (1 - peak) * 88),
                          child: Image.asset(Assets.logoPeak, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (ripple > 0 && ripple < 1)
                Positioned(
                  left: 100.4 - 34 * ripple,
                  top: 46 - 9 * ripple,
                  width: 68 * ripple,
                  height: 18 * ripple,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: const BorderRadius.all(Radius.elliptical(34, 9)),
                      border: Border.all(color: Palette.wordGreenB.withValues(alpha: 0.85 * (1 - ripple)), width: 1.6),
                    ),
                  ),
                ),
              Positioned.fill(
                child: Opacity(
                  opacity: span(t, 0.3, 0.34, Curves.linear),
                  child: Transform(
                    alignment: const Alignment(0.543, -0.07),
                    transform: Matrix4.identity()
                      ..translateByDouble(0, pinY, 0, 1)
                      ..scaleByDouble(1 + squash * 0.16, 1 - squash * 0.2, 1, 1),
                    child: Image.asset(Assets.logoPin, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GroundClip extends CustomClipper<Rect> {
  const _GroundClip();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(-20, -60, size.width + 20, 95.5);

  @override
  bool shouldReclip(_GroundClip oldClipper) => false;
}

class _Tagline extends StatelessWidget {
  const _Tagline({required this.intro, required this.lift});

  final Animation<double> intro;
  final double lift;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: intro,
      builder: (context, _) {
        final lines = [('Turn your city', 260.4), ('into your gym', 285.3)];
        return Stack(
          children: [
            for (var i = 0; i < lines.length; i++)
              () {
                final t = span(intro.value, 0.62 + i * 0.07, 0.95 + i * 0.05, swift);
                final style = font(21.3, 500, color: const Color(0xFF17354E));
                final base = lines[i].$2 + lift;
                return Positioned(
                  left: 0,
                  right: 0,
                  top: base - 24,
                  height: 31,
                  child: ClipRect(
                    child: Stack(
                      children: [
                        Label.centered(
                          lines[i].$1,
                          cx: 196.1,
                          base: 24 + (1 - t) * 28,
                          span: 320,
                          style: style.copyWith(color: style.color!.withValues(alpha: t.clamp(0.0, 1.0))),
                        ),
                      ],
                    ),
                  ),
                );
              }(),
          ],
        );
      },
    );
  }
}

class _Pillars extends StatelessWidget {
  const _Pillars({required this.intro, required this.clock, required this.drop});

  final Animation<double> intro;
  final Clock clock;
  final double drop;

  static const _items = [
    (PhosphorFill.personSimpleRun, 'Explore', 93.5),
    (PhosphorFill.mapPin, 'Move', 195.8),
    (PhosphorFill.heart, 'Feel Better', 296.8),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([intro, clock]),
      builder: (context, _) {
        final t = intro.value;
        final seconds = clock.seconds;
        final shadow = [Shadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 1))];
        return Stack(
          children: [
            for (final x in const [144.6, 246.3])
              Positioned(
                left: x - 0.6,
                top: 766 + drop + 14 * (1 - span(t, 0.8, 1.0)),
                width: 1.2,
                height: 28 * span(t, 0.8, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withValues(alpha: 0.0), Colors.white.withValues(alpha: 0.42), Colors.white.withValues(alpha: 0.0)],
                    ),
                  ),
                ),
              ),
            for (var i = 0; i < _items.length; i++)
              () {
                final item = _items[i];
                final local = span(t, 0.66 + i * 0.07, 0.98, Curves.linear);
                final pop = spring(local, bounce: 0.4, freq: 2.6);
                final idle = t < 1 ? 0.0 : 1.0;
                final beat = i == 2 ? _heartbeat(seconds) * idle : 0.0;
                final bob = i == 1 ? (wave(seconds, 1.6) * 1.4) * idle : 0.0;
                final run = i == 0 ? wave(seconds, 0.9) * 0.05 * idle : 0.0;
                return Stack(
                  children: [
                    Positioned(
                      left: item.$3 - 16,
                      top: 753.8 + drop + bob,
                      width: 32,
                      height: 32,
                      child: Opacity(
                        opacity: local.clamp(0.0, 1.0),
                        child: Transform.rotate(
                          angle: (1 - pop) * -0.6 + run,
                          child: Transform.scale(
                            scale: pop * (1 + beat * 0.16),
                            child: Icon(item.$1, size: 23, color: i == 2 ? const Color(0xFFE9EDF2) : Colors.white, shadows: shadow),
                          ),
                        ),
                      ),
                    ),
                    Label.centered(
                      item.$2,
                      cx: item.$3,
                      base: 799.7 + drop + (1 - span(local, 0.2, 1)) * 10,
                      span: 120,
                      style: font(13.2, 600, color: Colors.white.withValues(alpha: span(local, 0.2, 1).clamp(0.0, 1.0)), shadows: shadow),
                    ),
                  ],
                );
              }(),
          ],
        );
      },
    );
  }

  static double _heartbeat(double seconds) {
    final p = (seconds % 1.4) / 1.4;
    double pulse(double at) {
      final d = (p - at) / 0.07;
      return math.exp(-d * d);
    }

    return pulse(0.1) + 0.7 * pulse(0.28);
  }
}
