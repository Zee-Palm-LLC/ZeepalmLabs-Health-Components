import 'package:flutter/widgets.dart';

abstract final class Ph {
  static const house = IconData(0xe2c2, fontFamily: 'PhosphorRegular');
  static const houseBold = IconData(0xe2c2, fontFamily: 'PhosphorBold');
  static const houseLight = IconData(0xe2c2, fontFamily: 'PhosphorLight');
  static const flowerLight = IconData(0xe75e, fontFamily: 'PhosphorLight');
  static const timerLight = IconData(0xe492, fontFamily: 'PhosphorLight');
  static const userLight = IconData(0xe4c2, fontFamily: 'PhosphorLight');
  static const bell = IconData(0xe0ce, fontFamily: 'PhosphorRegular');
  static const caretRight = IconData(0xe13a, fontFamily: 'PhosphorRegular');
  static const caretRightBold = IconData(0xe13a, fontFamily: 'PhosphorBold');
  static const caretLeft = IconData(0xe138, fontFamily: 'PhosphorRegular');
  static const check = IconData(0xe182, fontFamily: 'PhosphorBold');
  static const minus = IconData(0xe32a, fontFamily: 'PhosphorBold');
  static const minusRegular = IconData(0xe32a, fontFamily: 'PhosphorRegular');
  static const plus = IconData(0xe3d4, fontFamily: 'PhosphorBold');
  static const plusRegular = IconData(0xe3d4, fontFamily: 'PhosphorRegular');
  static const clock = IconData(0xe19a, fontFamily: 'PhosphorRegular');
  static const lightning = IconData(0xe2de, fontFamily: 'PhosphorFill');
  static const gift = IconData(0xe276, fontFamily: 'PhosphorRegular');
  static const users = IconData(0xe4d6, fontFamily: 'PhosphorRegular');
  static const info = IconData(0xe2ce, fontFamily: 'PhosphorRegular');
  static const export = IconData(0xeaf0, fontFamily: 'PhosphorRegular');
  static const dotsThree = IconData(0xe1fe, fontFamily: 'PhosphorBold');
  static const camera = IconData(0xe10e, fontFamily: 'PhosphorRegular');
  static const x = IconData(0xe4f6, fontFamily: 'PhosphorBold');
  static const tote = IconData(0xe494, fontFamily: 'PhosphorRegular');
  static const calendarDots = IconData(0xe7b4, fontFamily: 'PhosphorRegular');
  static const sealCheck = IconData(0xe606, fontFamily: 'PhosphorFill');
  static const arrowUp = IconData(0xe08e, fontFamily: 'PhosphorBold');
  static const circleNotch = IconData(0xeb44, fontFamily: 'PhosphorBold');
}

class PhIcon extends StatelessWidget {
  const PhIcon(this.icon, {super.key, this.size = 24, this.color = const Color(0xFFFFFFFF), this.shadows, this.foreground});

  final IconData icon;
  final double size;
  final Color color;
  final List<Shadow>? shadows;
  final Paint? foreground;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Text(
          String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontFamily: icon.fontFamily,
            fontSize: size,
            height: 1,
            color: foreground == null ? color : null,
            foreground: foreground,
            shadows: shadows,
            leadingDistribution: TextLeadingDistribution.even,
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        ),
      ),
    );
  }
}
