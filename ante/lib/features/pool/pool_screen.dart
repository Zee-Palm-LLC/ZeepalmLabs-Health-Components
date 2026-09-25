import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/type.dart';
import '../../widgets/confetti.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/split_text.dart';
import '../home/streak_card.dart';
import 'activity_feed.dart';
import 'members_row.dart';

class PoolScreen extends StatefulWidget {
  const PoolScreen({super.key});

  static const ctaTop = 842.0;
  static const ctaHeight = 58.6;

  @override
  State<PoolScreen> createState() => _PoolScreenState();
}

class _PoolScreenState extends State<PoolScreen> with TickerProviderStateMixin {
  late final AnimationController _in;
  late final AnimationController _check;
  final _scroll = ScrollController();
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 2300))..forward();
    _check = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _in.dispose();
    _check.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _checkIn() async {
    if (_checked) return;
    HapticFeedback.heavyImpact();
    setState(() => _checked = true);
    await _check.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final ctaTop = frame.height - math.max(frame.bottom + 10, 21.8) - PoolScreen.ctaHeight;
    final content = math.max(frame.height, 822.0 + 52 + lift + (frame.height - ctaTop) + 16);
    final e = _in;

    return Scaffold(
      backgroundColor: const Color(0xFF000817),
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
                    Positioned(left: 0, top: 0, width: Frame.width, height: 298 + math.max(0.0, lift), child: _Banner(entrance: e, scroll: _scroll, lift: lift)),
                    Positioned(left: 0, top: lift, width: Frame.width, height: 300, child: _Identity(entrance: e)),
                    Positioned(left: 14, top: 299 + lift, child: _Stats(entrance: e)),
                    Positioned(left: 0, top: lift, width: Frame.width, height: 580, child: MembersRow(entrance: e, check: _check)),
                    Positioned(left: 0, top: lift, width: Frame.width, height: 880, child: ActivityFeed(entrance: e, check: _check)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(left: 0, right: 0, top: lift, height: 50, child: _TopBar(entrance: e)),
          Positioned(
            left: 0,
            right: 0,
            top: ctaTop - 44,
            bottom: 0,
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000817), Color(0xE0000817), Color(0xFF000817)],
                    stops: [0.0, 0.42, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20.2,
            top: ctaTop,
            child: Staged(
              animation: e,
              begin: 0.6,
              end: 0.98,
              offset: const Offset(0, 50),
              scale: 0.9,
              curve: settle,
              child: _CheckIn(check: _check, onTap: _checkIn),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _check,
                builder: (context, _) {
                  final flash = span(_check.value, 0.0, 0.06, Curves.easeOut) * (1 - span(_check.value, 0.06, 0.3, Curves.easeIn));
                  return Stack(
                    children: [
                      Opacity(opacity: flash * 0.85, child: const ColoredBox(color: Colors.white, child: SizedBox.expand())),
                      Confetti(progress: span(_check.value, 0.3, 1.0, Curves.linear), origin: Offset(196.5, ctaTop + 20), count: 60, seed: 3),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    Widget disc(Widget child) => Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x2E0C1A33),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
          ),
          child: Center(child: child),
        );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 33 - 19,
          top: 70 - 19,
          child: Staged(
            animation: entrance,
            begin: 0.1,
            end: 0.4,
            offset: const Offset(-14, 0),
            child: Pressable(
              onTap: () => Navigator.of(context).maybePop(),
              scale: 0.85,
              child: disc(const PhIcon(Ph.caretLeft, size: 23, color: Color(0xFFE6EFF7))),
            ),
          ),
        ),
        Positioned(
          left: 313.5 - 19,
          top: 69.2 - 19,
          child: Staged(
            animation: entrance,
            begin: 0.14,
            end: 0.44,
            offset: const Offset(0, -10),
            child: Pressable(
              onTap: () => HapticFeedback.selectionClick(),
              scale: 0.85,
              child: const SizedBox.square(dimension: 38, child: Center(child: PhIcon(Ph.export, size: 23, color: Color(0xFFDDE5F3)))),
            ),
          ),
        ),
        Positioned(
          left: 360.3 - 19,
          top: 70.2 - 19,
          child: Staged(
            animation: entrance,
            begin: 0.18,
            end: 0.48,
            offset: const Offset(14, 0),
            child: Pressable(
              onTap: () => HapticFeedback.selectionClick(),
              scale: 0.85,
              child: disc(const PhIcon(Ph.dotsThree, size: 21, color: Color(0xFFDDE9F3))),
            ),
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.entrance, required this.scroll, required this.lift});

  final Animation<double> entrance;
  final ScrollController scroll;
  final double lift;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([entrance, scroll]),
      builder: (context, _) {
        final off = scroll.hasClients ? scroll.offset : 0.0;
        final pull = off < 0 ? -off : 0.0;
        final cover = lift > 0 ? (298 + lift) / 298 : 1.0;
        final zoom = lerp(1.14, 1, span(entrance.value, 0, 0.8, gentle)) * (1 + pull / 300) * cover;
        final drift = math.max(0.0, off) * 0.5;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: lift + drift - pull,
              width: Frame.width,
              height: 298,
              child: Transform.scale(
                scale: zoom,
                alignment: Alignment.bottomCenter,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (r) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white, Colors.transparent],
                    stops: [0, 0.8, 1],
                  ).createShader(r),
                  child: Stack(
                    children: [
                      Art.clubPlate.image(),
                      Positioned.fill(child: Tick(builder: (context, s, _) => CustomPaint(painter: _Sun(seconds: s)))),
                      Positioned(
                        left: Art.clubRunner.left,
                        top: Art.clubRunner.top,
                        width: Art.clubRunner.width,
                        height: Art.clubRunner.height,
                        child: Transform.translate(
                          offset: Offset(26 * (1 - span(entrance.value, 0.1, 0.7, gentle)) - math.max(0.0, off) * 0.12, math.max(0.0, off) * -0.1),
                          child: Opacity(
                            opacity: span(entrance.value, 0.1, 0.3, Curves.linear),
                            child: Tick(
                              builder: (context, s, child) {
                                final b = (wave(s, 0.8) - wave(0, 0.8)) * 0.8;
                                return Transform.translate(offset: Offset(0, b), child: child);
                              },
                              child: Art.clubRunner.image(),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _Sun extends CustomPainter {
  _Sun({required this.seconds});

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    if (seconds == 0) return;
    const c = Offset(310, 171);
    final b = 0.5 + 0.5 * wave(seconds, 3.2);
    canvas.drawCircle(
      c,
      46 + 8 * b,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [Color.fromRGBO(255, 214, 150, 0.22 + 0.1 * b), const Color(0x00000000)],
        ).createShader(Rect.fromCircle(center: c, radius: 54)),
    );
    final rays = Paint()..blendMode = BlendMode.plus;
    for (var i = 0; i < 10; i++) {
      final a = seconds * 0.08 + i * math.pi / 5;
      final len = 90 + 22 * math.sin(i * 1.3 + seconds);
      final w = 0.05;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + math.cos(a - w) * len, c.dy + math.sin(a - w) * len)
        ..lineTo(c.dx + math.cos(a + w) * len, c.dy + math.sin(a + w) * len)
        ..close();
      rays.shader = RadialGradient(colors: [const Color(0x24FFE3B0), const Color(0x00000000)]).createShader(Rect.fromCircle(center: c, radius: len));
      canvas.drawPath(path, rays);
    }
  }

  @override
  bool shouldRepaint(_Sun old) => old.seconds != seconds;
}

class _Identity extends StatelessWidget {
  const _Identity({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final e = entrance;
    final title = inter(24.3, 700, color: Colors.white, optical: 18, shadows: const [Shadow(color: Color(0x88000000), blurRadius: 12)]);
    final sub = inter(12.76, 500, color: const Color(0xFFD7DCF2), shadows: const [Shadow(color: Color(0x99000000), blurRadius: 8)]);
    final streak = inter(11.14, 500, color: const Color(0xFFEDE6DD));
    final active = inter(11.98, 500, color: const Color(0xFF64D8B2));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 17.5,
          top: 173.8,
          child: AnimatedBuilder(
            animation: e,
            builder: (context, child) {
              final s = spring(span(e.value, 0.12, 0.6, Curves.linear), bounce: 0.35);
              return Opacity(
                opacity: span(e.value, 0.12, 0.25, Curves.linear),
                child: Transform.rotate(angle: (1 - s) * -0.5, child: Transform.scale(scale: lerp(0.4, 1, s), child: child)),
              );
            },
            child: Tick(
              builder: (context, s, child) {
                final g = 0.5 + 0.5 * wave(s, 2.6);
                return Container(
                  width: 68.3,
                  height: 73.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2A2027), Color(0xFF121522), Color(0xFF0D111D)],
                    ),
                    boxShadow: [BoxShadow(color: Color.fromRGBO(255, 150, 60, 0.18 + 0.12 * g), blurRadius: 18 + 6 * g)],
                  ),
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color.lerp(const Color(0xFF8A5A33), const Color(0xFFC98A4B), g)!, width: 1.4),
                  ),
                  child: child,
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: Art.dRun.left - 17.5,
                    top: Art.dRun.top - 173.8,
                    width: Art.dRun.width,
                    height: Art.dRun.height,
                    child: Hero(
                      tag: 'run-club',
                      child: Tick(
                        builder: (context, s, child) {
                          final k = s % 1.2;
                          final hop = s == 0 ? 0.0 : math.sin(k / 1.2 * math.pi * 2);
                          return Transform.translate(offset: Offset(0, -1.4 * hop), child: Transform.rotate(angle: 0.04 * hop, child: child));
                        },
                        child: Art.dRun.image(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 101.67 - bearing('R', title),
          top: 188.67 - capInset(title),
          child: SplitText(text: 'Run Club', style: title, animation: e, begin: 0.18, end: 0.5, rise: 12, flip: 0.8),
        ),
        Positioned(
          left: 101.67 - bearing('B', sub),
          top: 220.4 - capInset(sub),
          child: Staged(animation: e, begin: 0.28, end: 0.58, offset: const Offset(0, 10), child: Text('Better Together. Stronger Daily.', style: sub)),
        ),
        Positioned(
          left: 98.3,
          top: 250.8,
          child: Staged(
            animation: e,
            begin: 0.34,
            end: 0.66,
            offset: const Offset(-16, 0),
            scale: 0.8,
            curve: settle,
            child: Container(
              width: 113,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color(0xCC0D1A38),
                border: Border.all(color: const Color(0xFF2A2F48), width: 1),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(left: 112.3 - 98.3 - 11, top: 267.2 - 250.8 - 11.5, child: const Flicker(size: 22)),
                  Positioned(left: 130.33 - 98.3 - bearing('1', streak), top: 261.0 - 250.8 - capInset(streak), child: Text('12 Day Streak', style: streak)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 223.3,
          top: 250.7,
          child: Staged(
            animation: e,
            begin: 0.38,
            end: 0.7,
            offset: const Offset(16, 0),
            scale: 0.8,
            curve: settle,
            child: Container(
              width: 73.4,
              height: 29.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.7),
                color: const Color(0xCC0E2A2C),
                border: Border.all(color: const Color(0xFF1C3B3A), width: 1),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 240.2 - 223.3 - 9,
                    top: 265.7 - 250.7 - 9,
                    child: Tick(
                      builder: (context, s, _) => CustomPaint(size: const Size(18, 18), painter: _Live(seconds: s)),
                    ),
                  ),
                  Positioned(left: 251.2 - 223.3 - bearing('A', active), top: 260.8 - 250.7 - capInset(active), child: Text('Active', style: active)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Live extends CustomPainter {
  _Live({required this.seconds});

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    if (seconds > 0) {
      final t = (seconds % 1.8) / 1.8;
      canvas.drawCircle(c, 4.3 + 6 * t, Paint()..color = Color.fromRGBO(67, 210, 155, 0.45 * (1 - t)));
    }
    canvas.drawCircle(c, 4.3, Paint()..color = const Color(0xFF43D29B));
    canvas.drawCircle(c, 4.3, Paint()..color = const Color(0x6643D29B)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }

  @override
  bool shouldRepaint(_Live old) => old.seconds != seconds;
}

class _Stats extends StatelessWidget {
  const _Stats({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final e = entrance;
    final label = inter(11.6, 400, color: const Color(0xFF93A2BD));
    const cols = [
      (73.5, Ph.tote, r'$20', 18.46, 600.0, [Color(0xFF7FE3D6), Color(0xFF4DB8C9)], 'Pool Amount'),
      (198.4, Ph.users, '8 / 10', 16.6, 500.0, [Color(0xFFB9CDEB), Color(0xFF93AED6)], 'Members'),
      (321.6, Ph.calendarDots, '12', 17.76, 500.0, [Color(0xFFB2D8EA), Color(0xFF86BCD4)], 'Days Left'),
    ];
    return Staged(
      animation: e,
      begin: 0.3,
      end: 0.7,
      offset: const Offset(0, 36),
      rotateX: 0.3,
      alignment: Alignment.topCenter,
      child: Container(
        width: 368.8,
        height: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF071632), Color(0xFF051129)],
          ),
          border: Border.all(color: const Color(0xFF1C2A48), width: 1.1),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final x in const [134.0, 262.0])
              Positioned(
                left: x - 14,
                top: 13,
                child: AnimatedBuilder(
                  animation: e,
                  builder: (context, _) => Container(
                    width: 1,
                    height: 70 * span(e.value, 0.5, 0.85, gentle),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x001C2A48), Color(0xFF1E2C4A), Color(0x001C2A48)],
                      ),
                    ),
                  ),
                ),
              ),
            for (final (i, c) in cols.indexed) ...[
              Positioned(
                left: c.$1 - 14 - 11,
                top: 326.6 - 299 - 11,
                child: Staged(
                  animation: e,
                  begin: 0.45 + i * 0.06,
                  end: 0.75 + i * 0.06,
                  scale: 0.3,
                  curve: settle,
                  child: PhIcon(c.$2, size: 22, color: const Color(0xFFA3C7E9)),
                ),
              ),
              Positioned(
                left: c.$1 - 14 - 60,
                width: 120,
                top: 347.5 - 299 - capInset(inter(c.$4, c.$5)),
                child: Center(
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (r) => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: c.$6).createShader(r),
                    child: Text(c.$3, style: inter(c.$4, c.$5, color: Colors.white)),
                  ),
                ),
              ),
              Positioned(
                left: c.$1 - 14 - 60,
                width: 120,
                top: 368.8 - 299 - capInset(label),
                child: Text(c.$7, style: label, textAlign: TextAlign.center),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckIn extends StatelessWidget {
  const _CheckIn({required this.check, required this.onTap});

  final AnimationController check;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = inter(15.83, 600, color: Colors.white);
    return GlowButton(
      width: 353.3,
      height: PoolScreen.ctaHeight,
      onTap: onTap,
      child: AnimatedBuilder(
        animation: check,
        builder: (context, _) {
          final v = check.value;
          final out = span(v, 0.05, 0.25, Curves.easeIn);
          final into = span(v, 0.25, 0.5, settle);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (out < 1)
                Opacity(
                  opacity: 1 - out,
                  child: Transform.translate(
                    offset: Offset(0, 12 * out),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(left: 160.8 - 20.2 - 13.4, top: 872.2 - 842 - 13.4, child: const PhIcon(Ph.camera, size: 26.8)),
                        Positioned(left: 187 - 20.2 - bearing('C', label), top: 865.9 - 842 - capInset(label), child: Text('Check In', style: label)),
                      ],
                    ),
                  ),
                ),
              if (into > 0)
                Center(
                  child: Transform.scale(
                    scale: into,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PhIcon(Ph.check, size: 21),
                        const SizedBox(width: 8),
                        Text('Checked In', style: label),
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
