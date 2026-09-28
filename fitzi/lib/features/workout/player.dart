import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../widgets/blobs.dart';
import '../../widgets/live_mascot.dart';
import 'workout_screen.dart';

class PlayerRoute<T> extends PageRouteBuilder<T> {
  PlayerRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 700),
          reverseTransitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (context, a, b) => builder(context),
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, inner) {
        final t = animation.status == AnimationStatus.reverse
            ? Curves.easeInCubic.transform(animation.value)
            : gentle.transform(animation.value);
        final size = MediaQuery.sizeOf(context);
        return ClipPath(
          clipper: _Pill(t, size),
          child: Opacity(opacity: span(animation.value, 0, 0.25, Curves.linear), child: inner),
        );
      },
      child: child,
    );
  }
}

class _Pill extends CustomClipper<Path> {
  _Pill(this.t, this.screen);

  final double t;
  final Size screen;

  @override
  Path getClip(Size size) {
    final start = Rect.fromLTWH(20, size.height - 110, size.width - 40, 60);
    final end = Offset.zero & size;
    final r = Rect.lerp(start, end, t)!;
    return Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(lerp(30, 0, t))));
  }

  @override
  bool shouldReclip(_Pill old) => old.t != t;
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with TickerProviderStateMixin {
  late final AnimationController _in;
  late final AnimationController _count;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _elapsed = 0;
  int _step = 0;
  bool _running = false;
  bool _counting = true;

  double get _length => steps[_step].minutes * 60.0;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
    _count = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600));
    _ticker = createTicker(_tick);
    _count.addListener(_countTick);
    _count.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() {
          _counting = false;
          _running = true;
        });
        HapticFeedback.heavyImpact();
        _last = Duration.zero;
        _ticker.start();
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _count.forward();
    });
  }

  int _lastBeat = -1;

  void _countTick() {
    final beat = (_count.value * 4).floor();
    if (beat != _lastBeat) {
      _lastBeat = beat;
      HapticFeedback.selectionClick();
    }
  }

  void _tick(Duration now) {
    final dt = (now - _last).inMicroseconds / 1e6;
    _last = now;
    if (!_running) return;
    setState(() {
      _elapsed += dt;
      if (_elapsed >= _length) _next();
    });
  }

  void _next() {
    HapticFeedback.mediumImpact();
    if (_step < steps.length - 1) {
      _step++;
      _elapsed = 0;
    } else {
      _elapsed = _length;
      _running = false;
    }
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _running = !_running);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _in.dispose();
    _count.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final remain = math.max(0.0, _length - _elapsed);
    final total = remain.ceil();
    final mm = (total ~/ 60).toString().padLeft(2, '0');
    final ss = (total % 60).toString().padLeft(2, '0');
    final progress = (_elapsed / _length).clamp(0.0, 1.0);
    final label = inter(14, 500, color: Palette.body, track: -0.01);
    return Scaffold(
      backgroundColor: Palette.cream,
      body: Stack(
        children: [
          Positioned.fill(
            child: BlobField(
              entrance: _in,
              blobs: [
                Blob(
                  center: Offset(-30, 140 + lift),
                  radii: const Size(120, 120),
                  colors: const [Color(0xFFE8F7A6), Color(0xFFDDF57C)],
                  stops: const [0, 1],
                  seed: 1,
                ),
                Blob(
                  center: Offset(420, 520 + lift),
                  radii: const Size(120, 140),
                  colors: const [Color(0xFFE4D9FD), Color(0xFFB696FC)],
                  stops: const [0, 1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  seed: 2.4,
                  delay: 0.1,
                ),
              ],
            ),
          ),
          Positioned(
            left: 20.5,
            top: 64.5 + lift,
            child: Pressable(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 41,
                height: 41,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Color(0x2A7C6FA0), blurRadius: 14, offset: Offset(0, 6))],
                ),
                child: const PhIcon(Ph.x, size: 18, color: Palette.ink),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 76 + lift,
            child: Center(child: Cap('Full Body Blast', inter(17, 700, track: 0), align: TextAlign.center)),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 150 + lift,
            child: Center(
              child: SizedBox.square(
                dimension: 290,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Tick(
                      builder: (context, seconds, _) => CustomPaint(
                        size: const Size.square(290),
                        painter: _Ring(progress: progress, seconds: seconds, running: _running),
                      ),
                    ),
                    Positioned(
                      top: 46,
                      child: SizedBox(
                        width: 150,
                        height: 196,
                        child: FittedBox(
                          child: LiveMascot(sprite: Art.hero, entrance: _in, idle: _running ? Idle.run : Idle.breathe, begin: 0.1, end: 0.6, drop: 60),
                        ),
                      ),
                    ),
                    if (_counting) _Countdown(animation: _count),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 474 + lift,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(a), child: child),
              ),
              child: Column(
                key: ValueKey(_step),
                children: [
                  Text(steps[_step].name, style: nunito(30, 850, track: -0.02)),
                  const SizedBox(height: 6),
                  Text('Step ${_step + 1} of ${steps.length}', style: label),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 560 + lift,
            child: Center(
              child: Text(
                '$mm:$ss',
                style: inter(54, 700, track: -0.02).copyWith(fontFeatures: const [ui.FontFeature.tabularFigures()]),
              ),
            ),
          ),
          Positioned(
            left: 60,
            right: 60,
            top: 650 + lift,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < steps.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: settle,
                    width: i == _step ? 56 : 44,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i < _step ? Palette.limeDeep : (i == _step ? Palette.violet : const Color(0xFFE6E1F2)),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: math.max(frame.bottom, 24) + 34,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Side(
                  icon: Ph.arrowLeft,
                  onTap: () => setState(() {
                    if (_elapsed > 3 || _step == 0) {
                      _elapsed = 0;
                    } else {
                      _step--;
                      _elapsed = 0;
                    }
                  }),
                ),
                const SizedBox(width: 30),
                Pressable(
                  onTap: _counting ? null : _toggle,
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8D35FD), Color(0xFF5E5FF2)],
                      ),
                      boxShadow: [BoxShadow(color: Color(0x557B3DF5), blurRadius: 24, offset: Offset(0, 10))],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                      child: PhIcon(_running ? Ph.pause : Ph.play, key: ValueKey(_running), size: 32, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                _Side(icon: Ph.skip, onTap: () => setState(_next)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x1A5B4CE0), blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: PhIcon(icon, size: 22, color: Palette.ink),
      ),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final v = animation.value * 4;
        final beat = v.floor().clamp(0, 3);
        final f = v - v.floor();
        final text = beat < 3 ? '${3 - beat}' : 'GO!';
        final pop = spring(math.min(f * 2.2, 1.0), bounce: 0.6, freq: 2.8);
        final fade = f > 0.75 ? 1 - (f - 0.75) / 0.25 : 1.0;
        return Container(
          width: 290,
          height: 290,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Palette.cream.withValues(alpha: 0.86)),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120 + 150 * f,
                height: 120 + 150 * f,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Palette.violet.withValues(alpha: 0.35 * (1 - f)), width: 3),
                ),
              ),
              Opacity(
                opacity: fade.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: lerp(2.2, 1, pop),
                  child: Text(
                    text,
                    style: nunito(beat < 3 ? 110 : 76, 950, track: -0.03).copyWith(
                      foreground: Paint()
                        ..shader = ui.Gradient.linear(
                          const Offset(0, 0),
                          const Offset(0, 120),
                          beat < 3 ? const [Color(0xFF8D35FD), Color(0xFF5E5FF2)] : const [Color(0xFF8BC425), Color(0xFF5F9A10)],
                        ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Ring extends CustomPainter {
  _Ring({required this.progress, required this.seconds, required this.running});

  final double progress;
  final double seconds;
  final bool running;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 14;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..color = const Color(0xFFEDE8F7),
    );
    if (progress > 0) {
      final sweep = math.pi * 2 * progress;
      final rect = Rect.fromCircle(center: c, radius: r);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.sweep(
            c,
            const [Color(0xFF8D35FD), Color(0xFF5E5FF2), Color(0xFFD6F155), Color(0xFF8D35FD)],
            const [0, 0.4, 0.8, 1],
            TileMode.clamp,
            -math.pi / 2,
            math.pi * 1.5,
          ),
      );
      final a = -math.pi / 2 + sweep;
      final head = c + Offset(math.cos(a), math.sin(a)) * r;
      final pulse = running ? 0.5 + 0.5 * math.sin(seconds * 6) : 0.3;
      canvas.drawCircle(
        head,
        12 + 5 * pulse,
        Paint()
          ..color = const Color(0xFFDEF864).withValues(alpha: 0.35 + 0.3 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawCircle(head, 6, Paint()..color = Colors.white);
    }
    final tick = Paint()
      ..color = const Color(0xFFD9D2EA)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 60; i++) {
      final a = i / 60 * math.pi * 2;
      final long = i % 5 == 0;
      final p1 = c + Offset(math.cos(a), math.sin(a)) * (r - 16);
      final p2 = c + Offset(math.cos(a), math.sin(a)) * (r - (long ? 24 : 20));
      canvas.drawLine(p1, p2, tick);
    }
  }

  @override
  bool shouldRepaint(_Ring old) => old.progress != progress || old.seconds != seconds || old.running != running;
}
