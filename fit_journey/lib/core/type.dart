import 'package:flutter/material.dart';

import 'palette.dart';

const _ascent = 0.95;
const _descent = 0.25;

TextStyle font(
  double size,
  int weight, {
  Color color = Palette.navy,
  double height = 1.2,
  double? spacing,
  List<Shadow>? shadows,
}) {
  return TextStyle(
    fontFamily: 'Figtree',
    fontSize: size,
    height: height,
    letterSpacing: spacing ?? tracking(size),
    color: color,
    fontWeight: FontWeight.values[weight ~/ 100 - 1],
    shadows: shadows,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

double tracking(double size) {
  if (size >= 28) return -size * 0.022;
  if (size >= 17) return -size * 0.016;
  return -size * 0.008;
}

double baselineOffset(TextStyle style) {
  final size = style.fontSize ?? 14;
  final height = style.height ?? (_ascent + _descent);
  return size * (_ascent + (height - _ascent - _descent) / 2);
}

class Label extends StatelessWidget {
  const Label(
    this.text, {
    super.key,
    required this.x,
    required this.base,
    required this.style,
    this.width,
    this.align = TextAlign.left,
  });

  const Label.centered(
    this.text, {
    super.key,
    required double cx,
    required this.base,
    required this.style,
    double span = 160,
  }) : x = cx - span / 2,
       width = span,
       align = TextAlign.center;

  final String text;
  final double x;
  final double base;
  final TextStyle style;
  final double? width;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: base - baselineOffset(style),
      width: width,
      child: Text(text, style: style, textAlign: align, softWrap: width != null, maxLines: width == null ? 1 : 4),
    );
  }
}
