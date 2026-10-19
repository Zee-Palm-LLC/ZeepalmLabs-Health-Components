import 'package:flutter/widgets.dart';

const balooAscent = 1.078;
const balooCap = 0.602;

abstract final class Tone {
  static const white = Color(0xFFFFFFFF);
  static const navy = Color(0xFF26215F);
  static const ink = Color(0xFF3A2410);
  static const glass = Color(0xFF2E2A7A);
  static const glassDeep = Color(0xFF221E66);
  static const space = Color(0xFF1B1950);
  static const gold = Color(0xFFFFC93A);
  static const goldHi = Color(0xFFFFE07A);
  static const goldDeep = Color(0xFFF59E1B);
  static const orange = Color(0xFFFF8A2A);
  static const pink = Color(0xFFFF4F8B);
  static const lilac = Color(0xFFC08BFF);
  static const green = Color(0xFF55C76A);
  static const coral = Color(0xFFFF9A6A);
  static const sky = Color(0xFF8FD8FF);
}

TextStyle baloo(double size, {double weight = 700, Color color = Tone.white, double tracking = 0, List<Shadow>? shadows, double? height}) {
  return TextStyle(
    fontFamily: 'Baloo',
    fontSize: size,
    fontWeight: weight >= 750 ? FontWeight.w800 : FontWeight.w700,
    fontVariations: [FontVariation('wght', weight)],
    color: color,
    letterSpacing: tracking,
    shadows: shadows,
    height: height,
  );
}

class Label extends StatelessWidget {
  const Label(this.text, {super.key, required this.style, this.align = TextAlign.left});

  final String text;
  final TextStyle style;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: align,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
    );
  }
}

class At extends StatelessWidget {
  const At({super.key, required this.baseline, required this.size, required this.child, this.left, this.center, this.right});

  final double baseline;
  final double size;
  final double? left;
  final double? center;
  final double? right;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final top = baseline - size * balooAscent;
    if (center != null) {
      return Positioned(left: center! - 300, width: 600, top: top, child: Center(child: child));
    }
    if (right != null) {
      return Positioned(right: 402 - right!, top: top, child: child);
    }
    return Positioned(left: left, top: top, child: child);
  }
}
