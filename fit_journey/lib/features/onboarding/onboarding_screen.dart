import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/assets.dart';
import '../../core/canvas.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/onboarding_pages.dart';
import '../../widgets/line_arrow.dart';
import 'feature_flap.dart';
import 'page_dots.dart';
import 'roll_line.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinish, this.entrance});

  final ValueChanged<Rect> onFinish;
  final Animation<double>? entrance;

  static const buttonRect = Rect.fromLTWH(25.3, 719.8, 344, 54);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _flip;
  late final AnimationController _arrow;
  late final Clock _clock;
  int _page = 0;
  int _from = 0;
  bool _done = false;

  static const _titleSize = 32.2;
  static const _titleBases = [112.5, 148.5, 183.8];
  static const _bodyBases = [216.2, 237.5, 259.1];

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900));
    _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 1050), value: 1);
    _arrow = AnimationController(vsync: this, duration: const Duration(milliseconds: 560));
    _clock = Clock(this);
    final entrance = widget.entrance;
    if (entrance == null || entrance.isCompleted) {
      _enter.forward();
    } else {
      entrance.addListener(_watchEntrance);
    }
  }

  void _watchEntrance() {
    if ((widget.entrance?.value ?? 1) > 0.42 && _enter.value == 0 && !_enter.isAnimating) _enter.forward();
  }

  @override
  void dispose() {
    widget.entrance?.removeListener(_watchEntrance);
    _enter.dispose();
    _flip.dispose();
    _arrow.dispose();
    _clock.dispose();
    super.dispose();
  }

  void _go(int next) {
    if (next < 0 || next >= onboardingPages.length || next == _page) return;
    HapticFeedback.selectionClick();
    setState(() {
      _from = _page;
      _page = next;
    });
    _flip.forward(from: 0);
  }

  void _next() {
    _arrow.forward(from: 0);
    if (_page == onboardingPages.length - 1) {
      _finish();
    } else {
      _go(_page + 1);
    }
  }

  void _finish() {
    if (_done) return;
    _done = true;
    HapticFeedback.mediumImpact();
    final scope = CanvasScope.of(context);
    widget.onFinish(OnboardingScreen.buttonRect.translate(0, scope.drop));
  }

  @override
  Widget build(BuildContext context) {
    final scope = CanvasScope.of(context);
    final lift = scope.lift;
    final drop = scope.drop;
    final previous = onboardingPages[_from];
    final current = onboardingPages[_page];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v < -250) _go(_page + 1);
          if (v > 250) _go(_page - 1);
        },
        child: ColoredBox(
          color: Palette.page,
          child: AnimatedBuilder(
            animation: Listenable.merge([_enter, _flip, _clock]),
            builder: (context, _) {
              final enter = _enter.value;
              final flip = _flip.value;
              final seconds = _clock.seconds;
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  _Scene(enter: enter, flip: flip, seconds: seconds, lift: lift, from: previous.focus, to: current.focus, zoomFrom: _zoom(_from), zoomTo: _zoom(_page)),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    width: 104,
                    height: 46,
                    child: _Leaf(asset: Assets.leavesLeft, sway: wave(seconds, 5.2) * 0.022, grow: span(enter, 0.5, 1.0), pivot: Alignment.bottomLeft),
                  ),
                  Positioned(
                    left: 282,
                    bottom: 0,
                    width: 111,
                    height: 52,
                    child: _Leaf(asset: Assets.leavesRight, sway: wave(seconds, 6.1, 0.3) * 0.02, grow: span(enter, 0.55, 1.0), pivot: Alignment.bottomRight),
                  ),
                  Label(
                    'Skip',
                    x: 335.7 + 16 * (1 - span(enter, 0.3, 0.8)),
                    base: 73.6 + lift,
                    style: font(16.6, 600, color: const Color(0xFF15263F).withValues(alpha: span(enter, 0.3, 0.8))),
                  ),
                  Positioned(
                    left: 318,
                    top: 48 + lift,
                    width: 70,
                    height: 40,
                    child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _finish),
                  ),
                  for (var i = 0; i < 3; i++)
                    RollLine(
                      previous: flip < 1 ? previous.title[i] : null,
                      current: current.title[i],
                      progress: flip < 1 ? span(flip, i * 0.07, 0.62 + i * 0.07, swift) : span(enter, 0.02 + i * 0.07, 0.42 + i * 0.07, swift),
                      x: 27.0,
                      base: _titleBases[i] + lift,
                      style: font(_titleSize, 700, color: Palette.navy, height: 1.107),
                    ),
                  for (var i = 0; i < 3; i++)
                    RollLine(
                      previous: flip < 1 ? previous.body[i] : null,
                      current: current.body[i],
                      progress: flip < 1 ? span(flip, 0.14 + i * 0.06, 0.7 + i * 0.06, swift) : span(enter, 0.22 + i * 0.06, 0.62 + i * 0.06, swift),
                      x: 27.7,
                      base: _bodyBases[i] + lift,
                      style: font(17.55, 500, color: const Color(0xFF737F8D), height: 1.212),
                      tilt: false,
                    ),
                  for (var i = 0; i < 5; i++)
                    FeatureFlap(
                      top: 288.3 + 67.55 * i + lift,
                      previous: previous.features[i],
                      current: current.features[i],
                      flip: flip < 1 ? span(flip, i * 0.075, 0.55 + i * 0.075, Curves.linear) : 1,
                      enter: span(enter, 0.3 + i * 0.07, 0.72 + i * 0.07, Curves.linear),
                      seconds: seconds,
                    ),
                  PageDots(
                    count: onboardingPages.length,
                    from: _from,
                    to: _page,
                    progress: flip,
                    center: Offset(196.8, 692 + drop),
                    opacity: span(enter, 0.6, 0.9),
                  ),
                  _NextButton(
                    rect: OnboardingScreen.buttonRect.translate(0, drop),
                    enter: span(enter, 0.55, 1.0, Curves.linear),
                    previous: _from == onboardingPages.length - 1 ? 'Get Started' : 'Next',
                    label: _page == onboardingPages.length - 1 ? 'Get Started' : 'Next',
                    roll: flip,
                    arrow: _arrow,
                    onTap: _next,
                  ),
                  Label.centered(
                    'Discover Your Journey',
                    cx: 197.8,
                    base: 804.3 + drop + 8 * (1 - span(enter, 0.7, 1.0)),
                    span: 260,
                    style: font(15.4, 500, color: const Color(0xFF76808E).withValues(alpha: span(enter, 0.7, 1.0))),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static double _zoom(int page) => 1 + page * 0.022;
}

class _Scene extends StatelessWidget {
  const _Scene({
    required this.enter,
    required this.flip,
    required this.seconds,
    required this.lift,
    required this.from,
    required this.to,
    required this.zoomFrom,
    required this.zoomTo,
  });

  final double enter;
  final double flip;
  final double seconds;
  final double lift;
  final Alignment from;
  final Alignment to;
  final double zoomFrom;
  final double zoomTo;

  static const _pivot = Alignment(-0.49, -0.05);

  @override
  Widget build(BuildContext context) {
    final move = Curves.easeInOutCubic.transform(flip);
    final zoom = lerp(zoomFrom, zoomTo, move);
    final pan = Alignment.lerp(from, to, move)!;
    final bloom = span(enter, 0.0, 0.7, const Cubic(0.3, 0.6, 0.2, 1.0));
    final sprint = span(enter, 0.08, 0.62, const Cubic(0.2, 0.9, 0.25, 1.0));
    final hop = flip < 1 ? math.sin(math.pi * span(flip, 0.05, 0.6, Curves.easeInOut)) : 0.0;
    final settled = span(enter, 0.6, 1.0, Curves.easeInOut);
    final stride = (wave(seconds, 0.72).abs() - 0.64) * 2.4 * settled;
    final reach = (zoom - 1) / 0.066;
    final camera = Matrix4.identity()
      ..translateByDouble(pan.x * -4 * reach, pan.y * -3 * reach, 0, 1)
      ..scaleByDouble(zoom, zoom, 1, 1);
    return Positioned(
      left: 0,
      top: 266 + lift,
      width: 393,
      height: 446,
      child: Transform(
        alignment: _pivot,
        transform: camera,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => RadialGradient(
                  center: const Alignment(-0.49, -0.3),
                  radius: lerp(0.0, 1.7, bloom),
                  colors: const [Colors.white, Colors.white, Color(0x00FFFFFF)],
                  stops: const [0.0, 0.72, 1.0],
                ).createShader(rect),
                child: Image.asset(Assets.onboardingScene, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
              ),
            ),
            Positioned(
              left: 0,
              top: 14,
              width: 180,
              height: 392,
              child: Opacity(
                opacity: span(enter, 0.08, 0.3, Curves.easeOut),
                child: Transform(
                  alignment: const Alignment(0.3, 0.95),
                  transform: Matrix4.identity()
                    ..translateByDouble(lerp(-90, 0, sprint), stride - hop * 7, 0, 1)
                    ..rotateZ(lerp(0.12, 0, sprint) - hop * 0.03),
                  child: Image.asset(Assets.onboardingRunner, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Leaf extends StatelessWidget {
  const _Leaf({required this.asset, required this.sway, required this.grow, required this.pivot});

  final String asset;
  final double sway;
  final double grow;
  final Alignment pivot;

  @override
  Widget build(BuildContext context) {
    final g = spring(grow, bounce: 0.3, freq: 2.2);
    return Transform(
      alignment: pivot,
      transform: Matrix4.identity()
        ..rotateZ(sway)
        ..scaleByDouble(1, g, 1, 1),
      child: Image.asset(asset, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.rect,
    required this.enter,
    required this.previous,
    required this.label,
    required this.roll,
    required this.arrow,
    required this.onTap,
  });

  final Rect rect;
  final double enter;
  final String previous;
  final String label;
  final double roll;
  final Animation<double> arrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = font(18.1, 700, color: Colors.white, height: 1.2);
    final grow = span(enter, 0.0, 0.7, const Cubic(0.2, 0.9, 0.3, 1.0));
    final width = lerp(rect.height, rect.width, grow);
    final changing = previous != label && roll < 1;
    final textWidth = changing ? lerp(_measure(previous, style), _measure(label, style), Curves.easeInOut.transform(roll)) : _measure(label, style);
    return Positioned(
      left: rect.center.dx - width / 2,
      top: rect.top + 18 * (1 - span(enter, 0.0, 0.5)),
      width: width,
      height: rect.height,
      child: Opacity(
        opacity: span(enter, 0.0, 0.3).clamp(0.0, 1.0),
        child: Pressable(
          onTap: onTap,
          scale: 0.97,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Palette.deepTeal,
              borderRadius: BorderRadius.circular(rect.height / 2),
              boxShadow: [
                BoxShadow(color: Palette.deepTeal.withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 8)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(rect.height / 2),
              child: Opacity(
                opacity: span(enter, 0.4, 0.9),
                child: OverflowBox(
                  maxWidth: rect.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: textWidth,
                        height: rect.height,
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            if (changing)
                              Positioned(
                                left: 0,
                                top: 33.5 - baselineOffset(style) - 26 * swift.transform(roll),
                                child: Text(previous, style: style),
                              ),
                            Positioned(
                              left: 0,
                              top: 33.5 - baselineOffset(style) + (changing ? 26 * (1 - swift.transform(roll)) : 0),
                              child: Text(label, style: style),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedBuilder(
                        animation: arrow,
                        builder: (context, _) => LineArrow(size: 20, shift: Curves.easeInOut.transform(arrow.value)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static double _measure(String text, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    return painter.width;
  }
}
