import 'package:flutter/widgets.dart';

abstract final class Ph {
  static const caretLeft = IconData(0xe138, fontFamily: 'PhosphorRegular');
  static const caretLeftBold = IconData(0xe138, fontFamily: 'PhosphorBold');
  static const caretRight = IconData(0xe13a, fontFamily: 'PhosphorRegular');
  static const notePencil = IconData(0xe34c, fontFamily: 'PhosphorRegular');
  static const x = IconData(0xe4f6, fontFamily: 'PhosphorRegular');
  static const camera = IconData(0xe10e, fontFamily: 'PhosphorRegular');
  static const calendar = IconData(0xe10a, fontFamily: 'PhosphorRegular');
  static const arrowUp = IconData(0xe08e, fontFamily: 'PhosphorBold');
  static const stop = IconData(0xe46c, fontFamily: 'PhosphorFill');
  static const image = IconData(0xe2ca, fontFamily: 'PhosphorRegular');
  static const forkKnife = IconData(0xe262, fontFamily: 'PhosphorRegular');
  static const check = IconData(0xe182, fontFamily: 'PhosphorRegular');
  static const arrowUpRight = IconData(0xe092, fontFamily: 'PhosphorRegular');
  static const pencil = IconData(0xe3b4, fontFamily: 'PhosphorRegular');
  static const reset = IconData(0xe038, fontFamily: 'PhosphorRegular');
  static const copy = IconData(0xe1ca, fontFamily: 'PhosphorRegular');
  static const sparkle = IconData(0xe6a2, fontFamily: 'PhosphorFill');
  static const lightning = IconData(0xe2de, fontFamily: 'PhosphorRegular');
  static const cameraRotate = IconData(0xe7a4, fontFamily: 'PhosphorRegular');
}

class PhIcon extends StatelessWidget {
  const PhIcon(this.icon, {super.key, this.size = 24, this.color = const Color(0xFF1E1E1B)});

  final IconData icon;
  final double size;
  final Color color;

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
            leadingDistribution: TextLeadingDistribution.even,
          ),
          textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
        ),
      ),
    );
  }
}
