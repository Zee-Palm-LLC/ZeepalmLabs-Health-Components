import 'package:flutter/material.dart';

import '../core/motion.dart';

class RollingNumber extends StatelessWidget {
  const RollingNumber({
    super.key,
    required this.text,
    required this.style,
    required this.progress,
    this.from,
    this.stagger = 0.08,
  });

  final String text;
  final String? from;
  final TextStyle style;
  final double progress;
  final double stagger;

  @override
  Widget build(BuildContext context) {
    final digits = <int>[];
    for (var i = 0; i < text.length; i++) {
      if (_isDigit(text[i])) digits.add(i);
    }
    final count = digits.length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < text.length; i++)
          if (_isDigit(text[i]))
            _Wheel(
              digit: int.parse(text[i]),
              start: _startDigit(i),
              style: style,
              t: _local(digits.indexOf(i), count),
              turns: count - digits.indexOf(i),
            )
          else
            Text(text[i], style: style),
      ],
    );
  }

  int _startDigit(int i) {
    final f = from;
    if (f == null || f.length != text.length || !_isDigit(f[i])) return 0;
    return int.parse(f[i]);
  }

  double _local(int index, int count) {
    final order = count - 1 - index;
    final begin = order * stagger;
    final end = 1 - (count - 1 - order) * stagger * 0.3;
    return span(progress, begin.clamp(0.0, 0.9), end.clamp(begin + 0.1, 1.0), gentle);
  }

  static bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
}

class _Band extends CustomClipper<Rect> {
  const _Band();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(-12, 0, size.width + 12, size.height);

  @override
  bool shouldReclip(_Band oldClipper) => false;
}

class _Wheel extends StatelessWidget {
  const _Wheel({required this.digit, required this.start, required this.style, required this.t, required this.turns});

  final int digit;
  final int start;
  final TextStyle style;
  final double t;
  final int turns;

  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: '$digit', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final h = painter.height;
    final w = painter.width;
    final laps = start == digit && t < 1 ? 1 : 0;
    final distance = ((digit - start) % 10) + 10 * (laps + (turns > 1 ? 1 : 0));
    final pos = start + distance * t;
    final base = pos.floor();
    final frac = pos - base;
    return SizedBox(
      width: w,
      height: h,
      child: ClipRect(
        clipper: const _Band(),
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxHeight: h * 2,
          maxWidth: w + 24,
          child: Transform.translate(
            offset: Offset(0, -frac * h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: w, height: h, child: Center(child: Text('${base % 10}', style: style))),
                SizedBox(width: w, height: h, child: Center(child: Text('${(base + 1) % 10}', style: style))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
