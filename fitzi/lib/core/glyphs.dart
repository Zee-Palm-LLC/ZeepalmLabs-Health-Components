import 'package:flutter/widgets.dart';

abstract final class Ph {
  static const house = IconData(0xe2c2, fontFamily: 'PhosphorRegular');
  static const houseFill = IconData(0xe2c2, fontFamily: 'PhosphorFill');
  static const barbell = IconData(0xe0b6, fontFamily: 'PhosphorRegular');
  static const barbellFill = IconData(0xe0b6, fontFamily: 'PhosphorFill');
  static const barbellBold = IconData(0xe0b6, fontFamily: 'PhosphorBold');
  static const chartBar = IconData(0xe150, fontFamily: 'PhosphorRegular');
  static const chartBarFill = IconData(0xe150, fontFamily: 'PhosphorFill');
  static const chartLineUpBold = IconData(0xe156, fontFamily: 'PhosphorBold');
  static const user = IconData(0xe4c2, fontFamily: 'PhosphorRegular');
  static const userFill = IconData(0xe4c2, fontFamily: 'PhosphorFill');
  static const bell = IconData(0xe0ce, fontFamily: 'PhosphorBold');
  static const arrowLeft = IconData(0xe058, fontFamily: 'PhosphorBold');
  static const arrowRight = IconData(0xe06c, fontFamily: 'PhosphorBold');
  static const heart = IconData(0xe2a8, fontFamily: 'PhosphorBold');
  static const heartFill = IconData(0xe2a8, fontFamily: 'PhosphorFill');
  static const timer = IconData(0xe492, fontFamily: 'PhosphorRegular');
  static const flame = IconData(0xe624, fontFamily: 'PhosphorRegular');
  static const cellSignal = IconData(0xe142, fontFamily: 'PhosphorRegular');
  static const play = IconData(0xe3d0, fontFamily: 'PhosphorFill');
  static const pause = IconData(0xe39e, fontFamily: 'PhosphorFill');
  static const skip = IconData(0xe5a6, fontFamily: 'PhosphorFill');
  static const caretRight = IconData(0xe13a, fontFamily: 'PhosphorBold');
  static const caretDown = IconData(0xe136, fontFamily: 'PhosphorBold');
  static const calendar = IconData(0xe7b4, fontFamily: 'PhosphorRegular');
  static const sneaker = IconData(0xe80c, fontFamily: 'PhosphorRegular');
  static const clock = IconData(0xe19a, fontFamily: 'PhosphorBold');
  static const forkKnife = IconData(0xe262, fontFamily: 'PhosphorFill');
  static const dots = IconData(0xe1fe, fontFamily: 'PhosphorBold');
  static const x = IconData(0xe4f6, fontFamily: 'PhosphorBold');
  static const check = IconData(0xe182, fontFamily: 'PhosphorBold');
  static const trophy = IconData(0xe67e, fontFamily: 'PhosphorFill');
  static const gear = IconData(0xe270, fontFamily: 'PhosphorRegular');
  static const lightning = IconData(0xe2de, fontFamily: 'PhosphorFill');
}

class PhIcon extends StatelessWidget {
  const PhIcon(this.icon, {super.key, this.size = 24, this.color = const Color(0xFF000000), this.shadows, this.foreground});

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
          textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
        ),
      ),
    );
  }
}
