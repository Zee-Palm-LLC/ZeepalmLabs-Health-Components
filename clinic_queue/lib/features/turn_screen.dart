import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class TurnBackdrop extends StatelessWidget {
  const TurnBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(child: CustomPaint(painter: _TurnBackdropPainter()));
  }
}

class _TurnBackdropPainter extends CustomPainter {
  const _TurnBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          const [Color(0xFF0B4440), Color(0xFF0E5C56), Color(0xFF0F6962)],
          const [0, 0.55, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(_TurnBackdropPainter oldDelegate) => false;
}

class TurnScreen extends StatefulWidget {
  const TurnScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<TurnScreen> createState() => _TurnScreenState();
}

class _TurnScreenState extends State<TurnScreen> with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _waves;
  late final AnimationController _wave;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
    _waves = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _wave = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();
  }

  @override
  void dispose() {
    _enter.dispose();
    _waves.dispose();
    _wave.dispose();
    super.dispose();
  }

  Widget _stage(
    double begin,
    Widget child, {
    Offset offset = const Offset(0, 16),
    double scale = 1,
    Curve curve = Curves.easeOutCubic,
  }) {
    return Staged(
      animation: _enter,
      begin: begin,
      end: begin + 0.5,
      offset: offset,
      scale: scale,
      curve: curve,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shift = CanvasScope.of(context).pin(24);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: RepaintBoundary(child: CustomPaint(painter: _Rings(_waves, _enter))),
        ),
        Positioned(
          left: 123.5,
          top: 80.5,
          width: 145,
          height: 145,
          child: _stage(
            0.05,
            _BellBadge(ring: _waves),
            scale: 0.4,
            offset: Offset.zero,
            curve: Curves.elasticOut,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 243.5,
          child: _stage(
            0.25,
            Center(
              child: Text('GO NOW', style: caps(10.5, color: const Color(0xFF6ED4A6), tracking: 0.2, height: 1.2)),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 266,
          child: _stage(
            0.3,
            Center(
              child: Text(
                "It's your turn, Grace!",
                style: jakarta(31.75, 800, color: Colors.white, spacing: -1.27, height: 1.2),
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          top: 313,
          child: _stage(
            0.35,
            Text(
              'Please go to Room 3 · Dr. Oliver Hayes',
              textAlign: TextAlign.center,
              style: jakarta(14.25, 600, color: const Color(0xFFCFE3DF), spacing: -0.2, height: 22 / 14.25),
            ),
          ),
        ),
        Positioned(
          left: 40,
          top: 380,
          width: 320,
          height: 160,
          child: _stage(0.4, RepaintBoundary(child: CustomPaint(painter: _DoorScene(_wave)))),
        ),
        Positioned(
          left: 247.5,
          top: 385,
          width: 59.5,
          height: 20,
          child: _stage(
            0.55,
            Container(
              decoration: BoxDecoration(color: const Color(0xFFEFF8F5), borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text('Room 3', style: jakarta(11, 800, color: Hue.teal, spacing: -0.2)),
            ),
            scale: 0.6,
            offset: Offset.zero,
            curve: Curves.easeOutBack,
          ),
        ),
        Positioned(
          left: 24.5,
          top: 663 + shift,
          width: 345.5,
          height: 165,
          child: _stage(
            0.45,
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [BoxShadow(color: Color(0x40062B28), blurRadius: 30, offset: Offset(0, 14))],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 19.5,
                    top: 19.5,
                    child: Text(
                      'YOUR TOKEN',
                      style: caps(9.5, color: const Color(0xFF5E7370), tracking: 0.18, height: 11.7 / 9.5),
                    ),
                  ),
                  Positioned(
                    left: 19.5,
                    top: 32,
                    child: Text('A–27', style: jakarta(29.75, 800, spacing: -0.9, height: 1.2)),
                  ),
                  const Positioned(
                    left: 174.5,
                    top: 20,
                    width: 1,
                    height: 50,
                    child: DashedLine(vertical: true, dash: 4, gap: 4, color: Color(0xFFDDE6E3)),
                  ),
                  Positioned(
                    right: 20.5,
                    top: 19.5,
                    child: Text(
                      'CHECKED IN',
                      style: caps(9.5, color: const Color(0xFF5E7370), tracking: 0.18, height: 11.7 / 9.5),
                    ),
                  ),
                  Positioned(
                    right: 20.5,
                    top: 37,
                    child: Text('10:41 AM', style: jakarta(16.75, 800, spacing: -0.5, height: 1.2)),
                  ),
                  Positioned(left: 20.5, top: 85, width: 304.5, child: _CheckIn(onDone: widget.onDone)),
                ],
              ),
            ),
            offset: const Offset(0, 50),
          ),
        ),
      ],
    );
  }
}

class _BellBadge extends StatelessWidget {
  const _BellBadge({required this.ring});

  final Animation<double> ring;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2F6763)),
        ),
        Positioned(
          left: 11.5,
          top: 11.5,
          width: 122,
          height: 122,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 5))],
            ),
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: ring,
              child: const GlyphIcon(Glyph.bell, size: 40, color: Hue.teal, stroke: 2.3),
              builder: (context, child) {
                final v = (ring.value * 2) % 1.0;
                final swing = v < 0.3 ? math.sin(v / 0.3 * math.pi * 4) * (1 - v / 0.3) * 0.35 : 0.0;
                return Transform.rotate(angle: swing, alignment: const Alignment(0, -0.85), child: child);
              },
            ),
          ),
        ),
        Positioned(
          left: 86.5,
          top: 82.5,
          width: 45,
          height: 45,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22C55E),
              border: Border.all(color: const Color(0xFF0D4F4A), width: 3.5),
            ),
            alignment: Alignment.center,
            child: const GlyphIcon(Glyph.check, size: 16, color: Colors.white, stroke: 3),
          ),
        ),
      ],
    );
  }
}

class _Rings extends CustomPainter {
  _Rings(this.waves, this.enter) : super(repaint: Listenable.merge([waves, enter]));

  final Animation<double> waves;
  final Animation<double> enter;

  static const _confetti = [
    (Offset(48, 115.5), Color(0xFFF08A3C), 3.1, false, 0.0),
    (Offset(135, 91), Color(0xFF8FA9A5), 2.3, false, 0.0),
    (Offset(322.5, 101), Color(0xFFFBBF24), 4.6, true, 0.35),
    (Offset(300, 174), Color(0xFFF08A3C), 3.9, true, 0.2),
    (Offset(79, 234.5), Color(0xFF4ADE80), 3.1, false, 0.0),
    (Offset(343, 261), Color(0xFF8FA9A5), 2.8, false, 0.0),
    (Offset(34.5, 304), Color(0xFF6A8F8A), 4.1, true, 0.6),
    (Offset(250, 124), Color(0xFFE8F4F0), 1.6, false, 0.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const c = Offset(196.5, 153);
    final e = enter.value;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final (r, alpha) in const [(131.0, 0.16), (196.0, 0.12), (262.0, 0.09), (330.0, 0.06)]) {
      final grow = Curves.easeOutCubic.transform(span(e, 0, 0.8));
      canvas.drawCircle(c, r * (0.6 + 0.4 * grow), line..color = Color.fromRGBO(190, 230, 220, alpha * grow));
    }
    final t = waves.value;
    for (var k = 0; k < 2; k++) {
      final p = (t + k * 0.5) % 1.0;
      canvas.drawCircle(
        c,
        72 + p * 190,
        line
          ..strokeWidth = 1.6
          ..color = Color.fromRGBO(120, 220, 180, 0.22 * (1 - p)),
      );
    }
    final pop = span(e, 0.3, 0.9, Curves.easeOutBack);
    for (final (i, (at, color, r, square, angle)) in _confetti.indexed) {
      final drift = Offset(0, math.sin(t * math.pi * 2 + i) * 3);
      canvas.save();
      canvas.translate(at.dx + drift.dx, at.dy + drift.dy);
      canvas.scale(pop.clamp(0.0, 1.3));
      final paint = Paint()..color = color;
      if (square) {
        canvas.rotate(angle + t * math.pi * 2 * (i.isEven ? 0.25 : -0.25));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 2),
            const Radius.circular(1.2),
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, r, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_Rings oldDelegate) => false;
}

class _DoorScene extends CustomPainter {
  _DoorScene(this.wave) : super(repaint: wave);

  final Animation<double> wave;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(-40, -380);
    canvas.drawOval(const Rect.fromLTRB(60, 496, 330, 526), Paint()..color = const Color(0xFF0A4541));
    final floor = Path()
      ..moveTo(230, 510)
      ..lineTo(300, 510)
      ..lineTo(344, 525)
      ..lineTo(180, 525)
      ..close();
    canvas.drawPath(floor, Paint()..color = const Color(0xFF4F7A68));

    canvas.drawRRect(
      RRect.fromLTRBR(213, 400, 227, 511, const Radius.circular(7)),
      Paint()..color = const Color(0xFF0B4A45),
    );

    final door = RRect.fromLTRBAndCorners(
      231.5,
      398,
      292,
      510,
      topLeft: const Radius.circular(30.25),
      topRight: const Radius.circular(30.25),
    );
    canvas.drawRRect(door.inflate(3), Paint()..color = const Color(0xFF0A3F3B));
    canvas.drawRRect(
      door,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(0, 398), const Offset(0, 510), const [
          Color(0xFFFEE7C2),
          Color(0xFFFCD9A8),
        ]),
    );
    canvas.drawCircle(const Offset(240.5, 468), 3.8, Paint()..color = const Color(0xFF0F766E));

    void bush(Offset c, double r, Color top, Color base) {
      canvas.drawRRect(
        RRect.fromLTRBR(c.dx - r * 0.45, c.dy, c.dx + r * 0.45, c.dy + r * 1.35, const Radius.circular(4)),
        Paint()..color = base,
      );
      canvas.drawCircle(c, r, Paint()..color = top);
    }

    bush(const Offset(74.5, 484.5), 15.5, const Color(0xFF148A80), const Color(0xFF0C4F4A));
    bush(const Offset(329, 486), 17.5, const Color(0xFF16877D), const Color(0xFF0C4F4A));
    canvas.drawCircle(const Offset(329, 478), 11, Paint()..color = const Color(0xFF1E9A8F));

    final w = math.sin(wave.value * math.pi * 2);
    const person = Offset(149.5, 455);
    final body = RRect.fromLTRBAndCorners(
      person.dx - 16,
      person.dy + 7,
      person.dx + 16,
      person.dy + 52,
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFFF8C3F));
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      Rect.fromLTRB(person.dx - 17, person.dy + 38, person.dx + 17, person.dy + 53),
      Paint()..color = const Color(0xFFEB7422),
    );
    canvas.restore();
    canvas.drawCircle(person + const Offset(-7, 16), 4, Paint()..color = const Color(0x40FFFFFF));

    canvas.save();
    canvas.translate(person.dx + 10, person.dy + 16);
    canvas.rotate(-0.95 + w * 0.18);
    canvas.drawRRect(
      RRect.fromLTRBR(-4.5, -4.5, 30, 4.5, const Radius.circular(4.5)),
      Paint()..color = const Color(0xFFFF8C3F),
    );
    canvas.drawCircle(const Offset(31, 0), 6, Paint()..color = const Color(0xFFF6D3B8));
    canvas.restore();

    canvas.drawRRect(
      RRect.fromLTRBR(person.dx - 15, person.dy - 12, person.dx - 9, person.dy + 15, const Radius.circular(3)),
      Paint()..color = const Color(0xFF4A2A1C),
    );
    canvas.drawCircle(person + const Offset(0, -2), 14, Paint()..color = const Color(0xFFF6D3B8));
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(person.dx - 15, person.dy - 17, person.dx + 15, person.dy - 3));
    canvas.drawCircle(person + const Offset(0, -2), 14.3, Paint()..color = const Color(0xFF4A2A1C));
    canvas.restore();

    final burst = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF6ED4A6).withValues(alpha: 0.6 + 0.4 * w.abs());
    final lift = w * 1.5;
    canvas.drawArc(Rect.fromCircle(center: Offset(185, 441 + lift), radius: 12), -1.25, 0.8, false, burst);
    canvas.drawArc(Rect.fromCircle(center: Offset(185, 441 + lift), radius: 12), 0.45, 0.7, false, burst);
  }

  @override
  bool shouldRepaint(_DoorScene oldDelegate) => false;
}

class _CheckIn extends StatefulWidget {
  const _CheckIn({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<_CheckIn> {
  bool _here = false;

  @override
  Widget build(BuildContext context) {
    return TealButton(
      label: _here ? 'Checked in' : "I'm here",
      leading: Glyph.check,
      height: 59,
      halo: false,
      onTap: () {
        if (_here) return;
        setState(() => _here = true);
        widget.onDone();
      },
    );
  }
}
