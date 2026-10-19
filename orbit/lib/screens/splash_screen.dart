import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/art.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/fx.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _hatch;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
    _hatch = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _hatch.dispose();
    super.dispose();
  }

  Future<void> start() async {
    if (_leaving) return;
    _leaving = true;
    HapticFeedback.mediumImpact();
    await _hatch.forward(from: 0).orCancel.catchError((_) {});
    widget.onStart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tone.space,
      body: AnimatedBuilder(
        animation: Listenable.merge([_intro, _hatch]),
        builder: (context, _) {
          final i = _intro.value;
          final h = _hatch.value;
          final eggT = span(i, 0.0, 0.55, Curves.linear);
          final eggS = spring(eggT, bounce: 0.3, freq: 1.8);
          final logoT = span(i, 0.15, 0.6, Curves.linear);
          final logoS = spring(logoT, bounce: 0.45, freq: 2.2);
          final sunT = span(i, 0.35, 0.75, Curves.linear);
          final tag = span(i, 0.5, 0.75);
          final btn = span(i, 0.62, 0.95, Curves.linear);
          final pop = math.sin(span(h, 0, 0.35, Curves.linear) * math.pi);
          final fade = span(h, 0.45, 1, Curves.easeIn);
          final eggC = Art.egg.box.center;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Plate('splash'),
              Sparkles(
                area: const Rect.fromLTRB(20, 60, 390, 720),
                count: 26,
                seed: 5,
                opacity: span(i, 0.1, 0.5),
              ),
              Place(
                Art.logo,
                child: Opacity(
                  opacity: span(logoT, 0, 0.3, Curves.linear) * (1 - fade),
                  child: Transform.translate(
                    offset: Offset(0, -70 * (1 - logoS)),
                    child: Transform.scale(
                      scale: lerp(0.6, 1, logoS),
                      child: Float(dy: 3, period: 3.6, child: Art.logo.image()),
                    ),
                  ),
                ),
              ),
              At(
                baseline: 259.8,
                size: 22.7,
                center: 201.6,
                child: Opacity(
                  opacity: tag * (1 - fade),
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - tag)),
                    child: Label(
                      'Move. Grow. Build your world.',
                      style: baloo(
                        22.7,
                        shadows: const [
                          Shadow(
                            color: Color(0x663A2A9A),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: eggC.dx - 150,
                top: eggC.dy - 150,
                width: 300,
                height: 300,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (0.55 + 0.45 * pop) * eggT,
                    child: Tick(
                      builder: (context, t, _) => DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFE6A0).withValues(
                                alpha: 0.42 + 0.1 * wave(t, 2.6) + 0.5 * pop,
                              ),
                              const Color(0x00FFE6A0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Place(
                Art.egg,
                child: GestureDetector(
                  onTap: start,
                  child: Opacity(
                    opacity: span(eggT, 0, 0.25, Curves.linear) * (1 - fade),
                    child: Transform.translate(
                      offset: Offset(0, 90 * (1 - eggS)),
                      child: Transform.scale(
                        scale:
                            lerp(0.7, 1, eggS) * (1 + 0.12 * pop + 0.5 * fade),
                        child: Float(
                          dy: 5,
                          period: 3.4,
                          tilt: 0.02,
                          child: Art.egg.image(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Place(
                Art.sun,
                child: Opacity(
                  opacity: span(sunT, 0, 0.3, Curves.linear) * (1 - fade),
                  child: Transform.translate(
                    offset: Offset(
                      80 * (1 - spring(sunT, bounce: 0.3, freq: 1.6)),
                      -40 * (1 - spring(sunT, bounce: 0.3, freq: 1.6)),
                    ),
                    child: Float(
                      dy: 7,
                      dx: 3,
                      period: 2.6,
                      phase: 0.3,
                      tilt: 0.08,
                      child: Art.sun.image(),
                    ),
                  ),
                ),
              ),
              Burst(
                t: span(h, 0.15, 0.95, Curves.linear),
                center: eggC,
                radius: 170,
                count: 30,
              ),
              Positioned(
                left: 52,
                top: 729,
                child: Opacity(
                  opacity: span(btn, 0, 0.3, Curves.linear) * (1 - fade),
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      40 * (1 - spring(btn, bounce: 0.3, freq: 1.8)),
                    ),
                    child: Tick(
                      builder: (context, t, child) => Transform.scale(
                        scale: 1 + 0.015 * wave(t, 2.2),
                        child: child,
                      ),
                      child: GoldButton(
                        width: 298,
                        height: 64,
                        size: 27,
                        label: 'Start my planet',
                        onTap: start,
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: Opacity(
                  opacity:
                      (math.sin(span(h, 0.35, 1, Curves.linear) * math.pi) *
                              0.85)
                          .clamp(0.0, 1.0),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, 0.13),
                        radius: 0.9,
                        colors: [
                          Color(0xFFFFF6D8),
                          Color(0xFFFFD27A),
                          Color(0x00FFD27A),
                        ],
                        stops: [0, 0.5, 1],
                      ),
                    ),
                    child: SizedBox.expand(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
