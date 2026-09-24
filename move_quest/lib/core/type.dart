import 'package:flutter/material.dart';

import 'palette.dart';

const cabin = 'Cabin';

TextStyle typo(
  double size, {
  FontWeight weight = FontWeight.w600,
  Color color = Hue.white,
  double spacing = 0,
  double height = 1.0,
  List<Shadow>? shadows,
}) {
  return TextStyle(
    fontFamily: cabin,
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: spacing,
    height: height,
    shadows: shadows,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

List<Shadow> glowOf(Color color, [double blur = 10, double alpha = 0.55]) => [
  Shadow(
    color: color.withValues(alpha: alpha),
    blurRadius: blur,
  ),
];

final _ascents = <TextStyle, double>{};

double ascentOf(TextStyle style) {
  return _ascents.putIfAbsent(style, () {
    final painter = TextPainter(
      text: TextSpan(text: 'Hg', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final value = painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    painter.dispose();
    return value;
  });
}

class TextAt extends StatelessWidget {
  const TextAt({
    super.key,
    required this.x,
    required this.baseline,
    required this.child,
    required this.style,
    this.anchor = 0,
    this.width = 393,
  });

  final double x;
  final double baseline;
  final Widget child;
  final TextStyle style;
  final double anchor;
  final double width;

  @override
  Widget build(BuildContext context) {
    final align = anchor == 0 ? Alignment.topLeft : (anchor == 1 ? Alignment.topRight : Alignment.topCenter);
    return Positioned(
      left: x - width * anchor,
      top: baseline - ascentOf(style),
      width: width,
      child: Align(alignment: align, child: child),
    );
  }
}

class Label extends StatelessWidget {
  const Label(this.text, this.style, {super.key, this.align = TextAlign.left});

  final String text;
  final TextStyle style;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style, textAlign: align, maxLines: 1, softWrap: false, overflow: TextOverflow.visible);
  }
}
