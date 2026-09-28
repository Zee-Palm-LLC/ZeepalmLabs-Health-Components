import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/art.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/type.dart';
import '../../widgets/live_mascot.dart';
import '../../widgets/surfaces.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.entrance, required this.onOpen});

  static const rect = Rect.fromLTWH(19, 190, 357, 148.67);

  final Animation<double> entrance;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final r = rect;
    final goal = inter(14.2, 500, color: const Color(0xFFE3E1FE), track: 0.0125);
    final title = inter(23.8, 700, color: const Color(0xFFF7F6FF), track: 0.004);
    final kcal = inter(13.75, 500, color: const Color(0xFFE6E5FF), track: 0.0116);
    return SizedBox(
      width: r.width,
      height: r.height + (r.top - Art.runner.top),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: r.top - Art.runner.top,
            width: r.width,
            height: r.height,
            child: Pressable(
              onTap: onOpen,
              scale: 0.985,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [BoxShadow(color: Color(0x2A5B4CE0), blurRadius: 24, offset: Offset(0, 10))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Tick(
                    builder: (context, seconds, _) => CustomPaint(
                      painter: _Aurora(seconds, entrance),
                      size: r.size,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: Art.runner.left - r.left,
            top: 0,
            width: Art.runner.width,
            height: Art.runner.height,
            child: ClipRect(
              clipper: _BelowCard(r.bottom - Art.runner.top),
              child: LiveMascot(
                sprite: Art.runner,
                entrance: entrance,
                idle: Idle.run,
                begin: 0.25,
                end: 0.75,
                drop: 40,
              ),
            ),
          ),
          _at(r, 39.33, 214.67, goal, "Today's Goal", 0.2),
          _at(r, 39.33, 239.33, title, 'Stay Active', 0.26),
          Positioned(
            left: 38 - r.left,
            top: 271.2 - Art.runner.top,
            child: Staged(
              animation: entrance,
              begin: 0.32,
              end: 0.6,
              offset: const Offset(-10, 0),
              child: const Flicker(child: Emoji(Art.fire, size: 15)),
            ),
          ),
          Positioned(
            left: 60 - bearing('1', kcal) - r.left,
            top: 273.33 - Art.runner.top - capInset(kcal),
            child: Staged(
              animation: entrance,
              begin: 0.32,
              end: 0.6,
              offset: const Offset(-10, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Counter(value: 120, progress: _sub(entrance, 0.34, 0.9), style: kcal),
                  Text(' / 300 kcal', style: kcal),
                ],
              ),
            ),
          ),
          Positioned(
            left: 39 - r.left,
            top: 303.5 - Art.runner.top,
            child: _GoalBar(entrance: entrance),
          ),
          Positioned(
            left: 316 - r.left,
            top: 281 - Art.runner.top,
            child: Staged(
              animation: entrance,
              begin: 0.5,
              end: 0.85,
              offset: const Offset(20, 20),
              child: Pressable(onTap: onOpen, child: const _Dock()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _at(Rect r, double x, double cap, TextStyle style, String text, double begin) {
    return Positioned(
      left: x - bearing(text, style) - r.left,
      top: cap - Art.runner.top - capInset(style),
      child: Staged(
        animation: entrance,
        begin: begin,
        end: begin + 0.3,
        offset: const Offset(-14, 0),
        child: Text(text, style: style, softWrap: false),
      ),
    );
  }
}

Animation<double> _sub(Animation<double> parent, double a, double b) =>
    CurvedAnimation(parent: parent, curve: Interval(a, b));

class _BelowCard extends CustomClipper<Rect> {
  const _BelowCard(this.bottom);

  final double bottom;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(-60, -80, size.width + 60, bottom);

  @override
  bool shouldReclip(_BelowCard old) => old.bottom != bottom;
}

class _Aurora extends CustomPainter {
  _Aurora(this.seconds, this.entrance) : super(repaint: entrance);

  final double seconds;
  final Animation<double> entrance;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, 0),
          const [Color(0xFF5E5AF3), Color(0xFF6A63FA), Color(0xFF7466F8)],
          const [0, 0.5, 1],
        ),
    );
    final d1 = Offset(math.sin(seconds * 0.5) * 10, math.cos(seconds * 0.4) * 6);
    final d2 = Offset(math.cos(seconds * 0.35) * 14, math.sin(seconds * 0.45) * 5);
    void glow(Offset c, double r, Color color, [double stop = 0]) {
      canvas.drawCircle(
        c,
        r,
        Paint()..shader = ui.Gradient.radial(c, r, [color, color.withValues(alpha: 0)], [stop, 1]),
      );
    }

    glow(Offset(250, 150) + d2, 135, const Color(0xF2C3CDF7));
    glow(Offset(196, 64) + d1, 100, const Color(0xA8B37CEE));
    glow(Offset(165, 150) + d1, 80, const Color(0x5C877FFF));
    glow(Offset(190, 0) - d1, 90, const Color(0x668F7CF6));
    glow(Offset(292, 6) + d1, 86, const Color(0xE08B45E6));
    glow(Offset(340, 60) - d2, 60, const Color(0x80A45BEF));
    glow(Offset(0, 160), 70, const Color(0x2A3F37C8));
    final streak = span(entrance.value, 0.5, 1.0, Curves.linear);
    if (streak > 0) {
      for (var i = 0; i < 5; i++) {
        final speed = 70 + i * 23.0;
        final phase = (seconds * speed / 120 + i * 0.27) % 1.0;
        final y = 46 + i * 7.5 + math.sin(seconds * 2 + i) * 2;
        final x1 = 206 - phase * 44;
        final len = 18 + (i % 3) * 7;
        final a = math.sin(phase * math.pi) * streak;
        final paint = Paint()
          ..strokeWidth = i.isEven ? 2.2 : 1.4
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(
            Offset(x1, y),
            Offset(x1 + len, y),
            [const Color(0x00F46AA0), Color.fromRGBO(244, 106, 160, 0.55 * a), Color.fromRGBO(255, 255, 255, 0.4 * a)],
            const [0, 0.6, 1],
          );
        canvas.drawLine(Offset(x1, y), Offset(x1 + len, y), paint);
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(0.5), const Radius.circular(21.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          const [Color(0x33FFFFFF), Color(0x00FFFFFF)],
        ),
    );
  }

  @override
  bool shouldRepaint(_Aurora old) => old.seconds != seconds;
}

class _GoalBar extends StatelessWidget {
  const _GoalBar({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, seconds, _) => AnimatedBuilder(
        animation: entrance,
        builder: (context, _) => CustomPaint(
          size: const Size(180, 10.5),
          painter: _BarPainter(span(entrance.value, 0.4, 0.95, swift), seconds),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.t, this.seconds);

  final double t;
  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final track = RRect.fromLTRBR(0, 0, size.width, h, Radius.circular(h / 2));
    canvas.drawRRect(
      track,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, 0),
          const [Color(0x1FFFFFFF), Color(0x14FFFFFF), Color(0x00FFFFFF)],
          const [0, 0.6, 1],
        ),
    );
    final w = 83 * t;
    if (w < 1) return;
    final fill = RRect.fromLTRBR(0, 0, math.max(w, h), h, Radius.circular(h / 2));
    canvas.save();
    canvas.clipRRect(fill);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, h),
          const [Color(0xFFE9FC9E), Color(0xFFDFF584)],
        ),
    );
    final x = ((seconds * 46) % (w + 60)) - 30;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(x - 16, 0),
          Offset(x + 16, 0),
          const [Color(0x00FFFFFF), Color(0x88FFFFFF), Color(0x00FFFFFF)],
          const [0, 0.5, 1],
        ),
    );
    canvas.restore();
    canvas.drawCircle(
      Offset(w - h / 2, h / 2),
      h * 0.9,
      Paint()
        ..color = const Color(0x55E6FA8C)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.t != t || old.seconds != seconds;
}

class _Dock extends StatelessWidget {
  const _Dock();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 57.67,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CustomPaint(painter: _DockShape())),
          Positioned(
            left: 344.5 - 316 - 14.5,
            top: 305 - 281 - 14.5,
            child: Tick(
              builder: (context, seconds, _) {
                final beat = math.pow(math.max(0.0, math.sin(seconds * math.pi / 1.3)), 8).toDouble();
                return Transform.scale(
                  scale: 1 + 0.07 * beat,
                  child: Container(
                    width: 29,
                    height: 29,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE4EEF0),
                      boxShadow: [BoxShadow(color: const Color(0xFFFFFFFF).withValues(alpha: 0.25 + 0.3 * beat), blurRadius: 8 + 6 * beat)],
                    ),
                    child: Transform.translate(
                      offset: Offset(0.8 + 1.5 * beat, 0),
                      child: const PhIcon(Ph.caretRight, size: 15, color: Color(0xFF0E0F16)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DockShape extends CustomPainter {
  const _DockShape();

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: const Radius.circular(24),
      topRight: const Radius.circular(3),
      bottomLeft: const Radius.circular(22),
      bottomRight: const Radius.circular(22),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, size.height),
          const [Color(0xEB3A3B52), Color(0xF0262739), Color(0xF22A2440)],
          const [0, 0.5, 1],
        ),
    );
    canvas.drawRRect(
      r.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x1FFFFFFF),
    );
  }

  @override
  bool shouldRepaint(_DockShape old) => false;
}
