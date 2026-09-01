import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const curve = Cubic(0.16, 1, 0.3, 1);
  static const curveOut = Cubic(0.4, 0, 0.2, 1);

  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 480);

  static bool reduceMotionOf(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context);
  }

  static Duration dur(BuildContext context, Duration value) {
    return reduceMotionOf(context) ? Duration.zero : value;
  }
}
