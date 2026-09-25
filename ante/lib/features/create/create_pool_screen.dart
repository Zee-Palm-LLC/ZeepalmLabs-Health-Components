import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/routes.dart';
import '../../core/type.dart';
import '../../widgets/avatar.dart';
import '../../widgets/confetti.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/split_text.dart';
import '../../widgets/surface.dart';
import '../pool/pool_screen.dart';
import 'amount_card.dart';

class CreatePoolScreen extends StatefulWidget {
  const CreatePoolScreen({super.key});

  static const ctaTop = 854.3;
  static const ctaHeight = 56.9;

  @override
  State<CreatePoolScreen> createState() => _CreatePoolScreenState();
}

class _CreatePoolScreenState extends State<CreatePoolScreen> with TickerProviderStateMixin {
  late final AnimationController _in;
  late final AnimationController _done;
  final _scroll = ScrollController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 2100))..forward();
    _done = AnimationController(vsync: this, duration: const Duration(milliseconds: 2300));
  }

  @override
  void dispose() {
    _in.dispose();
    _done.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    await _done.forward(from: 0);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(LiftRoute(builder: (_) => const PoolScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final ctaTop = frame.height - math.max(frame.bottom + 10, 21.7) - CreatePoolScreen.ctaHeight;
    final floor = ctaTop - CreatePoolScreen.ctaTop;
    final content = math.max(frame.height, 836.0 + lift + (frame.height - ctaTop) + 16);
    final e = _in;

    return Scaffold(
      backgroundColor: const Color(0xFF000511),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: Frame.width,
                height: content,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: lift,
                      width: Frame.width,
                      height: 330,
                      child: _Hero(entrance: e, scroll: _scroll),
                    ),
                    Positioned(left: 0, top: lift, width: Frame.width, height: 330, child: _Headline(entrance: e)),
                    _card(0, 331.7, lift, _HabitCard(entrance: e)),
                    _card(1, AmountCard.rect.top, lift, AmountCard(entrance: e)),
                    _card(2, 614.3, lift, _PeopleCard(entrance: e)),
                    _card(3, 729.7, lift, _CharityCard(entrance: e)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: lift,
            height: 50,
            child: _TopBar(entrance: e),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: ctaTop - 40,
            bottom: 0,
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000511), Color(0xE6000511), Color(0xFF000511)],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 17.5,
            top: ctaTop,
            child: Staged(
              animation: e,
              begin: 0.55,
              end: 0.95,
              offset: const Offset(0, 50),
              scale: 0.9,
              curve: settle,
              child: _Cta(done: _done, onTap: _create, floor: floor),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _done,
              builder: (context, _) => Confetti(
                progress: span(_done.value, 0.42, 1.0, Curves.linear),
                origin: Offset(196.5, ctaTop + 28),
                count: 90,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(int i, double top, double lift, Widget child) {
    return Positioned(
      left: 17.2,
      top: top + lift,
      child: Staged(
        animation: _in,
        begin: 0.22 + i * 0.08,
        end: 0.62 + i * 0.08,
        offset: const Offset(0, 46),
        rotateX: 0.35,
        scale: 0.94,
        alignment: Alignment.topCenter,
        child: child,
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final title = inter(18.6, 600, color: const Color(0xFFEFF1F6));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 33.5 - 22,
          top: 68.5 - 22,
          child: Staged(
            animation: entrance,
            begin: 0.1,
            end: 0.4,
            offset: const Offset(-14, 0),
            child: Pressable(
              onTap: () => Navigator.of(context).maybePop(),
              scale: 0.85,
              child: const SizedBox.square(dimension: 44, child: Center(child: PhIcon(Ph.caretLeft, size: 26, color: Color(0xFFE6EAF1)))),
            ),
          ),
        ),
        Positioned(
          left: 149.33 - bearing('C', title),
          top: 61.8 - capInset(title),
          child: Staged(animation: entrance, begin: 0.12, end: 0.42, offset: const Offset(0, -10), child: Text('Create Pool', style: title)),
        ),
        Positioned(
          left: 364.5 - 22,
          top: 68 - 22,
          child: Staged(
            animation: entrance,
            begin: 0.16,
            end: 0.46,
            scale: 0.4,
            curve: settle,
            child: Pressable(
              onTap: () {},
              scale: 0.85,
              child: const SizedBox.square(dimension: 44, child: Center(child: PhIcon(Ph.info, size: 23.4, color: Color(0xFFCBD3E6)))),
            ),
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.entrance, required this.scroll});

  final Animation<double> entrance;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([entrance, scroll]),
      builder: (context, _) {
        final off = scroll.hasClients ? scroll.offset : 0.0;
        final zoom = lerp(1.1, 1, span(entrance.value, 0, 0.7, gentle));
        final stretch = off < 0 ? 1 + (-off / 330) : 1.0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..translateByDouble(0, math.max(0, off) * 0.45, 0, 1)
                  ..scaleByDouble(zoom * stretch, zoom * stretch, 1, 1),
                child: Opacity(
                  opacity: span(entrance.value, 0, 0.3, Curves.linear),
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (r) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white, Colors.transparent],
                      stops: [0, 0.9, 1],
                    ).createShader(r),
                    child: Stack(
                      children: [
                        Art.trioPlate.image(),
                        Positioned.fill(child: Tick(builder: (context, s, _) => CustomPaint(painter: _Arc(seconds: s)))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: Art.trio.left,
              top: Art.trio.top,
              width: Art.trio.width,
              height: Art.trio.height,
              child: Transform.translate(
                offset: Offset(0, math.max(0, off) * 0.22 + 36 * (1 - span(entrance.value, 0.06, 0.62, gentle))),
                child: Opacity(
                  opacity: span(entrance.value, 0.06, 0.34, Curves.linear),
                  child: Transform.scale(
                    scale: lerp(0.92, 1, span(entrance.value, 0.06, 0.62, gentle)) * stretch,
                    alignment: Alignment.bottomCenter,
                    child: Tick(
                      builder: (context, s, child) {
                        final b = (wave(s, 3.6) - wave(0, 3.6)) * 1.4;
                        return Transform.translate(offset: Offset(0, b), child: child);
                      },
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (r) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Colors.white, Colors.transparent],
                          stops: [0, 0.82, 1],
                        ).createShader(r),
                        child: Art.trio.image(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Arc extends CustomPainter {
  _Arc({required this.seconds});

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    if (seconds == 0) return;
    const c = Offset(212, 236);
    const r = 116.0;
    final head = math.pi + ((seconds * 0.45) % 1.0) * math.pi;
    for (var i = 0; i < 16; i++) {
      final a = head - i * 0.035;
      if (a < math.pi) break;
      final k = 1 - i / 16;
      canvas.drawCircle(
        c + Offset(math.cos(a), math.sin(a)) * r,
        3.4 * k + 0.6,
        Paint()
          ..blendMode = BlendMode.plus
          ..color = Color.fromRGBO(255, 190, 230, 0.55 * k * k)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(_Arc old) => old.seconds != seconds;
}

class _Headline extends StatelessWidget {
  const _Headline({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final head = inter(27, 700, color: Colors.white, track: -0.01, optical: 28, shadows: const [Shadow(color: Color(0x66000000), blurRadius: 10)]);
    final l1 = inter(15.13, 400, color: const Color(0xFFB3BCD4));
    final l2 = inter(14.15, 400, color: const Color(0xFFABB4CC));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 31 - bearing('B', head),
          top: 245 - capInset(head),
          child: SplitText(text: 'Better Together.', style: head, animation: entrance, begin: 0.18, end: 0.52, rise: 14, flip: 0.7),
        ),
        Positioned(
          left: 29 - bearing('C', l1),
          top: 291.0 - baselineInset(l1),
          child: Staged(animation: entrance, begin: 0.3, end: 0.6, offset: const Offset(0, 10), child: Text('Create a pool, set your goal,', style: l1)),
        ),
        Positioned(
          left: 29.67 - bearing('i', l2),
          top: 311.67 - baselineInset(l2),
          child: Staged(animation: entrance, begin: 0.34, end: 0.64, offset: const Offset(0, 10), child: Text('invite friends and make it happen.', style: l2)),
        ),
      ],
    );
  }
}

TextStyle get _cardTitle => inter(13.5, 600, color: const Color(0xFFE0E4EC));
TextStyle get _cardNote => inter(11.2, 400, color: const Color(0xFF808BA6));

class _HabitCard extends StatefulWidget {
  const _HabitCard({required this.entrance});

  final Animation<double> entrance;

  @override
  State<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<_HabitCard> with SingleTickerProviderStateMixin {
  static const habits = ['Gym', 'Run', 'Read', 'Yoga', 'Meditate'];
  static const origin = Offset(17.2, 331.7);
  int _i = 0;
  late final AnimationController _flip;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 520), value: 1);
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.selectionClick();
    setState(() => _i = (_i + 1) % habits.length);
    _flip.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    const o = origin;
    final value = inter(13.08, 500, color: const Color(0xFFE3E7EF));
    return SizedBox(
      width: 360.6,
      height: 91.6,
      child: Surface(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 29.5 - o.dx,
              top: 342.7 - o.dy,
              child: const Tile(width: 53, height: 52.4, fill: [Color(0xFF211F60), Color(0xFF1C1D57)], edge: Color(0xFF2B2B72), glow: Color(0x227A5CFF)),
            ),
            Positioned(
              left: Art.cDumbbell.left - o.dx,
              top: Art.cDumbbell.top - o.dy,
              width: Art.cDumbbell.width,
              height: Art.cDumbbell.height,
              child: AnimatedBuilder(
                animation: _flip,
                builder: (context, child) {
                  final j = _flip.value < 1 ? math.sin(_flip.value * math.pi * 3) * (1 - _flip.value) : 0.0;
                  return Transform.rotate(angle: j * 0.5, child: Transform.scale(scale: 1 + j.abs() * 0.12, child: child));
                },
                child: Tick(
                  builder: (context, s, child) {
                    final k = s % 3.4;
                    final lift = k < 0.9 ? math.sin(k / 0.9 * math.pi) : 0.0;
                    return Transform.rotate(angle: -0.18 * lift, child: Transform.translate(offset: Offset(0, -2.5 * lift), child: child));
                  },
                  child: Art.cDumbbell.image(),
                ),
              ),
            ),
            Positioned(left: 103 - o.dx - bearing('H', _cardTitle), top: 343.8 - o.dy - capInset(_cardTitle), child: Text('Habit', style: _cardTitle)),
            Positioned(left: 102.33 - o.dx - bearing('W', _cardNote), top: 365.0 - o.dy - capInset(_cardNote), child: Text('What do you want to achieve?', style: _cardNote)),
            Positioned(
              left: 94.5 - o.dx,
              top: 382.2 - o.dy,
              child: Pressable(
                onTap: _next,
                scale: 0.97,
                child: Container(
                  width: 272,
                  height: 31,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF101F41),
                    border: Border.all(color: const Color(0xFF192A4E), width: 1),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 104.67 - 94.5 - bearing('G', value),
                        top: 0,
                        bottom: 0,
                        width: 200,
                        child: ClipRect(
                          child: AnimatedBuilder(
                            animation: _flip,
                            builder: (context, _) {
                              final t = gentle.transform(_flip.value);
                              final prev = habits[(_i - 1 + habits.length) % habits.length];
                              final base = 393.2 - 382.2 - capInset(value);
                              return Stack(
                                children: [
                                  if (t < 1)
                                    Positioned(
                                      left: 0,
                                      top: base - 22 * t,
                                      child: Opacity(opacity: 1 - t, child: Text(prev, style: value)),
                                    ),
                                  Positioned(
                                    left: 0,
                                    top: base + 22 * (1 - t),
                                    child: Opacity(opacity: t, child: Text(habits[_i], style: value)),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        left: 354.2 - 94.5 - 7.5,
                        top: 397.7 - 382.2 - 7.5,
                        child: const PhIcon(Ph.caretRight, size: 15, color: Color(0xFFC3CADB)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeopleCard extends StatefulWidget {
  const _PeopleCard({required this.entrance});

  final Animation<double> entrance;

  @override
  State<_PeopleCard> createState() => _PeopleCardState();
}

class _PeopleCardState extends State<_PeopleCard> with SingleTickerProviderStateMixin {
  static const origin = Offset(17.2, 614.3);
  static const faces = [('p_ryan', 124.5, true), ('p_ava', 170.2, true), ('p_leo', 215.5, true), ('p_noah', 260.8, false)];
  late final AnimationController _add;

  @override
  void initState() {
    super.initState();
    _add = AnimationController(vsync: this, duration: const Duration(milliseconds: 700), value: 1);
  }

  @override
  void dispose() {
    _add.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const o = origin;
    final e = widget.entrance;
    return SizedBox(
      width: 360.6,
      height: 104.4,
      child: Surface(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 29.5 - o.dx,
              top: 624.7 - o.dy,
              child: const Tile(width: 53, height: 52.4, fill: [Color(0xFF231F62), Color(0xFF291A68)], edge: Color(0xFF332C7A), glow: Color(0x227A5CFF)),
            ),
            Positioned(
              left: Art.cUsers.left - o.dx,
              top: Art.cUsers.top - o.dy,
              width: Art.cUsers.width,
              height: Art.cUsers.height,
              child: Art.cUsers.image(),
            ),
            Positioned(left: 106.33 - o.dx - bearing('P', _cardTitle), top: 625.7 - o.dy - capInset(_cardTitle), child: Text('Participants', style: _cardTitle)),
            Positioned(left: 105.33 - o.dx - bearing('I', _cardNote), top: 646.6 - o.dy - capInset(_cardNote), child: Text('Invite your friends (min 3)', style: _cardNote)),
            for (final (i, f) in faces.indexed)
              Positioned(
                left: f.$2 - 20.6 - o.dx,
                top: 688.2 - 20.6 - o.dy,
                child: AnimatedBuilder(
                  animation: e,
                  builder: (context, child) {
                    final t = span(e.value, 0.5 + i * 0.06, 0.85 + i * 0.05, Curves.linear);
                    final s = spring(t, bounce: 0.35);
                    return Opacity(
                      opacity: span(e.value, 0.5 + i * 0.06, 0.6 + i * 0.06, Curves.linear),
                      child: Transform.translate(offset: Offset(-30 * (1 - s), 0), child: Transform.scale(scale: lerp(0.5, 1, s), child: child)),
                    );
                  },
                  child: SizedBox(
                    width: 41.2,
                    height: 41.2,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        RingAvatar(
                          asset: Art.avatar(f.$1),
                          radius: 20.6,
                          photo: 18.6,
                          stroke: 1.6,
                          ring: f.$3
                              ? const [Color(0xFFBFC6D4), Color(0xFF8A93A8), Color(0xFF5D6478)]
                              : const [Color(0xFFF3C77E), Color(0xFFD9A55B), Color(0xFF9B7042)],
                        ),
                        if (f.$3)
                          Positioned(
                            right: -2,
                            bottom: -1,
                            child: Staged(
                              animation: e,
                              begin: 0.72 + i * 0.05,
                              end: 0.95,
                              scale: 0,
                              curve: settle,
                              child: const CheckBadge(size: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 304.8 - 20 - o.dx,
              top: 687.8 - 20 - o.dy,
              child: Staged(
                animation: e,
                begin: 0.78,
                end: 1,
                scale: 0.3,
                curve: settle,
                child: Pressable(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _add.forward(from: 0);
                  },
                  scale: 0.85,
                  child: AnimatedBuilder(
                    animation: _add,
                    builder: (context, child) => Transform.rotate(angle: gentle.transform(_add.value) * math.pi / 2, child: child),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF11234A),
                        border: Border.all(color: const Color(0xFF2B3859), width: 1.2),
                      ),
                      child: const Center(child: PhIcon(Ph.plusRegular, size: 14, color: Color(0xFFB9C3D9))),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckBadge extends StatelessWidget {
  const CheckBadge({super.key, required this.size, this.color = const Color(0xFF2CC98E), this.edge = const Color(0xFF0B1733)});

  final double size;
  final Color color;
  final Color edge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color.lerp(color, Colors.white, 0.18)!, color]),
        border: Border.all(color: edge, width: size * 0.1),
      ),
      child: Center(child: PhIcon(Ph.check, size: size * 0.6, color: Colors.white)),
    );
  }
}

class _CharityCard extends StatelessWidget {
  const _CharityCard({required this.entrance});

  final Animation<double> entrance;

  static const origin = Offset(17.2, 729.7);

  @override
  Widget build(BuildContext context) {
    const o = origin;
    final opt = inter(11.33, 400, color: const Color(0xFF8792AF));
    final org = inter(10.12, 600, color: const Color(0xFFC9D3E8));
    final tag = inter(9.24, 400, color: const Color(0xFF7385A8));
    return SizedBox(
      width: 360.6,
      height: 106.3,
      child: Surface(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 29.5 - o.dx,
              top: 740.0 - o.dy,
              child: const Tile(width: 53, height: 53.3, fill: [Color(0xFF231F62), Color(0xFF291A68)], edge: Color(0xFF332C7A), glow: Color(0x22D35CFF)),
            ),
            Positioned(
              left: Art.cHeart.left - o.dx,
              top: Art.cHeart.top - o.dy,
              width: Art.cHeart.width,
              height: Art.cHeart.height,
              child: Tick(
                builder: (context, s, child) {
                  final k = s % 1.6;
                  double beat(double c) => math.exp(-math.pow((k - c) / 0.07, 2).toDouble());
                  final b = s == 0 ? 0.0 : beat(0.15) + 0.6 * beat(0.42);
                  return Transform.scale(scale: 1 + 0.12 * b, child: child);
                },
                child: Art.cHeart.image(),
              ),
            ),
            Positioned(
              left: 105.67 - o.dx - bearing('C', _cardTitle),
              top: 741.6 - o.dy - capInset(_cardTitle),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('Charity', style: _cardTitle),
                  const SizedBox(width: 3.4),
                  Text('(Optional)', style: opt),
                ],
              ),
            ),
            Positioned(left: 106 - o.dx - bearing('P', _cardNote), top: 762.0 - o.dy - capInset(_cardNote), child: Text('Pick a cause', style: _cardNote)),
            Positioned(
              left: 104.8 - o.dx,
              top: 779.0 - o.dy,
              child: Pressable(
                onTap: () => HapticFeedback.selectionClick(),
                scale: 0.97,
                child: Container(
                  width: 261.7,
                  height: 47.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0F2750), Color(0xFF0C2046)],
                    ),
                    border: Border.all(color: const Color(0xFF1B2F55), width: 1),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: Art.cCharity.left - 104.8,
                        top: Art.cCharity.top - 779.0,
                        width: Art.cCharity.width,
                        height: Art.cCharity.height,
                        child: Art.cCharity.image(),
                      ),
                      Positioned(
                        left: 147 - 104.8 - bearing('A', org),
                        top: 791.9 - 779.0 - capInset(org),
                        child: Text('American Cancer Society', style: org),
                      ),
                      Positioned(
                        left: 291.5 - 104.8 - 7,
                        top: 797.3 - 779.0 - 7,
                        child: Tick(
                          builder: (context, s, child) {
                            final k = s % 4.0;
                            final spin = s > 0 && k < 0.7 ? gentle.transform(k / 0.7) * math.pi * 2 : 0.0;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.004)
                                ..rotateY(spin),
                              child: child,
                            );
                          },
                          child: const _Verified(),
                        ),
                      ),
                      Positioned(
                        left: 147.33 - 104.8 - bearing('T', tag),
                        top: 810.8 - 779.0 - capInset(tag),
                        child: Text('Together we can make a difference.', style: tag),
                      ),
                      Positioned(
                        left: 348 - 104.8 - 7.5,
                        top: 803 - 779.0 - 7.5,
                        child: const PhIcon(Ph.caretRight, size: 15, color: Color(0xFFC3CADB)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Verified extends StatelessWidget {
  const _Verified();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PhIcon(Ph.sealCheck, size: 15, color: const Color(0xFF3B9BFF), shadows: [Shadow(color: const Color(0xFF3B9BFF).withValues(alpha: 0.6), blurRadius: 6)]),
        ],
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.done, required this.onTap, required this.floor});

  final AnimationController done;
  final VoidCallback onTap;
  final double floor;

  @override
  Widget build(BuildContext context) {
    final label = inter(16.38, 600, color: Colors.white);
    return GlowButton(
      width: 361,
      height: CreatePoolScreen.ctaHeight,
      onTap: onTap,
      child: AnimatedBuilder(
        animation: done,
        builder: (context, _) {
          final v = done.value;
          final out = span(v, 0, 0.18, Curves.easeIn);
          final spin = span(v, 0.12, 0.42, Curves.linear);
          final check = span(v, 0.4, 0.6, settle);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Opacity(
                opacity: 1 - out,
                child: Transform.translate(
                  offset: Offset(0, -10 * out),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 144.3 - 17.5 - 13,
                        top: 883.2 - 854.3 - 13,
                        child: const PhIcon(Ph.users, size: 26),
                      ),
                      Positioned(
                        left: 172.33 - 17.5 - bearing('C', label),
                        top: 876.9 - 854.3 - capInset(label),
                        child: Text('Create Pool', style: label),
                      ),
                      Positioned(
                        left: 362 - 17.5 - 8,
                        top: 882.5 - 854.3 - 8,
                        child: PhIcon(Ph.caretRight, size: 16, color: Colors.white.withValues(alpha: 0.35)),
                      ),
                    ],
                  ),
                ),
              ),
              if (spin > 0 && check < 0.01)
                Center(
                  child: Transform.rotate(
                    angle: spin * math.pi * 6,
                    child: const PhIcon(Ph.circleNotch, size: 24),
                  ),
                ),
              if (check > 0)
                Center(
                  child: Transform.scale(
                    scale: check,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PhIcon(Ph.check, size: 22),
                        const SizedBox(width: 8),
                        Text('Pool Created', style: label),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
