import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/art.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/chunky.dart';
import '../widgets/fx.dart';
import '../widgets/model3d.dart';
import 'run_game.dart';

class RunPage extends StatefulWidget {
  const RunPage({super.key, required this.onExit, this.game});

  final VoidCallback onExit;
  final RunGame? game;

  @override
  State<RunPage> createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  late final RunGame _game = widget.game ?? RunGame(seed: DateTime.now().millisecond);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onExit();
      },
      child: Scaffold(
        backgroundColor: Tone.space,
        body: GameWidget<RunGame>(
          game: _game,
          overlayBuilderMap: {
            'hero': (context, g) => HeroModel(game: g),
            'hud': (context, g) => Hud(game: g, onExit: widget.onExit),
            'ready': (context, g) => Ready(game: g),
            'over': (context, g) => Results(game: g, onExit: widget.onExit),
            'checkpoint': (context, g) => Checkpoint(game: g),
          },
          initialActiveOverlays: const ['hero', 'hud', 'ready', 'over', 'checkpoint'],
        ),
      ),
    );
  }
}

class Hud extends StatelessWidget {
  const Hud({super.key, required this.game, required this.onExit});

  final RunGame game;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final s = game.stats;
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 30,
          child: IgnorePointer(
            child: ValueListenableBuilder<int>(
              valueListenable: s.seconds,
              builder: (context, sec, _) {
                final m = (sec ~/ 60).toString().padLeft(2, '0');
                final r = (sec % 60).toString().padLeft(2, '0');
                return Center(child: ChunkyText('$m:$r', size: 76));
              },
            ),
          ),
        ),
        Positioned(
          left: 40,
          top: 148,
          child: IgnorePointer(
            child: GlassPill(
              width: 150,
              height: 50,
              rim: const Color(0xAAFF7AA8),
              child: Padding(
                padding: const EdgeInsets.only(left: 48),
                child: ValueListenableBuilder<int>(
                  valueListenable: s.lives,
                  builder: (context, lives, _) => Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        _Heart(on: i < lives, key: ValueKey('h$i$lives')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 22,
          top: 141,
          width: 64,
          height: 64,
          child: IgnorePointer(
            child: ValueListenableBuilder<int>(
              valueListenable: s.lives,
              builder: (context, lives, child) => Tick(
                builder: (context, t, child) {
                  final beat = (t * (1.6 + (3 - lives) * 0.8)) % 1.0;
                  final pulse = beat < 0.15 ? math.sin(beat / 0.15 * math.pi) : 0.0;
                  return Transform.scale(scale: 1 + 0.1 * pulse, child: child);
                },
                child: child,
              ),
              child: Art.heart.image(),
            ),
          ),
        ),
        Positioned(
          left: 212,
          top: 148,
          child: IgnorePointer(
            child: GlassPill(
              width: 170,
              height: 50,
              rim: const Color(0xAAFFB878),
              child: ValueListenableBuilder<int>(
                valueListenable: s.coins,
                builder: (context, coins, _) => Row(
                  children: [
                    const SizedBox(width: 10),
                    SizedBox(width: 34, height: 34, child: Image.asset(Art.coin.asset)),
                    const SizedBox(width: 6),
                    _Bump(value: coins, child: Label('$coins', style: baloo(22, weight: 800))),
                    const Spacer(),
                    ValueListenableBuilder<int>(
                      valueListenable: s.meters,
                      builder: (context, m, _) => Label('${m}m', style: baloo(16, color: const Color(0xFFFFE5C2))),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 212,
          child: IgnorePointer(
            child: ValueListenableBuilder<int>(
              valueListenable: s.combo,
              builder: (context, combo, _) => AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: combo >= 3 ? 1 : 0,
                child: Center(
                  child: _Bump(
                    value: combo,
                    child: Label('x$combo combo', style: baloo(20, weight: 800, color: const Color(0xFFFF9AE0), shadows: const [Shadow(color: Color(0xFF3A1E6E), offset: Offset(0, 2))])),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 240,
          child: IgnorePointer(
            child: ListenableBuilder(
              listenable: Listenable.merge([s.magnet, s.shield]),
              builder: (context, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (s.magnet.value > 0) _Power(asset: 'assets/game/magnet.webp', left: s.magnet.value),
                  if (s.shield.value) const _Power(asset: 'assets/game/shield.webp', left: 1),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          left: 110,
          top: 791,
          child: IgnorePointer(
            child: GlassPill(width: 239, height: 38, rim: Color(0x99C98BFF), fill: LinearGradient(colors: [Color(0xE6532C9A), Color(0xE6431F86)])),
          ),
        ),
        Positioned(
          left: 115,
          top: 799,
          width: 224,
          height: 21,
          child: IgnorePointer(
            child: ListenableBuilder(
              listenable: Listenable.merge([s.boost, s.boosting]),
              builder: (context, _) => Tick(builder: (context, t, _) => CustomPaint(painter: BoostPainter(s.boost.value, s.boosting.value, t))),
            ),
          ),
        ),
        At(
          baseline: 785.2,
          size: 17.5,
          left: 118.1,
          child: IgnorePointer(
            child: ValueListenableBuilder<double>(
              valueListenable: s.boost,
              builder: (context, b, _) => Label(b >= 1 ? 'Boost ready! Tap the rocket' : 'Boost', style: baloo(17.5, color: b >= 1 ? const Color(0xFFFFE27A) : Colors.white, shadows: const [Shadow(color: Color(0x66401A7A), blurRadius: 6)])),
            ),
          ),
        ),
        Place(
          Art.rocket,
          child: ValueListenableBuilder<double>(
            valueListenable: s.boost,
            builder: (context, b, child) => Pressable(
              onTap: game.fireBoost,
              scale: 0.85,
              child: Tick(
                builder: (context, t, child) {
                  final ready = b >= 1;
                  return Transform.rotate(
                    angle: ready ? 0.12 * math.sin(t * 18) : 0,
                    child: Transform.scale(
                      scale: ready ? 1 + 0.06 * wave(t, 0.6).abs() : 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: const Color(0xFFFF7AD0).withValues(alpha: ready ? 0.7 : 0.15), blurRadius: ready ? 26 : 10)],
                        ),
                        child: child,
                      ),
                    ),
                  );
                },
                child: child,
              ),
            ),
            child: Art.rocket.image(),
          ),
        ),
        Positioned(
          left: 6,
          top: 50,
          child: Pressable(
            onTap: () {
              HapticFeedback.selectionClick();
              game.paused = !game.paused;
              (context as Element).markNeedsBuild();
            },
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: const Color(0x99221C5E), shape: BoxShape.circle, border: Border.all(color: const Color(0x66FFFFFF), width: 1.4)),
                  child: Center(child: Label(game.paused ? '▶' : 'II', style: baloo(14, weight: 800))),
                ),
              ),
            ),
          ),
        ),
        if (game.paused) _PauseCard(game: game, onExit: onExit),
      ],
    );
  }
}

class _PauseCard extends StatelessWidget {
  const _PauseCard({required this.game, required this.onExit});

  final RunGame game;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0x99140F45),
        child: Center(
          child: GameCard(
            title: 'Paused',
            children: [
              const SizedBox(height: 10),
              GoldButton(
                width: 230,
                height: 54,
                size: 22,
                label: 'Resume',
                onTap: () {
                  game.paused = false;
                  game.overlays.remove('hud');
                  game.overlays.add('hud');
                },
              ),
              const SizedBox(height: 14),
              _GhostButton(label: 'Back to world', onTap: onExit),
            ],
          ),
        ),
      ),
    );
  }
}

class _Heart extends StatelessWidget {
  const _Heart({super.key, required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return Entrance(
      duration: const Duration(milliseconds: 500),
      builder: (context, a) => AnimatedBuilder(
        animation: a,
        builder: (context, child) {
          final s = on ? spring(a.value, bounce: 0.5, freq: 2.4) : 1 - 0.25 * Curves.easeOut.transform(a.value);
          return Opacity(opacity: on ? 1 : 0.3, child: Transform.scale(scale: s, child: child));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: ColorFiltered(
            colorFilter: on ? const ColorFilter.mode(Color(0x00000000), BlendMode.dst) : const ColorFilter.matrix([0.3, 0.3, 0.3, 0, 0, 0.3, 0.3, 0.3, 0, 0, 0.3, 0.3, 0.3, 0, 0, 0, 0, 0, 1, 0]),
            child: Image.asset('assets/game/red_heart.webp', width: 28, height: 28),
          ),
        ),
      ),
    );
  }
}

class _Bump extends StatefulWidget {
  const _Bump({required this.value, required this.child});

  final int value;
  final Widget child;

  @override
  State<_Bump> createState() => _BumpState();
}

class _BumpState extends State<_Bump> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  }

  @override
  void didUpdateWidget(_Bump old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Transform.scale(scale: 1 + 0.35 * math.sin(_c.value * math.pi) * (1 - _c.value), child: child),
      child: widget.child,
    );
  }
}

class _Power extends StatelessWidget {
  const _Power({required this.asset, required this.left});

  final String asset;
  final double left;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: SizedBox(
        width: 46,
        height: 46,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(size: const Size(46, 46), painter: _RingPainter(left)),
            Image.asset(asset, width: 30, height: 30),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.left);

  final double left;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawCircle(r.center, size.width / 2, Paint()..color = const Color(0xCC221C5E));
    canvas.drawArc(
      r.deflate(2.5),
      -math.pi / 2,
      math.pi * 2 * left,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFD34A),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.left != left;
}

class BoostPainter extends CustomPainter {
  BoostPainter(this.fill, this.boosting, this.t);

  final double fill;
  final bool boosting;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.height / 2));
    canvas.drawRRect(track, Paint()..color = const Color(0xFF3A1A6E));
    final w = size.width * fill.clamp(0.0, 1.0);
    if (w <= 1) return;
    final bar = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, size.height), Radius.circular(size.height / 2));
    final full = fill >= 1 || boosting;
    final colors = boosting
        ? [const Color(0xFFFFB0EE), const Color(0xFFFF6AD0), const Color(0xFFB04CF0)]
        : [const Color(0xFFFFE27A), const Color(0xFFFFC23A), const Color(0xFFF3A21E)];
    if (full) {
      canvas.drawRRect(
        bar,
        Paint()
          ..color = colors[1].withValues(alpha: 0.5 + 0.3 * math.sin(t * 8))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    canvas.drawRRect(
      bar,
      Paint()
        ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors, stops: const [0, 0.5, 1]).createShader(Offset.zero & size),
    );
    canvas.save();
    canvas.clipRRect(bar);
    final seg = size.width / 6.2;
    final shift = (t * 40) % seg;
    for (var x = shift; x < w + seg; x += seg) {
      canvas.drawLine(
        Offset(x + 3, 2),
        Offset(x - 3, size.height - 2),
        Paint()
          ..color = const Color(0x55C4600E)
          ..strokeWidth = 2,
      );
    }
    canvas.drawRect(Rect.fromLTWH(0, 2, w, size.height * 0.28), Paint()..color = Colors.white.withValues(alpha: 0.35));
    canvas.restore();
  }

  @override
  bool shouldRepaint(BoostPainter old) => true;
}

class Ready extends StatelessWidget {
  const Ready({super.key, required this.game});

  final RunGame game;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ListenableBuilder(
        listenable: Listenable.merge([game.stats.phase, game.stats.countdown]),
        builder: (context, _) {
          if (game.stats.phase.value != Phase.ready || game.readyClock < 0) return const SizedBox.shrink();
          final c = game.stats.countdown.value;
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 360,
                child: Center(
                  child: Entrance(
                    key: ValueKey(c),
                    duration: const Duration(milliseconds: 900),
                    builder: (context, a) => AnimatedBuilder(
                      animation: a,
                      builder: (context, child) {
                        final s = spring(span(a.value, 0, 0.6, Curves.linear), bounce: 0.5, freq: 2.4);
                        return Opacity(
                          opacity: 1 - span(a.value, 0.75, 1, Curves.linear),
                          child: Transform.scale(scale: lerp(2.2, 1, s), child: child),
                        );
                      },
                      child: ChunkyText('$c', size: 150),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 560,
                child: Center(
                  child: GlassPill(
                    width: 300,
                    height: 76,
                    radius: 22,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Label('Swipe ← → to change lanes', style: baloo(16)),
                          Label('Swipe ↑ or tap to jump', style: baloo(16, color: const Color(0xFFFFE27A))),
                        ],
                      ),
                    ),
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

class Checkpoint extends StatelessWidget {
  const Checkpoint({super.key, required this.game});

  final RunGame game;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<int>(
        valueListenable: game.stats.checkpoint,
        builder: (context, cp, _) {
          if (cp == 0) return const SizedBox.shrink();
          return Entrance(
            key: ValueKey(cp),
            duration: const Duration(milliseconds: 2200),
            builder: (context, a) => AnimatedBuilder(
              animation: a,
              builder: (context, _) {
                final v = a.value;
                final s = spring(span(v, 0, 0.3, Curves.linear), bounce: 0.5, freq: 2.2);
                final out = span(v, 0.8, 1, Curves.easeIn);
                return Opacity(
                  opacity: (1 - out) * span(v, 0, 0.1, Curves.linear),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 300,
                        child: Center(
                          child: Transform.scale(
                            scale: lerp(0.3, 1, s),
                            child: Transform.rotate(angle: 0.08 * math.sin(v * 30) * (1 - v), child: SizedBox(width: 120, height: 98, child: Art.chest.image(fit: BoxFit.contain))),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 410,
                        child: Center(child: Transform.scale(scale: lerp(0.5, 1, s), child: ChunkyText('${cp * 500}m!', size: 54))),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 480,
                        child: Center(child: Label('Volcano reward  +25 coins', style: baloo(20, weight: 800, color: const Color(0xFFFFE7A6), shadows: const [Shadow(color: Color(0xFF3A1E6E), offset: Offset(0, 2))]))),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class Results extends StatelessWidget {
  const Results({super.key, required this.game, required this.onExit});

  final RunGame game;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Phase>(
      valueListenable: game.stats.phase,
      builder: (context, phase, _) {
        if (phase != Phase.over) return const SizedBox.shrink();
        final s = game.stats;
        final score = s.score;
        final best = score >= Stats.best;
        final stars = s.meters.value > 600 ? 3 : (s.meters.value > 250 ? 2 : 1);
        return Entrance(
          delay: const Duration(milliseconds: 900),
          duration: const Duration(milliseconds: 2000),
          builder: (context, a) => AnimatedBuilder(
            animation: a,
            builder: (context, _) {
              final v = a.value;
              final card = spring(span(v, 0, 0.35, Curves.linear), bounce: 0.3, freq: 1.8);
              return Stack(
                children: [
                  Positioned.fill(child: ColoredBox(color: Color.fromRGBO(20, 15, 69, 0.65 * span(v, 0, 0.2, Curves.linear)))),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Opacity(
                        opacity: span(v, 0, 0.15, Curves.linear),
                        child: Transform.translate(
                          offset: Offset(0, 300 * (1 - card)),
                          child: GameCard(
                            title: 'Run complete!',
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (var i = 0; i < 3; i++)
                                    Transform.translate(
                                      offset: Offset(0, i == 1 ? -10 : 0),
                                      child: Transform.scale(
                                        scale: spring(span(v, 0.3 + i * 0.1, 0.55 + i * 0.1, Curves.linear), bounce: 0.6, freq: 2.6),
                                        child: Opacity(
                                          opacity: i < stars ? 1 : 0.25,
                                          child: Image.asset(Art.star.asset, width: i == 1 ? 64 : 52, height: i == 1 ? 64 : 52),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              CountUp(value: score, t: span(v, 0.4, 0.8, Curves.linear), style: baloo(46, weight: 800, color: const Color(0xFFFFE27A), shadows: const [Shadow(color: Color(0xFF3A1E6E), offset: Offset(0, 3))])),
                              Opacity(
                                opacity: best ? span(v, 0.8, 0.9, Curves.linear) : 0,
                                child: Label('NEW BEST!', style: baloo(18, weight: 800, color: const Color(0xFFFF9AE0))),
                              ),
                              const SizedBox(height: 10),
                              _Stat(icon: 'assets/game/stopwatch.webp', label: 'Distance', value: '${s.meters.value} m'),
                              _Stat(icon: Art.coin.asset, label: 'Coins', value: '${s.coins.value}'),
                              _Stat(icon: 'assets/game/trophy.webp', label: 'Best', value: CountUp.group(Stats.best)),
                              const SizedBox(height: 16),
                              Transform.scale(
                                scale: spring(span(v, 0.6, 0.9, Curves.linear), bounce: 0.4, freq: 2),
                                child: GoldButton(width: 240, height: 56, size: 22, label: 'Run again', onTap: game.restart),
                              ),
                              const SizedBox(height: 12),
                              _GhostButton(label: 'Back to world', onTap: onExit),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 26),
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF4A3FB0), Color(0xFF2E2780)]),
              border: Border.all(color: const Color(0xFFD9CCFF), width: 2.5),
              boxShadow: const [BoxShadow(color: Color(0xAA0C0830), blurRadius: 30, offset: Offset(0, 14)), BoxShadow(color: Color(0x668B6CFF), blurRadius: 40)],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
          Positioned(
            left: 40,
            right: 40,
            top: 0,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFF8AD8), Color(0xFFC64CE8)]),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [BoxShadow(color: Color(0x88701AA0), offset: Offset(0, 5))],
              ),
              alignment: Alignment.center,
              child: Label(title, style: baloo(24, weight: 800, shadows: const [Shadow(color: Color(0xFF6A1A9A), offset: Offset(0, 2))])),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0x55140F45), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Image.asset(icon, width: 28, height: 28),
          const SizedBox(width: 10),
          Label(label, style: baloo(17, color: const Color(0xFFD9D2FF))),
          const Spacer(),
          Label(value, style: baloo(19, weight: 800)),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.94,
      child: Container(
        width: 240,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x88FFFFFF), width: 1.6),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PhIcon(Ph.caretLeft, size: 16),
            const SizedBox(width: 6),
            Label(label, style: baloo(18)),
          ],
        ),
      ),
    );
  }
}

class HeroModel extends StatefulWidget {
  const HeroModel({super.key, required this.game});

  final RunGame game;

  @override
  State<HeroModel> createState() => _HeroModelState();
}

class _HeroModelState extends State<HeroModel> {
  Flutter3DController? _controller;
  String _clip = '';

  @override
  void initState() {
    super.initState();
    widget.game.airborne.addListener(_sync);
    widget.game.stats.phase.addListener(_sync);
  }

  @override
  void dispose() {
    widget.game.airborne.removeListener(_sync);
    widget.game.stats.phase.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    final c = _controller;
    if (c == null) return;
    final phase = widget.game.stats.phase.value;
    final clip = phase != Phase.playing ? 'Idle' : (widget.game.airborne.value ? 'Jump' : 'Run');
    if (clip == _clip) return;
    _clip = clip;
    c.playAnimation(animationName: clip);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<Rect>(
        valueListenable: widget.game.hero,
        builder: (context, rect, child) => Stack(children: [Positioned.fromRect(rect: rect, child: child!)]),
        child: Model3D(
          src: 'assets/models/runner.glb',
          interactive: false,
          fallback: const SizedBox.shrink(),
          onReady: (controller) {
            _controller = controller;
            controller.setCameraOrbit(180, 70, 100);
            widget.game.useModel = true;
            _clip = '';
            _sync();
          },
        ),
      ),
    );
  }
}
