import 'package:flutter/material.dart';

import 'primary_bg.dart';

abstract final class OnboardingAssets {
  static const avatars = [
    'assets/avatar_one.png',
    'assets/avatar_two.png',
    'assets/avatar_three.png',
    'assets/avatar_four.png',
    'assets/avatar_five.png',
    'assets/avatar_six.png',
  ];

  static const defaultIndex = 2;
}

abstract final class OnboardingColors {
  static const ink = PrimaryBgColors.title;
  static const muted = PrimaryBgColors.subtitle;
  static const header = Color(0xFF9B919E);
  static const slideTrack = Color(0xB3FFFFFF);
  static const slideBorder = Color(0xCCFFFFFF);
}
