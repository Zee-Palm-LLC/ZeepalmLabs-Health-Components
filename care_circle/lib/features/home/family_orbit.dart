import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/store.dart';

class FamilyOrbit extends StatefulWidget {
  const FamilyOrbit({super.key, required this.enter, required this.onOpen});

  final Animation<double> enter;
  final ValueChanged<Member> onOpen;

  @override
  State<FamilyOrbit> createState() => _FamilyOrbitState();
}

class _FamilyOrbitState extends State<FamilyOrbit> with TickerProviderStateMixin {
  late final AnimationController _clock;
  late final AnimationController _tap;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _tap = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  }

  @override
  void dispose() {
    _clock.dispose();
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = CareStore.instance;
    final enter = widget.enter;
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final centre = Offset(w / 2, 138);
        final rx = math.min(w * 0.36, 142.0);
        const ry = 112.0;
        final children = <Widget>[
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _OrbitPainter(centre: centre, rx: rx, ry: ry, enter: enter, clock: _clock, ripple: _tap),
              ),
            ),
          ),
          _core(centre),
        ];
        for (var i = 0; i < CareStore.members.length; i++) {
          final member = CareStore.members[i];
          final big = member.id == 'joe';
          final size = big ? 78.0 : 68.0;
          final a = member.angle * math.pi / 180;
          final at = centre + Offset(math.cos(a) * rx, math.sin(a) * ry);
          final nudged = big && store.nudged;
          final halo = big ? (store.morningTaken ? Hue.sage : (nudged ? Hue.honey : Hue.coral)) : member.halo;
          final mood = big && store.morningTaken ? Mood.good : member.mood;
          final seat = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onOpen(member),
            child: Column(
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (big && mood != Mood.good)
                        Positioned.fill(
                          child: RepaintBoundary(child: CustomPaint(painter: _PulsePainter(_clock, halo))),
                        ),
                      Hero(
                        tag: member.heroTag,
                        child: RepaintBoundary(
                          child: HaloAvatar(photo: member.photo, size: size, halo: halo, glow: big ? 1.1 : 0.8),
                        ),
                      ),
                      if (mood != Mood.nudge)
                        Positioned(
                          right: -3,
                          bottom: 0,
                          child: Staged(
                            animation: enter,
                            begin: 0.55 + i * 0.05,
                            end: 0.85 + i * 0.03,
                            curve: Curves.elasticOut,
                            fade: false,
                            scale: 0,
                            offset: Offset.zero,
                            child: MoodBadge(mood: mood),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Staged(
                  animation: enter,
                  begin: 0.3 + i * 0.06,
                  end: 0.7 + i * 0.06,
                  offset: const Offset(0, 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(member.name, style: jakarta(13, 750)),
                  ),
                ),
              ],
            ),
          );
          children.add(
            Positioned(
              left: at.dx - 60,
              top: at.dy - size / 2,
              width: 120,
              child: AnimatedBuilder(
                animation: _clock,
                child: seat,
                builder: (context, child) {
                  final bob = math.sin(_clock.value * math.pi * 6 + i * 1.7) * 3;
                  return Transform.translate(offset: Offset(0, bob), child: child);
                },
              ),
            ),
          );
        }
        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }

  Widget _core(Offset centre) {
    const size = 80.0;
    return Positioned(
      left: centre.dx - 70,
      top: centre.dy - size / 2,
      width: 140,
      child: Column(
        children: [
          Staged(
            animation: widget.enter,
            begin: 0.1,
            end: 0.55,
            curve: Curves.elasticOut,
            fade: false,
            scale: 0,
            offset: Offset.zero,
            child: Pressable(
              onTap: () => _tap.forward(from: 0),
              child: SizedBox.square(
                dimension: size,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _CorePainter(_clock),
                    child: const Center(
                      child: GlyphIcon(Glyph.home, size: 32, color: Colors.white, fill: Color(0x40FFFFFF), stroke: 2.2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Staged(
            animation: widget.enter,
            begin: 0.15,
            end: 0.5,
            offset: const Offset(0, 8),
            child: Column(
              children: [
                Text('Family', style: jakarta(17, 800, spacing: -0.3)),
                Text('5 members', style: jakarta(12, 550, color: Hue.inkSoft)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CorePainter extends CustomPainter {
  _CorePainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final clock = animation.value * math.pi * 2;
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final breath = 0.5 + 0.5 * math.sin(clock * 4);
    canvas.drawCircle(c, r * (1.55 + 0.08 * breath), Paint()..color = const Color(0xFFEFE9FF).withValues(alpha: 0.7));
    canvas.drawCircle(c, r * 1.22, Paint()..color = const Color(0xFFE4DAFF).withValues(alpha: 0.8));
    canvas.drawCircle(
      c + const Offset(0, 6),
      r * 0.95,
      Paint()
        ..color = Hue.iris.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.linear(c - Offset(r, r), c + Offset(r, r), const [Color(0xFFA689FF), Color(0xFF6A47EB)]),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = SweepGradient(
          transform: GradientRotation(clock * 2),
          colors: const [Color(0x00FFFFFF), Color(0x33FFFFFF), Color(0x00FFFFFF), Color(0x00FFFFFF)],
          stops: const [0, 0.12, 0.3, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c - Offset(r * 0.3, r * 0.45),
      r * 0.7,
      Paint()
        ..shader = ui.Gradient.radial(c - Offset(r * 0.3, r * 0.45), r * 0.7, [
          const Color(0x40FFFFFF),
          const Color(0x00FFFFFF),
        ]),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CorePainter oldDelegate) => false;
}

class _PulsePainter extends CustomPainter {
  _PulsePainter(this.animation, this.color) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final clock = animation.value * math.pi * 2;
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    for (var k = 0; k < 2; k++) {
      final p = ((clock / (math.pi * 2)) * 10 + k * 0.5) % 1.0;
      canvas.drawCircle(
        c,
        r * (1 + p * 0.45),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2 * (1 - p) + 0.4
          ..color = color.withValues(alpha: 0.55 * (1 - p)),
      );
    }
    final wave = (clock / (math.pi * 2) * 10) % 1.0;
    for (var k = 0; k < 2; k++) {
      final rr = r * (1.22 + k * 0.18);
      final alpha = (0.9 - k * 0.3) * (0.5 + 0.5 * math.sin(wave * math.pi * 2 - k));
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: rr),
        -math.pi * 0.36,
        math.pi * 0.22,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: alpha.clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) => oldDelegate.color != color;
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({
    required this.centre,
    required this.rx,
    required this.ry,
    required this.enter,
    required Animation<double> clock,
    required Animation<double> ripple,
  }) : _clock = clock,
       _ripple = ripple,
       super(repaint: Listenable.merge([enter, clock, ripple]));

  final Offset centre;
  final double rx;
  final double ry;
  final Animation<double> enter;
  final Animation<double> _clock;
  final Animation<double> _ripple;

  double get draw => span(enter.value, 0, 0.55, Curves.easeInOutCubic);
  double get clock => _clock.value * math.pi * 2;
  double get ripple => _ripple.value;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Rect.fromCenter(center: centre, width: rx * 2, height: ry * 2);
    final inner = Rect.fromCenter(center: centre, width: rx * 1.2, height: ry * 1.2);
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFC6B8F5);
    const count = 72;
    for (var i = 0; i < count; i++) {
      if (i / count > draw) break;
      final a = clock * 0.25 + i * math.pi * 2 / count - math.pi / 2;
      canvas.drawArc(outer, a, math.pi * 2 / count * 0.42, false, dash);
    }
    canvas.drawArc(
      inner,
      -math.pi / 2,
      math.pi * 2 * draw,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFFE2D9FB),
    );

    if (ripple > 0 && ripple < 1) {
      final e = Curves.easeOutCubic.transform(ripple);
      canvas.drawOval(
        Rect.fromCenter(center: centre, width: rx * 2 * e, height: ry * 2 * e),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * (1 - ripple)
          ..color = Hue.iris.withValues(alpha: 0.5 * (1 - ripple)),
      );
    }

    if (draw < 1) return;
    final dots = [
      (1.0, 0.4, const Color(0xFFA489FF), 5.5),
      (1.0, 2.6, const Color(0xFFF6A3BF), 4.2),
      (1.0, 4.4, const Color(0xFF7DD3A8), 4.4),
      (0.6, 1.2, const Color(0xFFB9A6FF), 4.0),
      (0.6, 3.9, const Color(0xFFF8C77A), 3.6),
    ];
    for (final (scale, phase, color, r) in dots) {
      final a = phase + clock * (scale > 0.8 ? 1 : -1.6);
      final p = centre + Offset(math.cos(a) * rx * scale, math.sin(a) * ry * scale);
      canvas.drawCircle(p, r * 2, Paint()..color = color.withValues(alpha: 0.16));
      canvas.drawCircle(
        p,
        r,
        Paint()..shader = ui.Gradient.radial(p - Offset(r * 0.35, r * 0.35), r * 1.2, [Colors.white, color], [0, 0.65]),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) {
    return oldDelegate.centre != centre || oldDelegate.rx != rx || oldDelegate.ry != ry;
  }
}
