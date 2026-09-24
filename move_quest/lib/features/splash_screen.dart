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
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _intro;
  final _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400))..forward();
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

  void _begin() {
    HapticFeedback.mediumImpact();
    final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box == null ? const Offset(196, 700) : box.localToGlobal(box.size.center(Offset.zero));
    Navigator.of(context).push(PortalRoute(origin: origin, builder: (_) => const OnboardingScreen()));
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
              SceneLayer(children: [_scene(), _runner()]),
              Motes(area: const Rect.fromLTWH(0, 250, 393, 440), seed: 3, count: 22),
              _logo(),
              _tagline(),
              Floor(children: [_button(), _indicator(), _footer()]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scene() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _intro,
        builder: (context, child) {
          final t = span(_intro.value, 0, 0.55, const Cubic(0.2, 0.8, 0.2, 1));
          return Transform.scale(
            scale: lerp(1.14, 1.0, t),
            alignment: const Alignment(0, -0.2),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.6 * (1 - t)), BlendMode.srcATop),
              child: child,
            ),
          );
        },
        child: Depth(
          depth: -5,
          cover: const Size(393, 852),
          child: Image.asset(
            Scenes.splash,
            fit: BoxFit.fill,
            width: 393,
            height: 852,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }

  Widget _runner() {
    const r = Art.splashRunner;
    return r.place(
      child: Depth(
        depth: 9,
        child: Breathe(
          period: 3.4,
          amount: 0.008,
          bob: 1.0,
          child: Energize(progress: _phase(0.14, 0.6), child: r.image()),
        ),
      ),
    );
  }

  Widget _logo() {
    final rise = _phase(0.06, 0.4);
    return Positioned.fill(
      child: Depth(
        depth: 3,
        idle: 0.2,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Art.logoPeaks.place(
              child: AnimatedBuilder(
                animation: rise,
                child: Art.logoPeaks.image(),
                builder: (context, child) {
                  final k = spring(rise.value, bounce: 0.3, freq: 2.4);
                  return ClipRect(
                    clipper: const _GroundClip(),
                    child: Transform.translate(offset: Offset(0, (1 - k) * 46), child: child),
                  );
                },
              ),
            ),
            Art.logoFlag.place(
              child: AnimatedBuilder(
                animation: _intro,
                builder: (context, child) =>
                    Opacity(opacity: span(_intro.value, 0.3, 0.36, Curves.linear), child: child),
                child: WavingFlag(sprite: Art.logoFlag, unfurl: _phase(0.3, 0.62)),
              ),
            ),
            Art.logoMove.place(child: _word(Art.logoMove, 0.2, 0.52, 0.0)),
            Art.logoQuest.place(child: _word(Art.logoQuest, 0.28, 0.6, 0.35)),
          ],
        ),
      ),
    );
  }

  Widget _word(Sprite sprite, double a, double b, double delay) {
    final t = _phase(a, b);
    return AnimatedBuilder(
      animation: t,
      child: Sheen(period: 4.6, delay: 3.2 + delay, child: sprite.image()),
      builder: (context, child) {
        final k = spring(t.value, bounce: 0.45, freq: 2.2);
        final m = Matrix4.identity()
          ..setEntry(3, 2, 0.0022)
          ..rotateX((1 - k) * -1.45)
          ..scaleByDouble(lerp(0.6, 1, k), lerp(0.6, 1, k), 1, 1);
        return Opacity(
          opacity: span(t.value, 0, 0.25, Curves.linear),
          child: Transform(alignment: Alignment.bottomCenter, transform: m, child: child),
        );
      },
    );
  }

  Widget _tagline() {
    final style = typo(
      22.0,
      weight: FontWeight.w600,
      italic: true,
      color: const Color(0xFFECFEFE),
      shadows: [
        const Shadow(color: Color(0xCC04124A), blurRadius: 8),
        const Shadow(color: Color(0x6604124A), blurRadius: 2, offset: Offset(0, 1)),
      ],
    );
    return Positioned.fill(
      child: Depth(
        depth: 2,
        idle: 0.2,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            TextAt(
              x: 198.2,
              baseline: 258.7,
              anchor: 0.5,
              style: style,
              child: GlyphReveal(
                text: 'Real Movement. Bigger Goals.',
                style: style,
                progress: _phase(0.42, 0.74),
                stagger: 0.6,
                lift: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final _tapStyle = typo(22.4, weight: FontWeight.w700, color: const Color(0xFFF8FDFE));

  Widget _button() {
    final trace = _phase(0.34, 0.6, Curves.easeInOut);
    final bloom = _phase(0.52, 0.7, Curves.easeOut);
    final label = _phase(0.6, 0.82);
    const style = NeonStyle(
      fill: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3050EE), Color(0xFF062BD3), Color(0xFF002CCB), Color(0xFF1250EE), Color(0xFF3FA6FB)],
        stops: [0.0, 0.32, 0.55, 0.8, 1.0],
      ),
      overlays: [
        LinearGradient(
          colors: [Color(0xCC6BD2FF), Color(0x003E78FF), Color(0x00000000), Color(0x003E78FF), Color(0xAA6BD8FF)],
          stops: [0.0, 0.1, 0.5, 0.9, 1.0],
        ),
      ],
      rim: LinearGradient(colors: [Color(0xFFE6FEFF), Color(0xFFBFEFFF), Color(0xFFF3FCFF)]),
      rimWidth: 1.7,
      halo: Glow(Color(0xDD9A5CF0), blur: 9, width: 7, spread: 3),
      inner: Glow(Color(0x884FD8FF), blur: 6, width: 6),
    );
    return Positioned(
      key: _buttonKey,
      left: 68.2,
      top: 668.7,
      width: 258.6,
      height: 59.6,
      child: Pressable(
        onTap: _begin,
        scale: 0.94,
        child: Tick(
          builder: (context, s, _) => AnimatedBuilder(
            animation: _intro,
            builder: (context, _) => CustomPaint(
              painter: NeonPainter(
                style: style,
                trace: trace.value,
                bloom: bloom.value,
                sheen: _intro.value < 1 ? null : ((s % 3.8) / 3.8) * 1.9 - 0.3,
                spark: _intro.value < 1 ? null : (s / 3.2) % 1,
                sparkColor: const Color(0xFFBFF6FF),
                halo: 0.8 + 0.2 * wave(s, 2.4),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  TextAt(
                    x: 190.83 - 68.2,
                    baseline: 705 - 668.7 + (1 - label.value) * 8,
                    anchor: 0.5,
                    width: 220,
                    style: _tapStyle,
                    child: Opacity(opacity: label.value, child: Label('Tap to Begin', _tapStyle)),
                  ),
                  Positioned(
                    left: 285.8 - 68.2 - 12.4 + 2.6 * math.max(0, wave(s, 1.3)) * label.value,
                    top: 698.8 - 668.7 - 12.4,
                    child: Opacity(
                      opacity: label.value,
                      child: const PhIcon(PhosphorBold.arrowRight, size: 24.8, color: Color(0xFFF4FCFF)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _indicator() {
    final t = _phase(0.66, 0.86);
    return Positioned(
      left: 156.5,
      top: 750,
      width: 80,
      height: 21.5,
      child: AnimatedBuilder(
        animation: t,
        builder: (context, _) => Tick(builder: (context, s, _) => CustomPaint(painter: _IndicatorPainter(t.value, s))),
      ),
    );
  }

  Widget _footer() {
    final t = _phase(0.72, 0.94);
    final style = typo(
      15,
      weight: FontWeight.w500,
      color: const Color(0xFFF4F8FE),
      shadows: const [
        Shadow(color: Color(0xE6020A36), blurRadius: 6),
        Shadow(color: Color(0x99020A36), blurRadius: 2),
      ],
    );
    return Positioned(
      left: 0,
      right: 0,
      top: 800,
      height: 20,
      child: AnimatedBuilder(
        animation: t,
        builder: (context, _) => Tick(
          builder: (context, s, _) {
            final k = t.value;
            final pulse = k >= 1 ? math.max(0.0, wave(s, 1.6)) * 3 : 0.0;
            final spread = (1 - span(k, 0, 1, gentle)) * 4;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                TextAt(
                  x: 196.5,
                  baseline: 810.67 - 800,
                  anchor: 0.5,
                  style: style,
                  child: Opacity(
                    opacity: span(k, 0, 0.5, Curves.linear),
                    child: Label('Your Fitness Adventure Starts Here', style.copyWith(letterSpacing: spread)),
                  ),
                ),
                Positioned(
                  left: 55.4 - 20 * (1 - k) + pulse,
                  top: 0,
                  width: 18.5,
                  height: 10,
                  child: Opacity(opacity: k, child: const _FooterArrow(right: true)),
                ),
                Positioned(
                  left: 319.4 + 20 * (1 - k) - pulse,
                  top: 0,
                  width: 18.5,
                  height: 10,
                  child: Opacity(opacity: k, child: const _FooterArrow(right: false)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GroundClip extends CustomClipper<Rect> {
  const _GroundClip();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(-20, -60, size.width + 20, size.height + 1);

  @override
  bool shouldReclip(_GroundClip old) => false;
}

class _IndicatorPainter extends CustomPainter {
  _IndicatorPainter(this.t, this.s);

  final double t;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final track = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10.75));
    canvas.drawRRect(
      track,
      Paint()..color = const Color(0xFF020E45).withValues(alpha: 0.9 * span(t, 0, 0.3, Curves.linear)),
    );
    canvas.drawRRect(
      track.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF2A4FC0).withValues(alpha: 0.35 * t),
    );
    const segs = [(5.5, 26.5, Color(0xFFFFFFFF)), (32.5, 41.5, Color(0xFFFFFFFF)), (52.5, 73.5, Color(0xFF63E8FF))];
    for (var i = 0; i < segs.length; i++) {
      final (a, b, c) = segs[i];
      final k = spring(((t - 0.2 - i * 0.18) / 0.5).clamp(0.0, 1.0), bounce: 0.5);
      if (k <= 0) continue;
      final w = (b - a) * k;
      final mid = (a + b) / 2;
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(mid, 10.25), width: w, height: 6.5),
        const Radius.circular(3.25),
      );
      if (i == 2) {
        canvas.drawRRect(
          r.inflate(2),
          Paint()
            ..color = c.withValues(alpha: 0.55 + 0.25 * wave(s, 1.8))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      } else {
        canvas.drawRRect(
          r.inflate(1),
          Paint()
            ..color = const Color(0xFF9FD8FF).withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
      canvas.drawRRect(r, Paint()..color = c);
    }
  }

  @override
  bool shouldRepaint(_IndicatorPainter old) => old.t != t || old.s != s;
}

class _FooterArrow extends StatelessWidget {
  const _FooterArrow({required this.right});

  final bool right;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxWidth: 30,
      maxHeight: 30,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scaleByDouble(right ? 1 : -1, 0.46, 1, 1),
        child: const PhIcon(
          PhosphorBold.arrowRight,
          size: 25,
          color: Color(0xFF5BE6FA),
          shadows: [Shadow(color: Color(0xAA2FD2FF), blurRadius: 5)],
        ),
      ),
    );
  }
}
