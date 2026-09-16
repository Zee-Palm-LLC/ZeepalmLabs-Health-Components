import 'package:flutter/painting.dart';

abstract final class AppColors {
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF15141A);
  static const inkMuted = Color(0xFF7C7B84);
  static const hairline = Color(0xFFECEBF0);

  static const orange = Color(0xFFFF7A3D);
  static const orangePressed = Color(0xFFF26A2C);
  static const orangeSoft = Color(0xFFFFEBDF);
  static const orangeBorder = Color(0xFFF3A083);

  static const violet = Color(0xFF3A2B8C);
  static const indicatorIdle = Color(0xFFE2E0EA);

  static const orbit = Color(0xFFE6E4EC);
  static const mapDot = Color(0xFFDDDCE4);
  static const photoPlaceholder = Color(0xFFE9E2DA);

  static const star = Color(0xFFFFB21E);
  static const heart = Color(0xFFE5402B);

  static const avatarSand = Color(0xFFE9B77F);
  static const avatarClay = Color(0xFFB9A58F);
  static const avatarRose = Color(0xFFE39A8D);
  static const avatarSage = Color(0xFF9DB89A);
}

abstract final class AppShadows {
  static const card = [
    BoxShadow(color: Color(0x0F1B1530), blurRadius: 18, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const raised = [
    BoxShadow(color: Color(0x1A1B1530), blurRadius: 28, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
  ];
}
