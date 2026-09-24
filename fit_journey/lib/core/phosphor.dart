import 'package:flutter/widgets.dart';

class PhosphorFill {
  static const barbell = IconData(0xe0b6, fontFamily: 'PhosphorFill');
  static const bell = IconData(0xe0ce, fontFamily: 'PhosphorFill');
  static const bookmarkSimple = IconData(0xe0ea, fontFamily: 'PhosphorFill');
  static const chartLineUp = IconData(0xe156, fontFamily: 'PhosphorFill');
  static const drop = IconData(0xe210, fontFamily: 'PhosphorFill');
  static const fire = IconData(0xe242, fontFamily: 'PhosphorFill');
  static const flagCheckered = IconData(0xea38, fontFamily: 'PhosphorFill');
  static const flowerLotus = IconData(0xe6cc, fontFamily: 'PhosphorFill');
  static const heart = IconData(0xe2a8, fontFamily: 'PhosphorFill');
  static const heartbeat = IconData(0xe2ac, fontFamily: 'PhosphorFill');
  static const house = IconData(0xe2c2, fontFamily: 'PhosphorFill');
  static const infinity = IconData(0xe634, fontFamily: 'PhosphorFill');
  static const lightning = IconData(0xe2de, fontFamily: 'PhosphorFill');
  static const mapPin = IconData(0xe316, fontFamily: 'PhosphorFill');
  static const moonStars = IconData(0xe58e, fontFamily: 'PhosphorFill');
  static const mountains = IconData(0xe7ae, fontFamily: 'PhosphorFill');
  static const park = IconData(0xecb2, fontFamily: 'PhosphorFill');
  static const pause = IconData(0xe39e, fontFamily: 'PhosphorFill');
  static const personSimpleRun = IconData(0xe730, fontFamily: 'PhosphorFill');
  static const personSimpleWalk = IconData(0xe73a, fontFamily: 'PhosphorFill');
  static const play = IconData(0xe3d0, fontFamily: 'PhosphorFill');
  static const shieldCheck = IconData(0xe40c, fontFamily: 'PhosphorFill');
  static const star = IconData(0xe46a, fontFamily: 'PhosphorFill');
  static const sun = IconData(0xe472, fontFamily: 'PhosphorFill');
  static const timer = IconData(0xe492, fontFamily: 'PhosphorFill');
  static const treeEvergreen = IconData(0xe6dc, fontFamily: 'PhosphorFill');
  static const trendUp = IconData(0xe4ae, fontFamily: 'PhosphorFill');
  static const user = IconData(0xe4c2, fontFamily: 'PhosphorFill');
}

class PhosphorRegular {
  static const chartLineUp = IconData(0xe156, fontFamily: 'PhosphorRegular');
  static const house = IconData(0xe2c2, fontFamily: 'PhosphorRegular');
  static const mapPin = IconData(0xe316, fontFamily: 'PhosphorRegular');
  static const user = IconData(0xe4c2, fontFamily: 'PhosphorRegular');
}

class PhosphorBold {
  static const arrowRight = IconData(0xe06c, fontFamily: 'PhosphorBold');
  static const bookmarkSimple = IconData(0xe0ea, fontFamily: 'PhosphorBold');
  static const caretLeft = IconData(0xe138, fontFamily: 'PhosphorBold');
  static const caretRight = IconData(0xe13a, fontFamily: 'PhosphorBold');
  static const check = IconData(0xe182, fontFamily: 'PhosphorBold');
  static const clock = IconData(0xe19a, fontFamily: 'PhosphorBold');
  static const crosshair = IconData(0xe1d6, fontFamily: 'PhosphorBold');
  static const path = IconData(0xe39c, fontFamily: 'PhosphorBold');
  static const plus = IconData(0xe3d4, fontFamily: 'PhosphorBold');
}

class DuotoneIcon {
  const DuotoneIcon(this.primary, this.secondary);

  final IconData primary;
  final IconData secondary;
}

class PhosphorDuotone {
  static const drop = DuotoneIcon(IconData(0xe211, fontFamily: 'PhosphorDuotone'), IconData(0xe210, fontFamily: 'PhosphorDuotone'));
  static const mountains = DuotoneIcon(IconData(0xe7af, fontFamily: 'PhosphorDuotone'), IconData(0xe7ae, fontFamily: 'PhosphorDuotone'));
  static const park = DuotoneIcon(IconData(0xecb3, fontFamily: 'PhosphorDuotone'), IconData(0xecb2, fontFamily: 'PhosphorDuotone'));
  static const shieldCheck = DuotoneIcon(IconData(0xe40f, fontFamily: 'PhosphorDuotone'), IconData(0xe40c, fontFamily: 'PhosphorDuotone'));
}

class Duotone extends StatelessWidget {
  const Duotone(this.icon, {super.key, required this.size, required this.color, this.shade = 0.28});

  final DuotoneIcon icon;
  final double size;
  final Color color;
  final double shade;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(icon.secondary, size: size, color: color.withValues(alpha: shade)),
        Icon(icon.primary, size: size, color: color),
      ],
    );
  }
}