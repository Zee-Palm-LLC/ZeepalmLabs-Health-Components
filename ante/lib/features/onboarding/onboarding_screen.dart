import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/routes.dart';
import '../../core/type.dart';
import '../../widgets/comet_border.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/rolling_number.dart';
import '../../widgets/split_text.dart';
import '../home/home_screen.dart';
import 'hero_stage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _release;
  final _tilt = ValueNotifier(Offset.zero);
  final _cta = GlobalKey();
  Offset _from = Offset.zero;

  static const heroTop = 92.0;
  static const heroBottom = 388.0;
  static const groupBottom = 895.0;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..forward();
    _release = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..addListener(() => _tilt.value = Offset.lerp(_from, Offset.zero, settle.transform(_release.value))!);
  }

  @override
  void dispose() {
    _intro.dispose();
    _release.dispose();
    _tilt.dispose();
    super.dispose();
  }

  void _drag(DragUpdateDetails d) {
    _release.stop();
    final next = _tilt.value + Offset(d.delta.dx / 120, d.delta.dy / 120);
    _tilt.value = Offset(next.dx.clamp(-1.0, 1.0), next.dy.clamp(-1.0, 1.0));
  }

  void _let(DragEndDetails _) {
    _from = _tilt.value;
    _release.forward(from: 0);
  }

  void _start() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      RevealRoute(center: centerOf(context, _cta), builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final floor = frame.height - math.max(frame.bottom, 22.0) - groupBottom;
    final room = (heroBottom + floor) - (heroTop + lift);
    final squeeze = math.min(1.0, room / (heroBottom - heroTop));
    final heroShift = heroTop + lift + (room - (heroBottom - heroTop) * squeeze) / 2;

    return Scaffold(
      backgroundColor: const Color(0xFF07091A),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: floor,
            width: Frame.width,
            height: 917,
            child: _Fade(intro: _intro, child: Art.onboardPlate.image()),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: Frame.width,
            height: 917,
            child: Transform(
              transform: Matrix4.identity()
                ..translateByDouble(Frame.width / 2, heroShift, 0, 1)
                ..scaleByDouble(squeeze, squeeze, 1, 1)
                ..translateByDouble(-Frame.width / 2, -heroTop, 0, 1),
              child: GestureDetector(
                onPanUpdate: _drag,
                onPanEnd: _let,
                behavior: HitTestBehavior.translucent,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      width: Frame.width,
                      height: 430,
                      child: _Fade(
                        intro: _intro,
                        child: ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (r) => const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Colors.white, Colors.transparent],
                            stops: [0, 0.86, 1],
                          ).createShader(r),
                          child: ClipRect(
                            child: OverflowBox(
                              alignment: Alignment.topLeft,
                              maxHeight: 917,
                              child: Art.onboardPlate.image(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Frame.width, height: 917),
                    Positioned.fill(child: HeroStage(intro: _intro, tilt: _tilt)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: lift,
            width: Frame.width,
            height: 100,
            child: _Header(intro: _intro, onSkip: _start),
          ),
          Positioned(
            left: 0,
            top: floor,
            width: Frame.width,
            height: 917,
            child: _Lower(intro: _intro, ctaKey: _cta, onStart: _start),
          ),
        ],
      ),
    );
  }
}

class _Fade extends StatelessWidget {
  const _Fade({required this.intro, required this.child});

  final Animation<double> intro;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: intro,
      builder: (context, inner) {
        final t = span(intro.value, 0, 0.3, Curves.easeOut);
        return Opacity(
          opacity: t,
          child: Transform.scale(scale: lerp(1.06, 1, span(intro.value, 0, 0.55)), child: inner),
        );
      },
      child: child,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.intro, required this.onSkip});

  final Animation<double> intro;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final brand = inter(24.2, 700, track: -0.003, color: const Color(0xFFF1F0F5));
    final skip = inter(14.7, 500, color: const Color(0xFFA9B2C8));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: Art.crownLogo.left,
          top: Art.crownLogo.top,
          child: Staged(
            animation: intro,
            begin: 0.02,
            end: 0.3,
            offset: const Offset(0, -14),
            rotateZ: -0.6,
            scale: 0.4,
            curve: settle,
            child: Tick(
              builder: (context, s, child) => Transform.rotate(angle: wave(s, 5) * 0.05, child: child),
              child: Art.crownLogo.image(),
            ),
          ),
        ),
        Positioned(
          left: 56 - bearing('Ante', brand),
          top: 69 - capInset(brand),
          child: Staged(
            animation: intro,
            begin: 0.06,
            end: 0.34,
            offset: const Offset(-12, 0),
            child: Text('Ante', style: brand),
          ),
        ),
        Positioned(
          left: 325,
          top: 52,
          width: 60,
          height: 48,
          child: Staged(
            animation: intro,
            begin: 0.1,
            end: 0.38,
            offset: const Offset(10, 0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSkip,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(left: 341 - 325 - bearing('Skip', skip), top: 68.8 - 52 - capInset(skip), child: Text('Skip', style: skip)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Lower extends StatelessWidget {
  const _Lower({required this.intro, required this.ctaKey, required this.onStart});

  final Animation<double> intro;
  final GlobalKey ctaKey;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    const glow = [Shadow(color: Color(0x59FFFFFF), blurRadius: 14)];
    final head = inter(44, 760, track: 0.004, optical: 14, height: 1.0, shadows: glow);
    final headLow = inter(44, 760, track: 0.019, optical: 14, height: 1.0, shadows: glow);
    final body = inter(16.9, 400, color: const Color(0xFFB4BACB), height: 22.75 / 16.9, optical: 16.9);
    final label = inter(19.5, 600, color: Colors.white);
    final invite = inter(15.3, 600, color: const Color(0xFFE6E8EF));
    final value = inter(20, 700, color: const Color(0xFFE4E7EC));
    final caption = inter(12.3, 500, color: const Color(0xFF8C94AD));
    final foot = inter(11.3, 400, color: const Color(0xFF626680));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 26 - bearing('S', head),
          top: 395 - capInset(head),
          child: SplitText(
            text: 'Small Bets.',
            style: head,
            animation: intro,
            begin: 0.34,
            end: 0.66,
            gradient: const LinearGradient(colors: Palette.headlineTop, stops: [0, 0.4, 1]),
            stretch: 1.042,
          ),
        ),
        Positioned(
          left: 26 - bearing('B', headLow),
          top: 445 - capInset(headLow),
          child: Tick(
            builder: (context, s, child) => ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (r) {
                final x = (s % 5.5) / 5.5;
                return LinearGradient(
                  colors: const [Color(0x00FFFFFF), Color(0x55FFFFFF), Color(0x00FFFFFF)],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment(-3 + x * 6 - 0.4, 0),
                  end: Alignment(-3 + x * 6 + 0.4, 0),
                ).createShader(r);
              },
              child: child,
            ),
            child: SplitText(
              text: 'Big Habits.',
              style: headLow,
              animation: intro,
              begin: 0.42,
              end: 0.74,
              gradient: const LinearGradient(colors: Palette.headlineLow, stops: [0, 0.3, 0.62, 1]),
              stretch: 1.051,
            ),
          ),
        ),
        for (final (i, line) in const [
          'Join or create pools, stay consistent,',
          'win rewards. Turn your goals into',
          'good habits.',
        ].indexed)
          Positioned(
            left: 26 - bearing(line, body),
            top: 501.2 + i * 22.75 - capInset(body),
            child: Staged(
              animation: intro,
              begin: 0.52 + i * 0.05,
              end: 0.8 + i * 0.05,
              offset: const Offset(0, 14),
              child: Text(line, style: body),
            ),
          ),
        Positioned(
          left: 21.6,
          top: 591.2,
          child: Staged(
            animation: intro,
            begin: 0.6,
            end: 0.92,
            offset: const Offset(0, 40),
            scale: 0.92,
            curve: settle,
            child: GlowButton(
              key: ctaKey,
              width: 351.7,
              height: 65.6,
              onTap: onStart,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 137.8 - 21.6 - 15,
                    top: 624 - 591.2 - 15,
                    child: PulseRing(
                      size: 30,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white.withValues(alpha: 0.34), Colors.white.withValues(alpha: 0.16)],
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 0.8),
                        ),
                        child: const Center(child: PhIcon(Ph.lightning, size: 17, color: Colors.white)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 166.3 - 21.6 - bearing('G', label),
                    top: 616 - 591.2 - capInset(label),
                    child: Text('Get Started', style: label),
                  ),
                  Positioned(
                    left: 331.5 - 21.6,
                    top: 614.5 - 591.2,
                    child: Tick(
                      builder: (context, s, child) =>
                          Transform.translate(offset: Offset(3 * math.max(0, wave(s, 1.6)), 0), child: child),
                      child: PhIcon(Ph.caretRightBold, size: 18, color: Colors.white.withValues(alpha: 0.92)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 24.2,
          top: 671.8,
          child: Staged(
            animation: intro,
            begin: 0.66,
            end: 0.96,
            offset: const Offset(0, 32),
            child: Pressable(
              onTap: () {},
              child: CometBorder(
                width: 347.2,
                height: 53.3,
                child: Stack(
                  children: [
                    Positioned(
                      left: 114.3 - 24.2 - 14,
                      top: 698 - 671.8 - 14,
                      child: Tick(
                        builder: (context, s, child) {
                          final k = (s % 4.5);
                          final w = k < 0.6 ? math.sin(k / 0.6 * math.pi * 3) * 0.18 * (1 - k / 0.6) : 0.0;
                          return Transform.rotate(angle: w, alignment: Alignment.bottomCenter, child: child);
                        },
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (r) => const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFA27BFF), Color(0xFFE77BD8)],
                          ).createShader(r),
                          child: const PhIcon(Ph.gift, size: 28),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 141.5 - 24.2 - bearing('H', invite),
                      top: 692.6 - 671.8 - capInset(invite),
                      child: Text('Have an Invite Code?', style: invite),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        for (final (i, stat) in _stats.indexed)
          Positioned(
            left: stat.x,
            top: 743.8,
            child: Staged(
              animation: intro,
              begin: 0.7 + i * 0.05,
              end: 0.98,
              offset: const Offset(0, 28),
              scale: 0.9,
              curve: settle,
              child: _StatCard(stat: stat, intro: intro, value: value, caption: caption, order: i),
            ),
          ),
        Positioned(
          left: 122 - bearing('B', foot),
          top: 880.6 - capInset(foot),
          child: Staged(
            animation: intro,
            begin: 0.8,
            end: 1,
            child: Text('Better Habits. Bigger Dreams.', style: foot),
          ),
        ),
      ],
    );
  }
}

class _Stat {
  const _Stat(this.x, this.sprite, this.value, this.label, this.valueX, this.labelX);

  final double x;
  final Sprite sprite;
  final String value;
  final String label;
  final double valueX;
  final double labelX;
}

const _stats = [
  _Stat(21.7, Art.oTrophy, '94%', 'Show Rate', 45.0, 44.5),
  _Stat(142.4, Art.oFlame, '41K', 'Pools', 164.5, 165.0),
  _Stat(262.3, Art.oPeople, '12K+', 'Active Users', 285.0, 284.0),
];

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat, required this.intro, required this.value, required this.caption, required this.order});

  final _Stat stat;
  final Animation<double> intro;
  final TextStyle value;
  final TextStyle caption;
  final int order;

  @override
  Widget build(BuildContext context) {
    final s = stat.sprite;
    return SizedBox(
      width: 112,
      height: 104.9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF071230), Color(0xFF050C22)],
          ),
          border: Border.all(color: const Color(0xFF1A2140), width: 1),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: s.left - stat.x,
              top: s.top - 743.8,
              width: s.width,
              height: s.height,
              child: Tick(
                builder: (context, sec, child) {
                  final hop = math.max(0.0, wave(sec, 3.2, order * 0.22));
                  return Transform.translate(offset: Offset(0, -2.5 * hop * hop), child: child);
                },
                child: s.image(),
              ),
            ),
            Positioned(
              left: stat.valueX - stat.x - bearing(stat.value, value),
              top: 796 - 743.8 - capInset(value),
              child: AnimatedBuilder(
                animation: intro,
                builder: (context, _) => RollingNumber(
                  text: stat.value,
                  style: value,
                  progress: span(intro.value, 0.72 + order * 0.04, 1.0, Curves.linear),
                ),
              ),
            ),
            Positioned(
              left: stat.labelX - stat.x - bearing(stat.label, caption),
              top: 819.8 - 743.8 - capInset(caption),
              child: Text(stat.label, style: caption),
            ),
          ],
        ),
      ),
    );
  }
}
