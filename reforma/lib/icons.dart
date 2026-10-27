import 'package:flutter/widgets.dart';

// Phosphor Icons (fonts in assets/fonts, MIT). The phosphor_flutter package's Dart
// classes subclass IconData, which Flutter 3.44 made final, so the glyphs are
// declared here as plain IconData; icon fonts are tree-shaken at build time.

abstract final class PhRegular {
  static const barbell = IconData(0xe0b6, fontFamily: 'PhosphorRegular');
  static const chartBar = IconData(0xe150, fontFamily: 'PhosphorRegular');
  static const clock = IconData(0xe19a, fontFamily: 'PhosphorRegular');
  static const floppyDisk = IconData(0xe248, fontFamily: 'PhosphorRegular');
  static const house = IconData(0xe2c2, fontFamily: 'PhosphorRegular');
  static const play = IconData(0xe3d0, fontFamily: 'PhosphorRegular');
  static const slidersHorizontal = IconData(0xe434, fontFamily: 'PhosphorRegular');
  static const user = IconData(0xe4c2, fontFamily: 'PhosphorRegular');
  static const waves = IconData(0xe6de, fontFamily: 'PhosphorRegular');
}

abstract final class PhFill {
  static const handTap = IconData(0xec90, fontFamily: 'PhosphorFill');
  static const handGrabbing = IconData(0xe57c, fontFamily: 'PhosphorFill');
  static const handSwipeRight = IconData(0xec92, fontFamily: 'PhosphorFill');
  static const arrowsDownUp = IconData(0xe098, fontFamily: 'PhosphorFill');
  static const barbell = IconData(0xe0b6, fontFamily: 'PhosphorFill');
  static const bell = IconData(0xe0ce, fontFamily: 'PhosphorFill');
  static const cellSignalFull = IconData(0xe142, fontFamily: 'PhosphorFill');
  static const chartBar = IconData(0xe150, fontFamily: 'PhosphorFill');
  static const house = IconData(0xe2c2, fontFamily: 'PhosphorFill');
  static const pause = IconData(0xe39e, fontFamily: 'PhosphorFill');
  static const personArmsSpread = IconData(0xecfe, fontFamily: 'PhosphorFill');
  static const play = IconData(0xe3d0, fontFamily: 'PhosphorFill');
  static const user = IconData(0xe4c2, fontFamily: 'PhosphorFill');
}

abstract final class PhBold {
  static const arrowRight = IconData(0xe06c, fontFamily: 'PhosphorBold');
  static const caretLeft = IconData(0xe138, fontFamily: 'PhosphorBold');
  static const cellSignalHigh = IconData(0xe144, fontFamily: 'PhosphorBold');
  static const check = IconData(0xe182, fontFamily: 'PhosphorBold');
  static const dotsThree = IconData(0xe1fe, fontFamily: 'PhosphorBold');
  static const personSimpleRun = IconData(0xe730, fontFamily: 'PhosphorBold');
  static const smiley = IconData(0xe436, fontFamily: 'PhosphorBold');
  static const wifiHigh = IconData(0xe4ea, fontFamily: 'PhosphorBold');
}
