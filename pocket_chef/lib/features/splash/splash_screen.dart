import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/routes.dart';
import '../../core/type.dart';
import '../../widgets/chef_hat.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/pop_text.dart';
import '../shell/shell.dart';
import 'pan_sparks.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const reference = 903.8;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _in;
  final _cta = GlobalKey();

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..forward();
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  void _start() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(RevealRoute(center: centerOf(context, _cta), builder: (_) => const Shell()));
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    double low(double y) => frame.height - frame.drop - (SplashScreen.reference - y);
    final e = _in;

    final pocket = outfit(27.5);
    final chef = outfit(27.5, color: const Color(0xFFE81A2E));
    final headline = gummy(50, color: Palette.navy).copyWith(letterSpacing: 0.6);
    final shout = gummy(59, color: Palette.cherry).copyWith(letterSpacing: 0.6);
    final sub = inter(16.2, 400, color: const Color(0xFF707076));
    final have = inter(12.9, 400, color: const Color(0xFF7B7777));
    final sign = inter(13.1, 600, color: const Color(0xFFE0223A));

    final roomTop = 325 + lift;
    final roomBottom = low(771);
    final squeeze = math.min(1.0, (roomBottom - roomTop) / 446);
    final mascotBase = low(757.3);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF4EA),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: math.min(0.0, lift),
            width: Frame.width,
            height: math.max(Art.splashPlate.height + lift, frame.height) - math.min(0.0, lift),
            child: AnimatedBuilder(
              animation: e,
              builder: (context, child) {
                final t = span(e.value, 0, 0.4, Curves.easeOutCubic);
                return Opacity(
                  opacity: t,
                  child: Transform.scale(scale: lerp(1.08, 1, t), child: child),
                );
              },
              child: Tick(
                builder: (context, s, child) => Transform.translate(
                  offset: Offset(2.4 * wave(s, 11), 3 * wave(s, 13, 0.3)),
                  child: Transform.scale(scale: 1.012, child: child),
                ),
                child: Image.asset(Art.splashPlate.asset, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
              ),
            ),
          ),
          Positioned(
            left: 26.4,
            top: 79.4 + lift,
            child: _DropHat(animation: e),
          ),
          Positioned(
            left: 75.67 - bearing('P', pocket),
            top: 109.67 + lift - 100,
            child: Baseline(
              baseline: 100,
              baselineType: TextBaseline.alphabetic,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  PopText(text: 'Pocket', style: pocket, animation: e, begin: 0.12, end: 0.42, rise: 14, spin: 0.12),
                  PopText(text: 'Chef', style: chef, animation: e, begin: 0.2, end: 0.48, rise: 14, spin: 0.12),
                ],
              ),
            ),
          ),
          Positioned(
            left: 29.9,
            top: 201.75 + lift - 100,
            child: _Tilt(
              degrees: 3.25,
              child: PopText(text: 'Small Bites,', style: headline, animation: e, begin: 0.18, end: 0.56, stretch: 1.175, ripple: 3.2),
            ),
          ),
          Positioned(
            left: 32.5,
            top: 260.75 + lift - 100,
            child: _Tilt(
              degrees: 3.0,
              child: PopText(
                text: 'Big Smiles!',
                style: shout,
                animation: e,
                begin: 0.3,
                end: 0.68,
                stretch: 1.175,
                ripple: 3.2,
                ripplePhase: 0.35,
              ),
            ),
          ),
          Positioned(
            left: 336,
            top: 218 + lift,
            width: 44,
            height: 56,
            child: _Accent(animation: e),
          ),
          Positioned(
            left: 0,
            top: lift,
            width: Frame.width,
            height: 340,
            child: _Wipe(
              animation: e,
              begin: 0.46,
              end: 0.78,
              child: Stack(
                children: [
                  Pin(x: 32.0, base: 296.4, text: 'Simple recipes, tasty results.', style: sub),
                  Pin(x: 32.0, base: 321.9, text: "Let's cook something amazing!", style: sub),
                ],
              ),
            ),
          ),
          Positioned(
            left: Art.splashMascot.left,
            top: mascotBase - (757.3 - Art.splashMascot.top),
            width: Frame.width - Art.splashMascot.left,
            height: 757.3 - Art.splashMascot.top,
            child: Transform.scale(
              scale: squeeze,
              alignment: Alignment((Art.splashMascot.center.dx - Art.splashMascot.left) / (Frame.width - Art.splashMascot.left) * 2 - 1, 1),
              child: _Mascot(animation: e),
            ),
          ),
          Positioned(
            left: 29,
            top: low(771),
            child: AnimatedBuilder(
              animation: e,
              builder: (context, child) {
                final t = span(e.value, 0.62, 0.95, settle);
                return Opacity(
                  opacity: span(e.value, 0.62, 0.8, Curves.linear),
                  child: Transform.translate(offset: Offset(0, 60 * (1 - t)), child: child),
                );
              },
              child: KeyedSubtree(
                key: _cta,
                child: GlowButton(
                  width: 337,
                  height: 61,
                  arrowX: 303.5,
                  labelShift: -3.8,
                  onTap: _start,
                  label: Text('Get Started', style: inter(20.1, 600, color: Colors.white)),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: low(840),
            width: Frame.width,
            height: 40,
            child: Staged(
              animation: e,
              begin: 0.74,
              end: 1,
              offset: const Offset(0, 12),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Pin(x: 94.0, base: 27.3, text: 'Already have an account?', style: have),
                  Positioned(
                    left: 250,
                    top: 8,
                    width: 60,
                    height: 26,
                    child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _start),
                  ),
                  Pin(x: 258.67, base: 27.3, text: 'Sign In', style: sign),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tilt extends StatelessWidget {
  const _Tilt({required this.degrees, required this.child});

  final double degrees;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Transform(
      origin: const Offset(0, 100),
      transform: Matrix4.rotationZ(-degrees * math.pi / 180),
      child: Baseline(baseline: 100, baselineType: TextBaseline.alphabetic, child: child),
    );
  }
}

class _DropHat extends StatelessWidget {
  const _DropHat({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final raw = ((animation.value - 0.04) / 0.34).clamp(0.0, 1.0);
        final fall = Curves.easeInCubic.transform((raw / 0.45).clamp(0.0, 1.0));
        final land = ((raw - 0.45) / 0.55).clamp(0.0, 1.0);
        final squash = land > 0 ? math.sin(land * math.pi * 2.5) * 0.22 * (1 - land) : 0.0;
        final y = -90 * (1 - fall);
        final spin = -0.9 * (1 - fall);
        return Opacity(
          opacity: (raw * 4).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, y),
            child: Transform.rotate(
              angle: spin,
              child: Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.diagonal3Values(1 + squash, 1 - squash, 1),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Tick(
        builder: (context, s, child) {
          final beat = math.pow(math.max(0.0, math.sin(s * math.pi * 2 / 4.2)), 12).toDouble();
          return ChefHat(size: 40, puff: 0.06 * beat);
        },
      ),
    );
  }
}

class _Accent extends StatelessWidget {
  const _Accent({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = span(animation.value, 0.62, 0.8, Curves.easeOutBack);
        return Tick(builder: (context, s, _) => CustomPaint(painter: _AccentPainter(t, s)));
      },
    );
  }
}

class _AccentPainter extends CustomPainter {
  _AccentPainter(this.grow, this.seconds);

  final double grow;
  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    if (grow <= 0) return;
    final beat = math.pow(math.max(0.0, math.sin((seconds / 3.6 - 0.55) * math.pi * 2)), 8).toDouble();
    final paint = Paint()
      ..color = Palette.cherry
      ..strokeWidth = 3.3
      ..strokeCap = StrokeCap.round;
    void stroke(Offset a, Offset b) {
      final mid = (a + b) / 2;
      final out = (b - a) * (grow * (1 + 0.18 * beat)) / 2;
      final push = const Offset(1.4, -1.0) * (3 * beat);
      canvas.drawLine(mid - out + push, mid + out + push, paint);
    }

    stroke(const Offset(15.2, 28.9), const Offset(24.6, 10.8));
    stroke(const Offset(17.2, 48.1), const Offset(33.4, 36.6));
  }

  @override
  bool shouldRepaint(_AccentPainter old) => old.grow != grow || old.seconds != seconds;
}

class _Wipe extends StatelessWidget {
  const _Wipe({required this.animation, required this.begin, required this.end, required this.child});

  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = span(animation.value, begin, end, Curves.easeOutCubic);
        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => LinearGradient(
            colors: const [Colors.white, Colors.white, Color(0x00FFFFFF)],
            stops: [0, t, math.min(1.0, t + 0.12)],
          ).createShader(rect),
          child: Transform.translate(offset: Offset(0, 6 * (1 - t)), child: child),
        );
      },
      child: child,
    );
  }
}

class _Mascot extends StatelessWidget {
  const _Mascot({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final origin = Offset(Art.splashMascot.left, Art.splashMascot.top);
    final pan = const Offset(352, 588) - origin;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final raw = ((animation.value - 0.3) / 0.46).clamp(0.0, 1.0);
        final s = spring(raw, bounce: 0.35, freq: 2.2);
        final squash = raw > 0.35 ? math.sin((raw - 0.35) / 0.65 * math.pi * 2) * 0.07 * (1 - raw) : 0.0;
        return Opacity(
          opacity: (raw * 5).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 320 * (1 - s)),
            child: Transform(
              alignment: const Alignment(-0.1, 1),
              transform: Matrix4.diagonal3Values(lerp(0.6, 1, s) * (1 + squash), lerp(0.6, 1, s) * (1 - squash), 1),
              child: child,
            ),
          ),
        );
      },
      child: Tick(
        builder: (context, seconds, child) {
          return Transform.translate(
            offset: Offset(0, 5.5 * wave(seconds, 3.4)),
            child: Transform.rotate(angle: 0.018 * wave(seconds, 5.2, 0.2), alignment: const Alignment(-0.1, 1), child: child),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(left: 0, top: 0, width: Art.splashMascot.width, height: Art.splashMascot.height, child: Art.splashMascot.image()),
            Positioned(left: pan.dx - 40, top: pan.dy - 150, width: 80, height: 170, child: const PanSparks()),
            for (final (i, piece) in Art.toss.indexed)
              _TossPiece(piece: piece.shift(-origin.dx, -origin.dy), pan: pan, index: i, animation: animation),
          ],
        ),
      ),
    );
  }
}

class _TossPiece extends StatelessWidget {
  const _TossPiece({required this.piece, required this.pan, required this.index, required this.animation});

  final Sprite piece;
  final Offset pan;
  final int index;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final seed = math.Random(index * 7 + 3);
    final period = 1.7 + seed.nextDouble() * 0.9;
    final phase = seed.nextDouble();
    final height = 5.0 + seed.nextDouble() * 9;
    final spinAmp = 0.12 + seed.nextDouble() * 0.28;
    final from = pan - piece.center;
    return Positioned(
      left: piece.left,
      top: piece.top,
      width: piece.width,
      height: piece.height,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final begin = 0.56 + index * 0.025;
          final t = span(animation.value, begin, begin + 0.22, Curves.easeOutCubic);
          final arc = -70 * math.sin(t * math.pi) * (1 - t * 0.4);
          return Opacity(
            opacity: span(animation.value, begin, begin + 0.06, Curves.linear),
            child: Transform.translate(
              offset: Offset(from.dx * (1 - t), from.dy * (1 - t) + arc * (1 - t)),
              child: Transform.scale(
                scale: lerp(0.3, 1, t),
                child: Transform.rotate(angle: 3 * (1 - t), child: child),
              ),
            ),
          );
        },
        child: Tick(
          builder: (context, s, child) {
            final u = (s / period + phase) % 1.0;
            final hop = math.sin(u * math.pi);
            return Transform.translate(
              offset: Offset(1.6 * math.sin(u * math.pi * 2), -height * hop * hop),
              child: Transform.rotate(angle: spinAmp * math.sin((s / period + phase) * math.pi * 2), child: child),
            );
          },
          child: piece.image(),
        ),
      ),
    );
  }
}
