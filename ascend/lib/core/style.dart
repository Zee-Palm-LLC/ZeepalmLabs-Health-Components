import 'package:flutter/widgets.dart';

const interAscent = 0.96875;

abstract final class Tone {
  static const night = Color(0xFF0E0E11);
  static const card = Color(0xFF1A1B21);
  static const cardLine = Color(0x1FFFFFFF);
  static const white = Color(0xFFFAFAFC);
  static const brand = Color(0xFFC4C4CC);
  static const body = Color(0xFF6E6E76);
  static const label = Color(0xFF8A8A95);
  static const dim = Color(0xFF2B2C33);

  static const violet = Color(0xFF8B6CFF);
  static const violetHi = Color(0xFFC9B8FF);
  static const violetDeep = Color(0xFF5A3FD8);
  static const mint = Color(0xFF3FE3A8);
  static const mintHi = Color(0xFFA6FFD9);
  static const mintDeep = Color(0xFF14946A);
  static const amber = Color(0xFFFFA24C);
  static const amberHi = Color(0xFFFFD39A);
  static const amberDeep = Color(0xFFD9641E);
}

TextStyle inter(double size, double weight, {double opsz = 20, double tracking = 0, Color color = Tone.white, double? height}) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
    fontVariations: [FontVariation('wght', weight), FontVariation('opsz', opsz)],
    letterSpacing: tracking,
    color: color,
    height: height,
    leadingDistribution: height == null ? null : TextLeadingDistribution.even,
  );
}

abstract final class Typo {
  static final brand = inter(15.8, 500, tracking: -0.45, color: Tone.brand);
  static final back = inter(16.6, 500, tracking: -0.3);
  static final lvl = inter(22.9, 600, opsz: 28, tracking: -0.27, color: const Color(0xFF7D838C));
  static final level = inter(49.9, 700, opsz: 32, tracking: -2.4);
  static final cardTitle = inter(17.6, 700, opsz: 24, tracking: -0.55);
  static final cardSub = inter(14.2, 500, tracking: 0, color: const Color(0xD9FFFFFF));
  static final cardXp = inter(17.3, 700, opsz: 24, tracking: -0.33, color: const Color(0xB3FFFFFF));
  static final headline = inter(36, 700, opsz: 14, tracking: 0.3, height: 1.28);
  static final headlineBig = inter(40, 700, opsz: 14, tracking: 0.2, height: 1.1);
  static final body = inter(15.4, 400, tracking: -0.34, color: Tone.body, height: 1.2);
  static final bodySmall = inter(14.2, 400, tracking: -0.2, color: Tone.body, height: 1.3);
  static final button = inter(15.5, 600, tracking: -0.4, color: const Color(0xFF0A0A0A));
  static final buttonLight = inter(16, 600, tracking: -0.3, color: const Color(0xFFEAEAEA));
  static final badge = inter(80, 800, opsz: 32, tracking: -2.6);
  static final badgeUnit = inter(13, 700, tracking: 2.4, color: const Color(0x66FFFFFF));
  static final streak = inter(19, 600, opsz: 24, tracking: -0.4, color: const Color(0xFFD2D2D8));
  static final podium = inter(24, 700, opsz: 28, tracking: 0, color: const Color(0x40000000));
  static final tag = inter(14.5, 700, tracking: -0.1);
  static final login = inter(15, 500, tracking: -0.2, color: const Color(0xFF75757D));
}

class Line extends StatelessWidget {
  const Line(this.text, {super.key, required this.style, this.align = TextAlign.left});

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
