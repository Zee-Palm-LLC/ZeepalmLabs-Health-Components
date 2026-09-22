import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../data/visit.dart';

class LiveLine extends StatefulWidget {
  const LiveLine({super.key, required this.sim});

  final QueueSim sim;

  @override
  State<LiveLine> createState() => _LiveLineState();
}

class _LiveLineState extends State<LiveLine> with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _march;
  late final AnimationController _step;
  late final AnimationController _pop;
  late final AnimationController _toast;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _march = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
    _step = AnimationController(vsync: this, duration: const Duration(milliseconds: 2100));
    _pop = AnimationController(vsync: this, duration: const Duration(milliseconds: 650), value: 1);
    _toast = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
    widget.sim.addListener(_changed);
    _schedule(const Duration(milliseconds: 3600));
  }

  bool _busy = false;

  void _changed() {
    if (_busy || (_timer?.isActive ?? false)) return;
    _schedule(const Duration(milliseconds: 4200));
  }

  void _schedule(Duration delay) {
    _timer?.cancel();
    if (widget.sim.next) return;
    _timer = Timer(delay, _advance);
  }

  Future<void> _advance() async {
    if (!mounted || widget.sim.next) return;
    _busy = true;
    _toast.forward(from: 0);
    final walked = _step.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 1350));
    if (!mounted) return;
    _pop.forward(from: 0);
    await walked;
    if (!mounted) return;
    widget.sim.advance();
    _step.value = 0;
    _busy = false;
    _schedule(const Duration(milliseconds: 5200));
  }

  @override
  void dispose() {
    widget.sim.removeListener(_changed);
    _timer?.cancel();
    _idle.dispose();
    _march.dispose();
    _step.dispose();
    _pop.dispose();
    _toast.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _LinePainter(sim: widget.sim, idle: _idle, march: _march, step: _step, pop: _pop),
            ),
          ),
        ),
        Positioned(
          left: 16,
          top: 16,
          child: Text(
            'THE LINE',
            style: caps(9.5, color: const Color(0xFF3F5553), tracking: 0.16, height: 12 / 9.5),
          ),
        ),
        Positioned(right: 9.5, top: 5.5, child: _RoomPill(ping: _toast)),
        Positioned(
          left: 0,
          right: 0,
          top: 12,
          child: IgnorePointer(
            child: _Toast(animation: _toast, sim: widget.sim),
          ),
        ),
      ],
    );
  }
}

class _RoomPill extends StatelessWidget {
  const _RoomPill({required this.ping});

  final Animation<double> ping;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ping,
      child: Container(
        width: 67.5,
        height: 24,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF19A393), Color(0xFF0F766E)]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x3314B8A6), blurRadius: 8, offset: Offset(0, 3))],
        ),
        alignment: Alignment.center,
        child: Text('Room 3', style: jakarta(12, 800, color: Colors.white, spacing: -0.2)),
      ),
      builder: (context, child) {
        final t = span(ping.value, 0.0, 0.35);
        final bump = math.sin(math.pi * t);
        return Transform.scale(scale: 1 + bump * 0.12, child: child);
      },
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast({required this.animation, required this.sim});

  final Animation<double> animation;
  final QueueSim sim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final v = animation.value;
        if (v <= 0 || v >= 1) return const SizedBox.shrink();
        final inT = Curves.easeOutBack.transform(span(v, 0, 0.18));
        final out = span(v, 0.78, 1, Curves.easeIn);
        return Center(
          child: Opacity(
            opacity: (inT.clamp(0.0, 1.0) * (1 - out)).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, -12 * (1 - inT) - 8 * out),
              child: Container(
                padding: const EdgeInsets.fromLTRB(9, 5, 11, 5),
                decoration: BoxDecoration(
                  color: Hue.ink,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Color(0x330F3B3A), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Hue.green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Now serving A–${sim.serving + 1}',
                      style: jakarta(10.5, 800, color: Colors.white, spacing: -0.1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Look {
  const _Look(this.body, this.shade, this.hair, this.skin);

  final Color body;
  final Color shade;
  final Color hair;
  final Color skin;
}

const _looks = [
  _Look(Color(0xFFDDEBE7), Color(0xFFC6DDD6), Color(0xFF3A2A22), Color(0xFFF1CBA9)),
  _Look(Color(0xFFF2C5C6), Color(0xFFE6AEB0), Color(0xFF3A2A22), Color(0xFFF1BE93)),
  _Look(Color(0xFFC3DDB8), Color(0xFFAFCFA2), Color(0xFF5A3A28), Color(0xFFF1BE93)),
  _Look(Color(0xFFF3DCC2), Color(0xFFE8C9A8), Color(0xFF2A1D18), Color(0xFFB27A57)),
  _Look(Color(0xFFC9E3DB), Color(0xFFB3D6CB), Color(0xFF3A2A22), Color(0xFFF1BE93)),
  _Look(Color(0xFFD6D5F2), Color(0xFFC0BFE8), Color(0xFF3A2418), Color(0xFFE8B48A)),
  _Look(Color(0xFFBFE3EE), Color(0xFFA6D4E3), Color(0xFF4A2E22), Color(0xFFF6D3B8)),
];

class _LinePainter extends CustomPainter {
  _LinePainter({required this.sim, required this.idle, required this.march, required this.step, required this.pop})
    : super(repaint: Listenable.merge([sim, idle, march, step, pop]));

  final QueueSim sim;
  final Animation<double> idle;
  final Animation<double> march;
  final Animation<double> step;
  final Animation<double> pop;

  static final Path _path = Path()
    ..moveTo(-24, 250)
    ..cubicTo(40, 246, 78, 214, 128, 196)
    ..cubicTo(170, 181, 200, 177, 238, 162)
    ..cubicTo(268, 150, 290, 144, 313, 143);

  static final ui.PathMetric _metric = _path.computeMetrics().first;
  static final List<double> _slots = [
    for (final x in const [313.0, 280.0, 238.0, 188.0, 132.0, 62.0]) _distanceAtX(x),
  ];
  static const _door = Rect.fromLTRB(293, 74.2, 333, 146.5);

  static double _distanceAtX(double x) {
    var lo = 0.0;
    var hi = _metric.length;
    for (var i = 0; i < 40; i++) {
      final mid = (lo + hi) / 2;
      if (_metric.getTangentForOffset(mid)!.position.dx < x) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return (lo + hi) / 2;
  }

  static Offset _at(double d) {
    if (d >= 0) return _metric.getTangentForOffset(math.min(d, _metric.length))!.position;
    final start = _metric.getTangentForOffset(0)!;
    return start.position + start.vector * d;
  }

  static double _depth(Offset p) => lerp(1.06, 0.8, ((250 - p.dy) / 110).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final t = step.value;
    final clock = idle.value * math.pi * 2;
    _floor(canvas, size, clock);
    _road(canvas);
    final open = _doorOpen(t);
    _doorway(canvas, open, clock);

    final people = <_Figure>[];
    final serving = sim.serving;
    final entering = span(t, 0.05, 0.5, Curves.easeInOut);
    if (entering < 1) {
      final from = _at(_slots[0]);
      final into = from + Offset(6 * entering, -5 * entering);
      people.add(
        _Figure(
          at: into,
          look: _looks[serving % _looks.length],
          scale: _depth(from) * lerp(1, 0.86, entering),
          alpha: 1 - span(entering, 0.45, 1),
          bob: _hop(entering) * 0.6,
          label: null,
          you: false,
          clip: entering > 0.2,
        ),
      );
    }
    for (var k = 1; k <= 6; k++) {
      final id = serving + k;
      final begin = 0.28 + (k - 1) * 0.06;
      final move = span(t, begin, math.min(begin + 0.55, 1), Curves.easeInOutCubic);
      final fromD = k <= 5 ? _slots[k] : _slots[5] - 70;
      final toD = _slots[k - 1];
      final d = lerp(fromD, toD, move);
      final p = _at(d);
      final isYou = id == QueueSim.you;
      people.add(
        _Figure(
          at: p,
          look: _looks[id % _looks.length],
          scale: _depth(p),
          alpha: k == 6 ? span(move, 0, 0.35) : 1,
          bob: _hop(move) + (move == 0 || move == 1 ? math.sin(clock * 2 + k) * 0.6 + 0.6 : 0),
          tilt: math.sin(move * math.pi * 6) * 0.05 * (move > 0 && move < 1 ? 1 : 0),
          label: k == 1 && move > 0.6 ? null : 'A–$id',
          you: isYou,
          walking: move > 0 && move < 1,
        ),
      );
    }
    people.sort((a, b) => a.at.dy.compareTo(b.at.dy));
    for (final f in people) {
      _shadow(canvas, f);
    }
    for (final f in people) {
      if (f.clip) {
        canvas.save();
        canvas.clipRRect(
          RRect.fromRectAndCorners(
            _door.deflate(2.6),
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
          ),
        );
        _figure(canvas, f, clock);
        canvas.restore();
      } else {
        _figure(canvas, f, clock);
      }
    }
    for (final f in people) {
      if (f.you) {
        _youBubble(canvas, f, t);
      } else if (f.label != null && f.alpha > 0.5 && !f.clip) {
        _tag(canvas, f);
      }
    }
    _motes(canvas, clock, open);
  }

  double _doorOpen(double t) {
    final opening = span(t, 0.0, 0.2, Curves.easeOut);
    final closing = span(t, 0.55, 0.8, Curves.easeInOut);
    return (opening - closing).clamp(0.0, 1.0);
  }

  double _hop(double move) {
    if (move <= 0 || move >= 1) return 0;
    return (math.sin(move * math.pi * 6)).abs() * 3.2;
  }

  void _floor(Canvas canvas, Size size, double clock) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), const [
          Color(0xFFFCFEFD),
          Color(0xFFE6F4EF),
        ]),
    );
    final drift = math.sin(clock) * 4;
    canvas.drawOval(Rect.fromLTRB(11.5 + drift, 33, 145 + drift, 95), Paint()..color = const Color(0xFFE6F6F2));
    canvas.drawOval(Rect.fromLTRB(193 - drift, 195.5, 346.5 - drift, 255), Paint()..color = const Color(0xFFE0F2EC));
    canvas.drawOval(const Rect.fromLTRB(250, 5, 360, 38), Paint()..color = const Color(0xFFDDF2EE));
    canvas.drawRRect(
      RRect.fromLTRBR(264, 34.3, 360, 43.3, const Radius.circular(4.5)),
      Paint()..color = const Color(0xFFDDEEEA),
    );
    final plus = Paint()
      ..color = Hue.orange
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(311, 38.75), const Offset(317.5, 38.75), plus);
    canvas.drawLine(const Offset(314.25, 35.5), const Offset(314.25, 42), plus);
  }

  void _road(Canvas canvas) {
    canvas.drawPath(
      _path.shift(const Offset(0, 5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x1A0F3B3A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      _path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 27
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFD5EBE4),
    );
    canvas.drawPath(
      _path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFBFEFD),
    );
    final flow = march.value * 18;
    final chevron = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (var d = 6 + flow; d < _metric.length - 14; d += 18) {
      final tangent = _metric.getTangentForOffset(d)!;
      final p = tangent.position;
      final dir = tangent.vector;
      final normal = Offset(-dir.dy, dir.dx);
      final fade = (d / 60).clamp(0.0, 1.0) * (1 - ((d - _metric.length + 60) / 50).clamp(0.0, 1.0));
      chevron.color = const Color(0xFF6CC4B3).withValues(alpha: 0.75 * fade);
      final tip = p + dir * 2.4;
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx - dir.dx * 4 + normal.dx * 3.2, tip.dy - dir.dy * 4 + normal.dy * 3.2)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(tip.dx - dir.dx * 4 - normal.dx * 3.2, tip.dy - dir.dy * 4 - normal.dy * 3.2),
        chevron,
      );
    }
  }

  void _doorway(Canvas canvas, double open, double clock) {
    final glow = 0.35 + 0.55 * open + 0.08 * math.sin(clock * 2);
    final centre = _door.center + const Offset(0, 6);
    canvas.drawCircle(
      centre,
      72,
      Paint()
        ..shader = ui.Gradient.radial(centre, 72, [Color.fromRGBO(255, 214, 160, 0.5 * glow), const Color(0x00FFD6A0)]),
    );
    final cone = Path()
      ..moveTo(_door.left + 3, _door.bottom)
      ..lineTo(_door.right - 3, _door.bottom)
      ..lineTo(_door.right + 26, _door.bottom + 24)
      ..lineTo(_door.left - 40, _door.bottom + 24)
      ..close();
    canvas.drawPath(
      cone,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, _door.bottom), Offset(0, _door.bottom + 24), [
          Color.fromRGBO(248, 223, 180, 0.55 + 0.4 * open),
          const Color(0x00F8DFB4),
        ]),
    );
    final frame = RRect.fromRectAndCorners(
      _door,
      topLeft: const Radius.circular(20.75),
      topRight: const Radius.circular(20.75),
    );
    canvas.drawRRect(frame, Paint()..color = const Color(0xFF0F3B3A));
    final inner = frame.deflate(2.6);
    canvas.drawRRect(
      inner,
      Paint()
        ..shader = ui.Gradient.linear(inner.outerRect.topCenter, inner.outerRect.bottomCenter, const [
          Color(0xFFFFF4DE),
          Color(0xFFFCE3B8),
        ]),
    );
    if (open < 1) {
      canvas.save();
      canvas.clipRRect(inner);
      final w = inner.width * (1 - open * 0.82);
      final panel = Rect.fromLTWH(inner.left, inner.top, w, inner.height);
      canvas.drawRect(
        panel,
        Paint()
          ..shader = ui.Gradient.linear(panel.topLeft, panel.topRight, const [Color(0xFFF7D4A2), Color(0xFFF2C68D)]),
      );
      canvas.drawRect(
        Rect.fromLTWH(panel.right - 1.2, panel.top, 1.2, panel.height),
        Paint()..color = const Color(0x33000000),
      );
      canvas.drawCircle(
        Offset(panel.right - 7 * (1 - open), panel.center.dy + 6),
        2.4 * (1 - open * 0.6),
        Paint()..color = Hue.teal,
      );
      canvas.restore();
    }
  }

  void _shadow(Canvas canvas, _Figure f) {
    if (f.alpha <= 0.02 || f.clip) return;
    final lift = f.bob;
    canvas.drawOval(
      Rect.fromCenter(center: f.at + const Offset(0, 1), width: 30 * f.scale * (1 - lift / 20), height: 7 * f.scale),
      Paint()..color = Color.fromRGBO(15, 59, 58, 0.14 * f.alpha),
    );
    if (f.you) {
      canvas.drawOval(
        Rect.fromCenter(center: f.at + const Offset(0, 2), width: 50 * f.scale, height: 12 * f.scale),
        Paint()..color = Color.fromRGBO(255, 154, 92, 0.25 * f.alpha),
      );
    }
  }

  void _figure(Canvas canvas, _Figure f, double clock) {
    if (f.alpha <= 0.01) return;
    canvas.save();
    canvas.translate(f.at.dx, f.at.dy - f.bob);
    canvas.rotate(f.tilt);
    canvas.scale(f.scale);
    if (f.alpha < 1) {
      canvas.saveLayer(const Rect.fromLTRB(-40, -70, 40, 10), Paint()..color = Color.fromRGBO(0, 0, 0, f.alpha));
    }
    if (f.you) {
      final pulse = (idle.value * 2) % 1.0;
      canvas.drawCircle(
        const Offset(0, -22),
        30 + 3 * math.sin(clock * 2),
        Paint()..shader = ui.Gradient.radial(const Offset(0, -22), 33, const [Color(0x55FFB27A), Color(0x00FFB27A)]),
      );
      canvas.drawCircle(
        const Offset(0, -18),
        16 + pulse * 22,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = Color.fromRGBO(255, 138, 61, 0.45 * (1 - pulse)),
      );
      if (f.walking) {
        final speed = Paint()
          ..color = const Color(0xFFFFA06A)
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(-38, -18), const Offset(-26, -18), speed);
        canvas.drawLine(const Offset(-41, -8), const Offset(-30, -8), speed);
        canvas.drawLine(const Offset(-35, 2), const Offset(-24, 2), speed);
      }
      final body = RRect.fromLTRBAndCorners(
        -14,
        -32,
        14,
        0,
        topLeft: const Radius.circular(14),
        topRight: const Radius.circular(14),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      );
      canvas.drawRRect(body, Paint()..color = const Color(0xFFFF9447));
      canvas.save();
      canvas.clipRRect(body);
      canvas.drawRect(const Rect.fromLTRB(-14, -13, 14, 0), Paint()..color = const Color(0xFFF07B26));
      canvas.restore();
      canvas.drawCircle(const Offset(-6, -24), 3, Paint()..color = const Color(0x40FFFFFF));
      canvas.drawRRect(
        RRect.fromLTRBR(-12.5, -52, -7.5, -28, const Radius.circular(2.5)),
        Paint()..color = const Color(0xFF3A2418),
      );
      _head(canvas, const Offset(0, -46), const Color(0xFFF6D3B8), const Color(0xFF3A2418));
    } else {
      final breathe = f.walking ? 0.0 : math.sin(clock * 2 + f.at.dx) * 0.6;
      final body = RRect.fromLTRBAndCorners(
        -11.75,
        -31 - breathe,
        11.75,
        0,
        topLeft: const Radius.circular(11.75),
        topRight: const Radius.circular(11.75),
        bottomLeft: const Radius.circular(8),
        bottomRight: const Radius.circular(8),
      );
      canvas.drawRRect(body, Paint()..color = f.look.body);
      canvas.save();
      canvas.clipRRect(body);
      canvas.drawRect(const Rect.fromLTRB(-12, -10, 12, 0), Paint()..color = f.look.shade);
      canvas.restore();
      canvas.drawCircle(Offset(-5, -24 - breathe), 3, Paint()..color = const Color(0x55FFFFFF));
      _head(canvas, Offset(0, -40 - breathe), f.look.skin, f.look.hair);
    }
    if (f.alpha < 1) canvas.restore();
    canvas.restore();
  }

  void _head(Canvas canvas, Offset c, Color skin, Color hair) {
    canvas.drawCircle(c, 11, Paint()..color = skin);
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(c.dx - 12, c.dy - 12, c.dx + 12, c.dy - 0.5));
    canvas.drawCircle(c, 11.2, Paint()..color = hair);
    canvas.restore();
  }

  void _tag(Canvas canvas, _Figure f) {
    final centre = Offset(f.at.dx, f.at.dy - f.bob - 67 * f.scale);
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: centre, width: 33.5, height: 18),
      const Radius.circular(9),
    );
    canvas.drawRRect(
      r.shift(const Offset(0, 1.5)),
      Paint()
        ..color = const Color(0x140F3B3A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0xFFFFFFFF));
    _text(canvas, f.label!, centre, jakarta(9.5, 800, color: const Color(0xFF3F5553), spacing: 0.2));
  }

  void _youBubble(Canvas canvas, _Figure f, double t) {
    final rank = QueueSim.you - sim.serving;
    final shown = t > 0.62 ? rank - 1 : rank;
    final label = shown <= 1 ? "You're next!" : 'You · ${ordinal(shown)}';
    final p = pop.value;
    final bounce = p >= 1 ? 1.0 : 0.75 + 0.25 * Curves.elasticOut.transform(p);
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: jakarta(13, 800, color: const Color(0xFF3A1B06), spacing: -0.26),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final width = painter.width + 22;
    final anchor = Offset(f.at.dx, f.at.dy - f.bob - 70 * f.scale);
    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);
    canvas.scale(bounce);
    final bubble = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -13.35), width: width, height: 26.7),
      const Radius.circular(13.3),
    );
    canvas.drawRRect(
      bubble.shift(const Offset(0, 3)),
      Paint()
        ..color = const Color(0x33FF8A3D)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    final fill = Paint()..color = shown <= 1 ? const Color(0xFF22C55E) : Hue.orange;
    canvas.drawRRect(bubble, fill);
    canvas.drawPath(
      Path()
        ..moveTo(-5.5, -0.3)
        ..lineTo(0, 6.2)
        ..lineTo(5.5, -0.3)
        ..close(),
      fill,
    );
    painter.paint(canvas, Offset(-painter.width / 2, -13.35 - painter.height / 2));
    painter.dispose();
    canvas.restore();
  }

  void _motes(Canvas canvas, double clock, double open) {
    final base = _door.center + const Offset(0, 30);
    for (var i = 0; i < 7; i++) {
      final phase = (idle.value + i / 7) % 1.0;
      final x = base.dx - 28 + i * 9 + math.sin(clock + i) * 4;
      final y = base.dy - phase * 70;
      final a = math.sin(math.pi * phase) * (0.35 + 0.5 * open);
      canvas.drawCircle(Offset(x, y), 1.4, Paint()..color = Color.fromRGBO(255, 200, 130, a));
    }
  }

  void _text(Canvas canvas, String text, Offset centre, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, centre - Offset(painter.width / 2, painter.height / 2));
    painter.dispose();
  }

  @override
  bool shouldRepaint(_LinePainter oldDelegate) => false;
}

class _Figure {
  const _Figure({
    required this.at,
    required this.look,
    required this.scale,
    required this.alpha,
    required this.bob,
    required this.label,
    required this.you,
    this.tilt = 0,
    this.walking = false,
    this.clip = false,
  });

  final Offset at;
  final _Look look;
  final double scale;
  final double alpha;
  final double bob;
  final double tilt;
  final String? label;
  final bool you;
  final bool walking;
  final bool clip;
}
