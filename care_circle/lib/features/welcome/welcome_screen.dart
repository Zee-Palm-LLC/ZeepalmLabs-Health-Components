import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/scenery.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/store.dart';
import '../shell/shell.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..forward();
    _idle = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Portrait.warm(context);
  }

  @override
  void dispose() {
    _enter.dispose();
    _idle.dispose();
    super.dispose();
  }

  void _start() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        reverseTransitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondary) => const Shell(),
        transitionsBuilder: (context, animation, secondary, child) {
          final t = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.25, 1, curve: Curves.easeOutCubic),
          );
          return FadeTransition(
            opacity: t,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(t),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final top = math.max(media.viewPadding.top, 20.0);
    final bottom = math.max(media.viewPadding.bottom, 16.0);
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: Wash()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 150 + bottom,
            child: Staged(
              animation: _enter,
              begin: 0.35,
              end: 0.9,
              offset: const Offset(0, 40),
              child: Meadow(sway: _idle),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: top + 10, bottom: bottom + 8),
            child: Column(
              children: [
                Staged(animation: _enter, end: 0.35, offset: const Offset(0, -12), child: const _Brand()),
                Expanded(
                  child: _OrbitHero(enter: _enter, idle: _idle),
                ),
                const SizedBox(height: 6),
                _Headline(enter: _enter),
                const SizedBox(height: 14),
                Staged(
                  animation: _enter,
                  begin: 0.55,
                  end: 0.85,
                  child: Text(
                    'Share health, meds and moments\nwith your family circle.',
                    textAlign: TextAlign.center,
                    style: jakarta(16, 450, color: Hue.inkSoft, height: 1.5),
                  ),
                ),
                const SizedBox(height: 28),
                Staged(
                  animation: _enter,
                  begin: 0.62,
                  end: 0.95,
                  curve: Curves.easeOutBack,
                  offset: const Offset(0, 24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: PrimaryButton(label: 'Create your circle', trailing: Glyph.arrow, height: 58, onTap: _start),
                  ),
                ),
                const SizedBox(height: 10),
                Staged(
                  animation: _enter,
                  begin: 0.72,
                  child: Pressable(
                    onTap: _start,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text('I was invited', style: jakarta(15.5, 650, color: Hue.irisDeep)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const CareLogo(size: 32),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Care', style: jakarta(23, 800, spacing: -0.6)),
                TextSpan(
                  text: 'Circle',
                  style: jakarta(23, 800, color: Hue.iris, spacing: -0.6),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text('Health · Family · Together', style: jakarta(11, 600, color: Hue.inkMute, spacing: 0.1)),
        ],
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.enter});

  final Animation<double> enter;

  @override
  Widget build(BuildContext context) {
    final style = jakarta(32, 800, spacing: -0.9, height: 1.18);
    Widget word(String text, int index, {bool accent = false}) {
      final begin = 0.4 + index * 0.04;
      return Staged(
        animation: enter,
        begin: begin,
        end: begin + 0.3,
        offset: const Offset(0, 18),
        child: accent ? GradientText(text, style: style) : Text(text, style: style),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [word('Care ', 0), word('for ', 1), word('the ', 2), word('people', 3)],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            word('who ', 4),
            word('cared ', 5, accent: true),
            word('for ', 6, accent: true),
            word('you', 7, accent: true),
          ],
        ),
      ],
    );
  }
}

class _Seat {
  const _Seat(this.id, this.x, this.y, this.size);

  final String id;
  final double x;
  final double y;
  final double size;
}

const _seats = [
  _Seat('joe', 0.3, 0.17, 0.245),
  _Seat('rose', 0.765, 0.235, 0.215),
  _Seat('mom', 0.215, 0.575, 0.235),
  _Seat('dad', 0.79, 0.62, 0.225),
  _Seat('leo', 0.5, 0.85, 0.21),
];

const _haloOf = {'joe': Hue.blush, 'rose': Hue.sage, 'mom': Hue.honey, 'dad': Hue.iris, 'leo': Hue.irisLight};

class _OrbitHero extends StatelessWidget {
  const _OrbitHero({required this.enter, required this.idle});

  final Animation<double> enter;
  final Animation<double> idle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        final unit = math.min(w, h * 1.1);
        final centre = Offset(w / 2, h / 2);
        final both = Listenable.merge([enter, idle]);
        final children = <Widget>[
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _RingsPainter(enter: enter, idle: idle, unit: unit),
              ),
            ),
          ),
          _bubble(
            both,
            Offset(w * 0.44, h * 0.37),
            unit * 0.1,
            Glyph.heart,
            Hue.iris,
            const Color(0xFFE9E1FF),
            0.45,
            0,
          ),
          _bubble(both, Offset(w * 0.56, h * 0.5), unit * 0.095, Glyph.walk, Hue.sage, Hue.sageSoft, 0.5, 1.4),
          _bubble(
            both,
            Offset(w * 0.28, h * 0.85),
            unit * 0.085,
            Glyph.moon,
            Hue.iris,
            const Color(0xFFEDE8FF),
            0.55,
            2.6,
          ),
        ];
        for (var i = 0; i < _seats.length; i++) {
          final seat = _seats[i];
          final member = CareStore.byId(seat.id);
          final size = unit * seat.size;
          final home = Offset(w * seat.x, h * seat.y);
          final begin = 0.05 + i * 0.08;
          children.add(
            Positioned(
              left: home.dx - size / 2,
              top: home.dy - size / 2,
              child: AnimatedBuilder(
                animation: both,
                child: Hero(
                  tag: member.heroTag,
                  child: RepaintBoundary(
                    child: HaloAvatar(photo: member.photo, size: size, halo: _haloOf[seat.id]!, glow: 0.95),
                  ),
                ),
                builder: (context, child) {
                  final e = enter.value;
                  final clock = idle.value * math.pi * 2;
                  final pop = span(e, begin, begin + 0.5, Curves.elasticOut);
                  final travel = span(e, begin, begin + 0.4, Curves.easeOutCubic);
                  final float = Offset(math.sin(clock * 2 + i * 1.3) * 3, math.cos(clock * 2 + i * 0.9) * 4);
                  final shift = (centre - home) * (1 - travel) + float * travel;
                  return Opacity(
                    opacity: span(e, begin, begin + 0.15),
                    child: Transform.translate(
                      offset: shift,
                      child: Transform.scale(scale: pop.clamp(0.0, 1.4), child: child),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }

  Widget _bubble(
    Listenable both,
    Offset at,
    double size,
    Glyph glyph,
    Color tone,
    Color soft,
    double begin,
    double phase,
  ) {
    return Positioned(
      left: at.dx - size / 2,
      top: at.dy - size / 2,
      child: AnimatedBuilder(
        animation: both,
        child: RepaintBoundary(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: soft,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: tone.withValues(alpha: 0.22), blurRadius: 14, offset: const Offset(0, 5))],
            ),
            alignment: Alignment.center,
            child: GlyphIcon(glyph, size: size * 0.48, color: tone, stroke: 2.1),
          ),
        ),
        builder: (context, child) {
          final t = span(enter.value, begin, begin + 0.3, Curves.easeOutBack);
          final bob = math.sin(idle.value * math.pi * 4 + phase) * 4;
          return Transform.translate(
            offset: Offset(0, bob),
            child: Transform.scale(scale: t.clamp(0.0, 1.3), child: child),
          );
        },
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({required this.enter, required this.idle, required this.unit})
    : super(repaint: Listenable.merge([enter, idle]));

  final Animation<double> enter;
  final Animation<double> idle;
  final double unit;

  double get draw => span(enter.value, 0.1, 0.7, Curves.easeInOutCubic);
  double get clock => idle.value * math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.52);
    final rings = [(unit * 0.4, const Color(0xFFBBAAF2), 1.0), (unit * 0.24, const Color(0xFFCFC4F4), -1.4)];
    for (final (r, color, speed) in rings) {
      _dashed(canvas, c, r, color, clock * speed * 0.15, draw);
    }
    _arc(
      canvas,
      Offset(size.width * 0.3, size.height * 0.17),
      Offset(size.width * 0.765, size.height * 0.235),
      -0.35,
      clock,
    );
    _arc(
      canvas,
      Offset(size.width * 0.215, size.height * 0.575),
      Offset(size.width * 0.5, size.height * 0.85),
      0.3,
      clock,
    );
    _arc(
      canvas,
      Offset(size.width * 0.5, size.height * 0.85),
      Offset(size.width * 0.79, size.height * 0.62),
      0.35,
      clock,
    );

    if (draw < 1) return;
    final satellites = [
      (unit * 0.4, 0.0, const Color(0xFFA489FF), 5.5),
      (unit * 0.4, 2.3, const Color(0xFF7DD3A8), 4.0),
      (unit * 0.4, 4.1, const Color(0xFFF7A8C4), 4.5),
      (unit * 0.24, 1.2, const Color(0xFFB9A6FF), 4.0),
      (unit * 0.24, 3.9, const Color(0xFFF8C77A), 3.5),
    ];
    for (final (r, phase, color, dot) in satellites) {
      final a = phase + clock * (r > unit * 0.3 ? 0.5 : -0.8);
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
      canvas.drawCircle(p, dot * 1.9, Paint()..color = color.withValues(alpha: 0.18));
      canvas.drawCircle(
        p,
        dot,
        Paint()
          ..shader = ui.Gradient.radial(p - Offset(dot * 0.3, dot * 0.3), dot * 1.2, [Colors.white, color], [0, 0.6]),
      );
    }
  }

  void _dashed(Canvas canvas, Offset c, double r, Color color, double phase, double draw) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = color;
    const dashes = 64;
    for (var i = 0; i < dashes; i++) {
      if (i / dashes > draw) break;
      final a = phase + i * math.pi * 2 / dashes - math.pi / 2;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), a, math.pi * 2 / dashes * 0.45, false, paint);
    }
  }

  void _arc(Canvas canvas, Offset a, Offset b, double bend, double clock) {
    if (draw <= 0) return;
    final mid = Offset.lerp(a, b, 0.5)!;
    final normal = Offset(-(b.dy - a.dy), b.dx - a.dx) * bend;
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(mid.dx + normal.dx, mid.dy + normal.dy, b.dx, b.dy);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFC9BCF5);
    for (final metric in path.computeMetrics()) {
      final length = metric.length * draw;
      final shift = (clock * 18) % 10;
      for (var d = -shift; d < length; d += 10) {
        final start = math.max(0.0, d);
        final end = math.min(length, d + 3.5);
        if (end > start) canvas.drawPath(metric.extractPath(start, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_RingsPainter oldDelegate) => oldDelegate.unit != unit;
}
