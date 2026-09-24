import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/canvas.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/sprites.dart';
import '../core/transitions.dart';
import '../core/type.dart';
import '../widgets/effects.dart';
import '../widgets/nav_bar.dart';
import '../widgets/neon.dart';
import '../widgets/parallax.dart';
import 'route_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _intro;
  final _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Animation<double> _phase(double a, double b, [Curve curve = Curves.linear]) => CurvedAnimation(
    parent: _intro,
    curve: Interval(a, b, curve: curve),
  );

  void _openQuest() {
    HapticFeedback.mediumImpact();
    final box = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    final from = box == null ? const Rect.fromLTWH(15, 561, 366, 190) : box.localToGlobal(Offset.zero) & box.size;
    Navigator.of(context).push(
      ExpandRoute(
        from: from,
        radius: 22 * (box == null ? 1 : box.size.width / 365.6),
        builder: (_) => const RouteScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Hue.night,
      body: DesignCanvas(
        child: TiltField(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SceneLayer(children: _scene()),
              _header(),
              _stats(),
              _level(),
              Floor(children: [_questCard(), _nav()]),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _scene() {
    final land = _phase(0.0, 0.5);
    return [
      Positioned.fill(
        child: AnimatedBuilder(
          animation: land,
          builder: (context, child) {
            final k = span(land.value, 0, 1, const Cubic(0.2, 0.8, 0.2, 1));
            return Transform.scale(scale: lerp(1.16, 1, k), alignment: const Alignment(-0.2, 0.2), child: child);
          },
          child: Depth(
            depth: -4,
            child: Image.asset(
              Scenes.map,
              fit: BoxFit.fill,
              width: 393,
              height: 852,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(child: _Energy(progress: _phase(0.4, 0.8))),
      ),
      Positioned.fill(
        child: Depth(depth: 2, child: _Pad(progress: _phase(0.25, 0.55))),
      ),
      Art.homeHero.place(
        child: Depth(depth: 2, child: Breathe(period: 3.8, amount: 0.01, bob: 0.0, child: Art.homeHero.image())),
      ),
      Motes(area: const Rect.fromLTWH(100, 380, 110, 140), seed: 21, count: 12, size: 1.8),
      _badge(Art.badgeGym, 0.36, 0.0),
      _badge(Art.badgePark, 0.44, 0.33),
      _badge(Art.badgeWater, 0.52, 0.66),
    ];
  }

  Widget _badge(Sprite sprite, double at, double phase) {
    final t = _phase(at, at + 0.3);
    return sprite.place(
      child: Depth(
        depth: 6,
        child: AnimatedBuilder(
          animation: t,
          child: Pressable(onTap: () => HapticFeedback.lightImpact(), scale: 0.86, child: sprite.image()),
          builder: (context, child) => Tick(
            builder: (context, s, _) {
              final k = t.value;
              final fall = span(k, 0, 0.42, const Cubic(0.55, 0, 1, 0.45));
              final land = span(k, 0.42, 1, Curves.linear);
              final squash = k < 0.42 ? 0.0 : math.sin(land * math.pi * 2.5) * math.exp(-4 * land) * 0.22;
              final hover = k >= 1 ? wave(s, 3.2, phase) * 2.0 : 0.0;
              final m = Matrix4.identity()
                ..translateByDouble(0, -(1 - fall) * 260 + hover, 0, 1)
                ..scaleByDouble(1 + squash, 1 - squash, 1, 1);
              return Opacity(
                opacity: span(k, 0, 0.1, Curves.linear),
                child: Transform(alignment: Alignment.bottomCenter, transform: m, child: child),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final t = _phase(0.08, 0.5);
    final hey = typo(17.85, weight: FontWeight.w700, color: const Color(0xFFF2FEFE));
    final keep = typo(15.05, weight: FontWeight.w500, color: const Color(0xFFD1ECFE));
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Art.avatar.place(
            child: AnimatedBuilder(
              animation: t,
              child: Art.avatar.image(),
              builder: (context, child) {
                final k = spring(span(t.value, 0, 0.7, Curves.linear), bounce: 0.5, freq: 2.4);
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateY((1 - k) * math.pi)
                    ..scaleByDouble(lerp(0.3, 1, k), lerp(0.3, 1, k), 1, 1),
                  child: Opacity(opacity: span(t.value, 0, 0.2, Curves.linear), child: child),
                );
              },
            ),
          ),
          Positioned(
            left: 16.5,
            top: 53.5,
            width: 9,
            height: 9,
            child: Tick(
              builder: (context, s, _) => Transform.translate(
                offset: Offset(math.sin(s * 0.8) * 1.2, math.sin(s * 1.1) * 1.6),
                child: Opacity(
                  opacity: span(_intro.value, 0.3, 0.45, Curves.linear),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF41D9F5), width: 1.8),
                      boxShadow: const [BoxShadow(color: Color(0x6641D9F5), blurRadius: 4)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          TextAt(
            x: 99.4,
            baseline: 82.7,
            style: hey,
            child: GlyphReveal(text: 'Hey, Ayesha!', style: hey, progress: _phase(0.14, 0.4), stagger: 0.5, lift: 8),
          ),
          TextAt(
            x: 99.8,
            baseline: 107.9,
            style: keep,
            child: GlyphReveal(text: 'Keep going!', style: keep, progress: _phase(0.2, 0.46), stagger: 0.5, lift: 8),
          ),
          Art.flex.place(
            child: AnimatedBuilder(
              animation: _intro,
              child: Art.flex.image(),
              builder: (context, child) => Tick(
                builder: (context, s, _) {
                  final k = spring(span(_intro.value, 0.4, 0.62, Curves.linear), bounce: 0.6);
                  final flexing = _intro.value >= 1 ? math.max(0.0, wave(s, 2.6)) : 0.0;
                  return Transform(
                    alignment: const Alignment(-0.6, 0.8),
                    transform: Matrix4.identity()
                      ..rotateZ(-0.25 * flexing)
                      ..scaleByDouble(k * (1 + 0.1 * flexing), k * (1 + 0.1 * flexing), 1, 1),
                    child: child,
                  );
                },
              ),
            ),
          ),
          _gems(),
        ],
      ),
    );
  }

  Widget _gems() {
    final t = _phase(0.16, 0.52);
    final style = typo(17.4, weight: FontWeight.w700, color: Colors.white);
    return Positioned(
      left: 272.7,
      top: 71.7,
      width: 104.6,
      height: 36.3,
      child: AnimatedBuilder(
        animation: t,
        builder: (context, _) {
          final k = t.value;
          final open = span(k, 0, 0.6, settle);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Transform(
                  alignment: Alignment.centerRight,
                  transform: Matrix4.identity()..scaleByDouble(math.max(0.35, open), 1, 1, 1),
                  child: Opacity(
                    opacity: span(k, 0, 0.2, Curves.linear),
                    child: const Glass(
                      style: GlassStyle(
                        fill: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xF2082A64), Color(0xF2031E4D), Color(0xF2062252), Color(0xF2011D46), Color(0xF2001A44)],
                          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                        ),
                        rim: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF6D8FE6), Color(0x553A5CB8), Color(0x996D8FE6)],
                        ),
                        radius: 18.15,
                        glow: Glow(Color(0x4431A0FF), blur: 6, width: 3),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: Art.gem.left - 272.7,
                top: Art.gem.top - 71.7,
                width: Art.gem.width,
                height: Art.gem.height,
                child: Tick(
                  builder: (context, s, _) => Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.003)
                      ..rotateY(
                        (1 - span(k, 0.3, 0.9, Curves.easeOutBack)) * math.pi * 3 +
                            (k >= 1 ? math.sin(s * 0.9) * 0.35 : 0),
                      )
                      ..scaleByDouble(span(k, 0.2, 0.6, settle), span(k, 0.2, 0.6, settle), 1, 1),
                    child: Sheen(period: 3.4, delay: 3.4, width: 0.3, strength: 0.9, child: Art.gem.image()),
                  ),
                ),
              ),
              TextAt(
                x: 310 - 272.7,
                baseline: 96.33 - 71.7,
                style: style,
                width: 50,
                child: Opacity(
                  opacity: span(k, 0.4, 0.6, Curves.linear),
                  child: Odometer(text: '235', style: style, progress: _phase(0.36, 0.72)),
                ),
              ),
              Positioned(
                left: 359.5 - 272.7 - 10,
                top: 89.8 - 71.7 - 10,
                width: 20,
                height: 20,
                child: Pressable(
                  onTap: () => HapticFeedback.lightImpact(),
                  scale: 0.8,
                  child: Transform.scale(
                    scale: spring(span(k, 0.5, 1, Curves.linear), bounce: 0.6),
                    child: const CustomPaint(painter: _PlusPainter()),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stats() {
    const pills = [
      (18.5, 144.67, 140.0, 199.67, Art.statFire, '320', 'Calories', 170.0, 186.3, 16.6, 11.95),
      (18.0, 207.33, 143.67, 262.67, Art.statSteps, '4,850', 'Steps', 232.0, 249.8, 17.35, 12.1),
      (18.3, 271.33, 144.67, 326.33, Art.statPin, '3.2 km', 'Distance', 298.0, 313.8, 17.8, 12.25),
    ];
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < pills.length; i++)
            () {
              final (l, t, r, b, icon, v, label, vBase, lBase, vSize, lSize) = pills[i];
              final value = typo(vSize, weight: FontWeight.w700, color: const Color(0xFFF8FEFE));
              final caption = typo(lSize, weight: FontWeight.w500, color: const Color(0xFFC6D2F2));
              final swing = _phase(0.18 + i * 0.07, 0.56 + i * 0.07);
              return Positioned(
                left: l,
                top: t,
                width: r - l,
                height: b - t,
                child: Depth(
                  depth: 1.2,
                  idle: 0.15,
                  child: AnimatedBuilder(
                    animation: swing,
                    builder: (context, child) {
                      final k = spring(swing.value, bounce: 0.35, freq: 2.2);
                      return Opacity(
                        opacity: span(swing.value, 0, 0.25, Curves.linear),
                        child: Transform(
                          alignment: Alignment.centerLeft,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0016)
                            ..rotateY((1 - k) * 1.35),
                          child: child,
                        ),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Positioned.fill(
                          child: Glass(
                            style: GlassStyle(
                              fill: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xF2548FDA),
                                  Color(0xF24184D1),
                                  Color(0xF21D4992),
                                  Color(0xF2123372),
                                  Color(0xF20A2B61),
                                  Color(0xF2072359),
                                  Color(0xF20D3571),
                                ],
                                stops: [0.0, 0.05, 0.2, 0.35, 0.55, 0.8, 1.0],
                              ),
                              rim: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFE2F4FF),
                                  Color(0xDDA8CFF6),
                                  Color(0x554A78C8),
                                  Color(0x333E5C9E),
                                  Color(0x996A8FCB),
                                ],
                                stops: [0.0, 0.3, 0.7, 1.0],
                              ),
                              rimWidth: 1.4,
                              radius: 27.5,
                              glow: Glow(Color(0x442C6BFF), blur: 6, width: 3),
                            ),
                          ),
                        ),
                        Positioned(
                          left: icon.left - l,
                          top: icon.top - t,
                          width: icon.width,
                          height: icon.height,
                          child: _statIcon(icon, i),
                        ),
                        TextAt(
                          x: 74.0 - l,
                          baseline: vBase - t,
                          style: value,
                          width: 90,
                          child: Odometer(text: v, style: value, progress: _phase(0.3 + i * 0.07, 0.8 + i * 0.05)),
                        ),
                        TextAt(
                          x: 73.6 - l,
                          baseline: lBase - t,
                          style: caption,
                          width: 90,
                          child: Label(label, caption),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }(),
        ],
      ),
    );
  }

  Widget _statIcon(Sprite icon, int i) {
    return Tick(
      child: icon.image(),
      builder: (context, s, child) {
        final beat = _intro.value >= 1
            ? math.pow(math.max(0.0, math.sin((s + i * 0.9) * math.pi / 1.6)), 12).toDouble()
            : 0.0;
        return Transform.scale(scale: 1 + beat * 0.07, child: child);
      },
    );
  }

  Widget _level() {
    final t = _phase(0.24, 0.62);
    final fill = _phase(0.55, 0.95);
    final title = typo(15.6, weight: FontWeight.w600, color: const Color(0xFFF5FEFE));
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 224,
            top: 163,
            width: 154.3,
            height: 61,
            child: Depth(
              depth: 1.2,
              idle: 0.15,
              child: Staged(
                animation: t,
                begin: 0,
                end: 1,
                offset: const Offset(60, 0),
                rotateY: -1.0,
                alignment: Alignment.centerRight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned.fill(
                      child: Glass(
                        style: GlassStyle(
                          fill: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xF2021E36), Color(0xF2062841), Color(0xF202273F), Color(0xF2003556), Color(0xF2093753)],
                            stops: [0.0, 0.2, 0.5, 0.7, 1.0],
                          ),
                          rim: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF3F7FB0), Color(0x55275A80), Color(0x88306A96)],
                          ),
                          radius: 16,
                          glow: Glow(Color(0x3320A0FF), blur: 6, width: 3),
                        ),
                      ),
                    ),
                    TextAt(
                      x: 278.4 - 224,
                      baseline: 189 - 163,
                      style: title,
                      width: 100,
                      child: Label('Level 3', title),
                    ),
                    Positioned(
                      left: 273 - 224,
                      top: 199.5 - 163,
                      width: 93,
                      height: 11.5,
                      child: AnimatedBuilder(
                        animation: fill,
                        builder: (context, _) =>
                            Tick(builder: (context, s, _) => CustomPaint(painter: _XpBar(fill.value, s))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Art.levelBadge.place(
            child: Depth(
              depth: 2,
              idle: 0.2,
              child: AnimatedBuilder(
                animation: t,
                child: Art.levelBadge.image(),
                builder: (context, child) => Tick(
                  builder: (context, s, _) {
                    final k = span(t.value, 0.1, 1, Curves.easeOutBack);
                    final glint = _intro.value >= 1 ? math.sin(s * 0.7) * 0.18 : 0.0;
                    return Opacity(
                      opacity: span(t.value, 0.1, 0.3, Curves.linear),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002)
                          ..rotateY((1 - k) * math.pi * 2 + glint)
                          ..scaleByDouble(lerp(0.4, 1, k), lerp(0.4, 1, k), 1, 1),
                        child: child,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            left: 229,
            top: 138,
            width: 22,
            height: 22,
            child: IgnorePointer(
              child: Tick(
                builder: (context, s, _) {
                  final a = span(_intro.value, 0.6, 0.8, Curves.linear) * (0.6 + 0.4 * wave(s, 1.8));
                  return CustomPaint(painter: _Twinkle(a, s));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _questCard() {
    final t = _phase(0.45, 0.85);
    final small = typo(14.9, weight: FontWeight.w500, color: const Color(0xFFDEF2FC));
    final big = typo(20, weight: FontWeight.w700, color: const Color(0xFFF9FEFE));
    final chip = typo(15.4, weight: FontWeight.w500, color: const Color(0xFFE9F0FD));
    const left = 15.2;
    const top = 561.0;
    return Positioned(
      left: left,
      top: 539,
      width: 380.8 - left,
      height: 750.7 - 539,
      child: Staged(
        animation: t,
        begin: 0,
        end: 1,
        offset: const Offset(0, 90),
        rotateX: 0.9,
        scale: 0.9,
        curve: const Cubic(0.2, 1.1, 0.3, 1.0),
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: _openQuest,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                key: _cardKey,
                left: 0,
                top: top - 539,
                right: 0,
                bottom: 0,
                child: const Glass(
                  style: GlassStyle(
                    fill: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xF2023A62),
                        Color(0xF2002D51),
                        Color(0xF200244C),
                        Color(0xF2011B46),
                        Color(0xF2001945),
                        Color(0xF2001E4B),
                        Color(0xF2012757),
                        Color(0xF2033064),
                      ],
                      stops: [0.0, 0.12, 0.2, 0.34, 0.6, 0.8, 0.94, 1.0],
                    ),
                    rim: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF6FC3F0), Color(0x55306EA8), Color(0x44245C96), Color(0xAA4AA6E6)],
                      stops: [0.0, 0.3, 0.75, 1.0],
                    ),
                    rimWidth: 1.4,
                    radius: 22,
                    glow: Glow(Color(0x5530A8FF), blur: 8, width: 4),
                  ),
                ),
              ),
              Positioned(
                left: Art.questRock.left - left,
                top: Art.questRock.top - 539,
                width: Art.questRock.width,
                height: Art.questRock.height,
                child: Art.questRock.image(),
              ),
              Positioned(
                left: Art.questCrystal.left - left,
                top: Art.questCrystal.top - 539,
                width: Art.questCrystal.width,
                height: Art.questCrystal.height,
                child: Tick(
                  builder: (context, s, _) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Hue.aqua.withValues(alpha: 0.18 + 0.14 * wave(s, 2.4)),
                                blurRadius: 16,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Transform.translate(offset: Offset(0, wave(s, 3.0) * 1.2), child: Art.questCrystal.image()),
                    ],
                  ),
                ),
              ),
              TextAt(
                x: 87.3 - left,
                baseline: 593.2 - 539,
                style: small,
                child: Text.rich(
                  const TextSpan(
                    children: [
                      TextSpan(text: "Today's "),
                      TextSpan(text: 'Quest', style: TextStyle(color: Color(0xFF8FE3F5))),
                    ],
                  ),
                  style: small,
                  maxLines: 1,
                ),
              ),
              TextAt(
                x: 87.4 - left,
                baseline: 619 - 539,
                style: big,
                child: Hero(tag: 'quest-title', child: Label('Riverside Park Loop', big)),
              ),
              _mini(Art.miniPin, '2.4 km', 70.2, left, chip.copyWith(fontSize: 16.5)),
              _mini(Art.miniClock, '30 min', 170.9, left, chip),
              _mini(Art.miniFlame, '~180 kcal', 286.3, left, chip.copyWith(fontSize: 16.3)),
              Positioned(left: 33.5 - left, top: 678.5 - 539, width: 329.3, height: 52.5, child: _startButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mini(Sprite icon, String text, double x, double left, TextStyle style) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: icon.left - left,
          top: icon.top - 539,
          width: icon.width,
          height: icon.height,
          child: icon.image(),
        ),
        TextAt(x: x - left, baseline: 656.4 - 539, style: style, width: 120, child: Label(text, style)),
      ],
    );
  }

  Widget _startButton() {
    final style = typo(19.35, weight: FontWeight.w700, color: const Color(0xFF151B3C));
    return Pressable(
      onTap: _openQuest,
      child: Tick(
        builder: (context, s, _) => CustomPaint(
          painter: NeonPainter(
            style: const NeonStyle(
              fill: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFEEB8C),
                  Color(0xFFFDDB42),
                  Color(0xFFFCCB28),
                  Color(0xFFFBB817),
                  Color(0xFFFBB414),
                  Color(0xFFFDC934),
                ],
                stops: [0.0, 0.1, 0.38, 0.72, 0.9, 1.0],
              ),
              overlays: [
                LinearGradient(
                  colors: [Color(0x55FFF3B0), Color(0x00FFFFFF), Color(0x00FFFFFF), Color(0x44FFF3B0)],
                  stops: [0.0, 0.08, 0.92, 1.0],
                ),
              ],
              rim: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF9D0), Color(0x00FFD040), Color(0xAAFFE27A)],
              ),
              rimWidth: 1.4,
              halo: Glow(Color(0x88FFB21C), blur: 10, width: 5, spread: 1),
            ),
            sheen: ((s % 3.6) / 3.6) * 2.0 - 0.3,
            halo: 0.7 + 0.3 * wave(s, 2.0),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 137.6 - 33.5,
                top: 694.5 - 678.5,
                width: 17,
                height: 21,
                child: const CustomPaint(painter: _PlayPainter(Color(0xFF151B3C))),
              ),
              TextAt(
                x: 165.4 - 33.5,
                baseline: 710.8 - 678.5,
                style: style,
                width: 160,
                child: Label('Start Quest', style),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nav() {
    return Positioned(left: 0, top: 764, width: 393, height: 100, child: QuestNavBar(entrance: _phase(0.35, 0.85)));
  }
}

class _Energy extends StatelessWidget {
  const _Energy({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) =>
          Tick(builder: (context, s, _) => CustomPaint(painter: _EnergyPainter(progress.value, s))),
    );
  }
}

class _EnergyPainter extends CustomPainter {
  _EnergyPainter(this.p, this.s);

  final double p;
  final double s;

  static const lines = [
    [Offset(126, 352), Offset(160, 371), Offset(206, 408)],
    [Offset(222, 418), Offset(265, 453)],
    [Offset(213, 404), Offset(213, 338)],
    [Offset(223, 410), Offset(258, 402), Offset(300, 393)],
  ];
  static const pads = [
    (Offset(110, 343), 17.0, 7.0, Color(0xFFFFD35A)),
    (Offset(213, 413), 16.0, 8.0, Color(0xFF7FE6FF)),
    (Offset(274, 461), 17.0, 9.0, Color(0xFFFFD35A)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (p <= 0) return;
    for (var i = 0; i < pads.length; i++) {
      final (c, rx, ry, color) = pads[i];
      final cycle = ((s + i * 0.7) % 2.4) / 2.4;
      final grow = lerp(0.8, 2.1, cycle);
      final a = (1 - cycle) * p;
      canvas.drawOval(
        Rect.fromCenter(center: c, width: rx * 2 * grow, height: ry * 2 * grow),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = color.withValues(alpha: 0.7 * a),
      );
    }
    for (var i = 0; i < lines.length; i++) {
      final pts = lines[i];
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final q in pts.skip(1)) {
        path.lineTo(q.dx, q.dy);
      }
      final metric = path.computeMetrics().first;
      final head = ((s * 0.45 + i * 0.29) % 1.0) * (metric.length + 30);
      for (var j = 0; j < 10; j++) {
        final d = head - j * 3;
        if (d < 0 || d > metric.length) continue;
        final tan = metric.getTangentForOffset(d);
        if (tan == null) continue;
        final fade = 1 - j / 10;
        canvas.drawCircle(
          tan.position,
          lerp(0.6, 2.6, fade),
          Paint()
            ..color = Color.lerp(const Color(0xFF5CFFC8), Colors.white, fade * 0.6)!.withValues(alpha: 0.85 * fade * p)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, lerp(2.5, 1.2, fade)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_EnergyPainter old) => old.p != p || old.s != s;
}

class _Pad extends StatelessWidget {
  const _Pad({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, _) => Tick(builder: (context, s, _) => CustomPaint(painter: _PadPainter(progress.value, s))),
      ),
    );
  }
}

class _PadPainter extends CustomPainter {
  _PadPainter(this.p, this.s);

  final double p;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    if (p <= 0) return;
    const c = Offset(154.5, 512.5);
    const rx = 46.0;
    const ry = 21.0;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(1, ry / rx);
    final open = span(p, 0, 1, settle);
    for (var i = 0; i < 3; i++) {
      final r = rx * (0.62 + i * 0.2) * open;
      final turn = s * (i.isEven ? 0.6 : -0.45) + i;
      final sweep = math.pi * (0.5 + 0.18 * i);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 - i * 0.5
        ..strokeCap = StrokeCap.round
        ..color = (i == 1 ? const Color(0xFFC08BFF) : const Color(0xFF7FF0FF)).withValues(alpha: 0.55 * p)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
      canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r), turn, sweep, false, paint);
      canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r), turn + math.pi, sweep * 0.6, false, paint);
    }
    final cycle = (s % 2.2) / 2.2;
    canvas.drawCircle(
      Offset.zero,
      rx * lerp(0.5, 1.35, cycle),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF9FF4FF).withValues(alpha: 0.5 * (1 - cycle) * p)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.restore();
    final beam = Rect.fromCenter(center: c.translate(0, -40), width: 70, height: 90);
    canvas.drawRect(
      beam,
      Paint()
        ..shader = ui.Gradient.linear(beam.bottomCenter, beam.topCenter, [
          const Color(0xFF8FF4FF).withValues(alpha: 0.12 * p * (0.7 + 0.3 * wave(s, 2.2))),
          const Color(0x008FF4FF),
        ])
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  @override
  bool shouldRepaint(_PadPainter old) => old.p != p || old.s != s;
}

class _XpBar extends CustomPainter {
  _XpBar(this.t, this.s);

  final double t;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.height / 2));
    canvas.drawRRect(track, Paint()..color = const Color(0xFF0B2F5C));
    canvas.drawRRect(
      track.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF2E5F96).withValues(alpha: 0.8),
    );
    final w = 45.0 * span(t, 0, 1, const Cubic(0.3, 0.1, 0.2, 1));
    if (w > 0.5) {
      final fill = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, math.max(w, size.height), size.height),
        Radius.circular(size.height / 2),
      );
      canvas.save();
      canvas.clipRRect(fill);
      canvas.drawRect(
        fill.outerRect,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(w, 0),
            [const Color(0xFF6CF0B4), const Color(0xFF34D59A), const Color(0xFF52E4C0)],
            const [0, 0.6, 1],
          ),
      );
      final path = Path()..moveTo(0, size.height);
      for (var x = 0.0; x <= w + 2; x += 2) {
        path.lineTo(x, size.height * 0.34 + math.sin(x * 0.35 - s * 5) * 1.1);
      }
      path
        ..lineTo(w + 2, 0)
        ..lineTo(0, 0)
        ..close();
      canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.22));
      canvas.restore();
      canvas.drawCircle(
        Offset(w - 2, size.height / 2),
        4,
        Paint()
          ..color = const Color(0xFFB8FFE0).withValues(alpha: 0.6 + 0.3 * wave(s, 1.2))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
    final style = typo(7.6, weight: FontWeight.w700, color: Colors.white);
    final shown = (560 * span(t, 0, 1, const Cubic(0.3, 0.1, 0.2, 1))).round();
    final tp = TextPainter(
      text: TextSpan(text: '$shown / 1000', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(43 - tp.width / 2 + 2, (size.height - tp.height) / 2));
    tp.dispose();
  }

  @override
  bool shouldRepaint(_XpBar old) => old.t != t || old.s != s;
}

class _Twinkle extends CustomPainter {
  _Twinkle(this.a, this.s);

  final double a;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    if (a <= 0) return;
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      6,
      Paint()
        ..color = const Color(0xFFFFE9A0).withValues(alpha: 0.6 * a)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(s * 0.6);
    final ray = Paint()
      ..color = Colors.white.withValues(alpha: a)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-7, 0), const Offset(7, 0), ray);
    canvas.drawLine(const Offset(0, -7), const Offset(0, 7), ray);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Twinkle old) => old.a != a || old.s != s;
}

class _PlusPainter extends CustomPainter {
  const _PlusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      9.8,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF1AA7A4), Color(0xFF0F7F84), Color(0xFF0C5D6E)],
          stops: [0.0, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: 9.8)),
    );
    final glow = Paint()
      ..strokeWidth = 4.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF8FFFF4).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final line = Paint()
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFEFFFFD);
    for (final p in [glow, line]) {
      canvas.drawLine(c + const Offset(-6.2, 0), c + const Offset(6.2, 0), p);
      canvas.drawLine(c + const Offset(0, -6.6), c + const Offset(0, 6.6), p);
    }
  }

  @override
  bool shouldRepaint(_PlusPainter old) => false;
}

class _PlayPainter extends CustomPainter {
  const _PlayPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(1.5, 1.8)
      ..quadraticBezierTo(1.5, 0, 3.2, 0.9)
      ..lineTo(size.width - 1.2, size.height / 2 - 1)
      ..quadraticBezierTo(size.width, size.height / 2, size.width - 1.2, size.height / 2 + 1)
      ..lineTo(3.2, size.height - 0.9)
      ..quadraticBezierTo(1.5, size.height, 1.5, size.height - 1.8)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PlayPainter old) => old.color != color;
}
