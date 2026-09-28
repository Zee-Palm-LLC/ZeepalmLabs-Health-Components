import 'package:flutter/widgets.dart';

abstract final class Ph {
  static const house = IconData(0xe2c2, fontFamily: 'PhosphorRegular');
  static const houseFill = IconData(0xe2c2, fontFamily: 'PhosphorFill');
  static const forkKnife = IconData(0xe262, fontFamily: 'PhosphorRegular');
  static const forkKnifeFill = IconData(0xe262, fontFamily: 'PhosphorFill');
  static const heart = IconData(0xe2a8, fontFamily: 'PhosphorRegular');
  static const heartBold = IconData(0xe2a8, fontFamily: 'PhosphorBold');
  static const heartFill = IconData(0xe2a8, fontFamily: 'PhosphorFill');
  static const user = IconData(0xe4c2, fontFamily: 'PhosphorRegular');
  static const userFill = IconData(0xe4c2, fontFamily: 'PhosphorFill');
  static const plus = IconData(0xe3d4, fontFamily: 'PhosphorBold');
  static const bell = IconData(0xe0ce, fontFamily: 'PhosphorRegular');
  static const search = IconData(0xe30c, fontFamily: 'PhosphorBold');
  static const chefHat = IconData(0xed8e, fontFamily: 'PhosphorRegular');
  static const chefHatFill = IconData(0xed8e, fontFamily: 'PhosphorFill');
  static const clock = IconData(0xe19a, fontFamily: 'PhosphorRegular');
  static const clockBold = IconData(0xe19a, fontFamily: 'PhosphorBold');
  static const arrowRight = IconData(0xe06c, fontFamily: 'PhosphorRegular');
  static const arrowRightBold = IconData(0xe06c, fontFamily: 'PhosphorBold');
  static const arrowLeftBold = IconData(0xe058, fontFamily: 'PhosphorBold');
  static const gear = IconData(0xe270, fontFamily: 'PhosphorRegular');
  static const camera = IconData(0xe10e, fontFamily: 'PhosphorFill');
  static const caretRight = IconData(0xe13a, fontFamily: 'PhosphorRegular');
  static const question = IconData(0xe3e8, fontFamily: 'PhosphorRegular');
  static const bag = IconData(0xe0b0, fontFamily: 'PhosphorRegular');
  static const users = IconData(0xe4d6, fontFamily: 'PhosphorRegular');
  static const usersBold = IconData(0xe4d6, fontFamily: 'PhosphorBold');
  static const star = IconData(0xe46a, fontFamily: 'PhosphorFill');
  static const check = IconData(0xe182, fontFamily: 'PhosphorBold');
  static const timer = IconData(0xe492, fontFamily: 'PhosphorBold');
  static const basket = IconData(0xe964, fontFamily: 'PhosphorFill');
}

class PhIcon extends StatelessWidget {
  const PhIcon(this.icon, {super.key, this.size = 24, this.color = const Color(0xFF0B0A19), this.shadows});

  final IconData icon;
  final double size;
  final Color color;
  final List<Shadow>? shadows;

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
            color: color,
            shadows: shadows,
            leadingDistribution: TextLeadingDistribution.even,
          ),
          textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
        ),
      ),
    );
  }
}
