import 'package:flutter/widgets.dart';

abstract final class Tone {
  static const night = Color(0xFF070A24);
  static const ink = Color(0xFF0B0C2B);
  static const white = Color(0xFFFFFFFF);
  static const mist = Color(0xFFE6E3F5);
  static const lilac = Color(0xFFB9B4D8);
  static const muted = Color(0xFF9C98BC);
  static const dim = Color(0xFF6E6A93);

  static const gold = Color(0xFFFCAD14);
  static const goldHi = Color(0xFFF9D138);
  static const goldDeep = Color(0xFFFC9008);
  static const cream = Color(0xFFF8F1BE);
  static const butter = Color(0xFFFFE36B);
  static const amber = Color(0xFFF5AC22);
  static const buttonInk = Color(0xFF1C1430);

  static const violet = Color(0xFF7943F9);
  static const violetHi = Color(0xFF965DEF);
  static const violetDeep = Color(0xFF6A34EE);
  static const lavender = Color(0xFFB7A6FF);

  static const teal = Color(0xFF45C9CE);
  static const tealHi = Color(0xFF8FF3F0);
  static const cyan = Color(0xFF4AD2D7);
  static const pink = Color(0xFFE77BFF);
  static const green = Color(0xFF3AD06B);

  static const glass = Color(0x8C1A1D45);
  static const glassHi = Color(0x26FFFFFF);
  static const glassLine = Color(0x26C9C3FF);
  static const tile = Color(0xFF2B2550);
  static const track = Color(0xFF2D2B4A);
}

TextStyle poppins(double size, FontWeight weight, {Color color = Tone.white, double tracking = 0, double? height, List<Shadow>? shadows}) {
  return TextStyle(
    fontFamily: 'Poppins',
    fontSize: size,
    fontWeight: weight,
    letterSpacing: tracking,
    color: color,
    height: height,
    shadows: shadows,
    leadingDistribution: height == null ? null : TextLeadingDistribution.even,
  );
}

const _w4 = FontWeight.w400;
const _w5 = FontWeight.w500;
const _w6 = FontWeight.w600;
const _w7 = FontWeight.w700;

const glowText = [Shadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2))];

/// Sizes fitted against the mockup's measured ink widths.
abstract final class Typo {
  static final tagline = poppins(18.3, _w7, color: const Color(0xFFFFE9A6), height: 1.2, shadows: glowText);
  static final intro = poppins(14.8, _w4, color: Tone.white, height: 1.45, shadows: glowText);
  static final title = poppins(32.3, _w7, height: 1.12, tracking: -0.2, shadows: glowText);
  static final lede = poppins(15.8, _w4, color: const Color(0xFFEEECFA), height: 1.5);
  static final button = poppins(19.2, _w6, color: Tone.buttonInk, tracking: -0.1);
  static final buttonLight = poppins(15.8, _w6, tracking: 0);
  static final skip = poppins(15, _w6, color: Tone.white);

  static final greet = poppins(16.1, _w6);
  static final greetSub = poppins(13.4, _w4, color: const Color(0xFFB9B6D6));
  static final streak = poppins(24.2, _w7);
  static final level = poppins(19.9, _w6, color: const Color(0xFFF3E7C2));
  static final xp = poppins(14.1, _w5, color: const Color(0xFF7A84BE));
  static final statLabel = poppins(12.8, _w4, color: const Color(0xFFD4D2EC));
  static final statValue = poppins(18.4, _w6);
  static final navLabel = poppins(12.8, _w6, color: const Color(0xFFB8B3D8));
  static final navActive = poppins(12.8, _w6, color: Tone.butter);

  static final header = poppins(17.1, _w6);
  static final questLabel = poppins(13.5, _w5);
  static final questTitle = poppins(13.9, _w4, color: const Color(0xFFE9E6FA));
  static final questCount = poppins(13.4, _w7);
  static final questTotal = poppins(13.4, _w4, color: const Color(0xFF9E9AC0));
  static final timer = poppins(27, _w6, tracking: 0.3);
  static final metricLabel = poppins(12.3, _w4, color: const Color(0xFFCFCBE8));
  static final metricValue = poppins(21, _w6);

  static final tab = poppins(13.6, _w5, color: const Color(0xFFDAD6F0));
  static final section = poppins(19.8, _w6, color: Tone.cream);
  static final seeAll = poppins(12.6, _w5, color: Tone.butter);
  static final caption = poppins(12.2, _w4, color: const Color(0xFFA9A5C8));
  static final rowTitle = poppins(12.6, _w5, color: const Color(0xFFF2F0FF));
  static final rowCount = poppins(13.4, _w6, color: Tone.butter);
  static final rowSub = poppins(13, _w6, color: Tone.white);
  static final rowSubDim = poppins(13, _w4, color: const Color(0xFF8E8AB0));
  static final xpLabel = poppins(16, _w7, height: 1);
  static final xpValue = poppins(16.6, _w7, color: Tone.butter, height: 1);
  static final bubble = poppins(14.3, _w6, color: const Color(0xFF2A1B10), height: 1.2);
  static final toast = poppins(15, _w7, color: Tone.butter, shadows: glowText);
}

/// A single unclipped line of text (keeps ink exactly where the mockup has it).
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

/// Text painted with a vertical gradient, used for the gold headings.
class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style, required this.colors, this.align = TextAlign.left, this.stops});

  final String text;
  final TextStyle style;
  final List<Color> colors;
  final List<double>? stops;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors, stops: stops).createShader(r),
      child: Line(
        text,
        style: style.copyWith(shadows: const []),
        align: align,
      ),
    );
  }
}

const goldText = [Color(0xFFFFF2A0), Color(0xFFFFD84A), Color(0xFFF5A623)];
const goldStops = [0.0, 0.45, 1.0];
