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
import '../../widgets/nav_bar.dart';
import '../../widgets/surfaces.dart';
import '../workout/workout_screen.dart';
import 'hero_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _in;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..forward();
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  void _open() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(WorkoutRoute(builder: (_) => const WorkoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final content = math.max(frame.height, 805 + lift + NavBar.height(frame) - 70);
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
                height: 820,
                child: _Body(entrance: _in, onOpen: _open),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.entrance, required this.onOpen});

  final Animation<double> entrance;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final hello = inter(21.44, 560, color: const Color(0xFF0C0B12), track: 0.010);
    final john = inter(21.44, 560, color: const Color(0xFF0C0B12), track: 0.0215);
    final small = inter(15.12, 400, color: const Color(0xFF6E6C6F), track: -0.013);
    const logoScale = 73.67 / 101.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 23.67 - 1.33 * logoScale,
          top: 64 - 1.67 * logoScale,
          child: Staged(
            animation: entrance,
            begin: 0,
            end: 0.3,
            offset: const Offset(-16, 0),
            child: Image.asset(
              Art.logo.asset,
              width: Art.logo.width * logoScale,
              height: Art.logo.height * logoScale,
              fit: BoxFit.fill,
              color: const Color(0xFF0A0B14),
              colorBlendMode: BlendMode.srcIn,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
        Positioned(
          left: 299.7 - 20,
          top: 81.5 - 20,
          child: Staged(
            animation: entrance,
            begin: 0.05,
            end: 0.4,
            scale: 0.4,
            child: const _Bell(),
          ),
        ),
        Positioned(
          left: Art.avatar.left - 3,
          top: Art.avatar.top - 3,
          child: Staged(
            animation: entrance,
            begin: 0.1,
            end: 0.45,
            scale: 0.4,
            child: const _Avatar(),
          ),
        ),
        _line(entrance, 22.8, 97.6, 'Good morning,', hello, 0.08),
        Positioned(
          left: 22.1 - bearing('J', john),
          top: 125.7 - capInset(john),
          child: Staged(
            animation: entrance,
            begin: 0.13,
            end: 0.45,
            offset: const Offset(0, 14),
            child: Text('John Doe', style: john),
          ),
        ),
        Positioned(
          left: 127.8,
          top: 124.8,
          child: Staged(
            animation: entrance,
            begin: 0.2,
            end: 0.5,
            scale: 0.2,
            rotateZ: -0.8,
            child: const _Wave(),
          ),
        ),
        _line(entrance, 22.33, 156.67, 'Small steps. Big changes.', small, 0.18),
        Positioned(
          left: HeroCard.rect.left,
          top: Art.runner.top,
          child: Staged(
            animation: entrance,
            begin: 0.16,
            end: 0.55,
            offset: const Offset(0, 40),
            scale: 0.94,
            child: HeroCard(entrance: entrance, onOpen: onOpen),
          ),
        ),
        for (var i = 0; i < _tiles.length; i++)
          Positioned(
            left: _tiles[i].x - 47,
            top: 354,
            width: 94,
            height: 96,
            child: _QuickTile(spec: _tiles[i], entrance: entrance, index: i),
          ),
        Positioned(
          left: 21.67,
          top: 480.0,
          child: Staged(
            animation: entrance,
            begin: 0.42,
            end: 0.7,
            offset: const Offset(0, 12),
            child: const SectionTitle('Recommended for you', track: 0.013),
          ),
        ),
        Positioned(
          right: Frame.width - 375.6,
          top: 481.2,
          child: Staged(animation: entrance, begin: 0.46, end: 0.74, offset: const Offset(12, 0), child: const SeeAll()),
        ),
        Positioned(
          left: 20,
          top: 505.7,
          width: 356,
          height: 93,
          child: Staged(
            animation: entrance,
            begin: 0.48,
            end: 0.82,
            offset: const Offset(60, 0),
            child: _RecCard(
              onTap: onOpen,
              tint: const Color(0xFFF6F5FA),
              thumb: Hero(tag: 'blast', child: Art.thumbBlast.image()),
              thumbAt: Offset(Art.thumbBlast.left - 20, Art.thumbBlast.top - 505.0),
              title: 'Full Body Blast',
              titleCap: 524.6 - 505.0,
              lines: const [
                _Meta('20 min • Beginner', 545.3 - 505.0),
                _Meta('210 kcal', 563.67 - 505.0, fire: true),
              ],
              chevron: const ChevronDisc(
                colors: [Color(0xFF8B86F2), Color(0xFF4A40DC)],
                chevron: Color(0xFFFFFFFF),
                size: 27,
                glyph: 14,
                shadow: Color(0x405A4FE0),
              ),
              chevronAt: const Offset(346.8 - 20, 551.5 - 505.0),
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 604.5,
          width: 356,
          height: 89,
          child: Staged(
            animation: entrance,
            begin: 0.54,
            end: 0.88,
            offset: const Offset(60, 0),
            child: _RecCard(
              onTap: () {},
              tint: const Color(0xFFFFFCF6),
              thumb: Art.thumbSalad.image(),
              thumbAt: Offset(Art.thumbSalad.left - 20, Art.thumbSalad.top - 603.5),
              title: 'Healthy Eating Guide',
              titleCap: 625.0 - 603.5,
              titleTrack: -0.028,
              titleSize: 16.04,
              lines: const [_Meta('Build better habits', 647.3 - 603.5, size: 13.29, track: -0.034)],
              chevron: const ChevronDisc(
                colors: [Color(0xFFE6F597), Color(0xFFD5EA66)],
                chevron: Color(0xFF1A1B12),
                size: 28,
                glyph: 14,
                shadow: Color(0x40BFD85A),
              ),
              chevronAt: const Offset(345.7 - 20, 644.8 - 603.5),
            ),
          ),
        ),
        Positioned(
          left: 21.0,
          top: 709.9,
          child: Staged(
            animation: entrance,
            begin: 0.6,
            end: 0.88,
            offset: const Offset(0, 12),
            child: const SectionTitle('Your Progress', track: -0.003),
          ),
        ),
        for (var i = 0; i < _stats.length; i++)
          Positioned(
            left: _stats[i].rect.left,
            top: _stats[i].rect.top,
            width: _stats[i].rect.width,
            height: _stats[i].rect.height,
            child: Staged(
              animation: entrance,
              begin: 0.64 + i * 0.05,
              end: 0.95 + i * 0.02,
              offset: const Offset(0, 30),
              scale: 0.9,
              child: _StatTile(spec: _stats[i], entrance: entrance),
            ),
          ),
      ],
    );
  }

  Widget _line(Animation<double> a, double x, double cap, String text, TextStyle style, double begin) {
    return Positioned(
      left: x - bearing(text, style),
      top: cap - capInset(style),
      child: Staged(
        animation: a,
        begin: begin,
        end: begin + 0.32,
        offset: const Offset(0, 14),
        child: Text(text, style: style, softWrap: false),
      ),
    );
  }
}

class _Bell extends StatefulWidget {
  const _Bell();

  @override
  State<_Bell> createState() => _BellState();
}

class _BellState extends State<_Bell> with SingleTickerProviderStateMixin {
  late final AnimationController _ring;

  @override
  void initState() {
    super.initState();
    _ring = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _ring.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => _ring.forward(from: 0),
      child: SizedBox.square(
        dimension: 40,
        child: AnimatedBuilder(
          animation: _ring,
          builder: (context, _) {
            final v = _ring.value;
            final swing = math.sin(v * math.pi * 6) * (1 - v) * 0.42;
            final dot = v == 0 ? 1.0 : 1 + 0.35 * math.sin(math.min(v * 3, 1.0) * math.pi);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 20 - 13.5,
                  top: 20 - 12.5,
                  child: Transform.rotate(
                    angle: swing,
                    alignment: const Alignment(0, -0.9),
                    child: const PhIcon(Ph.bell, size: 27, color: Color(0xFF07060A)),
                  ),
                ),
                Positioned(
                  left: 306.3 - 299.7 + 20 - 4.2,
                  top: 72.0 - 81.5 + 20 - 4.2,
                  child: Transform.scale(
                    scale: dot,
                    child: Container(
                      width: 8.4,
                      height: 8.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE2262C),
                        border: Border.all(color: const Color(0xFFFEFAF2), width: 1),
                        boxShadow: const [BoxShadow(color: Color(0x66E2262C), blurRadius: 4)],
                      ),
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

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, seconds, child) {
        final p = wave(seconds, 3.4) * 0.5 + 0.5;
        return Container(
          width: Art.avatar.width + 6,
          height: Art.avatar.height + 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: const Color(0xFFD9CCFA).withValues(alpha: 0.35 + 0.25 * p), blurRadius: 8 + 4 * p)],
          ),
          padding: const EdgeInsets.all(3),
          child: child,
        );
      },
      child: ClipOval(child: Art.avatar.image(fit: BoxFit.cover)),
    );
  }
}

class _Wave extends StatelessWidget {
  const _Wave();

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, seconds, child) {
        final cycle = (seconds % 3.6) / 3.6;
        final waving = cycle < 0.3 ? math.sin(cycle / 0.3 * math.pi * 4) * math.sin(cycle / 0.3 * math.pi) : 0.0;
        return Transform.rotate(angle: 0.35 * waving, alignment: const Alignment(0.4, 0.8), child: child);
      },
      child: const Emoji(Art.wave, size: 20.5),
    );
  }
}

class _TileSpec {
  const _TileSpec(this.label, this.x, this.fill, this.icon, this.colors, this.labelWidth);

  final String label;
  final double x;
  final Color fill;
  final IconData icon;
  final List<Color> colors;
  final double labelWidth;
}

const _tiles = [
  _TileSpec('Workouts', 55.5, Color(0xFFEFE3FD), Ph.barbellBold, [Color(0xFFA56BF5), Color(0xFF6A22D8)], 57.33),
  _TileSpec('Nutrition', 149.0, Color(0xFFEFF7D0), Ph.forkKnife, [Color(0xFFC7DE5C), Color(0xFF9EBC2A)], 52),
  _TileSpec('Progress', 245.3, Color(0xFFDDEFF8), Ph.chartLineUpBold, [Color(0xFF6CC0EC), Color(0xFF1E68AE)], 52.67),
  _TileSpec('More', 340.0, Color(0xFFF4F0EA), Ph.dots, [Color(0xFF55545C), Color(0xFF3D3C44)], 29.67),
];

class _QuickTile extends StatefulWidget {
  const _QuickTile({required this.spec, required this.entrance, required this.index});

  final _TileSpec spec;
  final Animation<double> entrance;
  final int index;

  @override
  State<_QuickTile> createState() => _QuickTileState();
}

class _QuickTileState extends State<_QuickTile> with SingleTickerProviderStateMixin {
  late final AnimationController _tap;

  @override
  void initState() {
    super.initState();
    _tap = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.spec;
    final label = inter(13.75, 500, color: const Color(0xFF38373A), track: -0.03);
    final begin = 0.34 + widget.index * 0.06;
    return Pressable(
      onTap: () => _tap.forward(from: 0),
      scale: 0.92,
      child: Tick(
        builder: (context, seconds, _) => AnimatedBuilder(
          animation: Listenable.merge([widget.entrance, _tap]),
          builder: (context, _) {
            final t = span(widget.entrance.value, begin, begin + 0.34, Curves.linear);
            final pop = spring(t, bounce: 0.7, freq: 2.8);
            final ripple = _tap.value;
            final idle = t >= 1 ? _idle(widget.index, seconds) : const _Pose(0, 0, 1);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 47 - 35,
                  top: 389 - 354 - 35,
                  child: Transform.scale(
                    scale: pop,
                    child: SizedBox.square(
                      dimension: 70,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          if (ripple > 0 && ripple < 1)
                            Container(
                              width: 70 + 40 * ripple,
                              height: 70 + 40 * ripple,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: s.colors.last.withValues(alpha: 0.35 * (1 - ripple)), width: 2),
                              ),
                            ),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(-0.3, -0.4),
                                radius: 0.95,
                                colors: [Color.lerp(s.fill, Colors.white, 0.35)!, s.fill],
                              ),
                            ),
                          ),
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..translateByDouble(0, idle.dy - 6 * math.sin(ripple * math.pi), 0, 1)
                              ..rotateZ(idle.rot + 0.3 * math.sin(ripple * math.pi * 3) * (1 - ripple))
                              ..scaleByDouble(idle.scale, idle.scale, 1, 1),
                            child: _glyph(s, widget.index),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 432.67 - 354,
                  child: Opacity(
                    opacity: span(t, 0.2, 0.6, Curves.linear),
                    child: Center(child: Cap(s.label, label, align: TextAlign.center)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _glyph(_TileSpec s, int i) {
    if (i == 2) return const CustomPaint(size: Size(30, 30), painter: _ChartGlyph());
    final icon = PhIcon(
      s.icon,
      size: i == 3 ? 28 : (i == 0 ? 36 : 32),
      foreground: Paint()..shader = ui.Gradient.linear(const Offset(0, 0), const Offset(0, 32), s.colors),
      shadows: [Shadow(color: s.colors.last.withValues(alpha: 0.28), blurRadius: 6, offset: const Offset(0, 3))],
    );
    return i == 0 ? Transform.rotate(angle: -0.62, child: icon) : icon;
  }

  _Pose _idle(int i, double seconds) {
    final c = ((seconds + i * 0.9) % 4.0) / 4.0;
    final k = c < 0.25 ? math.sin(c / 0.25 * math.pi) : 0.0;
    switch (i) {
      case 0:
        return _Pose(-4 * k, -0.18 * k * math.sin(c * 40), 1 + 0.05 * k);
      case 1:
        return _Pose(0, 0.22 * k * math.sin(c / 0.25 * math.pi * 2), 1);
      case 2:
        return _Pose(-3 * k, 0, 1 + 0.1 * k);
      default:
        return _Pose(0, 0, 1 + 0.12 * k);
    }
  }
}

class _ChartGlyph extends CustomPainter {
  const _ChartGlyph();

  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromLTRBR(2.5, 4, 27.5, 28, const Radius.circular(4.5));
    final shader = ui.Gradient.linear(const Offset(0, 2), const Offset(0, 28), const [Color(0xFF5DB8EE), Color(0xFF1E68AE)]);
    canvas.drawRRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..shader = shader,
    );
    final bar = Paint()..shader = ui.Gradient.linear(const Offset(0, 14), const Offset(0, 26), const [Color(0xFF8CD2F6), Color(0xFF3B8FD2)]);
    canvas.drawRRect(RRect.fromLTRBR(7, 18, 10.6, 25, const Radius.circular(1)), bar);
    canvas.drawRRect(RRect.fromLTRBR(13.2, 15, 16.8, 25, const Radius.circular(1)), bar);
    canvas.drawRRect(RRect.fromLTRBR(19.4, 12.5, 23, 25, const Radius.circular(1)), bar);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = shader;
    canvas.drawPath(
      Path()
        ..moveTo(6.5, 14)
        ..lineTo(12, 9.5)
        ..lineTo(16.5, 11.5)
        ..lineTo(24, 3.5),
      line,
    );
    canvas.drawCircle(const Offset(24.5, 3.2), 2.6, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_ChartGlyph old) => false;
}

class _Pose {
  const _Pose(this.dy, this.rot, this.scale);

  final double dy;
  final double rot;
  final double scale;
}

class _Meta {
  const _Meta(this.text, this.cap, {this.fire = false, this.size = 12.6, this.track = -0.03});

  final String text;
  final double track;
  final double cap;
  final bool fire;
  final double size;
}

class _RecCard extends StatelessWidget {
  const _RecCard({
    required this.onTap,
    required this.tint,
    required this.thumb,
    required this.thumbAt,
    required this.title,
    required this.titleCap,
    required this.lines,
    required this.chevron,
    required this.chevronAt,
    this.titleSize = 15.12,
    this.titleTrack = -0.006,
  });

  final VoidCallback onTap;
  final Color tint;
  final Widget thumb;
  final Offset thumbAt;
  final String title;
  final double titleCap;
  final double titleSize;
  final double titleTrack;
  final List<_Meta> lines;
  final Widget chevron;
  final Offset chevronAt;

  @override
  Widget build(BuildContext context) {
    final head = inter(titleSize, 600, color: const Color(0xFF0B0B12), track: titleTrack);
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: SoftShadowBox(color: tint, radius: 20, shadow: const Color(0x10584C7A)),
          ),
          Positioned(left: thumbAt.dx, top: thumbAt.dy, child: thumb),
          Positioned(
            left: 128.67 - 20 - bearing(title, head),
            top: titleCap - capInset(head),
            child: Text(title, style: head, softWrap: false),
          ),
          for (final l in lines) _meta(l),
          Positioned(
            left: chevronAt.dx - 14,
            top: chevronAt.dy - 14,
            child: SizedBox.square(dimension: 28, child: Center(child: chevron)),
          ),
        ],
      ),
    );
  }

  Widget _meta(_Meta m) {
    final style = inter(m.size, 400, color: const Color(0xFF808084), track: m.track);
    final x = m.fire ? 143.0 - 20 : 128.0 - 20;
    return Positioned(
      left: (m.fire ? 126.2 - 20 : x - bearing(m.text, style)),
      top: m.cap - capInset(style) - (m.fire ? 0 : 0),
      child: m.fire
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.translate(offset: const Offset(0, -0.5), child: const Flicker(child: Emoji(Art.fire, size: 13))),
                const SizedBox(width: 3),
                Text(m.text, style: style),
              ],
            )
          : Text(m.text, style: style, softWrap: false),
    );
  }
}

class _StatSpec {
  const _StatSpec(this.rect, this.fill, this.icon, this.value, this.format, this.label, this.textX);

  final Rect rect;
  final Color fill;
  final Sprite icon;
  final double value;
  final String Function(double v) format;
  final String label;
  final double textX;
}

String _int(double v) => grouped(v.round());
String _litres(double v) => '${v.toStringAsFixed(1)} L';

final _stats = [
  _StatSpec(const Rect.fromLTWH(20, 735, 108, 90), const Color(0xFFFDF1E4), Art.statFire, 3, _int, 'Workouts', 71.67),
  _StatSpec(const Rect.fromLTWH(140, 735, 112, 90), const Color(0xFFE8F3F5), Art.statShoe, 4320, _int, 'Steps', 194.67),
  _StatSpec(const Rect.fromLTWH(263, 735, 113, 90), const Color(0xFFF0F0F7), Art.statDrop, 1.8, _litres, 'Water', 320.0),
];

class _StatTile extends StatelessWidget {
  const _StatTile({required this.spec, required this.entrance});

  final _StatSpec spec;
  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final value = inter(15.12, 700, color: const Color(0xFF0E0F16), track: -0.052);
    final label = inter(12.3, 400, color: const Color(0xFFA29D99), track: -0.062);
    final r = spec.rect;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [spec.fill, Color.lerp(spec.fill, const Color(0xFFFEFAF2), 0.5)!],
              ),
            ),
          ),
        ),
        Positioned(
          left: spec.icon.left - r.left,
          top: spec.icon.top + 1 - r.top,
          child: Tick(
            builder: (context, seconds, child) => Transform.translate(
              offset: Offset(0, 1.6 * wave(seconds, 2.6, spec.textX / 100)),
              child: child,
            ),
            child: spec.icon.image(),
          ),
        ),
        Positioned(
          left: spec.textX - r.left - bearing(spec.format(spec.value), value),
          top: 758.0 - r.top - capInset(value),
          child: Counter(
            value: spec.value,
            progress: CurvedAnimation(parent: entrance, curve: const Interval(0.7, 1)),
            style: value,
            format: spec.format,
          ),
        ),
        Positioned(
          left: spec.textX - r.left - bearing(spec.label, label) - 0.5,
          top: 776.4 - r.top - capInset(label),
          child: Text(spec.label, style: label),
        ),
      ],
    );
  }
}
