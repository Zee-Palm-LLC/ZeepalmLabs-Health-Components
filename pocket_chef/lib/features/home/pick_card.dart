import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/art.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/type.dart';

class PickCard extends StatefulWidget {
  const PickCard({super.key, required this.entrance, required this.onOpen});

  static const rect = Rect.fromLTRB(18.3, 239.6, 377.3, 422.8);
  static const radius = 20.0;

  final Animation<double> entrance;
  final VoidCallback onOpen;

  @override
  State<PickCard> createState() => _PickCardState();
}

class _PickCardState extends State<PickCard> with TickerProviderStateMixin {
  late final AnimationController _x;
  late final AnimationController _y;

  @override
  void initState() {
    super.initState();
    _x = AnimationController.unbounded(vsync: this);
    _y = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _x.dispose();
    _y.dispose();
    super.dispose();
  }

  void _drag(DragUpdateDetails d) {
    _x.value = (_x.value + d.delta.dx / 160).clamp(-1.0, 1.0);
    _y.value = (_y.value + d.delta.dy / 90).clamp(-1.0, 1.0);
  }

  void _release([DragEndDetails? _]) {
    const sim = SpringDescription(mass: 1, stiffness: 180, damping: 11);
    _x.animateWith(SpringSimulation(sim, _x.value, 0, 0));
    _y.animateWith(SpringSimulation(sim, _y.value, 0, 0));
  }

  @override
  Widget build(BuildContext context) {
    final r = PickCard.rect;
    final e = widget.entrance;
    final pick = inter(15.57, 400, color: const Color(0xFFFFD4D9));
    final title = inter(22.8, 700, color: const Color(0xFFFFF2F4));
    final minutes = inter(14.3, 400, color: const Color(0xFFFFD6D8));
    final view = inter(12.13, 600, color: const Color(0xFF191721));

    Widget at(double dx, Widget child) => AnimatedBuilder(
      animation: Listenable.merge([_x, _y]),
      builder: (context, c) => Transform.translate(offset: Offset(_x.value * dx, _y.value * dx * 0.6), child: c),
      child: child,
    );

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(PickCard.radius),
      child: SizedBox(
        width: r.width,
        height: r.height,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFDE1B29), Color(0xFFF82C3A), Color(0xFFED1D30)],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -6,
              top: -6,
              width: r.width + 12,
              height: r.height + 12,
              child: at(-4, Image.asset(Art.pickPlate.asset, fit: BoxFit.fill, filterQuality: FilterQuality.medium)),
            ),
            Positioned.fill(child: at(-2, const _Clouds())),
            Positioned(
              left: Art.pickMascot.left - r.left,
              top: Art.pickMascot.top - r.top,
              width: Art.pickMascot.width,
              height: Art.pickMascot.height,
              child: at(7, _Mascot(entrance: e)),
            ),
            Positioned.fill(
              child: IgnorePointer(child: at(9, _Sparks(entrance: e))),
            ),
            Positioned.fill(
              child: at(
                3,
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _Slide(
                      e: e,
                      begin: 0.46,
                      dx: -24,
                      child: Stack(
                        children: [Pin(x: 35 - r.left, base: 271.33 - r.top, text: "Today's Pick", style: pick)],
                      ),
                    ),
                    _Slide(
                      e: e,
                      begin: 0.5,
                      dx: -30,
                      child: Stack(
                        children: [
                          Pin(x: 35.1 - r.left, base: 302.7 - r.top, text: 'Quick & Tasty', style: title),
                          Pin(x: 35.6 - r.left, base: 329.0 - r.top, text: 'Pasta', style: title),
                        ],
                      ),
                    ),
                    _Slide(
                      e: e,
                      begin: 0.56,
                      dx: -24,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 42.1 - r.left - 9,
                            top: 349.7 - r.top - 9,
                            child: const PhIcon(Ph.clock, size: 18, color: Color(0xFFFFD6D8)),
                          ),
                          Pin(x: 59 - r.left, base: 355 - r.top, text: '20 min', style: minutes),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 33.3 - r.left,
                      top: 373.3 - r.top,
                      child: AnimatedBuilder(
                        animation: e,
                        builder: (context, child) {
                          final raw = ((e.value - 0.6) / 0.3).clamp(0.0, 1.0);
                          final s = spring(raw, bounce: 0.5, freq: 2.6);
                          return Opacity(
                            opacity: (raw * 4).clamp(0.0, 1.0),
                            child: Transform.scale(scale: s, child: child),
                          );
                        },
                        child: Pressable(
                          onTap: widget.onOpen,
                          child: Container(
                            width: 125,
                            height: 36.7,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDFCFB),
                              borderRadius: BorderRadius.circular(18.35),
                              boxShadow: const [BoxShadow(color: Color(0x40780010), blurRadius: 12, offset: Offset(0, 5))],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Pin(x: 51 - 33.3, base: 397.33 - 373.3, text: 'View Recipe', style: view),
                                Positioned(
                                  left: 139.3 - 33.3 - 10,
                                  top: 391.9 - 373.3 - 10,
                                  child: Tick(
                                    builder: (context, s, child) {
                                      final k = math.pow((math.sin(s * math.pi * 2 / 1.5) + 1) / 2, 3).toDouble();
                                      return Transform.translate(offset: Offset(2.4 * k, 0), child: child);
                                    },
                                    child: const PhIcon(Ph.arrowRightBold, size: 20, color: Color(0xFF191721)),
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
              ),
            ),
          ],
        ),
      ),
    );

    return AnimatedBuilder(
      animation: e,
      builder: (context, child) {
        final t = span(e.value, 0.3, 0.72, gentle);
        final m = Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..translateByDouble(0, 50 * (1 - t), 0, 1)
          ..rotateX(0.55 * (1 - t));
        return Opacity(
          opacity: span(e.value, 0.3, 0.45, Curves.linear),
          child: Transform(alignment: Alignment.center, transform: m, child: child),
        );
      },
      child: GestureDetector(
        onTap: widget.onOpen,
        onPanUpdate: _drag,
        onPanEnd: _release,
        onPanCancel: _release,
        child: AnimatedBuilder(
          animation: Listenable.merge([_x, _y]),
          builder: (context, child) {
            final m = Matrix4.identity()
              ..setEntry(3, 2, 0.0011)
              ..rotateY(_x.value * 0.2)
              ..rotateX(-_y.value * 0.16);
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PickCard.radius),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8192F).withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: Offset(-_x.value * 6, 8 - _y.value * 4),
                  ),
                ],
              ),
              child: Transform(alignment: Alignment.center, transform: m, child: child),
            );
          },
          child: card,
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.e, required this.begin, required this.dx, required this.child});

  final Animation<double> e;
  final double begin;
  final double dx;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Staged(animation: e, begin: begin, end: begin + 0.3, offset: Offset(dx, 0), child: child),
    );
  }
}

class _Mascot extends StatelessWidget {
  const _Mascot({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entrance,
      builder: (context, child) {
        final raw = ((entrance.value - 0.42) / 0.42).clamp(0.0, 1.0);
        final s = spring(raw, bounce: 0.4, freq: 2.3);
        return Transform.translate(
          offset: Offset(0, 150 * (1 - s)),
          child: Transform.rotate(angle: 0.25 * (1 - s), alignment: Alignment.bottomCenter, child: child),
        );
      },
      child: Tick(
        builder: (context, s, child) => Transform.translate(
          offset: Offset(0, 2.4 * wave(s, 3.6)),
          child: Transform.rotate(angle: 0.014 * wave(s, 4.8, 0.3), alignment: Alignment.bottomCenter, child: child),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: Art.pickMascot.image()),
            const Positioned(left: 88, top: 82, width: 90, height: 70, child: _Steam()),
          ],
        ),
      ),
    );
  }
}

class _Steam extends StatelessWidget {
  const _Steam();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Tick(builder: (context, s, _) => CustomPaint(painter: _SteamPainter(s))),
    );
  }
}

class _SteamPainter extends CustomPainter {
  _SteamPainter(this.seconds);

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      final u = (seconds / 2.6 + i / 4) % 1.0;
      final x = size.width * (0.28 + 0.16 * i);
      final y = size.height * (1 - u);
      final a = math.sin(u * math.pi) * 0.34;
      final path = Path()..moveTo(x, y + 18);
      final sway = math.sin((seconds * 1.3 + i) * 1.7) * 5;
      path.cubicTo(x - 7 + sway, y + 10, x + 7 + sway, y + 2, x + sway * 0.6, y - 10);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2 * (1 - u * 0.5)
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: a)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2),
      );
    }
  }

  @override
  bool shouldRepaint(_SteamPainter old) => old.seconds != seconds;
}

class _Clouds extends StatelessWidget {
  const _Clouds();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Tick(builder: (context, s, _) => CustomPaint(painter: _CloudPainter(s))),
    );
  }
}

class _CloudPainter extends CustomPainter {
  _CloudPainter(this.seconds);

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final blobs = [
      (const Offset(196, 150), 46.0, 0.13, 9.0),
      (const Offset(238, 176), 40.0, 0.11, 11.0),
      (const Offset(150, 186), 34.0, 0.08, 13.0),
      (const Offset(300, 40), 60.0, 0.06, 15.0),
    ];
    for (final (i, (c, r, a, period)) in blobs.indexed) {
      final drift = Offset(6 * math.sin(seconds / period * math.pi * 2 + i), 3 * math.cos(seconds / period * math.pi * 2 + i));
      final center = c + drift;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: a),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_CloudPainter old) => old.seconds != seconds;
}

class _Sparks extends StatelessWidget {
  const _Sparks({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entrance,
      builder: (context, _) {
        final grow = span(entrance.value, 0.7, 0.95, Curves.easeOutBack);
        return Tick(builder: (context, s, _) => CustomPaint(painter: _SparkPainter(grow, s)));
      },
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.grow, this.seconds);

  final double grow;
  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    if (grow <= 0) return;
    const o = Offset(18.3, 239.6);
    final beat = math.pow(math.max(0.0, math.sin(seconds / 2.8 * math.pi * 2)), 6).toDouble();
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    void dash(Offset a, Offset b, Offset away) {
      final mid = (a + b) / 2 - o + away * (2.5 * beat);
      final half = (b - a) * (grow * (1 + 0.15 * beat)) / 2;
      canvas.drawLine(mid - half, mid + half, paint);
    }

    dash(const Offset(346.9, 272.4), const Offset(352.2, 260.3), const Offset(0.6, -0.8));
    dash(const Offset(355.4, 278.6), const Offset(362.6, 275.0), const Offset(0.9, -0.4));
    dash(const Offset(204.4, 299.4), const Offset(214.9, 308.2), const Offset(-0.8, -0.6));
    dash(const Offset(200.6, 320.2), const Offset(212.8, 319.6), const Offset(-1, 0));
    dash(const Offset(190.6, 373.6), const Offset(195.2, 378.4), const Offset(-0.7, 0.7));

    final star = const Offset(334.2, 263.2) - o;
    final k = 6.2 * grow * (1 + 0.25 * beat);
    canvas.save();
    canvas.translate(star.dx, star.dy);
    canvas.rotate(0.3 + seconds * 0.4);
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final rad = i.isEven ? k : k * 0.42;
      final ang = i * math.pi / 4;
      final p = Offset(math.cos(ang) * rad, math.sin(ang) * rad);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.95));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.grow != grow || old.seconds != seconds;
}
