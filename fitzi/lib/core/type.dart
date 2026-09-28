import 'package:flutter/widgets.dart';

import 'palette.dart';

class _Metrics {
  const _Metrics(this.ascent, this.descent, this.cap);

  final double ascent;
  final double descent;
  final double cap;
}

const _interMetrics = _Metrics(0.96875, 0.24121, 0.72754);
const _nunitoMetrics = _Metrics(1.011, 0.353, 0.705);

TextStyle inter(
  double size,
  double weight, {
  Color color = Palette.ink,
  double track = 0,
  double height = 1,
  Paint? foreground,
  List<Shadow>? shadows,
  TextDecoration? decoration,
}) {
  final opsz = size.clamp(14.0, 32.0);
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
    fontVariations: [FontVariation('wght', weight), FontVariation('opsz', opsz)],
    letterSpacing: track * size,
    height: height,
    color: foreground == null ? color : null,
    foreground: foreground,
    shadows: shadows,
    decoration: decoration,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

TextStyle nunito(
  double size,
  double weight, {
  Color color = Palette.ink,
  double track = 0,
  double height = 1,
  Paint? foreground,
  List<Shadow>? shadows,
}) {
  return TextStyle(
    fontFamily: 'Nunito',
    fontSize: size,
    fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
    fontVariations: [FontVariation('wght', weight)],
    letterSpacing: track * size,
    height: height,
    color: foreground == null ? color : null,
    foreground: foreground,
    shadows: shadows,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

_Metrics _metrics(TextStyle style) => style.fontFamily == 'Nunito' ? _nunitoMetrics : _interMetrics;

double capInset(TextStyle style) {
  final m = _metrics(style);
  final size = style.fontSize!;
  final h = style.height ?? 1;
  return ((h - (m.ascent + m.descent)) / 2 + m.ascent - m.cap) * size;
}

double bearing(String text, TextStyle style) {
  if (text.isEmpty) return 0;
  if (style.fontFamily == 'Nunito') {
    final c = text[0];
    if (c == 'f' || c == 't') return 0;
    return 0.068 * style.fontSize!;
  }
  final row = _bearings[text[0]];
  if (row == null) return 0.05 * style.fontSize!;
  final w = style.fontVariations?.firstWhere((v) => v.axis == 'wght').value ?? 400;
  final i = ((w - 400) / 100).clamp(0.0, 3.0);
  final lo = i.floor();
  final hi = i.ceil();
  final f = i - lo;
  return (row[lo] * (1 - f) + row[hi] * f) * style.fontSize!;
}

class Pin extends StatelessWidget {
  const Pin({super.key, required this.x, required this.cap, required this.text, required this.style});

  final double x;
  final double cap;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x - bearing(text, style),
      top: cap - capInset(style),
      child: Text(text, style: style, softWrap: false, maxLines: 1),
    );
  }
}

class Cap extends StatelessWidget {
  const Cap(this.text, this.style, {super.key, this.align = TextAlign.left});

  final String text;
  final TextStyle style;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(align == TextAlign.left ? -bearing(text, style) : 0, -capInset(style)),
      child: Text(text, style: style, softWrap: false, maxLines: 1, textAlign: align),
    );
  }
}

const _bearings = <String, List<double>>{
  'A': [0.0254, 0.0249, 0.0244, 0.0239], 'B': [0.0879, 0.0806, 0.0732, 0.0659], 'C': [0.0596, 0.0552, 0.0503, 0.0459],
  'D': [0.0879, 0.0806, 0.0732, 0.0659], 'E': [0.0879, 0.0806, 0.0732, 0.0659], 'F': [0.0879, 0.0806, 0.0732, 0.0659],
  'G': [0.0596, 0.0552, 0.0503, 0.0459], 'H': [0.0879, 0.0806, 0.0732, 0.0659], 'I': [0.0879, 0.0806, 0.0732, 0.0659],
  'J': [0.0488, 0.0435, 0.0381, 0.0332], 'K': [0.0879, 0.0806, 0.0732, 0.0659], 'L': [0.0879, 0.0806, 0.0732, 0.0659],
  'M': [0.0879, 0.0806, 0.0732, 0.0659], 'N': [0.0879, 0.0806, 0.0732, 0.0659], 'O': [0.0596, 0.0552, 0.0503, 0.0459],
  'P': [0.0879, 0.0806, 0.0732, 0.0659], 'Q': [0.0596, 0.0552, 0.0503, 0.0459], 'R': [0.0879, 0.0806, 0.0732, 0.0659],
  'S': [0.0566, 0.0518, 0.0464, 0.0415], 'T': [0.0479, 0.0439, 0.0405, 0.0366], 'U': [0.0879, 0.0806, 0.0732, 0.0659],
  'V': [0.0254, 0.0249, 0.0244, 0.0239], 'W': [0.0254, 0.0249, 0.0244, 0.0239], 'X': [0.0278, 0.0269, 0.0259, 0.0249],
  'Y': [0.0254, 0.0249, 0.0244, 0.0239], 'Z': [0.0596, 0.0581, 0.0566, 0.0547], 'a': [0.0439, 0.0405, 0.0371, 0.0332],
  'b': [0.0771, 0.0723, 0.0674, 0.0625], 'c': [0.0508, 0.0469, 0.0435, 0.0396], 'd': [0.0508, 0.0469, 0.0435, 0.0396],
  'e': [0.0508, 0.0469, 0.0435, 0.0396], 'f': [0.0098, 0.0098, 0.0098, 0.0098], 'g': [0.0508, 0.0469, 0.0435, 0.0396],
  'h': [0.0771, 0.0723, 0.0674, 0.0625], 'i': [0.0605, 0.0586, 0.0571, 0.0552], 'j': [-0.0127, -0.0166, -0.0205, -0.0244],
  'k': [0.0771, 0.0723, 0.0674, 0.0625], 'l': [0.0771, 0.0723, 0.0674, 0.0625], 'm': [0.0771, 0.0723, 0.0674, 0.0625],
  'n': [0.0771, 0.0723, 0.0674, 0.0625], 'o': [0.0508, 0.0469, 0.0435, 0.0396], 'p': [0.0771, 0.0723, 0.0674, 0.0625],
  'q': [0.0508, 0.0469, 0.0435, 0.0396], 'r': [0.0771, 0.0723, 0.0674, 0.0625], 's': [0.0527, 0.0479, 0.0430, 0.0381],
  't': [0.0098, 0.0098, 0.0098, 0.0098], 'u': [0.0771, 0.0723, 0.0674, 0.0625], 'v': [0.0264, 0.0225, 0.0190, 0.0151],
  'w': [0.0342, 0.0278, 0.0215, 0.0151], 'x': [0.0317, 0.0278, 0.0244, 0.0205], 'y': [0.0264, 0.0225, 0.0190, 0.0151],
  'z': [0.0615, 0.0605, 0.0596, 0.0586], '0': [0.0596, 0.0552, 0.0503, 0.0459], '1': [0.0469, 0.0464, 0.0459, 0.0454],
  '2': [0.0752, 0.0693, 0.0615, 0.0537], '3': [0.0610, 0.0566, 0.0522, 0.0483], '4': [0.0586, 0.0557, 0.0522, 0.0493],
  '5': [0.0625, 0.0566, 0.0513, 0.0454], '6': [0.0596, 0.0552, 0.0503, 0.0459], '7': [0.0479, 0.0439, 0.0405, 0.0366],
  '8': [0.0596, 0.0552, 0.0503, 0.0459], '9': [0.0596, 0.0552, 0.0503, 0.0459],
};
