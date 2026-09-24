import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/sprites.dart';
import '../core/type.dart';
import '../widgets/effects.dart';
import '../widgets/neon.dart';
import '../widgets/parallax.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _launch;
  final _scroll = ScrollController();
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..forward();
    _launch = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _intro.dispose();
    _launch.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Animation<double> _phase(double a, double b, [Curve curve = Curves.linear]) => CurvedAnimation(
    parent: _intro,
    curve: Interval(a, b, curve: curve),
  );

  Future<void> _start() async {
    HapticFeedback.heavyImpact();
    await _launch.forward(from: 0);
    if (mounted) _launch.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        backgroundColor: const Color(0xFF01113A),
        body: DesignCanvas(
          backdrop: const Color(0xFF01113A),
          child: TiltField(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF01123A), Color(0xFF011137), Color(0xFF020F33), Color(0xFF031F5B)],
                        stops: [0.0, 0.7, 0.9, 1.0],
                      ),
                    ),
                  ),
                ),
                _hero(),
                _details(),
                _topBar(),
                Floor(children: [_startButton()]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Positioned(
      left: 0,
      top: 0,
      width: 393,
      height: 470,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scroll, _launch]),
        builder: (context, child) {
          final off = _scroll.hasClients ? _scroll.offset : 0.0;
          final pull = math.max(0.0, -off);
          final push = math.max(0.0, off);
          return Transform.translate(
            offset: Offset(0, -push * 0.45),
            child: Transform.scale(scale: 1 + pull / 470, alignment: Alignment.topCenter, child: child),
          );
        },
        child: ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -8,
                top: -8,
                width: 409,
                height: 486,
                child: Depth(
                  depth: -6,
                  child: AnimatedBuilder(
                    animation: _intro,
                    builder: (context, child) {
                      final k = span(_intro.value, 0, 0.6, const Cubic(0.2, 0.8, 0.2, 1));
                      return Transform.scale(
                        scale: lerp(1.12, 1, k),
                        alignment: const Alignment(0, -0.3),
                        child: child,
                      );
                    },
                    child: Image.asset(Scenes.river, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(child: _Ripples(progress: _phase(0.2, 0.6))),
              ),
              Art.balloon.place(
                child: Depth(
                  depth: -2,
                  child: Tick(
                    child: Art.balloon.image(),
                    builder: (context, s, child) => Transform.translate(
                      offset: Offset(math.sin(s * 0.23) * 7, math.sin(s * 0.41) * 3.5),
                      child: Transform.rotate(angle: math.sin(s * 0.5) * 0.04, child: child),
                    ),
                  ),
                ),
              ),
              Art.routeRunner.place(child: _runner()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _runner() {
    return AnimatedBuilder(
      animation: _launch,
      child: Depth(
        depth: 7,
        child: Tick(
          child: Art.routeRunner.image(),
          builder: (context, s, child) {
            final stride = math.sin(s * math.pi * 2 / 0.62);
            final m = Matrix4.identity()
              ..translateByDouble(0, -math.max(0.0, stride).abs() * 2.2, 0, 1)
              ..rotateZ(stride * 0.012);
            return Transform(alignment: Alignment.bottomCenter, transform: m, child: child);
          },
        ),
      ),
      builder: (context, child) {
        final k = _launch.value;
        final go = span(k, 0.15, 0.85, launch);
        return Opacity(
          opacity: 1 - span(k, 0.55, 0.85, Curves.linear),
          child: Transform(
            alignment: const Alignment(0, -0.2),
            transform: Matrix4.identity()
              ..translateByDouble(go * 18, -go * 130, 0, 1)
              ..scaleByDouble(1 - go * 0.62, 1 - go * 0.62, 1, 1),
            child: child,
          ),
        );
      },
    );
  }

  Widget _topBar() {
    final t = _phase(0.1, 0.45);
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _circle(
            40.5,
            87.8,
            25.3,
            t,
            0,
            () => Navigator.of(context).maybePop(),
            const GlyphIcon(Glyph.back, size: 26, stroke: 2.8),
          ),
          _circle(310.5, 88.5, 24.5, t, 0.1, () {
            HapticFeedback.lightImpact();
            setState(() => _liked = !_liked);
          }, _Heart(liked: _liked)),
          _circle(
            357.5,
            88.5,
            24.5,
            t,
            0.2,
            () => HapticFeedback.lightImpact(),
            const GlyphIcon(Glyph.share, size: 24, stroke: 2.2),
          ),
        ],
      ),
    );
  }

  Widget _circle(double cx, double cy, double r, Animation<double> t, double delay, VoidCallback onTap, Widget icon) {
    return Positioned(
      left: cx - r,
      top: cy - r,
      width: r * 2,
      height: r * 2,
      child: AnimatedBuilder(
        animation: t,
        child: Pressable(
          onTap: onTap,
          scale: 0.86,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(0, -0.3),
                colors: [Color(0xF0152B55), Color(0xF00B1B3F), Color(0xF0071331)],
                stops: [0.0, 0.7, 1.0],
              ),
              border: Border.all(color: const Color(0x663D72B8), width: 1.2),
              boxShadow: const [BoxShadow(color: Color(0x55000A26), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Center(child: icon),
          ),
        ),
        builder: (context, child) {
          final k = spring(((t.value - delay) / (1 - delay)).clamp(0.0, 1.0), bounce: 0.55);
          return Opacity(
            opacity: k.clamp(0.0, 1.0),
            child: Transform.scale(scale: k, child: child),
          );
        },
      ),
    );
  }

  Widget _details() {
    return Positioned.fill(
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (n) {
          n.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          child: Builder(
            builder: (context) => SizedBox(
              height: 852 + CanvasScope.of(context).slack.clamp(0.0, double.infinity) + 12,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned(
                    left: 0,
                    top: 0,
                    width: 393,
                    height: 338,
                    child: IgnorePointer(child: SizedBox.expand()),
                  ),
                  _titleRow(),
                  _rating(),
                  _description(),
                  _statCards(),
                  _highlights(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleRow() {
    final t = _phase(0.2, 0.55);
    final title = typo(
      25.7,
      weight: FontWeight.w700,
      color: const Color(0xFFFBFEFE),
      shadows: const [Shadow(color: Color(0x88000A30), blurRadius: 8)],
    );
    final epic = typo(16.5, weight: FontWeight.w700, color: Colors.white);
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Art.crownBadge.place(
            child: AnimatedBuilder(
              animation: t,
              child: Art.crownBadge.image(),
              builder: (context, child) => Tick(
                builder: (context, s, _) {
                  final k = span(t.value, 0, 0.8, Curves.easeOutBack);
                  return Opacity(
                    opacity: span(t.value, 0, 0.2, Curves.linear),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateY((1 - k) * math.pi * 2 + (_intro.value >= 1 ? math.sin(s * 0.8) * 0.2 : 0))
                        ..scaleByDouble(lerp(0.3, 1, k), lerp(0.3, 1, k), 1, 1),
                      child: child,
                    ),
                  );
                },
              ),
            ),
          ),
          TextAt(
            x: 72.4,
            baseline: 397.4,
            style: title,
            child: Hero(
              tag: 'quest-title',
              flightShuttleBuilder: (context, animation, direction, from, to) => DefaultTextStyle(
                style: title,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.topLeft,
                  child: Label('Riverside Park Loop', title),
                ),
              ),
              child: Label('Riverside Park Loop', title),
            ),
          ),
          Positioned(
            left: 306.3,
            top: 376,
            width: 58.4,
            height: 30.7,
            child: AnimatedBuilder(
              animation: t,
              builder: (context, _) => Tick(
                builder: (context, s, _) {
                  final k = spring(span(t.value, 0.3, 1, Curves.linear), bounce: 0.6);
                  return Transform.scale(
                    scale: k,
                    child: CustomPaint(
                      painter: NeonPainter(
                        style: const NeonStyle(
                          fill: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF1455CD),
                              Color(0xFF1253DA),
                              Color(0xFF1E44BC),
                              Color(0xFF0D38BD),
                              Color(0xFF1331BA),
                            ],
                          ),
                          rim: LinearGradient(colors: [Color(0xFFD6E6FF), Color(0xFFF2F8FF), Color(0xFFD6E6FF)]),
                          rimWidth: 1.8,
                          halo: Glow(Color(0x884D7BFF), blur: 6, width: 4),
                        ),
                        spark: _intro.value >= 1 ? (s / 2.6) % 1 : null,
                        sparkColor: const Color(0xFFCFE0FF),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 309.6 - 306.3,
                            top: 382 - 376,
                            width: 16,
                            height: 16,
                            child: const GlyphIcon(Glyph.crown, size: 16, color: Color(0xFFE8F2FF)),
                          ),
                          TextAt(
                            x: 331.6 - 306.3,
                            baseline: 397.3 - 376,
                            style: epic,
                            width: 40,
                            child: Label('Epic', epic),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rating() {
    final t = _phase(0.3, 0.7);
    final style = typo(15.8, weight: FontWeight.w500, color: const Color(0xFFE7EEFC));
    const xs = [80.3, 102.5, 124.2, 146.3];
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: t,
        builder: (context, _) => Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < xs.length; i++)
              () {
                final k = spring(((t.value - i * 0.1) / 0.6).clamp(0.0, 1.0), bounce: 0.6, freq: 2.6);
                return Positioned(
                  left: xs[i] - 11,
                  top: 421.5 - 11,
                  width: 22,
                  height: 22,
                  child: Transform.rotate(
                    angle: (1 - k) * -math.pi,
                    child: Transform.scale(
                      scale: k,
                      child: const CustomPaint(painter: _StarPainter()),
                    ),
                  ),
                );
              }(),
            TextAt(
              x: 165.3,
              baseline: 430,
              style: style,
              width: 100,
              child: Opacity(opacity: span(t.value, 0.4, 0.8, Curves.linear), child: Label('4.8 (124)', style)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _description() {
    final style = typo(15.95, weight: FontWeight.w500, color: const Color(0xFFD5E0F9));
    const lines = [
      ('A beautiful and peaceful loop around the river', 470.2),
      ('with lush greenery, benches and scenic views.', 492.3),
      ('Perfect for beginners and casual walkers.', 508.67),
    ];
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < lines.length; i++)
            TextAt(
              x: 19.2,
              baseline: lines[i].$2,
              style: style,
              child: Staged(
                animation: _phase(0.36 + i * 0.06, 0.7 + i * 0.06),
                begin: 0,
                end: 1,
                offset: const Offset(0, 10),
                child: Label(lines[i].$1, style),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statCards() {
    const cards = [
      (16.8, 142.6, Art.routePin, '2.4 km', 'Distance', 62.0, 187.0),
      (142.6, 261.6, Art.routeClock, '30 min', 'Est. Time', 187.0, 186.7),
      (261.6, 380.0, Art.routeFlame, '~180 kcal', 'Calories', 301.0, 300.3),
    ];
    final value = typo(17.9, weight: FontWeight.w700, color: const Color(0xFFF6FAFE));
    final caption = typo(12.4, weight: FontWeight.w500, color: const Color(0xFFD9E7FE));
    final t = _phase(0.45, 0.85);
    return Positioned(
      left: 16.8,
      top: 527.5,
      width: 380 - 16.8,
      height: 82,
      child: AnimatedBuilder(
        animation: t,
        builder: (context, _) {
          final unfold = t.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(
                child: Glass(
                  style: GlassStyle(
                    fill: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF011D4E),
                        Color(0xFF011B4B),
                        Color(0xFF001945),
                        Color(0xFF011948),
                        Color(0xFF001745),
                      ],
                    ),
                    rim: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF2C82C8), Color(0x55185598), Color(0xFF2C6FC0)],
                    ),
                    rimWidth: 1.2,
                    radius: 16,
                  ),
                ),
              ),
              for (var i = 0; i < cards.length; i++)
                () {
                  final (l, r, icon, v, label, x, cx) = cards[i];
                  final k = spring(((unfold - i * 0.14) / 0.6).clamp(0.0, 1.0), bounce: 0.35, freq: 2.2);
                  return Positioned(
                    left: l - 16.8,
                    top: 0,
                    width: r - l,
                    height: 82,
                    child: Transform(
                      alignment: Alignment.centerLeft,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateY((1 - k) * -1.5),
                      child: Opacity(
                        opacity: span(unfold - i * 0.14, 0, 0.2, Curves.linear),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            if (i > 0)
                              Positioned(
                                left: 0,
                                top: 14,
                                bottom: 14,
                                width: 1,
                                child: const ColoredBox(color: Color(0x33386CB8)),
                              ),
                            Positioned(
                              left: icon.left - l,
                              top: icon.top - 527.5,
                              width: icon.width,
                              height: icon.height,
                              child: icon.image(),
                            ),
                            TextAt(
                              x: x - l,
                              baseline: 566 - 527.5,
                              style: value,
                              width: 110,
                              child: Odometer(text: v, style: value, progress: _phase(0.55 + i * 0.05, 0.95)),
                            ),
                            TextAt(
                              x: x - l,
                              baseline: 588 - 527.5,
                              style: caption,
                              width: 110,
                              child: Label(label, caption),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }(),
            ],
          );
        },
      ),
    );
  }

  Widget _highlights() {
    final heading = typo(16.8, weight: FontWeight.w700, color: const Color(0xFFF8FBFE));
    final label = typo(11.7, weight: FontWeight.w500, color: const Color(0xFFE6EDFD));
    const items = [
      (Art.highlightScenic, 'Scenic', 'Views', 54.8, 18.0, 92.5),
      (Art.highlightWater, 'Water', 'Fountain', 155.2, 117.0, 193.5),
      (Art.highlightRest, 'Rest', 'Areas', 247.4, 209.3, 285.6),
      (Art.highlightSafe, 'Safe', 'Route', 345.2, 307.0, 383.5),
    ];
    final t = _phase(0.55, 1.0);
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          TextAt(
            x: 19.6,
            baseline: 648.5,
            style: heading,
            child: GlyphReveal(
              text: 'Route Highlights',
              style: heading,
              progress: _phase(0.5, 0.8),
              stagger: 0.5,
              lift: 8,
            ),
          ),
          for (var i = 0; i < items.length; i++)
            () {
              final (icon, a, b, cx, l, r) = items[i];
              final k = _phase(0.58 + i * 0.07, 0.86 + i * 0.035);
              return Positioned(
                left: l,
                top: 649,
                width: r - l,
                height: 115,
                child: AnimatedBuilder(
                  animation: k,
                  builder: (context, _) {
                    final v = k.value;
                    final flip = span(v, 0, 1, const Cubic(0.3, 1.3, 0.4, 1));
                    return Opacity(
                      opacity: span(v, 0, 0.25, Curves.linear) * span(t.value, 0, 0.1, Curves.linear),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0022)
                          ..translateByDouble(0, (1 - flip) * 30, 0, 1)
                          ..rotateX((1 - flip) * -1.4),
                        child: Pressable(
                          onTap: () => HapticFeedback.selectionClick(),
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
                                        Color(0xFF010B2D),
                                        Color(0xFF000F2C),
                                        Color(0xFF010D29),
                                        Color(0xFF000E2D),
                                        Color(0xFF011341),
                                      ],
                                    ),
                                    rim: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Color(0x55275A9C), Color(0x22183E75), Color(0x44275A9C)],
                                    ),
                                    rimWidth: 1,
                                    radius: 16,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: icon.left - l,
                                top: icon.top - 649,
                                width: icon.width,
                                height: icon.height,
                                child: icon.image(),
                              ),
                              TextAt(
                                x: cx - l,
                                baseline: 733 - 649,
                                anchor: 0.5,
                                style: label,
                                width: r - l + 20,
                                child: Label(a, label),
                              ),
                              TextAt(
                                x: cx - l,
                                baseline: 749.3 - 649,
                                anchor: 0.5,
                                style: label,
                                width: r - l + 20,
                                child: Label(b, label),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }(),
        ],
      ),
    );
  }

  Widget _startButton() {
    final t = _phase(0.6, 1.0);
    final style = typo(
      18.3,
      weight: FontWeight.w700,
      color: Colors.white,
      shadows: const [Shadow(color: Color(0x55000A40), blurRadius: 4)],
    );
    return Positioned(
      left: 31.5,
      top: 770,
      width: 334,
      height: 57,
      child: Staged(
        animation: t,
        begin: 0,
        end: 1,
        offset: const Offset(0, 40),
        scale: 0.8,
        curve: settle,
        child: Pressable(
          onTap: _start,
          child: AnimatedBuilder(
            animation: _launch,
            builder: (context, _) => Tick(
              builder: (context, s, _) {
                final burst = _launch.value;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: NeonPainter(
                          style: NeonStyle(
                            fill: LinearGradient(
                              colors: const [
                                Color(0xFF48EBB4),
                                Color(0xFF26D6E0),
                                Color(0xFF01ADFC),
                                Color(0xFF2FA4FD),
                                Color(0xFFBC8CDE),
                                Color(0xFFFC82B4),
                                Color(0xFFFE50E6),
                              ],
                              stops: const [0.0, 0.18, 0.42, 0.58, 0.8, 0.94, 1.0],
                              transform: _Hue(0.05 * wave(s, 4.0)),
                            ),
                            overlays: const [
                              LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x66FFFFFF), Color(0x10FFFFFF), Color(0x00000000), Color(0x22002050)],
                                stops: [0.0, 0.18, 0.55, 1.0],
                              ),
                            ],
                            rim: const LinearGradient(
                              colors: [Color(0xFFD4FFF2), Color(0xFFE6F8FF), Color(0xFFFFE2FA)],
                            ),
                            rimWidth: 1.5,
                            halo: const Glow(Color(0xAA7A5CFF), blur: 12, width: 8, spread: 2),
                          ),
                          sheen: burst > 0 ? burst * 1.6 - 0.3 : ((s % 4.0) / 4.0) * 2.0 - 0.4,
                          halo: 0.8 + 0.2 * wave(s, 2.0) + burst,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 140.6 - 31.5 - (burst > 0 ? span(burst, 0, 0.4, Curves.easeIn) * -140 : 0),
                      top: 785.5 - 770,
                      width: 18.5,
                      height: 22,
                      child: Opacity(
                        opacity: 1 - span(burst, 0.3, 0.45, Curves.linear) + span(burst, 0.8, 1, Curves.linear),
                        child: const CustomPaint(painter: _Play()),
                      ),
                    ),
                    TextAt(
                      x: 172.7 - 31.5,
                      baseline: 808.3 - 770,
                      style: style,
                      width: 160,
                      child: Label(burst > 0.35 && burst < 0.95 ? 'Quest Started!' : 'Start Quest', style),
                    ),
                    if (burst > 0)
                      Positioned.fill(
                        child: IgnorePointer(child: CustomPaint(painter: _Burst(burst))),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Hue extends GradientTransform {
  const _Hue(this.dx);

  final double dx;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) => Matrix4.translationValues(bounds.width * dx, 0, 0);
}

class _Heart extends StatelessWidget {
  const _Heart({required this.liked});

  final bool liked;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: liked ? 1 : 0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.linear,
      builder: (context, t, _) {
        final pop = liked ? 1 + math.sin(t * math.pi) * 0.4 : 1.0;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (liked && t < 1) CustomPaint(size: const Size(44, 44), painter: _HeartBurst(t)),
            Transform.scale(
              scale: pop,
              child: CustomPaint(size: const Size(24, 24), painter: _HeartPainter(t)),
            ),
          ],
        );
      },
    );
  }
}

class _HeartPainter extends CustomPainter {
  _HeartPainter(this.fill);

  final double fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24);
    final path = GlyphPainter.pathOf(Glyph.heart);
    if (fill > 0) {
      canvas.save();
      canvas.clipPath(path);
      canvas.drawCircle(const Offset(12, 13), 14 * fill, Paint()..color = const Color(0xFFFF4F7B));
      canvas.restore();
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round
        ..color = Color.lerp(Colors.white, const Color(0xFFFF8FA8), fill)!,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeartPainter old) => old.fill != fill;
}

class _HeartBurst extends CustomPainter {
  _HeartBurst(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final d = lerp(10, 24, span(t, 0, 1, Curves.easeOut));
      final p = c + Offset(math.cos(a), math.sin(a)) * d;
      canvas.drawCircle(
        p,
        2.2 * (1 - t),
        Paint()..color = (i.isEven ? const Color(0xFFFF6F91) : const Color(0xFFFFD35A)).withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(_HeartBurst old) => old.t != t;
}

class _StarPainter extends CustomPainter {
  const _StarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24);
    final path = GlyphPainter.pathOf(Glyph.star);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFB21C).withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(12, 1),
          const Offset(12, 23),
          [const Color(0xFFFFE680), const Color(0xFFFFC21E), const Color(0xFFF59A0C)],
          const [0, 0.5, 1],
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StarPainter old) => false;
}

class _Play extends CustomPainter {
  const _Play();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(1.6, 2)
      ..quadraticBezierTo(1.6, 0, 3.4, 1)
      ..lineTo(size.width - 1.2, size.height / 2 - 1.1)
      ..quadraticBezierTo(size.width, size.height / 2, size.width - 1.2, size.height / 2 + 1.1)
      ..lineTo(3.4, size.height - 1)
      ..quadraticBezierTo(1.6, size.height, 1.6, size.height - 2)
      ..close();
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0x55001040)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(p, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_Play old) => false;
}

class _Burst extends CustomPainter {
  _Burst(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final rnd = math.Random(4);
    final k = span(t, 0, 0.7, Curves.easeOut);
    for (var i = 0; i < 26; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final speed = 60 + rnd.nextDouble() * 110;
      final p = c + Offset(math.cos(a) * speed * k * 1.4, math.sin(a) * speed * k * 0.7 - 30 * k * k);
      final colors = [Hue.aqua, Hue.cyan, Hue.magenta, Hue.gold, Colors.white];
      canvas.drawCircle(
        p,
        2.6 * (1 - k) + 0.4,
        Paint()..color = colors[i % colors.length].withValues(alpha: (1 - k).clamp(0.0, 1.0)),
      );
    }
    final ring = span(t, 0, 0.5, Curves.easeOut);
    if (ring < 1) {
      final r = RRect.fromRectAndRadius(
        (Offset.zero & size).inflate(ring * 22),
        Radius.circular(size.height / 2 + ring * 22),
      );
      canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * (1 - ring)
          ..color = Colors.white.withValues(alpha: 0.8 * (1 - ring)),
      );
    }
  }

  @override
  bool shouldRepaint(_Burst old) => old.t != t;
}

class _Ripples extends StatelessWidget {
  const _Ripples({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return Tick(builder: (context, s, _) => CustomPaint(painter: _RipplePainter(s, progress.value)));
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter(this.s, this.p);

  final double s;
  final double p;

  @override
  void paint(Canvas canvas, Size size) {
    if (p <= 0) return;
    final rnd = math.Random(9);
    for (var i = 0; i < 16; i++) {
      final x = 70 + rnd.nextDouble() * 300;
      final y = 208 + rnd.nextDouble() * 60;
      final period = 1.6 + rnd.nextDouble() * 2.2;
      final phase = rnd.nextDouble();
      final t = ((s / period) + phase) % 1.0;
      final a = math.sin(t * math.pi) * p * 0.8;
      final w = lerp(4, 16, rnd.nextDouble()) * (0.7 + 0.3 * math.sin(s * 2 + i));
      canvas.drawLine(
        Offset(x - w / 2, y),
        Offset(x + w / 2, y),
        Paint()
          ..strokeWidth = 1.1
          ..strokeCap = StrokeCap.round
          ..color = Colors.