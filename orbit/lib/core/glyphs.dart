import 'package:flutter/widgets.dart';

abstract final class Ph {
  static const caretLeft = IconData(0xe138, fontFamily: 'PhosphorBold');
  static const gear = IconData(0xe272, fontFamily: 'PhosphorFill');
  static const users = IconData(0xe68e, fontFamily: 'PhosphorFill');
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
          style: TextStyle(fontFamily: icon.fontFamily, fontSize: size, height: 1, color: color, shadows: shadows, leadingDistribution: TextLeadingDistribution.even),
          textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
        ),
      ),
    );
  }
}
