import 'package:flutter/widgets.dart';

import '../core/design.dart';

/// A count whose digits roll like an odometer when the value changes. Each
/// digit column scrolls independently, so 9 -> 10 rolls two columns and
/// 10 -> 11 rolls one.
class RollingNumber extends StatelessWidget {
  const RollingNumber({
    super.key,
    required this.value,
    required this.style,
  });

  final int value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final text = value.toString();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 0; i < text.length; i++)
          _Digit(
            key: ValueKey<int>(text.length - i),
            digit: int.parse(text[i]),
            style: style,
          ),
      ],
    );
  }
}

class _Digit extends StatelessWidget {
  const _Digit({super.key, required this.digit, required this.style});

  final int digit;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final lineHeight = (style.fontSize ?? 12) * (style.height ?? 1.3);
    return ClipRect(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: digit.toDouble()),
        duration: const Duration(milliseconds: 520),
        curve: D.emphasized,
        builder: (BuildContext context, double v, Widget? _) {
          // The stack is sized by an invisible "8" - the widest digit - and
          // the ten real digits are positioned through it. Positioned
          // children may sit outside the box without a flex complaint.
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              Opacity(
                opacity: 0,
                child: SizedBox(
                  height: lineHeight,
                  child: Text('8', style: style),
                ),
              ),
              for (var d = 0; d <= 9; d++)
                Positioned(
                  left: 0,
                  right: 0,
                  top: (d - v) * lineHeight,
                  height: lineHeight,
                  child: Text('$d', style: style),
                ),
            ],
          );
        },
      ),
    );
  }
}
