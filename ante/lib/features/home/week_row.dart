import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/motion.dart';
import '../../core/type.dart';

enum Mark { done, missed, today, ahead }

class Day {
  const Day(this.label, this.x, this.mark);

  final String label;
  final double x;
  final Mark mark;
}

const week = [
  Day('Mon', 33.8, Mark.done),
  Day('Tue', 89.2, Mark.done),
  Day('Wed', 143.8, Mark.missed),
  Day('Thu', 199.2, Mark.done),
  Day('Fri', 253.8, Mark.done),
  Day('Sat', 308.8, Mark.today),
  Day('Sun', 363.2, Mark.ahead),
];

class WeekRow extends StatelessWidget {
  const WeekRow({super.key, required this.entrance});

  static const cy = 374.3;

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final label = inter(11.3, 500, color: const Color(0xFFA0A7B2));
    final bright = inter(11.3, 600, color: const Color(0xFFD9DCE6));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final (i, d) in week.indexed) ...[
          Positioned(
            left: d.x - 22,
            top: cy - 22,
            child: _Dot(day: d, entrance: entrance, begin: 0.34 + i * 0.05),
          ),
          Positioned(
            left: d.x - 30,
            width: 60,
            top: 400.6 - capInset(label),
            child: Staged(
              animation: entrance,
              begin: 0.4 + i * 0.05,
              end: 0.7 + i * 0.05,
              offset: const Offset(0, 6),
              child: Text(d.label, style: d.mark == Mark.today ? bright : label, textAlign: TextAlign.center),
            ),
          ),
        ],
      ],
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.day, required this.entrance, required this.begin});

  final Day day;
  final Animation<double> entrance;
  final double begin;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _boing;

  @override
  void initState() {
    super.initState();
    _boing = AnimationController(vsync: this, duration: const Duration(milliseconds: 700), value: 1);
  }

  @override
  void dispose() {
    _boing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _boing.forward(from: 0);
      },
      child: Tick(
        builder: (context, s, _) => AnimatedBuilder(
          animation: Listenable.merge([widget.entrance, _boing]),
          builder: (context, _) {
            final raw = span(widget.entrance.value, widget.begin, widget.begin + 0.3, Curves.linear);
            final pop = spring(raw, bounce: 0.45, freq: 2.6);
            final draw = span(widget.entrance.value, widget.begin + 0.12, widget.begin + 0.36, gentle);
            final boing = 1 + math.sin(_boing.value * math.pi) * 0.14 * (1 - _boing.value);
            return Opacity(
              opacity: span(widget.entrance.value, widget.begin, widget.begin + 0.08, Curves.linear),
              child: Transform.scale(
                scale: pop * boing,
                child: CustomPaint(
                  size: const Size(44, 44),
                  painter: _DotPainter(mark: widget.day.mark, draw: draw, seconds: s),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  _DotPainter({required this.mark, required this.draw, required this.seconds});

  final Mark mark;
  final double draw;
  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    switch (mark) {
      case Mark.done:
        canvas.drawCircle(c, 16.4, Paint()..color = const Color(0x3326C39A)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
        canvas.drawCircle(c, 16.8, Paint()..color = const Color(0xFF02262A));
        canvas.drawCircle(
          c,
          16.2,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3
            ..shader = const SweepGradient(
              colors: [Color(0xFF2D6C67), Color(0xFF3F8C7F), Color(0xFF236461), Color(0xFF2D6C67)],
            ).createShader(Rect.fromCircle(center: c, radius: 16.2)),
        );
        canvas.drawCircle(
          c,
          11.6,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(-0.3, -0.4),
              colors: [Color(0xFF52D2A4), Color(0xFF34BF8D), Color(0xFF239E78)],
              stops: [0.0, 0.6, 1.0],
            ).createShader(Rect.fromCircle(center: c, radius: 11.6)),
        );
        _check(canvas, c, draw);
      case Mark.missed:
        _hollow(canvas, c, const Color(0xFF475066), const Color(0xFF131E3A));
        _dash(canvas, c, const Color(0xFFD0D7E0), draw);
      case Mark.ahead:
        _hollow(canvas, c, const Color(0xFF263047), const Color(0xFF101A33));
        _dash(canvas, c, const Color(0xFFBBC6CD), draw);
      case Mark.today:
        final pulse = (seconds % 2.2) / 2.2;
        if (seconds > 0) {
          canvas.drawCircle(
            c,
            16 + 7 * pulse,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5 * (1 - pulse)
              ..color = Color.fromRGBO(127, 233, 242, 0.5 * (1 - pulse)),
          );
        }
        canvas.drawCircle(c, 16.8, Paint()..color = const Color(0xFF062540));
        canvas.drawCircle(
          c,
          16.3,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..shader = const LinearGradient(
              colors: [Color(0xFF1C3451), Color(0xFF3F6B77)],
            ).createShader(Rect.fromCircle(center: c, radius: 16.3)),
        );
        canvas.drawCircle(c, 9.5, Paint()..color = const Color(0x5557E6EC)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
        final ring = Rect.fromCircle(center: c, radius: 8.4);
        canvas.drawArc(
          ring,
          -math.pi / 2,
          math.pi * 2 * draw,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.3
            ..color = const Color(0xFFA6FBF5),
        );
        if (seconds > 0) {
          canvas.drawArc(
            ring,
            seconds * 2.4,
            1.1,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.3
              ..strokeCap = StrokeCap.round
              ..shader = SweepGradient(
                colors: const [Color(0x00FFFFFF), Color(0xCCFFFFFF), Color(0x00FFFFFF)],
                transform: GradientRotation(seconds * 2.4),
                stops: const [0.0, 0.1, 0.18],
              ).createShader(ring),
          );
        }
    }
  }

  void _hollow(Canvas canvas, Offset c, Color ring, Color fill) {
    canvas.drawCircle(c, 16.8, Paint()..color = fill);
    canvas.drawCircle(
      c,
      16.2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = ring,
    );
  }

  void _dash(Canvas canvas, Offset c, Color color, double t) {
    final w = 10.0 * t;
    canvas.drawLine(
      c - Offset(w / 2, 0),
      c + Offset(w / 2, 0),
      Paint()
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  void _check(Canvas canvas, Offset c, double t) {
    final path = Path()
      ..moveTo(c.dx - 5.2, c.dy + 0.2)
      ..lineTo(c.dx - 1.6, c.dy + 3.8)
      ..lineTo(c.dx + 5.4, c.dy - 3.6);
    final metric = path.computeMetrics().first;
    final part = metric.extractPath(0, metric.length * t);
    canvas.drawPath(
      part,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFE6FFF9),
    );
  }

  @override
  bool shouldRepaint(_DotPainter old) => old.draw != draw || old.seconds != seconds || old.mark != mark;
}
