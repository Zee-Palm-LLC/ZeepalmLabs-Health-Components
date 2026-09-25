import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/type.dart';
import '../../widgets/avatar.dart';

class Member {
  const Member(this.name, this.photo, this.cx, this.cy, this.radius, this.photoRadius);

  final String name;
  final String photo;
  final double cx;
  final double cy;
  final double radius;
  final double photoRadius;
}

const crew = [
  Member('Sarah', 'm_sarah', 132.8, 483.5, 27.8, 25.6),
  Member('Mike', 'm_mike', 206.2, 482.8, 27.4, 25.2),
  Member('Priya', 'm_priya', 280.2, 483.2, 27.6, 25.4),
];

class MembersRow extends StatelessWidget {
  const MembersRow({super.key, required this.entrance, required this.check});

  final Animation<double> entrance;
  final Animation<double> check;

  @override
  Widget build(BuildContext context) {
    final e = entrance;
    final head = inter(18.26, 700, color: const Color(0xFFE6E8EC));
    final link = inter(13.18, 600, color: const Color(0xFF9272F5));
    final name = inter(12.3, 500, color: const Color(0xFFE3E7EE));
    final status = inter(11.4, 400, color: const Color(0xFF3FD29B));
    final more = inter(12.3, 500, color: const Color(0xFF7F889D));
    final plus = inter(13.5, 600, color: const Color(0xFFE9ECF2));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 17.33 - bearing('M', head),
          top: 420.8 - capInset(head),
          child: Staged(animation: e, begin: 0.4, end: 0.7, offset: const Offset(-12, 0), child: Text('Members', style: head)),
        ),
        Positioned(
          left: 336.33 - bearing('S', link),
          top: 423 - capInset(link),
          child: Staged(animation: e, begin: 0.44, end: 0.74, offset: const Offset(12, 0), child: Text('See All', style: link)),
        ),
        Positioned(
          left: 16.7,
          top: 446.5,
          child: Staged(
            animation: e,
            begin: 0.44,
            end: 0.84,
            offset: const Offset(0, 24),
            scale: 0.85,
            curve: settle,
            child: _You(check: check),
          ),
        ),
        for (final (i, m) in crew.indexed) ...[
          Positioned(
            left: m.cx - m.radius,
            top: m.cy - m.radius,
            child: _Pop(
              entrance: e,
              begin: 0.5 + i * 0.07,
              child: SizedBox(
                width: m.radius * 2,
                height: m.radius * 2,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    RingAvatar(
                      asset: Art.avatar(m.photo),
                      radius: m.radius,
                      photo: m.photoRadius,
                      stroke: 1.6,
                      ring: const [Color(0xFFC9D1DC), Color(0xFF8D96A8), Color(0xFF4D5467)],
                    ),
                    Positioned(
                      left: m.radius + 19.4 - 9.2,
                      top: m.radius + 19.4 - 9.2,
                      child: Staged(
                        animation: e,
                        begin: 0.72 + i * 0.05,
                        end: 0.98,
                        scale: 0,
                        curve: settle,
                        child: const TickBadge(size: 18.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: m.cx - 40,
            width: 80,
            top: 523.3 - capInset(name),
            child: Staged(animation: e, begin: 0.58 + i * 0.07, end: 0.86 + i * 0.05, offset: const Offset(0, 8), child: Text(m.name, style: name, textAlign: TextAlign.center)),
          ),
          Positioned(
            left: m.cx - 40,
            width: 80,
            top: 540.0 - capInset(status),
            child: Staged(animation: e, begin: 0.62 + i * 0.07, end: 0.9 + i * 0.05, offset: const Offset(0, 8), child: Text('Checked In', style: status, textAlign: TextAlign.center)),
          ),
        ],
        Positioned(
          left: 351.5 - 27.4,
          top: 483.2 - 27.4,
          child: _Pop(
            entrance: e,
            begin: 0.72,
            child: Pressable(
              onTap: () => HapticFeedback.selectionClick(),
              child: Container(
                width: 54.8,
                height: 54.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF061025),
                  border: Border.all(color: const Color(0xFF545C70), width: 1.4),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(left: 0, right: 0, top: 478.3 - 483.2 + 27.4 - capInset(plus), child: Text('+2', style: plus, textAlign: TextAlign.center)),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 351.5 - 40,
          width: 80,
          top: 523.3 - capInset(more),
          child: Staged(animation: e, begin: 0.78, end: 1, offset: const Offset(0, 8), child: Text('More', style: more, textAlign: TextAlign.center)),
        ),
      ],
    );
  }
}

class _Pop extends StatelessWidget {
  const _Pop({required this.entrance, required this.begin, required this.child});

  final Animation<double> entrance;
  final double begin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entrance,
      builder: (context, inner) {
        final t = span(entrance.value, begin, begin + 0.3, Curves.linear);
        final s = spring(t, bounce: 0.4, freq: 2.6);
        return Opacity(
          opacity: span(entrance.value, begin, begin + 0.08, Curves.linear),
          child: Transform.translate(offset: Offset(0, 22 * (1 - s)), child: Transform.scale(scale: lerp(0.4, 1, s), child: inner)),
        );
      },
      child: child,
    );
  }
}

class TickBadge extends StatelessWidget {
  const TickBadge({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF45E6AC), Color(0xFF22C487)]),
        border: Border.all(color: const Color(0xFF0A1322), width: 2.2),
        boxShadow: const [BoxShadow(color: Color(0x5532D69A), blurRadius: 6)],
      ),
      child: Center(child: PhIcon(Ph.check, size: size * 0.52, color: Colors.white)),
    );
  }
}

class _You extends StatelessWidget {
  const _You({required this.check});

  final Animation<double> check;

  @override
  Widget build(BuildContext context) {
    final you = inter(11.8, 600, color: const Color(0xFFE9AE55));
    final pend = inter(11.4, 400, color: const Color(0xFFA9B0C1));
    final ok = inter(11.4, 400, color: const Color(0xFF3FD29B));
    const ox = 16.7;
    const oy = 446.5;
    return Tick(
      builder: (context, s, _) => AnimatedBuilder(
        animation: check,
        builder: (context, _) {
          final done = span(check.value, 0.3, 0.6, gentle);
          final glow = 0.5 + 0.5 * wave(s, 2.8);
          final warm = Color.lerp(const Color(0xFFE39A3B), const Color(0xFF34D39A), done)!;
          return Container(
            width: 71,
            height: 114.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFF3B2A26), const Color(0xFF14322C), done)!,
                  const Color(0xCC151B28),
                  const Color(0x40101626),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [BoxShadow(color: warm.withValues(alpha: 0.10 + 0.08 * glow), blurRadius: 18)],
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: GradientBoxBorder(
                colors: [Color.lerp(const Color(0xFF5A3F33), const Color(0xFF245A48), done)!, const Color(0x00202838)],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 52.8 - 31.8 - ox,
                  top: 484.8 - 31.8 - oy,
                  child: CustomPaint(
                    foregroundPainter: _Halo(color: warm, seconds: s, glow: glow),
                    child: RingAvatar(
                      asset: Art.avatar('m_you'),
                      radius: 31.8,
                      photo: 28.6,
                      stroke: 2.6,
                      ring: [Color.lerp(const Color(0xFFFFD27E), const Color(0xFF7BF0C4), done)!, warm, Color.lerp(const Color(0xFFB87428), const Color(0xFF1E9C6F), done)!],
                      glow: warm.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                Positioned(
                  left: 71.5 - 10.5 - ox,
                  top: 503 - 10.5 - oy,
                  child: done < 0.5
                      ? Opacity(opacity: 1 - done * 2, child: _Pending(seconds: s))
                      : Transform.scale(scale: spring((done - 0.5) * 2, bounce: 0.5), child: const TickBadge(size: 21)),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 528.9 - oy - capInset(you),
                  child: Text('You', style: you.copyWith(color: Color.lerp(you.color, const Color(0xFF52DDA8), done)), textAlign: TextAlign.center),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 545.6 - oy - capInset(pend),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Opacity(opacity: 1 - done, child: Transform.translate(offset: Offset(0, -8 * done), child: Text('Pending', style: pend, textAlign: TextAlign.center))),
                      Opacity(opacity: done, child: Transform.translate(offset: Offset(0, 8 * (1 - done)), child: Text('Checked In', style: ok, textAlign: TextAlign.center, softWrap: false))),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Pending extends StatelessWidget {
  const _Pending({required this.seconds});

  final double seconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 21,
      height: 21,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF15182A),
        border: Border.all(color: const Color(0xFF0A1020), width: 1.6),
      ),
      child: Center(
        child: Transform.rotate(
          angle: seconds * 3,
          child: CustomPaint(size: const Size(11, 11), painter: _Arc()),
        ),
      ),
    );
  }
}

class _Arc extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawArc(
      rect.deflate(0.8),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(colors: [Color(0x33FFFFFF), Color(0xFFFFFFFF)]).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_Arc old) => false;
}

class _Halo extends CustomPainter {
  _Halo({required this.color, required this.seconds, required this.glow});

  final Color color;
  final double seconds;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    if (seconds == 0) return;
    final c = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: c, radius: size.width / 2 - 1.3);
    canvas.drawCircle(
      c,
      size.width / 2 - 1.3,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..blendMode = BlendMode.plus
        ..shader = SweepGradient(
          colors: const [Color(0x00FFFFFF), Color(0x88FFF3D6), Color(0x00FFFFFF), Color(0x00FFFFFF)],
          stops: const [0.0, 0.08, 0.16, 1.0],
          transform: GradientRotation(seconds * 1.6),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_Halo old) => old.seconds != seconds || old.color != color;
}

class GradientBoxBorder extends BoxBorder {
  const GradientBoxBorder({required this.colors, this.width = 1});

  final List<Color> colors;
  final double width;

  @override
  BorderSide get top => BorderSide.none;

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  bool get isUniform => true;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  ShapeBorder scale(double t) => this;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection, BoxShape shape = BoxShape.rectangle, BorderRadius? borderRadius}) {
    final rr = (borderRadius ?? BorderRadius.zero).toRRect(rect).deflate(width / 2);
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors).createShader(rect),
    );
  }
}
