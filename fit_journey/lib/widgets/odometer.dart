import 'package:flutter/material.dart';

import '../core/motion.dart';

class Odometer extends StatelessWidget {
  const Odometer({super.key, required this.value, required this.style, required this.progress, this.stagger = 0.12});

  final String value;
  final TextStyle style;
  final double progress;
  final double stagger;

  @override
  Widget build(BuildContext context) {
    final size = style.fontSize!;
    final lineHeight = size * 1.25;
    if (progress >= 1) return Text(value, style: style.copyWith(height: 1.25));
    final digits = value.characters.toList();
    final count = digits.where(_isDigit).length;
    var index = 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final ch in digits)
          if (_isDigit(ch))
            () {
              final order = count - 1 - index++;
              final begin = (order * stagger).clamp(0.0, 0.6);
              final t = span(progress, begin, begin + 0.55, const Cubic(0.2, 0.8, 0.2, 1.0));
              return _Wheel(target: int.parse(ch), turns: order + 1, t: t, style: style.copyWith(height: 1.25), height: lineHeight);
            }()
          else
            Text(ch, style: style.copyWith(height: 1.25)),
      ],
    );
  }

  static bool _isDigit(String ch) => ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
}

class _Wheel extends StatelessWidget {
  const _Wheel({required this.target, required this.turns, required this.t, required this.style, required this.height});

  final int target;
  final int turns;
  final double t;
  final TextStyle style;
  final double height;

  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(text: TextSpan(text: '$target', style: style), textDirection: TextDirection.ltr)..layout();
    final width = painter.width;
    final total = turns * 10 + target;
    final position = total * t;
    final whole = position.floor();
    final frac = position - whole;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var k = 0; k < 2; k++)
              Positioned(
                left: 0,
                right: 0,
                top: (k - frac) * height,
                child: Text('${(whole + k) % 10}', style: style, textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }
}
