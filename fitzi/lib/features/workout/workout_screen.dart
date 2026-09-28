import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../widgets/blobs.dart';
import '../../widgets/live_mascot.dart';
import 'player.dart';

class WorkoutRoute<T> extends PageRouteBuilder<T> {
  WorkoutRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 760),
          reverseTransitionDuration: const Duration(milliseconds: 520),
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
        return Opacity(
          opacity: span(animation.value, 0, 0.35, Curves.linear),
          child: Transform.scale(scale: lerp(1.04, 1, t), child: inner),
        );
      },
      child: child,
    );
  }
}

class Step {
  const Step(this.name, this.minutes);

  final String name;
  final int minutes;
}

const steps = [Step('Warm Up', 3), Step('Circuit 1', 7), Step('Circuit 2', 7), Step('Cool Down', 3)];

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  static const refHeight = 895.2;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> with TickerProviderStateMixin {
  late final AnimationController _in;
  late final AnimationController _like;
  final _scroll = ScrollController();
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 2300))..forward();
    _like = AnimationController(vsync: this, duration: const Duration(milliseconds: 820));
  }

  @override
  void dispose() {
    _in.dispose();
    _like.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toggleLike() {
    HapticFeedback.lightImpact();
    setState(() => _liked = !_liked);
    if (_liked) _like.forward(from: 0);
  }

  void _start() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(PlayerRoute(builder: (_) => const PlayerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final low = frame.height - WorkoutScreen.refHeight - math.max(0.0, frame.bottom - 34);
    final ctaTop = 792.0 + low;
    return Scaffold(
      backgroundColor: Palette.cream,
      body: PopScope(
        child: SizedBox(
          width: Frame.width,
          height: frame.height,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: Frame.width,
                    height: math.max(frame.height, 770 + lift + (frame.height - ctaTop) + 18),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 0,
                          top: lift,
                          width: Frame.width,
                          height: 356,
                          child: _StageBack(entrance: _in),
                        ),
                        Positioned(
                          left: 0,
                          top: 296 + lift,
                          width: Frame.width,
                          height: 600,
                          child: Staged(
                            animation: _in,
                            begin: 0.08,
                            end: 0.5,
                            offset: const Offset(0, 120),
                            child: _Sheet(entrance: _in),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: lift,
                          width: Frame.width,
                          height: 356,
                          child: _StageFront(entrance: _in),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20.5,
                top: 64.5 + lift,
                child: Staged(
                  animation: _in,
                  begin: 0.1,
                  end: 0.45,
                  scale: 0.3,
                  child: _RoundButton(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const PhIcon(Ph.arrowLeft, size: 20, color: Color(0xFF14141C)),
                  ),
                ),
              ),
              Positioned(
                left: 358.5 - 20.5,
                top: 84.3 + lift - 20.5,
                child: Staged(
                  animation: _in,
                  begin: 0.14,
                  end: 0.5,
                  scale: 0.3,
                  child: Pressable(onTap: _toggleLike, child: _Heart(liked: _liked, burst: _like)),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: ctaTop - 36,
                bottom: 0,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Palette.cream.withValues(alpha: 0), Palette.cream.withValues(alpha: 0.94), Palette.cream],
                        stops: const [0, 0.4, 1],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: ctaTop,
                width: 355,
                height: 60,
                child: Staged(
                  animation: _in,
                  begin: 0.6,
                  end: 1,
                  offset: const Offset(0, 80),
                  scale: 0.8,
                  child: StartButton(onTap: _start),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 41,
        height: 41,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(color: Color(0x2A7C6FA0), blurRadius: 14, offset: Offset(0, 6)),
            BoxShadow(color: Color(0x10000000), blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _Heart extends StatelessWidget {
  const _Heart({required this.liked, required this.burst});

  final bool liked;
  final Animation<double> burst;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 41,
      child: AnimatedBuilder(
        animation: burst,
        builder: (context, _) {
          final v = burst.value;
          final pop = liked ? spring(v, bounce: 0.8, freq: 3) : 1.0;
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (liked && v > 0 && v < 1) CustomPaint(size: const Size(41, 41), painter: _Burst(v)),
              Transform.scale(
                scale: liked ? lerp(0.3, 1, pop) : 1,
                child: PhIcon(
                  liked ? Ph.heartFill : Ph.heart,
                  size: 25,
                  color: liked ? const Color(0xFFF0457A) : const Color(0xFF14111A),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Burst extends CustomPainter {
  _Burst(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final ring = Curves.easeOut.transform(t);
    canvas.drawCircle(
      c,
      8 + 16 * ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - ring)
        ..color = const Color(0xFFB696FC).withValues(alpha: 1 - ring),
    );
    for (var i = 0; i < 8; i++) {
      final a = i / 8 * math.pi * 2 + 0.3;
      final d = 12 + 16 * ring;
      final p = c + Offset(math.cos(a), math.sin(a)) * d;
      canvas.drawCircle(
        p,
        2.4 * (1 - ring),
        Paint()..color = (i.isEven ? const Color(0xFFF0457A) : const Color(0xFFD6F155)).withValues(alpha: 1 - ring * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_Burst old) => old.t != t;
}

class _StageBack extends StatelessWidget {
  const _StageBack({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: BlobField(
            entrance: entrance,
            blobs: const [
              Blob(
                center: Offset(-18, 330),
                radii: Size(137, 137),
                colors: [Color(0xFFEEF8C5), Color(0xFFDDF57C), Color(0xFFD7F268)],
                stops: [0, 0.6, 1],
                seed: 1.2,
                delay: 0.02,
              ),
              Blob(
                center: Offset(392, 302),
                radii: Size(114, 114),
                colors: [Color(0xFFE2D6FD), Color(0xFFBFA3FD), Color(0xFFA47DFB)],
                stops: [0, 0.55, 1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                seed: 3.3,
                delay: 0.08,
              ),
              Blob(
                center: Offset(386, 113),
                radii: Size(36, 36),
                colors: [Color(0xFFF1F8D3), Color(0xFFECF6C4)],
                stops: [0, 1],
                seed: 0.2,
                delay: 0.12,
              ),
            ],
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: _Arc(entrance))),
      ],
    );
  }
}

class _StageFront extends StatelessWidget {
  const _StageFront({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 145,
          top: 293,
          child: Tick(
            builder: (context, seconds, _) => AnimatedBuilder(
              animation: entrance,
              builder: (context, _) => CustomPaint(
                size: const Size(185, 22),
                painter: _Ground(span(entrance.value, 0.3, 0.8, Curves.linear), wave(seconds, 2.6)),
              ),
            ),
          ),
        ),
        Positioned(
          left: Art.stretch.left,
          top: Art.stretch.top,
          child: Hero(
            tag: 'blast',
            flightShuttleBuilder: _shuttle,
            child: LiveMascot(
              sprite: Art.stretch,
              entrance: entrance,
              idle: Idle.lunge,
              begin: 0.12,
              end: 0.62,
              drop: 50,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _shuttle(BuildContext flight, Animation<double> a, HeroFlightDirection d, BuildContext from, BuildContext to) {
    return AnimatedBuilder(
      animation: a,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(a.value);
        return Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 1 - t,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(lerp(12, 40, t)),
                child: Image.asset(Art.thumbBlast.asset, fit: BoxFit.cover),
              ),
            ),
            Opacity(opacity: t, child: Image.asset(Art.stretch.asset, fit: BoxFit.contain)),
          ],
        );
      },
    );
  }
}

class _Ground extends CustomPainter {
  _Ground(this.t, this.breath);

  final double t;
  final double breath;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final c = size.center(Offset.zero);
    final w = size.width * (0.6 + 0.4 * t) * (1 - 0.03 * breath);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: w, height: size.height * 0.62),
      Paint()
        ..color = const Color(0xFF8E68CF).withValues(alpha: 0.55 * t)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
  }

  @override
  bool shouldRepaint(_Ground old) => old.t != t || old.breath != breath;
}

class _Arc extends CustomPainter {
  _Arc(this.entrance) : super(repaint: entrance);

  final Animation<double> entrance;

  @override
  void paint(Canvas canvas, Size size) {
    final t = span(entrance.value, 0.18, 0.75, swift);
    if (t <= 0) return;
    final path = Path()
      ..moveTo(69.7, 295.7)
      ..cubicTo(25.1, 126.6, 305.3, -11.5, 235.3, 148.4);
    final metric = path.computeMetrics().first;
    final part = metric.extractPath(0, metric.length * t);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        const Offset(70, 296),
        const Offset(240, 90),
        const [Color(0xFFD2EF4E), Color(0xFFDCF55C), Color(0xFFD8F35A)],
        const [0, 0.5, 1],
      );
    canvas.drawPath(part, paint);
    final tip = metric.getTangentForOffset(metric.length * t);
    if (tip != null && t < 1) {
      canvas.drawCircle(
        tip.position,
        8,
        Paint()
          ..color = const Color(0x88EAFB8C)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(_Arc old) => false;
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.entrance});

  final Animation<double> entrance;

  static const top = 296.0;

  @override
  Widget build(BuildContext context) {
    final title = inter(23.8, 700, color: const Color(0xFF0A0A14), track: 0.028);
    final meta = inter(15.57, 400, color: const Color(0xFF727070), track: -0.005);
    final desc = inter(16.0, 400, color: const Color(0xFF737172), track: -0.027);
    final head = inter(15.57, 700, color: const Color(0xFF0A0A10), track: 0.008);
    Widget at(double x, double cap, String text, TextStyle style, double begin) {
      return Positioned(
        left: x - bearing(text, style),
        top: cap - top - capInset(style),
        child: Staged(
          animation: entrance,
          begin: begin,
          end: begin + 0.3,
          offset: const Offset(0, 16),
          child: Text(text, style: style, softWrap: false),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Palette.cream,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [BoxShadow(color: const Color(0xFF8C6BD8).withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -6))],
            ),
          ),
        ),
        Positioned(
          left: 21.33,
          top: 334.33 - top,
          child: Staged(
            animation: entrance,
            begin: 0.24,
            end: 0.56,
            scale: 0.5,
            alignment: Alignment.centerLeft,
            child: const _Pill(),
          ),
        ),
        at(24.0, 375.4, 'Full Body Blast', title, 0.28),
        at(23.33, 408.8, '20 min • 210 kcal • No Equipment', meta, 0.32),
        at(23.33, 442.67, 'A quick and effective full body workout', desc, 0.36),
        at(23.33, 464.4, 'to boost your energy and get you moving!', desc, 0.39),
        Positioned(
          left: 0,
          top: 494 - top,
          width: Frame.width,
          height: 76,
          child: _Stats(entrance: entrance),
        ),
        at(23.0, 589.33, 'What you’ll do', head, 0.5),
        Positioned(
          left: 22,
          top: 611 - top,
          width: 351,
          height: 159,
          child: Staged(
            animation: entrance,
            begin: 0.52,
            end: 0.84,
            offset: const Offset(0, 30),
            child: _Steps(entrance: entrance),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill();

  @override
  Widget build(BuildContext context) {
    final style = inter(12.37, 500, color: const Color(0xFF3B4112), track: 0.006);
    return Container(
      width: 84.33,
      height: 27.33,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13.7),
        gradient: const LinearGradient(colors: [Color(0xFFE3F68C), Color(0xFFE8F89C)]),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 38 - 21.33 - bearing('B', style),
            top: 343 - 334.33 - capInset(style),
            child: Text('Beginner', style: style),
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final label = inter(14.67, 400, color: const Color(0xFF4E4E50), track: -0.01);
    const cols = [(72.0, 73.5, '20 min'), (191.0, 194.8, '210 kcal'), (315.0, 317.8, 'Beginner')];
    return Tick(
      builder: (context, seconds, _) => AnimatedBuilder(
        animation: entrance,
        builder: (context, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (final x in const [132.0, 255.0])
                Positioned(
                  left: x,
                  top: 6,
                  child: Opacity(
                    opacity: span(entrance.value, 0.5, 0.8, Curves.linear),
                    child: Container(
                      width: 1,
                      height: 62,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00E9E5DE), Color(0xFFEDE9E2), Color(0x00E9E5DE)],
                        ),
                      ),
                    ),
                  ),
                ),
              for (var i = 0; i < 3; i++) ...[
                Positioned(
                  left: cols[i].$1 - 16,
                  top: 516.5 - 494 - 16,
                  child: Transform.scale(
                    scale: spring(span(entrance.value, 0.42 + i * 0.06, 0.8 + i * 0.06, Curves.linear), bounce: 0.6, freq: 2.8),
                    child: SizedBox.square(dimension: 32, child: Center(child: _statIcon(i, seconds))),
                  ),
                ),
                Positioned(
                  left: 0,
                  width: cols[i].$2 * 2,
                  top: 545 - 494,
                  child: Opacity(
                    opacity: span(entrance.value, 0.46 + i * 0.06, 0.7 + i * 0.06, Curves.linear),
                    child: Center(child: Cap(cols[i].$3, label, align: TextAlign.center)),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _statIcon(int i, double seconds) {
    const color = Color(0xFF3F3E42);
    switch (i) {
      case 0:
        return CustomPaint(size: const Size(28, 28), painter: _Stopwatch(seconds));
      case 1:
        final f = wave(seconds, 0.5) * 0.5 + wave(seconds, 0.37, 0.4) * 0.5;
        return Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()..scaleByDouble(1 - 0.03 * f, 1 + 0.06 * f, 1, 1),
          child: Transform.translate(offset: const Offset(0, 2.3), child: const PhIcon(Ph.flame, size: 28, color: color)),
        );
      default:
        return CustomPaint(size: const Size(28, 28), painter: _Levels(seconds));
    }
  }
}

class _Stopwatch extends CustomPainter {
  _Stopwatch(this.seconds);

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF3F3E42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final c = Offset(14, 15.5);
    canvas.drawCircle(c, 10.2, p);
    canvas.drawLine(const Offset(11, 2.2), const Offset(17, 2.2), p);
    canvas.drawLine(const Offset(14, 2.2), const Offset(14, 5.3), p);
    canvas.drawLine(const Offset(22.5, 6.2), const Offset(24.2, 4.5), p);
    final a = (seconds % 6) / 6 * math.pi * 2 - math.pi / 2;
    canvas.drawLine(c, c + Offset(math.cos(a), math.sin(a)) * 6.2, p);
    canvas.drawCircle(c, 1.4, Paint()..color = const Color(0xFF3F3E42));
  }

  @override
  bool shouldRepaint(_Stopwatch old) => old.seconds != seconds;
}

class _Levels extends CustomPainter {
  _Levels(this.seconds);

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF3F3E42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9;
    final heights = [8.0, 14.0, 21.0];
    for (var i = 0; i < 3; i++) {
      final k = math.max(0.0, math.sin((seconds * 1.4 - i * 0.35) * math.pi)) * (i == 0 ? 1 : 0.6);
      final h = heights[i] + (i == 0 ? 2.5 * k : 0);
      final x = 2.5 + i * 8.5;
      canvas.drawRRect(RRect.fromLTRBR(x, 25 - h, x + 6, 25, const Radius.circular(3)), p);
    }
  }

  @override
  bool shouldRepaint(_Levels old) => old.seconds != seconds;
}

class _Steps extends StatelessWidget {
  const _Steps({required this.entrance});

  final Animation<double> entrance;

  static const rows = [637.7, 672.9, 708.1, 743.3];

  @override
  Widget build(BuildContext context) {
    final name = inter(14.16, 400, color: const Color(0xFF4F4F52), track: -0.018);
    final time = inter(14.2, 400, color: const Color(0xFF8A8A8B), track: -0.03);
    final number = inter(12.4, 600, color: const Color(0xFFFFFFFF));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF6F6F7), Color(0xFFF6F5F6)],
              ),
            ),
          ),
        ),
        for (var i = 0; i < steps.length; i++)
          AnimatedBuilder(
            animation: entrance,
            builder: (context, _) {
              final b = 0.56 + i * 0.06;
              final t = span(entrance.value, b, b + 0.24, Curves.linear);
              final pop = spring(t, bounce: 0.7, freq: 3);
              final y = rows[i] - 611;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 49.8 - 22 - 11.5,
                    top: y - 11.5,
                    child: Transform.scale(
                      scale: pop,
                      child: Container(
                        width: 23,
                        height: 23,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF7F72F2), Color(0xFF5A4FDC)],
                          ),
                          boxShadow: [BoxShadow(color: Color(0x33594EDC), blurRadius: 6, offset: Offset(0, 2))],
                        ),
                        child: Center(
                          child: Transform.translate(
                            offset: const Offset(0, 0.2),
                            child: Text('${i + 1}', style: number, textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 73 - 22 - bearing(steps[i].name, name) + 16 * (1 - Curves.easeOutCubic.transform(t)),
                    top: y - 5.7 - capInset(name),
                    child: Opacity(opacity: t, child: Text(steps[i].name, style: name)),
                  ),
                  Positioned(
                    right: 351 - (356.0 - 22),
                    top: y - 5.5 - capInset(time),
                    child: Opacity(opacity: t, child: Text('${steps[i].minutes} min', style: time)),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class StartButton extends StatelessWidget {
  const StartButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = inter(17.41, 600, color: const Color(0xFFF4F4FF), track: 0.016);
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      haptic: false,
      child: Tick(
        builder: (context, seconds, _) {
          final flow = math.sin(seconds * 0.9) * 0.04;
          final ring = (seconds % 1.8) / 1.8;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF7B3DF5).withValues(alpha: 0.28), blurRadius: 22, offset: const Offset(-40, 10)),
                      BoxShadow(color: const Color(0xFFD6F155).withValues(alpha: 0.28), blurRadius: 22, offset: const Offset(60, 8)),
                    ],
                    gradient: LinearGradient(
                      colors: const [Color(0xFF8F3AFD), Color(0xFF864AF9), Color(0xFF675EF6), Color(0xFF98A2C9), Color(0xFFC3DA86), Color(0xFFDEF85A)],
                      stops: [0, 0.22 + flow, 0.4 + flow, 0.64 + flow, 0.8 + flow, 1],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CustomPaint(painter: _Sheen((seconds % 3.8) / 3.8)),
                ),
              ),
              Positioned(
                left: 128 - 20 - 15,
                top: 822 - 792 - 15,
                child: SizedBox.square(
                  dimension: 30,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: 1 + ring * 0.8,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.18 * (1 - ring))),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      Transform.translate(
                        offset: const Offset(1, 0),
                        child: const PhIcon(Ph.play, size: 15, color: Color(0xFFFCF4FF)),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 152.33 - 20 - bearing('S', label),
                top: 815.33 - 792 - capInset(label),
                child: Text('Start Workout', style: label),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Sheen extends CustomPainter {
  _Sheen(this.p);

  final double p;

  @override
  void paint(Canvas canvas, Size size) {
    final x = -120 + p * (size.width + 240);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(x - 60, 0),
          Offset(x + 60, size.height),
          const [Color(0x00FFFFFF), Color(0x2EFFFFFF), Color(0x00FFFFFF)],
          const [0, 0.5, 1],
        ),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius((Offset.zero & size).deflate(0.5), const Radius.circular(29.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), const [Color(0x40FFFFFF), Color(0x00FFFFFF)]),
    );
  }

  @override
  bool shouldRepaint(_Sheen old) => old.p != p;
}
