import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/surfaces.dart';
import '../workout/workout_screen.dart';
import 'weekly_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _in;
  int _range = 0;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..forward();
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final content = math.max(frame.height, 790 + lift + NavBar.height(frame) + 8);
    final title = inter(27.04, 800, color: const Color(0xFF0B0B16), track: 0.034);
    final sub = inter(14.67, 400, color: const Color(0xFF6E6D6D), track: 0.002);
    return Scaffold(
      backgroundColor: Palette.cream,
      body: SingleChildScrollView(
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
                height: 800,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 364 - 16,
                      top: 70.2 - 16,
                      child: Staged(
                        animation: _in,
                        begin: 0.05,
                        end: 0.35,
                        scale: 0.4,
                        child: Pressable(onTap: () {}, child: const SizedBox.square(dimension: 32, child: Center(child: PhIcon(Ph.calendar, size: 20, color: Color(0xFF7D7C7B))))),
                      ),
                    ),
                    Positioned(
                      left: 21 - bearing('P', title),
                      top: 79.2 - capInset(title),
                      child: Staged(
                        animation: _in,
                        begin: 0,
                        end: 0.3,
                        offset: const Offset(-20, 0),
                        child: Text('Progress', style: title),
                      ),
                    ),
                    Positioned(
                      left: 20.67 - bearing('Y', sub),
                      top: 114.0 - capInset(sub),
                      child: Staged(
                        animation: _in,
                        begin: 0.06,
                        end: 0.36,
                        offset: const Offset(-20, 0),
                        child: Text('Your journey, in numbers.', style: sub),
                      ),
                    ),
                    Positioned(
                      left: 272,
                      top: 92,
                      child: Staged(
                        animation: _in,
                        begin: 0.1,
                        end: 0.4,
                        offset: const Offset(20, 0),
                        child: _RangeChip(
                          index: _range,
                          onTap: () => setState(() => _range = (_range + 1) % 3),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 148,
                      width: 355,
                      height: 120,
                      child: Staged(
                        animation: _in,
                        begin: 0.1,
                        end: 0.48,
                        offset: const Offset(0, 30),
                        scale: 0.95,
                        child: _Summary(entrance: _in),
                      ),
                    ),
                    Positioned(
                      left: 20.33,
                      top: 296.2,
                      child: Staged(
                        animation: _in,
                        begin: 0.2,
                        end: 0.5,
                        offset: const Offset(0, 12),
                        child: const SectionTitle('Weekly Activity', track: -0.012),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 320.2,
                      width: Frame.width,
                      height: 165,
                      child: WeeklyChart(entrance: _in, origin: 318),
                    ),
                    Positioned(
                      left: 21,
                      top: 522.1,
                      child: Staged(
                        animation: _in,
                        begin: 0.46,
                        end: 0.74,
                        offset: const Offset(0, 12),
                        child: const SectionTitle('Recent Workouts', size: 16.04, track: 0.0277),
                      ),
                    ),
                    Positioned(
                      right: Frame.width - 375.0,
                      top: 524.4,
                      child: Staged(animation: _in, begin: 0.5, end: 0.78, offset: const Offset(12, 0), child: const SeeAll()),
                    ),
                    for (var i = 0; i < _recent.length; i++)
                      Positioned(
                        left: 22,
                        top: 545 + i * 82.5,
                        width: 354,
                        height: 79,
                        child: Staged(
                          animation: _in,
                          begin: 0.54 + i * 0.07,
                          end: 0.86 + i * 0.05,
                          offset: const Offset(0, 36),
                          child: _RecentRow(spec: _recent[i], index: i),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({required this.index, required this.onTap});

  final int index;
  final VoidCallback onTap;

  static const labels = ['Last 7 days', 'Last 30 days', 'This year'];

  @override
  Widget build(BuildContext context) {
    final style = inter(14.0, 500, color: const Color(0xFF3F3F42), track: -0.04);
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 99,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [BoxShadow(color: Color(0x14655A80), blurRadius: 14, offset: Offset(0, 4))],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 12.33,
              top: 7.33 - capInset(style),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(position: Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(a), child: c),
                ),
                child: Text(labels[index], key: ValueKey(index), style: style, softWrap: false, maxLines: 1),
              ),
            ),
            const Positioned(left: 84.5, top: 7, child: PhIcon(Ph.caretDown, size: 11, color: Color(0xFF3F3F42))),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final big = inter(33, 700, color: const Color(0xFF0B0C1A), track: -0.035);
    final side = inter(13.9, 400, color: const Color(0xFF5D5769), track: -0.05);
    final num = inter(16.04, 700, color: const Color(0xFF0B0B16), track: -0.003);
    final small = inter(12.0, 400, color: const Color(0xFF7B7983), track: -0.01);
    const ox = 20.0;
    const oy = 148.0;
    Animation<double> count(double a) => CurvedAnimation(parent: entrance, curve: Interval(a, math.min(1.0, a + 0.45)));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF1EFFD),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [BoxShadow(color: Color(0x0F6A4FD8), blurRadius: 18, offset: Offset(0, 6))],
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 165,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(22), right: Radius.circular(18)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFEFE5FB), const Color(0xFFF0E9FC).withValues(alpha: 0.9)],
              ),
            ),
          ),
        ),
        Positioned(
          left: Art.flame.left - ox,
          top: Art.flame.top - oy,
          child: Flicker(child: Art.flame.image()),
        ),
        Positioned(
          left: 39.33 - ox - bearing('6', big),
          top: 218.8 - oy - capInset(big),
          child: Counter(value: 680, progress: count(0.25), style: big),
        ),
        Positioned(left: 108.67 - ox - bearing('C', side), top: 217.9 - oy - capInset(side), child: Text('Calories', style: side)),
        Positioned(left: 109.67 - ox - bearing('B', side), top: 234.9 - oy - capInset(side), child: Text('Burned', style: side)),
        Positioned(
          left: 232.8 - ox - 16,
          top: 185.5 - oy - 16,
          child: Tick(
            builder: (context, seconds, child) {
              final c = (seconds % 1.6) / 1.6;
              final step = c < 0.4 ? math.sin(c / 0.4 * math.pi) : 0.0;
              return Transform.translate(
                offset: Offset(1.5 * step, -2.5 * step),
                child: Transform.rotate(angle: -0.12 * step, child: child),
              );
            },
            child: const SizedBox.square(dimension: 32, child: Center(child: PhIcon(Ph.sneaker, size: 30, color: Color(0xFF16203A)))),
          ),
        ),
        Positioned(
          left: 326.2 - ox - 14,
          top: 185.8 - oy - 14,
          child: Tick(builder: (context, seconds, _) => CustomPaint(size: const Size(28, 28), painter: _Clock(seconds))),
        ),
        _centered(232.3 - ox, 213.0 - oy, Counter(value: 12340, progress: count(0.32), style: num), num),
        _centered(232.3 - ox, 235.0 - oy, Text('Steps', style: small), small),
        _centered(
          326.0 - ox,
          213.0 - oy,
          Counter(
            value: 405,
            progress: count(0.38),
            style: num,
            format: (v) => '${v.round() ~/ 60}h ${(v.round() % 60).toString().padLeft(2, '0')}m',
          ),
          num,
        ),
        _centered(325.8 - ox, 235.0 - oy, Text('Active Time', style: small), small),
      ],
    );
  }

  Widget _centered(double cx, double cap, Widget child, TextStyle style) {
    return Positioned(
      left: cx - 60,
      width: 120,
      top: cap - capInset(style),
      child: Center(child: child),
    );
  }
}

class _Clock extends CustomPainter {
  _Clock(this.seconds);

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final shader = ui.Gradient.linear(Offset.zero, Offset(size.width, size.height), const [Color(0xFF5F60D6), Color(0xFF2D2C97)]);
    canvas.drawCircle(
      c,
      11.6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..shader = shader,
    );
    final hand = Paint()
      ..strokeWidth = 2.3
      ..strokeCap = StrokeCap.round
      ..shader = shader;
    final m = seconds / 4 * math.pi * 2 - math.pi / 2;
    final h = seconds / 48 * math.pi * 2;
    canvas.drawLine(c, c + Offset(math.cos(m), math.sin(m)) * 6.4, hand);
    canvas.drawLine(c, c + Offset(math.cos(h), math.sin(h)) * 4.6, hand);
    canvas.drawCircle(
      const Offset(23.5, 5.3),
      1.6,
      Paint()..color = const Color(0xFF5F60D6),
    );
  }

  @override
  bool shouldRepaint(_Clock old) => old.seconds != seconds;
}

class _RecentSpec {
  const _RecentSpec(this.sprite, this.title, this.meta, this.when);

  final Sprite sprite;
  final String title;
  final String meta;
  final String when;
}

const _recent = [
  _RecentSpec(Art.recentBlast, 'Full Body Blast', '20 min • 210 kcal', 'Today'),
  _RecentSpec(Art.recentCore, 'Core Crusher', '15 min • 150 kcal', 'Yesterday'),
  _RecentSpec(Art.recentStretch, 'Morning Stretch', '10 min • 80 kcal', 'Sep 24'),
];

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.spec, required this.index});

  final _RecentSpec spec;
  final int index;

  @override
  Widget build(BuildContext context) {
    final title = inter(14.2, 600, color: const Color(0xFF16161C), track: -0.026);
    final meta = inter(12.9, 400, color: const Color(0xFF807E7E), track: -0.05);
    final when = inter(12.3, 400, color: const Color(0xFF8E8C8D), track: -0.03);
    const oy = 545.0;
    final dy = index * 82.5;
    return Pressable(
      onTap: () => Navigator.of(context).push(WorkoutRoute(builder: (_) => const WorkoutScreen())),
      scale: 0.97,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFAF8F3),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          Positioned(
            left: spec.sprite.left - 22,
            top: spec.sprite.top - oy - dy,
            child: Tick(
              builder: (context, seconds, child) => Transform.translate(
                offset: Offset(0, -1.2 * math.max(0.0, wave(seconds, 1.4, index * 0.33))),
                child: child,
              ),
              child: spec.sprite.image(),
            ),
          ),
          Positioned(left: 108.33 - 22 - bearing(spec.title, title), top: 563.3 - oy - capInset(title), child: Text(spec.title, style: title)),
          Positioned(left: 108.0 - 22 - bearing(spec.meta, meta), top: 583.6 - oy - capInset(meta), child: Text(spec.meta, style: meta)),
          Positioned(left: 108.0 - 22 - bearing(spec.when, when), top: 602.1 - oy - capInset(when), child: Text(spec.when, style: when)),
          const Positioned(
            left: 346 - 22 - 14,
            top: 586.7 - oy - 14,
            child: SizedBox.square(
              dimension: 28,
              child: Center(
                child: ChevronDisc(
                  colors: [Color(0xFFE6D8FB), Color(0xFFD6C1F7)],
                  chevron: Color(0xFF7F55DD),
                  size: 27,
                  glyph: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
