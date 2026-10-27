import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../icons.dart';
import 'package:flutter/services.dart';

import '../state.dart';
import '../theme.dart';
import '../three/face.dart';
import '../three/figure.dart';
import '../three/figures.dart';
import '../three/mesh.dart';
import '../three/renderer.dart';
import '../three/vec.dart';
import '../widgets/art.dart';
import '../widgets/common.dart';
import '../widgets/gauges.dart';
import '../widgets/motion.dart';

class MobilityScreen extends StatefulWidget {
  const MobilityScreen({super.key});

  @override
  State<MobilityScreen> createState() => _MobilityScreenState();
}

class _MobilityScreenState extends State<MobilityScreen> with SingleTickerProviderStateMixin {
  late final _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400), value: stillMode ? 1 : 0)..forward();
  final _scroll = ScrollController();
  final _playing = ValueNotifier(false);

  @override
  void dispose() {
    _enter.dispose();
    _scroll.dispose();
    _playing.dispose();
    super.dispose();
  }

  Widget _r(int i, Widget c, {double dy = 22}) => Reveal(anim: _enter, index: i, dy: dy, child: c);

  double get _offset => _scroll.hasClients ? _scroll.offset : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: DesignCanvas(
        child: Builder(builder: (context) {
          final top = math.max(0.0, MediaQuery.of(context).padding.top - 47);
          return ColoredBox(
            color: C.bg,
            child: SingleChildScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _hero(top),
                  const SizedBox(height: 22),
                  _r(
                    6,
                    Padding(
                      padding: const EdgeInsets.only(left: 21, right: 25),
                      child: Row(
                        children: [
                          Text('Included exercises', style: inter(16, FontWeight.w500, C.ink, ls: -0.1)),
                          const Spacer(),
                          Text('3 exercises', style: inter(10, FontWeight.w400, C.ink2)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final (i, e) in _exercises.indexed) ...[
                    _r(7 + i, _ExerciseRow(index: i, data: e)),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 15),
                  _r(
                    10,
                    const Padding(
                      padding: EdgeInsets.only(left: 21, right: 25),
                      child: DarkButton(label: 'Start session', icon: PhRegular.play, heroTag: 'session-cta'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _hero(double top) {
    final h = 411 + top;
    return AnimatedBuilder(
      animation: _scroll,
      builder: (context, child) {
        final o = _offset;
        // Overscroll at the top stretches the hero; scrolling up parallaxes it.
        final stretch = o < 0 ? -o : 0.0;
        return SizedBox(
          height: h,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: -stretch + o * 0.45,
                  height: h + stretch,
                  child: const RepaintBoundary(child: CustomPaint(painter: HeroSkyPainter())),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: -stretch * 0.7 + o * 0.22,
                  height: h + stretch * 0.7,
                  child: _HeroFigure(playing: _playing, top: top),
                ),
                child!,
              ],
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Positioned(left: 0, right: 0, top: 55 + top, child: _r(0, const TopBar(title: 'Shoulder mobility', action: PhBold.dotsThree), dy: 10)),
          Positioned(
            left: 26,
            top: 194 + top,
            child: _r(
              1,
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xC7FFFFFF), borderRadius: BorderRadius.circular(13)),
                child: Text('Mobility', style: inter(11, FontWeight.w400, C.ink)),
              ),
            ),
          ),
          Positioned(
            left: 26,
            top: 230 + top,
            child: _r(2, Text('Shoulder\nmobility', style: inter(28, FontWeight.w400, C.ink, ls: -0.4, height: 1.12))),
          ),
          Positioned(
            left: 26,
            top: 304 + top,
            child: _r(
              3,
              Row(
                children: [
                  const Icon(PhRegular.clock, size: 12, color: C.ink2),
                  const SizedBox(width: 4),
                  Text('12 min  •  ', style: inter(11, FontWeight.w400, C.ink2)),
                  const Icon(PhBold.cellSignalHigh, size: 12, color: C.ink2),
                  const SizedBox(width: 3),
                  Text('Beginner', style: inter(11, FontWeight.w400, C.ink2)),
                ],
              ),
            ),
          ),
          Positioned(
            left: 26,
            top: 344 + top,
            child: _r(
              4,
              Pressable(
                onTap: () => _playing.value = !_playing.value,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.only(left: 9, right: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xE6FFFFFF),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: cardShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 27,
                        height: 27,
                        decoration: const BoxDecoration(color: C.button, shape: BoxShape.circle),
                        child: _PlayPause(_playing),
                      ),
                      const SizedBox(width: 10),
                      ValueListenableBuilder(
                        valueListenable: _playing,
                        builder: (context, p, _) => AnimatedSize(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          child: Text(p ? 'Playing preview' : 'Watch preview', style: inter(13, FontWeight.w500, C.ink)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayPause extends StatefulWidget {
  const _PlayPause(this.playing);

  final ValueNotifier<bool> playing;

  @override
  State<_PlayPause> createState() => _PlayPauseState();
}

class _PlayPauseState extends State<_PlayPause> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));

  void _sync() => widget.playing.value ? _c.forward() : _c.reverse();

  @override
  void initState() {
    super.initState();
    widget.playing.addListener(_sync);
  }

  @override
  void dispose() {
    widget.playing.removeListener(_sync);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeInOutBack.transform(_c.value.clamp(0.0, 1.0));
          Widget icon(IconData d, double o) => Opacity(
                opacity: o.clamp(0.0, 1.0),
                child: Icon(d, size: 13, color: Colors.white),
              );
          return Center(
            child: Transform.rotate(
              angle: t * 3.14159,
              child: Transform.scale(
                scale: 1 - 0.25 * (1 - (2 * t - 1).abs()),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    icon(PhFill.play, 1 - t * 2),
                    Transform.rotate(angle: -3.14159, child: icon(PhFill.pause, t * 2 - 1)),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

/// The hero "photo" is a live 3D figure doing wall slides: two keyframe
/// meshes with identical topology are morphed per frame. Drag to turn her;
/// she springs back to the camera angle with inertia.
class _HeroFigure extends StatefulWidget {
  const _HeroFigure({required this.playing, required this.top});

  final ValueNotifier<bool> playing;
  final double top;

  @override
  State<_HeroFigure> createState() => _HeroFigureState();
}

class _HeroFigureState extends State<_HeroFigure> with SingleTickerProviderStateMixin {
  final Mesh mesh = Figures.heroLow.clone();
  late final view = BodyView(mesh);
  late final _ticker = createTicker(_tick);
  final _frame = _Notifier();
  Duration _last = Duration.zero;
  double time = 0, phase = 0, pose = 0.3, poseV = 0, yaw = 0, yawV = 0;
  bool drag = false;
  static const restYaw = 2.05;

  @override
  void initState() {
    super.initState();
    _render();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  void _tick(Duration now) {
    final dt = ((now - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _last = now;
    time += dt;
    // Pose: a slow rep cycle while playing, a gentle hold otherwise (spring-followed).
    final playing = widget.playing.value;
    if (playing) phase += dt;
    final target = playing ? 0.5 - 0.5 * math.cos(phase * math.pi * 2 / 2.8) : 0.32 + 0.03 * math.sin(time * 1.3);
    const k = 70.0;
    poseV += (-(pose - target) * k - 2 * math.sqrt(k) * 0.9 * poseV) * dt;
    pose += poseV * dt;
    if (!drag) {
      const ky = 38.0;
      yawV += (-yaw * ky - 2 * math.sqrt(ky) * 0.45 * yawV) * dt;
      yaw += yawV * dt;
    }
    _render();
    _frame.tick();
  }

  void _render() {
    Mesh.morph(Figures.heroLow, Figures.heroHigh, pose.clamp(-0.05, 1.05), mesh);
    view.update(
      yaw: restYaw + yaw,
      pitch: 0.04,
      scale: 2.95,
      origin: Offset(268, 420 + widget.top),
      pivot: const V3(0, 85, 0),
      rim: const Color(0xFFD9C8FF),
      rimAmt: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => drag = true,
      onHorizontalDragUpdate: (d) => yaw += d.delta.dx * 0.012,
      onHorizontalDragEnd: (d) {
        drag = false;
        yawV = d.velocity.pixelsPerSecond.dx * 0.012;
        HapticFeedback.selectionClick();
      },
      child: RepaintBoundary(child: CustomPaint(painter: _HeroPainter(this))),
    );
  }
}

class _Notifier extends ChangeNotifier {
  void tick() => notifyListeners();
}

class _HeroPainter extends CustomPainter {
  _HeroPainter(this.s) : super(repaint: s._frame);

  final _HeroFigureState s;

  @override
  void paint(Canvas canvas, Size size) {
    final v = s.view;
    // Wall the hands rest on, kept in the figure's frame so it turns with her.
    final y0 = v.project(const V3(0, 230, 19.5)).$1, y1 = v.project(const V3(0, -10, 19.5)).$1;
    final w0 = v.project(const V3(-60, 230, 19.5)).$1, w1 = v.project(const V3(-60, -10, 19.5)).$1;
    final wall = Path()..addPolygon([y0, w0, w1, y1], true);
    final wb = wall.getBounds();
    canvas.drawPath(
      wall,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.95), const Color(0xFFF3ECF8).withValues(alpha: 0.9)],
        ).createShader(wb)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
    // Soft shadow the figure casts on the wall.
    final (sh, _) = v.project(const V3(0, 140, 19));
    canvas.drawOval(
      Rect.fromCenter(center: sh + const Offset(10, 0), width: 60, height: 200),
      Paint()
        ..color = const Color(0x1A4A3A6A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    v.draw(canvas);
    drawFace(canvas, v, Pose.standing, hair: Figures.heroPalette.hair);
  }

  @override
  bool shouldRepaint(_HeroPainter old) => false;
}

// ---------------------------------------------------------------------------

typedef _Ex = ({String title, String sub, double progress, ThumbKind thumb});

const List<_Ex> _exercises = [
  (title: 'Wall Slides', sub: '3 sets • 10 reps • 2 min', progress: 0.6, thumb: ThumbKind.wall),
  (title: 'Shoulder Rolls', sub: '3 sets • 12 reps • 3 min', progress: 0.15, thumb: ThumbKind.roll),
  (title: 'Band Pull Aparts', sub: '3 sets • 15 reps • 7 min', progress: 0.44, thumb: ThumbKind.band),
];

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.index, required this.data});

  final int index;
  final _Ex data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 21, right: 25),
      child: Pressable(
        scale: 0.975,
        onTap: () {
          final s = {...AppState.done.value};
          s.contains(index) ? s.remove(index) : s.add(index);
          AppState.done.value = s;
        },
        child: GlassCard(
          radius: 16,
          color: const Color(0xF2FFFFFF),
          child: SizedBox(
            height: 80,
            child: Row(
              children: [
                const SizedBox(width: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(width: 79, height: 72, child: ThumbArt(data.thumb)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(data.title, style: inter(13, FontWeight.w500, C.ink)),
                      const SizedBox(height: 4),
                      Text(data.sub, style: inter(10, FontWeight.w400, C.muted)),
                      const SizedBox(height: 11),
                      SpringBar(value: data.progress, delay: Duration(milliseconds: 650 + index * 140)),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Padding(
                  padding: const EdgeInsets.only(bottom: 26),
                  child: ValueListenableBuilder(
                    valueListenable: AppState.done,
                    builder: (context, done, _) => _Check(on: done.contains(index)),
                  ),
                ),
                const SizedBox(width: 9),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Completion check: the fill pops in with a spring and the tick draws itself.
class _Check extends StatelessWidget {
  const _Check({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: on ? 1 : 0),
      duration: const Duration(milliseconds: 650),
      curve: springy,
      builder: (context, v, _) => CustomPaint(size: const Size(21, 21), painter: _CheckPainter(v)),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.v);

  final double v;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const r = 10.0;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Color.lerp(const Color(0xFFB9BCC0), C.teal, v.clamp(0, 1))!,
    );
    if (v <= 0.01) return;
    canvas.drawCircle(c, r * v.clamp(0, 1.15), Paint()..color = C.teal);
    final p = Path()
      ..moveTo(c.dx - 4.2, c.dy + 0.2)
      ..lineTo(c.dx - 1.2, c.dy + 3.2)
      ..lineTo(c.dx + 4.6, c.dy - 3.0);
    final m = p.computeMetrics().first;
    canvas.drawPath(
      m.extractPath(0, m.length * ((v - 0.35) / 0.65).clamp(0, 1)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.v != v;
}
