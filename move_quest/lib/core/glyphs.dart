import 'package:flutter/widgets.dart';

abstract final class PhosphorFill {
  static const house = IconData(0xe2c2, fontFamily: 'PhosphorFill');
  static const mapTrifold = IconData(0xe31a, fontFamily: 'PhosphorFill');
  static const chartLineUp = IconData(0xe156, fontFamily: 'PhosphorFill');
  static const shoppingCart = IconData(0xe41e, fontFamily: 'PhosphorFill');
  static const user = IconData(0xe4c2, fontFamily: 'PhosphorFill');
  static const heart = IconData(0xe2a8, fontFamily: 'PhosphorFill');
  static const crown = IconData(0xe614, fontFamily: 'PhosphorFill');
  static const star = IconData(0xe46a, fontFamily: 'PhosphorFill');
  static const play = IconData(0xe3d0, fontFamily: 'PhosphorFill');
}

abstract final class PhosphorRegular {
  static const house = IconData(0xe2c2, fontFamily: 'PhosphorRegular');
  static const mapTrifold = IconData(0xe31a, fontFamily: 'PhosphorRegular');
  static const chartLineUp = IconData(0xe156, fontFamily: 'PhosphorRegular');
  static const shoppingCart = IconData(0xe41e, fontFamily: 'PhosphorRegular');
  static const user = IconData(0xe4c2, fontFamily: 'PhosphorRegular');
  static const heart = IconData(0xe2a8, fontFamily: 'PhosphorRegular');
}

abstract final class PhosphorBold {
  static const arrowRight = IconData(0xe06c, fontFamily: 'PhosphorBold');
  static const caretLeft = IconData(0xe138, fontFamily: 'PhosphorBold');
  static const export = IconData(0xeaf0, fontFamily: 'PhosphorBold');
  static const heart = IconData(0xe2a8, fontFamily: 'PhosphorBold');
  static const check = IconData(0xe182, fontFamily: 'PhosphorBold');
  static const plus = IconData(0xe3d4, fontFamily: 'PhosphorBold');
}

class PhIcon extends StatelessWidget {
  const PhIcon(this.icon, {super.key, this.size = 24, this.color = const Color(0xFFFFFFFF), this.shadows});

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
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        ),
      ),
    );
  }
}
