import 'package:flutter/painting.dart';

import 'palette.dart';

abstract final class TextStyles {
  static const family = 'Poppins';

  static const display = TextStyle(
    fontFamily: family,
    fontSize: 40,
    height: 1.08,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.4,
    color: Palette.surface,
  );

  static const headline = TextStyle(
    fontFamily: family,
    fontSize: 25,
    height: 1.44,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: Palette.surface,
  );

  static const section = TextStyle(
    fontFamily: family,
    fontSize: 19,
    height: 1.3,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    color: Palette.ink,
  );

  static const title = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    color: Palette.ink,
  );

  static const body = TextStyle(
    fontFamily: family,
    fontSize: 13.5,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: Palette.inkMuted,
  );

  static const label = TextStyle(
    fontFamily: family,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: Palette.ink,
  );

  static const caption = TextStyle(
    fontFamily: family,
    fontSize: 12.5,
    height: 1.3,
    fontWeight: FontWeight.w400,
    color: Palette.inkMuted,
  );
}
