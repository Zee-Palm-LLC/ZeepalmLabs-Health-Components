import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/assets.dart';
import '../../core/canvas.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../widgets/icon_orb.dart';
import 'goal_card.dart';
import 'nav_bar.dart';
import 'quick_actions.dart';
import 'route_card.dart';
import '../../core/phosphor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenRoute, this.entrance, this.routeOpen = false});

  final ValueChanged<Rect> onOpenRoute;
  final Animation<double>? entrance;
  final bool routeOpen;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class _Category {
  const _Category(this.label, this.glyph, this.swatch);

  final String label;
  final IconData glyph;
  final Swatch swatch;
}

const _categories = [
  _Category('Running\nRoutes', PhosphorFill.personSimpleRun, Swatch.run),
  _Category('Gyms', PhosphorFill.barbell, Swatch.gym),
  _Category('Parks', PhosphorFill.treeEvergreen, Swatch.park),
  _Category('Water\nStations', PhosphorFill.drop, Swatch.water),
];

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _goal;
  late final AnimationController _bell;
  late final AnimationController _quick;
  late final List<AnimationController> _tiles;
  late final Clock _clock;
  final _scroll = ScrollController();
  Section _section = Section.home;
  bool _replayed = false;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 2100));
    _goal = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));
    _bell = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _quick = AnimationController(vsync: this, duration: const Duration(milliseconds: 620));
    _tiles = List.generate(4, (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 900), value: 1));
    _clock = Clock(this);
    _scroll.addListener(() => setState(() {}));
    final entrance = widget.entrance;
    if (entrance == null || entrance.isCompleted) {
      _play();
    } else {
      entrance.addListener(_watchEntrance);
    }
  }

  void _watchEntrance() {
    if ((widget.entrance?.value ?? 1) > 0.45 && _enter.value == 0 && !_enter.isAnimating) _play();
  }

  void _play() => _enter.forward(from: 0);

  @override
  void dispose() {
    widget.entrance?.removeListener(_watchEntrance);
    _enter.dispose();
    _goal.dispose();
    _bell.dispose();
    _quick.dispose();
    for (final t in _tiles) {
      t.dispose();
    }
    _clock.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _replayGoal() {
    HapticFeedback.lightImpact();
    _replayed = true;
    _goal.forward(from: 0);
  }

  void _openRoute() {
    HapticFeedback.mediumImpact();
    final scope = CanvasScope.of(context);
    final card = RouteCard.rect.translate(0, scope.lift - _scroll.offset);
    widget.onOpenRoute(RouteCard.image.shift(card.topLeft));
  }

  void _select(Section section) {
    HapticFeedback.selectionClick();
    switch (section) {
      case Section.home:
        setState(() => _section = Section.home);
        _scroll.animateTo(0, duration: const Duration(milliseconds: 600), curve: gentle);
      case Section.progress:
        setState(() => _section = Section.progress);
        _scroll.animateTo(0, duration: const Duration(milliseconds: 500), curve: gentle);
        _replayGoal();
      case Section.map:
        setState(() => _section = Section.map);
        _openRoute();
      case Section.profile:
        setState(() => _section = Section.profile);
        _bell.forward(from: 0);
    }
  }

  void resetSection() {
    if (mounted) setState(() => _section = Section.home);
  }

  void _toggleQuick() {
    HapticFeedback.lightImpact();
    if (_quick.value > 0.5 || _quick.status == AnimationStatus.forward) {
      _quick.animateBack(0, duration: const Duration(milliseconds: 380), curve: Curves.easeIn);
    } else {
      _quick.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = CanvasScope.of(context);
    final lift = scope.lift;
    final navTop = NavBar.topIn(scope);
    final squeeze = (lift - (navTop - 761.5)).clamp(0.0, 40.0);
    final contentHeight = 752 + lift - squeeze;
    final fab = NavBar.fabCenter(scope);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: Palette.canvas,
        child: AnimatedBuilder(
          animation: Listenable.merge([_enter, _goal, _bell, _quick, _clock, ..._tiles]),
          builder: (context, _) {
            final enter = _enter.value;
            final seconds = _clock.seconds;
            final offset = _scroll.hasClients ? _scroll.offset : 0.0;
            return Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: EdgeInsets.only(bottom: math.max(0, scope.height - navTop - 8)),
                    child: SizedBox(
                      height: math.max(contentHeight, navTop - 1),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ..._header(enter, seconds, lift),
                          Positioned(
                            left: GoalCard.rect.left,
                            top: GoalCard.rect.top + lift - squeeze * 0.3,
                            child: Staged(
                              animation: _enter,
                              begin: 0.08,
                              end: 0.55,
                              offset: const Offset(0, 34),
                              rotateX: 0.35,
                              scale: 0.96,
                              child: AnimatedBuilder(
                                animation: _goal,
                                builder: (context, _) => GoalCard(fill: _replayed ? _goal.value : span(enter, 0.24, 1.0, Curves.linear), seconds: seconds, onTap: _replayGoal),
                              ),
                            ),
                          ),
                          for (var i = 0; i < 4; i++) _tile(i, enter, seconds, lift - squeeze * 0.5),
                          _SectionTitle(enter: enter, lift: lift - squeeze),
                          Positioned(
                            left: RouteCard.rect.left,
                            top: RouteCard.rect.top + lift - squeeze,
                            child: Staged(
                              animation: _enter,
                              begin: 0.4,
                              end: 0.95,
                              offset: const Offset(0, 50),
                              rotateX: 0.28,
                              child: RouteCard(
                                enter: span(enter, 0.42, 1.0, Curves.linear),
                                parallax: offset * 0.18,
                                onOpen: _openRoute,
                                hidden: widget.routeOpen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                NavBar(
                  top: navTop,
                  active: _section,
                  enter: span(enter, 0.2, 0.75, Curves.linear),
                  onSelect: _select,
                ),
                QuickActions(
                  open: _quick.value,
                  origin: fab,
                  onClose: _toggleQuick,
                  onPick: (i) {
                    _toggleQuick();
                    if (i == 1) _openRoute();
                  },
                ),
                NavFab(
                  center: fab,
                  enter: span(enter, 0.2, 0.75, Curves.linear),
                  open: Curves.easeOutBack.transform(_quick.value.clamp(0.0, 1.0)),
                  onTap: _toggleQuick,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _header(double enter, double seconds, double lift) {
    final avatar = spring(span(enter, 0.0, 0.4, Curves.linear), bounce: 0.35, freq: 2.3);
    final ring = span(enter, 0.05, 0.45, Curves.easeInOut);
    final greet = span(enter, 0.06, 0.34, swift);
    final name = span(enter, 0.12, 0.42, swift);
    final sunIn = spring(span(enter, 0.25, 0.6, Curves.linear), bounce: 0.4, freq: 2.2);
    final settled = span(enter, 0.6, 1.0, Curves.easeInOut);
    final bellT = _bell.isAnimating ? _bell.value : span(enter, 0.3, 0.75, Curves.linear);
    final swing = math.sin(bellT * math.pi * 5) * math.exp(-3.4 * bellT) * 0.45 * (bellT > 0 && bellT < 1 ? 1 : 0);
    final ping = (seconds % 3.2) / 3.2;
    final nameStyle = font(18.1, 700, color: const Color(0xFF0F213B));
    final nameWidth = (TextPainter(text: TextSpan(text: 'Ayesha', style: nameStyle), textDirection: TextDirection.ltr)..layout()).width;
    final glow = 0.5 + 0.5 * wave(seconds, 3.4) * settled;
    return [
      Positioned(
        left: 49.7 - 30,
        top: 80.5 - 30 + lift,
        width: 60,
        height: 60,
        child: Transform.scale(
          scale: avatar,
          child: CustomPaint(
            foregroundPainter: _RingSweep(ring),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.4),
                  boxShadow: [BoxShadow(color: Palette.shadow.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 3))],
                  image: const DecorationImage(image: AssetImage(Assets.avatar), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),
      ),
      _clipRise('Good Morning,', 90.2, 72.8 + lift, font(14.2, 600, color: const Color(0xFF6B7684)), greet),
      _clipRise('Ayesha', 90.3, 95.7 + lift, nameStyle, name),
      Positioned(
        left: 90.3 + nameWidth + 4,
        top: 89.6 - 11 + lift,
        width: 22,
        height: 22,
        child: Transform.scale(
          scale: sunIn,
          child: Transform.rotate(
            angle: (1 - sunIn) * -2 + seconds * 0.35 * settled,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFFFFC928).withValues(alpha: 0.35 * glow), blurRadius: 10, spreadRadius: -2)],
              ),
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFD54A), Color(0xFFF7A70B)],
                ).createShader(rect),
                child: const Icon(PhosphorFill.sun, size: 22, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 354.8 - 18,
        top: 82.7 - 18 + lift,
        width: 36,
        height: 36,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _bell.forward(from: 0),
          child: Opacity(
            opacity: span(enter, 0.25, 0.45),
            child: Transform.rotate(
              angle: swing,
              alignment: const Alignment(0, -0.8),
              child: const Icon(PhosphorFill.bell, size: 27, color: Color(0xFF0B3150)),
            ),
          ),
        ),
      ),
      Positioned(
        left: 364.6 - 12,
        top: 71.6 - 12 + lift,
        width: 24,
        height: 24,
        child: CustomPaint(painter: _Ping(pop: spring(span(enter, 0.5, 0.8, Curves.linear), bounce: 0.6), ping: settled > 0.99 ? ping : 0)),
      ),
    ];
  }

  Widget _clipRise(String text, double x, double base, TextStyle style, double t) {
    final size = style.fontSize!;
    return Positioned(
      left: x - 2,
      top: base - size * 1.05,
      width: 200,
      height: size * 1.35,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 2,
              top: size * 1.05 - baselineOffset(style) + (1 - t) * size * 1.3,
              child: Text(text, style: style),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(int i, double enter, double seconds, double lift) {
    final c = _categories[i];
    final left = 22.3 + 90.2 * i;
    final local = span(enter, 0.22 + i * 0.07, 0.62 + i * 0.07, Curves.linear);
    final pop = spring(local, bounce: 0.34, freq: 2.4);
    final lines = c.label.split('\n');
    final bases = lines.length == 1 ? [77.5] : [76.4, 94.2];
    final tap = _tiles[i];
    final pulse = tap.value < 1 ? tap.value : 0.0;
    return Positioned(
      left: left,
      top: 267.5 + lift,
      width: 78,
      height: 110,
      child: Opacity(
        opacity: span(local, 0.0, 0.3).clamp(0.0, 1.0),
        child: Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..translateByDouble(0, (1 - pop) * 26, 0, 1)
            ..scaleByDouble(0.86 + 0.14 * pop, 0.86 + 0.14 * pop, 1, 1),
          child: Pressable(
            jelly: true,
            scale: 0.93,
            onTap: () {
              HapticFeedback.selectionClick();
              tap.forward(from: 0);
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Palette.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Palette.shadow.withValues(alpha: 0.055), blurRadius: 14, offset: const Offset(0, 4))],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 39.5 - 23.7,
                    top: 33.3 - 23.7,
                    child: IconOrb(
                      swatch: c.swatch,
                      icon: c.glyph,
                      core: 17.8,
                      halo: 23.7,
                      iconSize: 22.5,
                      fill: span(local, 0.2, 1.0, Curves.linear),
                      pulse: pulse,
                      seconds: seconds,
                    ),
                  ),
                  for (var k = 0; k < lines.length; k++)
                    Label.centered(lines[k], cx: 39.2, base: bases[k], span: 78, style: font(13.4, 700, color: const Color(0xFF263A4E), height: 1.25)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.enter, required this.lift});

  final double enter;
  final double lift;

  @override
  Widget build(BuildContext context) {
    final t = span(enter, 0.35, 0.7, swift);
    return Positioned(
      left: 0,
      top: 400 + lift,
      width: 393,
      height: 40,
      child: ClipRect(
        child: Stack(
          children: [
            Label('Recommended For You', x: 22.4, base: 27 + (1 - t) * 26, style: font(17.7, 700, color: const Color(0xFF10213A))),
            Label('See All', x: 326.1 + (1 - t) * 20, base: 27, style: font(14.15, 600, color: const Color(0xFF6F8690).withValues(alpha: t))),
          ],
        ),
      ),
    );
  }
}

class _RingSweep extends CustomPainter {
  _RingSweep(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2 - 1.2);
    canvas.drawArc(
      rect,
      -math.pi / 2 + t * math.pi,
      2 * math.pi * Curves.easeOut.transform(t) * (1 - t) * 1.6,
      false,
      Paint()
        ..color = Palette.jade.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingSweep old) => old.t != t;
}

class _Ping extends CustomPainter {
  _Ping({required this.pop, required this.ping});

  final double pop;
  final double ping;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    if (ping > 0 && ping < 0.5) {
      final p = ping / 0.5;
      canvas.drawCircle(c, 4.3 + 7 * p, Paint()..color = Palette.coral.withValues(alpha: 0.35 * (1 - p)));
    }
    canvas.drawCircle(c, 5.6 * pop, Paint()..color = Colors.white);
    canvas.drawCircle(c, 4.2 * pop, Paint()..color = Palette.coral);
  }

  @override
  bool shouldRepaint(_Ping old) => old.pop != pop || old.ping != ping;
}
