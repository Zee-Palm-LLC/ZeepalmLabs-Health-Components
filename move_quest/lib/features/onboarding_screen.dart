import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/sprites.dart';
import '../core/transitions.dart';
import '../core/type.dart';
import '../widgets/effects.dart';
import '../widgets/neon.dart';
import '../widgets/parallax.dart';
import 'home_screen.dart';

class Activity {
  const Activity(this.label, this.sprite, this.baseline);

  final String label;
  final Sprite sprite;
  final double baseline;
}

const activities = [
  Activity('Run', Art.chipRun, 180.6),
  Activity('Walk', Art.chipWalk, 239.6),
  Activity('Yoga', Art.chipYoga, 299.9),
  Activity('Gym', Art.chipGym, 360.2),
  Activity('Cycling', Art.chipCycling, 420.9),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late final AnimationController _intro;
  final _picked = <String>{};

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..forward();
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

  void _next() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(DescendRoute(builder: (_) => const HomeScreen()));
  }

  void _toggle(Activity a) {
    HapticFeedback.selectionClick();
    setState(() => _picked.contains(a.label) ? _picked.remove(a.label) : _picked.add(a.label));
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
              SceneLayer(
                children: [
                  Positioned.fill(
                    child: Depth(
                      depth: -4,
                      cover: const Size(393, 852),
                      child: Image.asset(
                        Scenes.path,
                        fit: BoxFit.fill,
                        width: 393,
                        height: 852,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  Art.pathRunner.place(
                    child: Depth(
                      depth: 8,
                      child: Breathe(period: 3.2, amount: 0.007, bob: 1.2, child: Art.pathRunner.image()),
                    ),
                  ),
                  Motes(area: const Rect.fromLTWH(0, 120, 393, 440), seed: 11, count: 18),
                  for (var i = 0; i < activities.length; i++) _chip(activities[i], i),
                ],
              ),
              _skip(),
              Floor(children: [_title(), _body(), _dots(), _nextButton()]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skip() {
    final t = _phase(0.05, 0.3);
    final style = typo(16.2, weight: FontWeight.w600, color: const Color(0xFFF4FBFE));
    return Positioned(
      left: 313.33,
      top: 58.67,
      width: 63.67,
      height: 38.33,
      child: Staged(
        animation: t,
        begin: 0,
        end: 1,
        offset: const Offset(24, 0),
        scale: 0.7,
        child: Pressable(
          onTap: _next,
          child: Glass(
            style: const GlassStyle(
              fill: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xF2013785), Color(0xF20E6DB1), Color(0xF2013487), Color(0xF2013C8F), Color(0xF204479C)],
                stops: [0.0, 0.2, 0.4, 0.7, 1.0],
              ),
              rim: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF7FC4FF), Color(0x663C7BD8), Color(0xAA5FA8F0)],
              ),
              radius: 19.2,
              glow: Glow(Color(0x552B7BFF), blur: 6, width: 3),
            ),
            child: Stack(
              children: [
                TextAt(
                  x: 345.67 - 313.33,
                  baseline: 83.3 - 58.67,
                  anchor: 0.5,
                  width: 64,
                  style: style,
                  child: Label('Skip', style),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(Activity a, int i) {
    final slot = a.sprite;
    final cy = slot.center.dy;
    final pillLeft = slot.center.dx;
    const pillRight = 372.5;
    const origin = Offset(150, 262);
    final t = _phase(0.12 + i * 0.075, 0.5 + i * 0.075);
    final picked = _picked.contains(a.label);
    final style = typo(16.5, weight: FontWeight.w600, color: const Color(0xFFEEFEFE));
    return Positioned(
      left: pillLeft - 30,
      top: cy - 30,
      width: pillRight - pillLeft + 34,
      height: 60,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _toggle(a),
        child: AnimatedBuilder(
          animation: t,
          builder: (context, child) {
            final k = t.value;
            final fly = span(k, 0, 0.6, const Cubic(0.3, 0.0, 0.2, 1.0));
            final target = slot.center;
            final ctrl = Offset(lerp(origin.dx, target.dx, 0.2), math.min(origin.dy, target.dy) - 90);
            final p = _bezier(origin, ctrl, target, fly) - target;
            final pop = spring(span(k, 0.35, 1, Curves.linear), bounce: 0.55, freq: 2.4);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 30,
                  top: 30 - 22.5,
                  width: pillRight - pillLeft,
                  height: 45,
                  child: Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()..scaleByDouble(math.max(0.001, pop), 1, 1, 1),
                    child: Opacity(opacity: span(k, 0.4, 0.6, Curves.linear), child: _pill(picked)),
                  ),
                ),
                TextAt(
                  x: slot.right - pillLeft + 30 + 9 + (1 - pop) * 16,
                  baseline: a.baseline - cy + 30,
                  width: 120,
                  style: style,
                  child: Opacity(opacity: span(k, 0.55, 0.8, Curves.linear), child: Label(a.label, style)),
                ),
                Positioned(
                  left: slot.left - pillLeft + 30 + p.dx,
                  top: slot.top - cy + 30 + p.dy,
                  width: slot.width,
                  height: slot.height,
                  child: _disc(a, k, fly, picked),
                ),
                if (k > 0.55 && k < 1) _landRing(slot, pillLeft, cy, span(k, 0.55, 1, Curves.easeOut)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _landRing(Sprite slot, double pillLeft, double cy, double t) {
    final r = slot.width / 2 * lerp(1, 1.9, t);
    final c = Offset(slot.center.dx - pillLeft + 30, 30);
    return Positioned(
      left: c.dx - r,
      top: c.dy - r,
      width: r * 2,
      height: r * 2,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Hue.cyan.withValues(alpha: 0.8 * (1 - t)),
              width: 2.2 * (1 - t) + 0.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _disc(Activity a, double k, double fly, bool picked) {
    return Pressable(
      onTap: () => _toggle(a),
      scale: 0.88,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: picked ? 1 : 0),
        duration: const Duration(milliseconds: 720),
        curve: const Cubic(0.3, 1.25, 0.4, 1.0),
        child: a.sprite.image(),
        builder: (context, flip, child) {
          final spin = (1 - fly) * math.pi * 2.2 + flip * math.pi * 2;
          final m = Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateY(spin)
            ..scaleByDouble(lerp(0.3, 1, fly), lerp(0.3, 1, fly), 1, 1);
          return Opacity(
            opacity: span(k, 0, 0.2, Curves.linear),
            child: Transform(
              alignment: Alignment.center,
              transform: m,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (flip > 0)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Hue.cyan.withValues(alpha: 0.7 * flip.clamp(0.0, 1.0)),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  child!,
                  Positioned(
                    right: -3,
                    top: -3,
                    width: 18,
                    height: 18,
                    child: Opacity(
                      opacity: flip.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: spring(flip.clamp(0.0, 1.0), bounce: 0.6),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [Hue.aqua, Hue.cyan]),
                            border: Border.all(color: Colors.white, width: 1.4),
                            boxShadow: const [BoxShadow(color: Color(0xAA4FD8FF), blurRadius: 8)],
                          ),
                          child: Center(child: PhIcon(PhosphorBold.check, size: 11, color: Hue.navy)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _pill(bool picked) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: picked ? 1 : 0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, lit, _) => Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Glass(
              lit: lit,
              style: const GlassStyle(
                fill: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xE8025697),
                    Color(0xE8006BA6),
                    Color(0xE8005C9A),
                    Color(0xE80166A3),
                    Color(0xE8024E95),
                  ],
                  stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                ),
                rim: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF8EE6FF), Color(0x6648B8E8), Color(0xCC7FE0FF)],
                ),
                rimWidth: 1.3,
                radius: 22.5,
                glow: Glow(Color(0x6640C8FF), blur: 6, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Offset _bezier(Offset a, Offset b, Offset c, double t) {
    final u = 1 - t;
    return a * (u * u) + b * (2 * u * t) + c * (t * t);
  }

  Widget _title() {
    final style = typo(
      35.3,
      weight: FontWeight.w700,
      color: const Color(0xFFFCFDFE),
      shadows: const [Shadow(color: Color(0x88071F6A), blurRadius: 10)],
    );
    return TextAt(
      x: 188.67,
      baseline: 614.3,
      anchor: 0.5,
      style: style,
      child: GlyphReveal(
        text: 'Choose Your Path',
        style: style,
        progress: _phase(0.3, 0.72),
        stagger: 0.5,
        lift: 18,
        flip: -1.3,
      ),
    );
  }

  Widget _body() {
    final style = typo(18.05, weight: FontWeight.w500, color: const Color(0xFFD2E5FC));
    final wipe = _phase(0.48, 0.9, Curves.easeInOut);
    Widget line(InlineSpan text, double cx, double baseline, double delay) {
      return TextAt(
        x: cx,
        baseline: baseline,
        anchor: 0.5,
        style: style,
        child: AnimatedBuilder(
          animation: wipe,
          child: Text.rich(text, style: style, maxLines: 1, softWrap: false),
          builder: (context, child) {
            final p = ((wipe.value - delay) / (1 - delay)).clamp(0.0, 1.0);
            if (p >= 1) return child!;
            return ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => LinearGradient(
                colors: const [Colors.white, Colors.white, Colors.transparent],
                stops: [0, (p * 1.2 - 0.2).clamp(0.0, 1.0), (p * 1.2).clamp(0.0, 1.0)],
              ).createShader(rect),
              child: child,
            );
          },
        ),
      );
    }

    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          line(const TextSpan(text: 'Select your fitness goals and let'), 190.5, 649.8, 0),
          line(
            const TextSpan(
              children: [
                TextSpan(text: 'Move'),
                TextSpan(
                  text: 'Quest',
                  style: TextStyle(color: Color(0xFF7FDDF5)),
                ),
                TextSpan(text: ' build your journey.'),
              ],
            ),
            190.9,
            674.5,
            0.18,
          ),
        ],
      ),
    );
  }

  Widget _dots() {
    final t = _phase(0.6, 0.85);
    return Positioned(
      left: 140,
      top: 705,
      width: 110,
      height: 24,
      child: AnimatedBuilder(
        animation: t,
        builder: (context, _) => Tick(builder: (context, s, _) => CustomPaint(painter: _DotsPainter(t.value, s))),
      ),
    );
  }

  Widget _nextButton() {
    final t = _phase(0.62, 0.95);
    final style = typo(18.2, weight: FontWeight.w700, color: Colors.white);
    return Positioned(
      left: 25.5,
      top: 756.2,
      width: 339.8,
      height: 57.6,
      child: Staged(
        animation: t,
        begin: 0,
        end: 1,
        offset: const Offset(0, 30),
        scale: 0.86,
        rotateX: 0.8,
        curve: settle,
        child: Pressable(
          onTap: _next,
          child: Tick(
            builder: (context, s, _) => CustomPaint(
              painter: NeonPainter(
                style: NeonStyle(
                  fill: LinearGradient(
                    colors: const [
                      Color(0xFF2596FF),
                      Color(0xFF1C6CFD),
                      Color(0xFF4867FD),
                      Color(0xFF6A63FC),
                      Color(0xFFA070FA),
                    ],
                    stops: const [0.0, 0.22, 0.52, 0.75, 1.0],
                    transform: _Slide(0.04 * wave(s, 5.0)),
                  ),
                  overlays: const [
                    LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x7A6FF2FF), Color(0x2250D8FF), Color(0x00000000), Color(0x10000A40)],
                      stops: [0.0, 0.3, 0.6, 1.0],
                    ),
                  ],
                  rim: const LinearGradient(colors: [Color(0xFFC8FAFF), Color(0xFFE8F4FF), Color(0xFFE6D8FF)]),
                  rimWidth: 1.6,
                  halo: const Glow(Color(0xAA1D46FF), blur: 12, width: 8, spread: 2),
                  inner: const Glow(Color(0x6690E8FF), blur: 5, width: 4),
                ),
                sheen: ((s % 4.4) / 4.4) * 2.2 - 0.4,
                halo: 0.85 + 0.15 * wave(s, 2.2),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  TextAt(x: 170 - 25.5, baseline: 791.7 - 756.2, style: style, child: Label('Next', style)),
                  Positioned(
                    left: 226.7 - 25.5 - 10.5 + 2.4 * math.max(0, wave(s, 1.2)),
                    top: 785.4 - 756.2 - 10.5,
                    child: const PhIcon(PhosphorBold.arrowRight, size: 21, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Slide extends GradientTransform {
  const _Slide(this.dx);

  final double dx;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) => Matrix4.translationValues(bounds.width * dx, 0, 0);
}

class _DotsPainter extends CustomPainter {
  _DotsPainter(this.t, this.s);

  final double t;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    const xs = [156.0, 181.5, 206.5, 231.5];
    for (var i = 0; i < xs.length; i++) {
      final k = spring(((t - i * 0.12) / 0.6).clamp(0.0, 1.0), bounce: 0.6);
      if (k <= 0) continue;
      final c = Offset(xs[i] - 140, 717 - 705);
      if (i == 0) {
        final pulse = 0.5 + 0.5 * wave(s, 1.6);
        canvas.drawCircle(
          c,
          7 + pulse * 2.5,
          Paint()
            ..color = Hue.cyan.withValues(alpha: 0.5 * k)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawCircle(c, 5.2 * k, Paint()..color = Colors.white);
        canvas.drawCircle(c, 3.2 * k, Paint()..color = const Color(0xFFBFF7FF));
      } else {
        canvas.drawCircle(c, 5.2 * k, Paint()..color = const Color(0xFF3A4D9A).withValues(alpha: 0.85));
        canvas.drawCircle(
          c,
          5.2 * k,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8
            ..color = const Color(0xFF5F74C4).withValues(alpha: 0.6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.t != t || old.s != s;
}
