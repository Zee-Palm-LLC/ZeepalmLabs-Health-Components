import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/routes.dart';
import '../../core/type.dart';
import '../../widgets/blobs.dart';
import '../../widgets/live_mascot.dart';
import '../../widgets/sparks.dart';
import '../shell/shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const refHeight = 895.8;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late final AnimationController _in;
  late final AnimationController _drag;
  late final AnimationController _launch;
  final _orbKey = GlobalKey();
  Offset _tilt = Offset.zero;
  Offset _release = Offset.zero;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..forward();
    _drag = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _drag.addListener(() => setState(() => _tilt = _release * (1 - spring(_drag.value, bounce: 0.5, freq: 2.4))));
    _launch = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  }

  @override
  void dispose() {
    _in.dispose();
    _drag.dispose();
    _launch.dispose();
    super.dispose();
  }

  void _pan(DragUpdateDetails d) {
    _drag.stop();
    setState(() {
      final next = _tilt + d.delta * 0.18;
      _tilt = Offset(next.dx.clamp(-14.0, 14.0), next.dy.clamp(-14.0, 14.0));
    });
  }

  void _panEnd(DragEndDetails _) {
    _release = _tilt;
    _drag.forward(from: 0);
  }

  Future<void> _start() async {
    HapticFeedback.mediumImpact();
    await _launch.forward(from: 0);
    if (!mounted) return;
    final center = centerOf(context, _orbKey);
    await Navigator.of(context).pushReplacement(
      RevealRoute(center: center, builder: (_) => const Shell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final low = frame.height - OnboardingScreen.refHeight - math.max(0.0, frame.bottom - 34);
    final panelTop = 720.0 + low;
    final feet = Art.hero.top + Art.hero.height;
    final room = feet + low - (Art.hero.top + lift);
    final scale = math.min(1.0, room / Art.hero.height);
    final mascotW = Art.hero.width * scale;
    final mascotH = Art.hero.height * scale;
    final mascotCx = Art.hero.left + Art.hero.width / 2;

    return Scaffold(
      backgroundColor: Palette.cream,
      body: GestureDetector(
        onPanUpdate: _pan,
        onPanEnd: _panEnd,
        behavior: HitTestBehavior.translucent,
        child: SizedBox(
          width: Frame.width,
          height: frame.height,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: BlobField(
                  entrance: _in,
                  parallax: -_tilt * 0.6,
                  blobs: [
                    Blob(
                      center: Offset(-5, 20 + lift),
                      radii: const Size(97, 97),
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: const [Color(0xFFDEF864), Color(0xFFDFF866), Color(0x00F1F8CF)],
                      stops: const [0, 0.78, 1],
                      seed: 0.4,
                      delay: 0.0,
                    ),
                    Blob(
                      center: Offset(414.1, 99.5 + lift),
                      radii: const Size(63.2, 63.2),
                      colors: const [Color(0xFF9A7CF7), Color(0xFFAE93FA), Color(0xFFD2C4FB)],
                      stops: const [0, 0.5, 1],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomCenter,
                      seed: 2.1,
                      delay: 0.08,
                    ),
                    Blob(
                      center: Offset(408, 560 + (lift + low) / 2),
                      radii: const Size(58, 92),
                      colors: const [Color(0xFFDEF86A), Color(0xFFDDF66E)],
                      stops: const [0, 1],
                      seed: 4.2,
                      delay: 0.16,
                    ),
                    Blob(
                      center: Offset(395, 648 + (lift + low) / 2),
                      radii: const Size(58, 58),
                      colors: const [Color(0xFFDDF66E), Color(0xFFDDF670)],
                      stops: const [0, 1],
                      wobble: 0.025,
                      seed: 4.9,
                      delay: 0.18,
                    ),
                    Blob(
                      center: Offset(-12, 718 + low),
                      radii: const Size(78, 76),
                      colors: const [Color(0xFFEAF5BE), Color(0xFFE6F4B2)],
                      stops: const [0, 1],
                      seed: 5.3,
                      delay: 0.22,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                top: lift,
                width: Frame.width,
                height: 330,
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Sparks(
                          entrance: _in,
                          begin: 0.62,
                          origin: const Offset(292, 205),
                          colors: const [Color(0xFFD9F55A), Color(0xFFCBEA48)],
                          strokes: const [
                            Stroke(Offset(306.8, 187.9), Offset(325.3, 175.1), width: 6.1),
                            Stroke(Offset(311.9, 199.2), Offset(340.0, 195.5), width: 6.0),
                            Stroke(Offset(314.5, 208.4), Offset(334.4, 214.1), width: 4.8),
                          ],
                        ),
                      ),
                      const Positioned(left: 21.5, top: 72.5, child: _Caret()),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: Art.logo.left,
                top: Art.logo.top + lift,
                child: Staged(
                  animation: _in,
                  begin: 0.02,
                  end: 0.32,
                  offset: const Offset(0, -18),
                  scale: 0.82,
                  child: _Logo(width: Art.logo.width, height: Art.logo.height),
                ),
              ),
              Positioned(
                left: 0,
                top: lift,
                width: Frame.width,
                height: 330,
                child: _Headline(entrance: _in),
              ),
              Positioned(
                left: 8,
                top: panelTop,
                right: 8,
                bottom: -30,
                child: Staged(
                  animation: _in,
                  begin: 0.5,
                  end: 0.9,
                  offset: const Offset(0, 90),
                  child: const _Panel(),
                ),
              ),
              Positioned(
                left: mascotCx - mascotW / 2,
                top: feet + low - mascotH,
                width: mascotW,
                height: mascotH,
                child: FittedBox(
                  child: LiveMascot(
                    sprite: Art.hero,
                    entrance: _in,
                    begin: 0.26,
                    end: 0.86,
                    drop: 120,
                    parallax: _tilt / scale,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: low,
                width: Frame.width,
                height: OnboardingScreen.refHeight,
                child: IgnorePointer(
                  child: Sparks(
                    entrance: _in,
                    begin: 0.7,
                    origin: const Offset(86, 492),
                    period: 3.4,
                    colors: const [Color(0xFF8446F4), Color(0xFF6A2FF2)],
                    strokes: const [
                      Stroke(Offset(47.8, 467.8), Offset(66.5, 478.8), width: 5.7),
                      Stroke(Offset(39.8, 502.0), Offset(60.8, 497.6), width: 5.6),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 25,
                top: 741.67 + low,
                width: 344.33,
                height: 63,
                child: Staged(
                  animation: _in,
                  begin: 0.58,
                  end: 0.96,
                  offset: const Offset(0, 70),
                  scale: 0.9,
                  child: _StartButton(entrance: _in, launch: _launch, orbKey: _orbKey, onTap: _start),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 836.33 + low,
                child: Staged(
                  animation: _in,
                  begin: 0.72,
                  end: 1,
                  offset: const Offset(0, 16),
                  child: const _SignIn(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Art.logo.asset,
      width: width,
      height: height,
      fit: BoxFit.fill,
      color: Palette.ink,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.medium,
    );
  }
}

class _Caret extends StatelessWidget {
  const _Caret();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(10, 8), painter: _CaretPainter());
  }
}

class _CaretPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x99949B64)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(1, 7)
        ..lineTo(5, 1.5)
        ..lineTo(9, 7),
      p,
    );
  }

  @override
  bool shouldRepaint(_CaretPainter old) => false;
}

class _Headline extends StatelessWidget {
  const _Headline({required this.entrance});

  final Animation<double> entrance;

  static final _style = nunito(54.6, 880, color: const Color(0xFF0B0C15), track: -0.0246);

  @override
  Widget build(BuildContext context) {
    final lead = TextPainter(text: TextSpan(text: 'fitness ', style: _style), textDirection: TextDirection.ltr)..layout();
    final sub = inter(16.5, 400, color: const Color(0xFF535255), track: -0.026);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _Rise(
          entrance: entrance,
          begin: 0.14,
          x: 28.99,
          cap: 142.2,
          text: 'Let’s make',
          style: _style,
        ),
        _Rise(
          entrance: entrance,
          begin: 0.22,
          x: 26.2,
          cap: 199.3,
          text: 'fitness',
          style: _style,
        ),
        Positioned(
          left: 26.2 + lead.width - 5.2,
          top: 199.3 - capInset(_style),
          child: _Fun(entrance: entrance, style: _style),
        ),
        Positioned(
          left: 26 - bearing('S', sub),
          top: 267.6 - capInset(sub),
          child: Staged(
            animation: entrance,
            begin: 0.36,
            end: 0.66,
            offset: const Offset(0, 14),
            child: Text('Short workouts, big results.', style: sub),
          ),
        ),
        Positioned(
          left: 26.33 - bearing('L', sub),
          top: 292.0 - capInset(sub),
          child: Staged(
            animation: entrance,
            begin: 0.41,
            end: 0.7,
            offset: const Offset(0, 14),
            child: Text('Let’s get you moving!', style: sub),
          ),
        ),
      ],
    );
  }
}

class _Rise extends StatelessWidget {
  const _Rise({
    required this.entrance,
    required this.begin,
    required this.x,
    required this.cap,
    required this.text,
    required this.style,
  });

  final Animation<double> entrance;
  final double begin;
  final double x;
  final double cap;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final top = cap - capInset(style);
    return Positioned(
      left: x - bearing(text, style),
      top: top,
      child: ClipRect(
        clipper: const _Reveal(),
        child: AnimatedBuilder(
          animation: entrance,
          builder: (context, child) {
            final t = span(entrance.value, begin, begin + 0.3, swift);
            final m = Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..translateByDouble(0, 64 * (1 - t), 0, 1)
              ..rotateX(-0.9 * (1 - t));
            return Transform(alignment: Alignment.bottomLeft, transform: m, child: child);
          },
          child: Text(text, style: style, softWrap: false),
        ),
      ),
    );
  }
}

class _Reveal extends CustomClipper<Rect> {
  const _Reveal();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(-20, -30, size.width + 20, size.height + 4);

  @override
  bool shouldReclip(_Reveal old) => false;
}

class _Fun extends StatelessWidget {
  const _Fun({required this.entrance, required this.style});

  final Animation<double> entrance;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, seconds, _) {
        return AnimatedBuilder(
          animation: entrance,
          builder: (context, _) {
            final t = span(entrance.value, 0.4, 0.78, Curves.linear);
            final pop = spring(t, bounce: 0.7, freq: 3.1);
            final sweep = ((seconds - 1.6) / 3.6) % 1.0;
            final shine = Paint()
              ..shader = ui.Gradient.linear(
                Offset(-60 + sweep * 260, 0),
                Offset(-10 + sweep * 260, 60),
                const [Color(0xFF6326E6), Color(0xFF8A58FB), Color(0xFF6326E6)],
                const [0.0, 0.5, 1.0],
              );
            final hopPhase = (seconds % 3.2) / 3.2;
            final hop = hopPhase < 0.18 ? math.sin(hopPhase / 0.18 * math.pi) : 0.0;
            final live = entrance.value >= 1 ? 1.0 : 0.0;
            final base = Paint()
              ..shader = ui.Gradient.linear(
                const Offset(0, 0),
                const Offset(0, 60),
                const [Color(0xFF6A2CF0), Color(0xFF5921D6)],
              );
            final funStyle = style.copyWith(color: null, foreground: live > 0 ? shine : base);
            return Opacity(
              opacity: span(t, 0, 0.15, Curves.linear),
              child: Transform(
                alignment: Alignment.bottomLeft,
                transform: Matrix4.identity()
                  ..translateByDouble(0, 40 * (1 - pop), 0, 1)
                  ..rotateZ(-0.25 * (1 - pop))
                  ..scaleByDouble(lerp(0.4, 1, pop), lerp(0.4, 1, pop), 1, 1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('fun', style: funStyle, softWrap: false),
                    Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.identity()
                        ..translateByDouble(0, -7 * hop * live, 0, 1)
                        ..rotateZ(0.12 * hop * live)
                        ..scaleByDouble(1 - 0.06 * hop * live, 1 + 0.08 * hop * live, 1, 1),
                      child: Text('!', style: funStyle, softWrap: false),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFFFFFF).withValues(alpha: 0.62),
                const Color(0xFFFFFEFA).withValues(alpha: 0.8),
                const Color(0xFFF9F6EE).withValues(alpha: 0.96),
              ],
              stops: const [0, 0.35, 1],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.entrance, required this.launch, required this.orbKey, required this.onTap});

  final Animation<double> entrance;
  final Animation<double> launch;
  final GlobalKey orbKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = inter(17.4, 600, color: const Color(0xFFF0F1F4), track: 0.012);
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      haptic: false,
      child: Tick(
        builder: (context, seconds, _) => AnimatedBuilder(
          animation: Listenable.merge([entrance, launch]),
          builder: (context, _) {
            final orbIn = spring(span(entrance.value, 0.82, 1.0, Curves.linear), bounce: 0.8, freq: 3);
            final l = launch.value;
            final nudge = entrance.value >= 1 ? math.max(0.0, wave(seconds, 1.8)) * 3.2 : 0.0;
            final ripple = (seconds % 2.2) / 2.2;
            final sheenX = ((seconds - 2.4) % 4.2) / 4.2;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(31.5),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF181A24).withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 9)),
                        BoxShadow(color: const Color(0xFFDEF864).withValues(alpha: 0.12 + 0.1 * l), blurRadius: 30, spreadRadius: -4, offset: const Offset(20, 6)),
                      ],
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1C1F29), Color(0xFF14161E)],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(31.5),
                    child: CustomPaint(painter: _ButtonFx(sheen: sheenX, fill: l)),
                  ),
                ),
                Positioned(
                  left: 147 - 25 - bearing('G', label),
                  top: 766.67 - 741.67 - capInset(label),
                  child: Opacity(
                    opacity: 1 - span(l, 0.2, 0.7, Curves.linear),
                    child: Text('Get Started', style: label),
                  ),
                ),
                Positioned(
                  left: 333.7 - 25 - 16,
                  top: 773.4 - 741.67 - 16,
                  child: SizedBox.square(
                    key: orbKey,
                    dimension: 32,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        if (entrance.value >= 1)
                          Transform.scale(
                            scale: 1 + ripple * 0.9,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Palette.lime.withValues(alpha: 0.5 * (1 - ripple)), width: 1.6),
                              ),
                            ),
                          ),
                        Transform.scale(
                          scale: orbIn * (1 + 0.06 * math.sin(l * math.pi)),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF8E9760), Color(0xFFB2C466), Color(0xFFC6DA6F)],
                                stops: [0, 0.55, 1],
                              ),
                              boxShadow: [BoxShadow(color: Color(0x55DEF864), blurRadius: 10, offset: Offset(0, 2))],
                            ),
                            child: Transform.translate(
                              offset: Offset(nudge + 18 * Curves.easeIn.transform(l), 0),
                              child: Opacity(
                                opacity: 1 - span(l, 0.5, 0.9, Curves.linear),
                                child: const PhIcon(Ph.arrowRight, size: 17, color: Color(0xFF1B1D14)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ButtonFx extends CustomPainter {
  _ButtonFx({required this.sheen, required this.fill});

  final double sheen;
  final double fill;

  @override
  void paint(Canvas canvas, Size size) {
    final x = -80 + sheen * (size.width + 160);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(x - 50, 0),
          Offset(x + 50, size.height),
          const [Color(0x00FFFFFF), Color(0x14FFFFFF), Color(0x00FFFFFF)],
          const [0, 0.5, 1],
        ),
    );
    if (fill > 0) {
      final c = Offset(308.7, size.height / 2);
      final r = 16 + (size.width + 40) * Curves.easeInCubic.transform(fill);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = ui.Gradient.radial(c, r, const [Color(0xFFDEF864), Color(0xFFB9A2FF), Color(0xFF6A2FF2)], const [0, 0.6, 1]),
      );
    }
  }

  @override
  bool shouldRepaint(_ButtonFx old) => old.sheen != sheen || old.fill != fill;
}

class _SignIn extends StatelessWidget {
  const _SignIn();

  @override
  Widget build(BuildContext context) {
    final base = inter(13.75, 400, color: const Color(0xFF726E72), track: -0.03);
    final link = inter(13.75, 600, color: const Color(0xFF6A3FD8), track: -0.01);
    return Center(
      child: Transform.translate(
        offset: Offset(-1.0, -capInset(base)),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Already have an Account? ', style: base),
              TextSpan(text: 'Sign in', style: link),
            ],
          ),
          softWrap: false,
        ),
      ),
    );
  }
}
