import 'package:flutter/widgets.dart';

abstract final class Ph {
  static const arrowLeft = IconData(0xe058, fontFamily: 'PhosphorRegular');
  static const apple = IconData(0xe516, fontFamily: 'PhosphorFill');
  static const check = IconData(0xe182, fontFamily: 'PhosphorBold');
  static const caretUp = IconData(0xe13c, fontFamily: 'PhosphorBold');
}

class PhIcon extends StatelessWidget {
  const PhIcon(this.icon, {super.key, this.size = 24, this.color = const Color(0xFFFFFFFF)});

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
          style: TextStyle(fontFamily: icon.fontFamily, fontSize: size, height: 1, color: color, leadingDistribution: TextLeadingDistribution.even),
          textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
        ),
      ),
    );
  }
}

abstract final class Art {
  static const run = 'assets/art/habit_run.webp';
  static const journal = 'assets/art/habit_journal.webp';
  static const water = 'assets/art/habit_water.webp';
  static const fire = 'assets/art/fire.webp';
  static const maya = 'assets/art/avatar_maya.webp';
  static const you = 'assets/art/avatar_you.webp';
  static const leo = 'assets/art/avatar_leo.webp';

  static const all = [run, journal, water, fire, maya, you, leo];
}
