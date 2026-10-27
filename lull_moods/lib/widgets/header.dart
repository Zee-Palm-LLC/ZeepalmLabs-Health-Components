import 'package:flutter/material.dart';

import '../layout.dart';
import '../mood.dart';

class LullHeader extends StatelessWidget {
  const LullHeader({super.key, required this.v, required this.s});

  final MoodVisual v;
  final double s;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CustomPaint(size: Size(40 * s, 40 * s), painter: _MenuGlyph(v.ink, v.knob, s)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(size: Size(11 * s, 11 * s), painter: _Crescent(v.ink)),
            SizedBox(width: 7 * s),
            Text('LULL', style: inter(15 * s, FontWeight.w500, v.ink, ls: 5.5 * s)),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.ios_share_rounded, size: 20 * s, color: v.ink),
              SizedBox(width: 14 * s),
              CustomPaint(size: Size(21 * s, 21 * s), painter: _TargetGlyph(v.ink, s)),
              SizedBox(width: 6 * s),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuGlyph extends CustomPainter {
  _MenuGlyph(this.color, this.dot, this.s);
  final Color color, dot;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(10 * s, 16 * s), Offset(26 * s, 16 * s), p);
    canvas.drawLine(Offset(10 * s, 22.5 * s), Offset(26 * s, 22.5 * s), p);
    canvas.drawLine(Offset(10 * s, 29 * s), Offset(20 * s, 29 * s), p);
    canvas.drawCircle(Offset(28.5 * s, 11.5 * s), 2.7 * s, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(_MenuGlyph old) => old.color != color || old.dot != dot || old.s != s;
}

class _Crescent extends CustomPainter {
  _Crescent(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = size.center(Offset.zero);
    final moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: r)),
      Path()..addOval(Rect.fromCircle(center: c + Offset(r * 0.5, -r * 0.3), radius: r * 0.85)),
    );
    canvas.drawPath(moon, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_Crescent old) => old.color != color;
}

class _TargetGlyph extends CustomPainter {
  _TargetGlyph(this.color, this.s);
  final Color color;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s;
    canvas.drawCircle(c, size.width / 2 - s, p);
    canvas.drawCircle(c, size.width * 0.26, p);
    canvas.drawCircle(c, 1.8 * s, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TargetGlyph old) => old.color != color || old.s != s;
}
