import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/fx.dart';
import '../widgets/parts.dart';
import '../widgets/place.dart';

/// Onboarding 1: "Train. Level Up. Explore."
///
/// The logo slams in with a shockwave and a camera shake, the crown drops onto
/// it and bursts into sparkles, the tagline is wiped on by a beam of light and
/// the hero rises into frame. Dragging anywhere tilts the scene in depth.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.onNext});

  final void Function(Offset origin) onNext;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _tiltBack;
  Offset _tilt = Offset.zero;
  Offset _tiltFrom = Offset.zero;
  bool _slammed = false;
  bool _crowned = false;

  static const _logoCenter = Offset(205.8, 116);
  static const _crownTip = Offset(195, 44);

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..addListener(_cues)
      ..forward();
    _tiltBack = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..addListener(() => setState(() => _tilt = Offset.lerp(_tiltFrom, Offset.zero, settle.transform(_tiltBack.value))!));
  }

  void _cues() {
    final f = Frame.read(context);
    final fx = FxLayer.of(context);
    if (!_slammed && _intro.value >= 0.17) {
      _slammed = true;
      HapticFeedback.mediumImpact();
      final c = Offset(_logoCenter.dx, f.y(_logoCenter.dy));
      fx.ring(c, color: const Color(0xFFFFD45A), radius: 190, life: 0.8, squash: 0.62);
      fx.ring(c, color: const Color(0xFFB487FF), radius: 140, life: 0.6, squash: 0.62);
      fx.burst(c, count: 22, colors: const [Color(0xFFFFE07A), Color(0xFFB98CFF), Colors.white], power: 210, size: 2.6);
    }
    if (!_crowned && _intro.value >= 0.42) {
      _crowned = true;
      HapticFeedback.lightImpact();
      fx.burst(Offset(_crownTip.dx, f.y(_crownTip.dy + 14)), count: 18, colors: const [Color(0xFFFFF3B0), Tone.goldHi, Colors.white], power: 120, size: 2.4);
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _tiltBack.dispose();
    super.dispose();
  }

  void _drag(DragUpdateDetails d) {
    _tiltBack.stop();
    setState(() {
      final next = _tilt + d.delta / 90;
      _tilt = Offset(next.dx.clamp(-1.0, 1.0), next.dy.clamp(-1.0, 1.0));
    });
  }

  void _release([DragEndDetails? _]) {
    _tiltFrom = _tilt;
    _tiltBack.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final f = Frame.of(context);
    final a = _intro;
    return GestureDetector(
      onPanUpdate: _drag,
      onPanEnd: _release,
      onPanCancel: _release,
      child: AnimatedBuilder(
        animation: a,
        builder: (context, _) {
          final quake = shake(span(a.value, 0.17, 0.32, Curves.linear), freq: 6, decay: 4);
          return Transform.translate(
            offset: Offset(quake * 5, quake * 3),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Transform.translate(
                  offset: _tilt * -4,
                  child: Transform.scale(
                    scale: 1 + 0.035 * (1 - span(a.value, 0, 0.7)) + 0.02 * _tilt.distance,
                    alignment: Alignment.bottomCenter,
                    child: const Plate(asset: Art.bgSplash, size: Size(402, 784.3), sky: Color(0xFF15183F), ground: Color(0xFF6E5384)),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: f.y(44),
                  height: 240,
                  child: const Twinkles(points: _stars, color: Color(0xFFDCD6FF), period: 3.4),
                ),
                _castleLights(f),
                const Positioned.fill(
                  child: Opacity(
                    opacity: 0.8,
                    child: Motes(count: 26, colors: [Color(0xFFFFE08A), Color(0xFFC7A2FF), Color(0xFF9DE6FF)], speed: 10, seed: 3, size: (0.8, 2.2)),
                  ),
                ),
                _hero(f, a),
                _logo(f, a),
                _tagline(f, a),
                _button(f, a),
                IgnorePointer(
                  child: Opacity(
                    opacity: 1 - span(a.value, 0.0, 0.14, Curves.easeOut),
                    child: const ColoredBox(color: Tone.night, child: SizedBox.expand()),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: f.b(735.5),
                  child: Staged(
                    animation: a,
                    begin: 0.8,
                    end: 1,
                    offset: const Offset(0, 10),
                    child: const Center(child: Dots(index: 0)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static const _stars = [(40.0, 30.0, 4.0), (350.0, 18.0, 3.2), (70.0, 120.0, 2.6), (360.0, 96.0, 3.6), (26.0, 206.0, 2.8), (330.0, 160.0, 2.4), (120.0, 6.0, 2.2), (290.0, 40.0, 2.0)];

  Widget _castleLights(Frame f) {
    // Window glows on the castle and the lantern island flicker like torchlight.
    const lights = [(334.0, 414.0, 16.0), (322.0, 378.0, 9.0), (346.0, 366.0, 8.0), (40.0, 393.0, 12.0), (370.0, 420.0, 8.0)];
    return Positioned.fill(
      child: IgnorePointer(
        child: Transform.translate(
          offset: _tilt * -4,
          child: Tick(
            builder: (context, s, _) => Stack(
              children: [
                for (var i = 0; i < lights.length; i++)
                  Positioned(
                    left: lights[i].$1 - lights[i].$3 * 1.6,
                    top: f.b(lights[i].$2) - lights[i].$3 * 1.6,
                    width: lights[i].$3 * 3.2,
                    height: lights[i].$3 * 3.2,
                    child: Glow(color: const Color(0xFFFFB347), opacity: 0.35 + 0.3 * (0.5 + 0.5 * math.sin(s * (5 + i) + i * 2) * math.sin(s * 2.3 + i))),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(Frame f, Animation<double> a) {
    const art = Art.heroSplash;
    final rise = span(a.value, 0.0, 0.5, swift);
    final light = span(a.value, 0.04, 0.6, Curves.easeOut);
    return Positioned(
      left: art.x + _tilt.dx * 3,
      top: f.b(art.y) + (1 - rise) * 34 + _tilt.dy * 2,
      width: art.w,
      height: art.h,
      child: Opacity(
        opacity: span(a.value, 0.0, 0.1, Curves.linear),
        child: Tick(
          builder: (context, s, _) {
            final breath = (wave(s, 3.6) + 1) / 2;
            return Transform.scale(
              scale: 1 + breath * 0.006 + (1 - rise) * 0.05,
              alignment: const Alignment(0.1, 1),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ColorFiltered(colorFilter: ColorFilter.mode(Color.lerp(const Color(0xFFFFFFFF), const Color(0x00FFFFFF), light)!, BlendMode.srcATop), child: art.image()),
                  ),
                  // Smartwatch face: a cyan pulse plus a heart-rate blip.
                  Positioned(
                    left: 230,
                    top: 252,
                    width: 26,
                    height: 26,
                    child: Glow(color: const Color(0xFF5FE6FF), opacity: 0.35 + 0.45 * math.pow(math.max(0, math.sin(s * 3.4)), 6)),
                  ),
                  // Hoodie zipper light strip.
                  Positioned(
                    left: 120,
                    top: 226,
                    width: 30,
                    height: 92,
                    child: Opacity(
                      opacity: 0.25 + 0.25 * breath,
                      child: const Glow(color: Color(0xFF3FD8FF)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _logo(Frame f, Animation<double> a) {
    const art = Art.logo;
    const crown = Rect.fromLTWH(66, 0, 64, 31);
    final slam = span(a.value, 0.0, 0.2, Curves.easeIn);
    final settleT = span(a.value, 0.17, 0.4, pop);
    final scale = a.value < 0.17 ? lerp(2.6, 0.92, slam) : lerp(0.92, 1, settleT);
    final drop = span(a.value, 0.28, 0.46, Curves.easeIn);
    final land = span(a.value, 0.42, 0.62, Curves.linear);
    final crownY = a.value < 0.42 ? lerp(-90, 0, drop) : -math.sin(land * math.pi) * 10 * (1 - land) - shake(land, freq: 2, decay: 3) * 3;
    final crownR = a.value < 0.42 ? lerp(-0.9, 0, drop) : shake(land, freq: 2.5, decay: 4) * 0.12;
    final image = art.image();
    return Positioned(
      left: art.x,
      top: f.y(art.y),
      width: art.w,
      height: art.h,
      child: Bob(
        amplitude: 2.2,
        period: 4.2,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -40,
              right: -40,
              top: -30,
              bottom: -30,
              child: Opacity(
                opacity: span(a.value, 0.17, 0.5) * 0.55,
                child: const Glow(color: Color(0xFF7B4DFF)),
              ),
            ),
            Opacity(
              opacity: span(a.value, 0.02, 0.14, Curves.linear),
              child: Transform.scale(
                scale: scale,
                child: ImageFiltered(
                  enabled: a.value < 0.17,
                  imageFilter: ui.ImageFilter.blur(sigmaX: (1 - slam) * 8 + 0.01, sigmaY: (1 - slam) * 8 + 0.01),
                  child: Sheen(
                    period: 4.5,
                    delay: 1.2,
                    strength: 0.6,
                    width: 0.16,
                    child: ClipPath(clipper: const _Without(crown), child: image),
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: span(a.value, 0.28, 0.33, Curves.linear),
              child: Transform.translate(
                offset: Offset(0, crownY),
                child: Transform.rotate(
                  angle: crownR,
                  alignment: const Alignment(-0.14, -0.6),
                  child: ClipRect(clipper: const _Only(crown), child: image),
                ),
              ),
            ),
            Positioned(
              left: 60,
              top: -14,
              width: 80,
              height: 50,
              child: Opacity(
                opacity: span(a.value, 0.5, 0.7),
                child: const Twinkles(points: [(12, 24, 6), (68, 22, 5), (40, 4, 7)], color: Color(0xFFFFF6C8), period: 2.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagline(Frame f, Animation<double> a) {
    final wipe = span(a.value, 0.4, 0.66, glide);
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: f.y(216 - ascent * 18.3),
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) =>
                LinearGradient(colors: const [Colors.white, Colors.white, Colors.transparent], stops: [0, (lerp(0.2, 0.84, wipe) - 0.04).clamp(0, 1), lerp(0.2, 0.84, wipe)]).createShader(r),
            child: Transform.translate(
              offset: const Offset(8.5, 0),
              child: Center(
                child: GradientText('Train. Level Up. Explore.', style: tight(Typo.tagline), colors: const [Color(0xFFFFF7C9), Color(0xFFFFE07A), Color(0xFFF6B935)]),
              ),
            ),
          ),
        ),
        // The light beam riding the wipe edge.
        if (wipe > 0 && wipe < 1)
          Positioned(
            left: lerp(-6, 402, lerp(0.2, 0.84, wipe)) - 18,
            top: f.y(194),
            width: 36,
            height: 30,
            child: const Glow(color: Color(0xFFFFF0B0)),
          ),
        Positioned(
          left: 0,
          right: 0,
          top: f.y(245.4 - ascent * 14.8),
          child: Staged(
            animation: a,
            begin: 0.55,
            end: 0.8,
            offset: const Offset(0, 14),
            blur: 6,
            child: Transform.translate(
              offset: const Offset(7.5, 0),
              child: Column(
                children: [
                  Line('Turn your workouts into', style: tight(Typo.intro)),
                  Transform.translate(
                    offset: const Offset(0, -1.6),
                    child: Line('an epic adventure!', style: tight(Typo.intro)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _button(Frame f, Animation<double> a) {
    return Positioned(
      left: 69,
      top: f.b(641),
      child: Staged(
        animation: a,
        begin: 0.68,
        end: 0.95,
        offset: const Offset(0, 60),
        scale: 0.7,
        curve: pop,
        child: GoldButton(label: 'Get Started', icon: Ph.arrowRight, width: 270, height: 70, onTap: () => widget.onNext(Offset(204, f.b(676)))),
      ),
    );
  }
}

class _Only extends CustomClipper<Rect> {
  const _Only(this.rect);

  final Rect rect;

  @override
  Rect getClip(Size size) => rect;

  @override
  bool shouldReclip(_Only old) => old.rect != rect;
}

class _Without extends CustomClipper<Path> {
  const _Without(this.rect);

  final Rect rect;

  @override
  Path getClip(Size size) => Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), Path()..addRect(rect));

  @override
  bool shouldReclip(_Without old) => old.rect != rect;
}
