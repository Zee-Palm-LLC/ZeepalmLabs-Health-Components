import 'package:flutter/widgets.dart';

class Night {
  Night._();

  static const Color abyss = Color(0xFF03050A);
  static const Color base = Color(0xFF070A11);
  static const Color raised = Color(0xFF0B0F18);
  static const Color panel = Color(0xCC0A0E17);
  static const Color panelSolid = Color(0xFF0D121C);
  static const Color veil = Color(0x99050810);
  static const Color hairline = Color(0x1FFFFFFF);
  static const Color hairlineSoft = Color(0x12FFFFFF);
  static const Color hairlineBright = Color(0x3DFFFFFF);
}

class Spectrum {
  Spectrum._();

  static const Color deep = Color(0xFF1240C8);
  static const Color blue = Color(0xFF2E7BFF);
  static const Color sky = Color(0xFF3FC4FF);
  static const Color cyan = Color(0xFF2FE8FF);
  static const Color teal = Color(0xFF1FE3BE);
  static const Color amber = Color(0xFFFFB645);
  static const Color ember = Color(0xFFFF7A3C);
  static const Color rose = Color(0xFFFF5E7A);

  static const List<Color> trail = <Color>[deep, blue, sky, cyan, teal];
  static const List<double> trailStops = <double>[0.0, 0.28, 0.55, 0.78, 1.0];

  static const List<Color> heat = <Color>[
    Color(0xFF10245E),
    Color(0xFF1B57C8),
    Color(0xFF2FA8FF),
    Color(0xFF39E6E0),
    Color(0xFFFFC65A),
    Color(0xFFFF7A3C),
  ];
  static const List<double> heatStops = <double>[
    0.0,
    0.22,
    0.42,
    0.62,
    0.82,
    1.0,
  ];
}

class Tone {
  Tone._();

  static const Color bright = Color(0xFFF4F8FF);
  static const Color primary = Color(0xFFDCE6F7);
  static const Color secondary = Color(0xFF93A3BF);
  static const Color muted = Color(0xFF5E6D88);
  static const Color faint = Color(0xFF3A4459);
}

class MapTone {
  MapTone._();

  static const Color land = Color(0xFF080B12);
  static const Color landAlt = Color(0xFF0A0E16);
  static const Color water = Color(0xFF040711);
  static const Color park = Color(0xFF07130F);
  static const Color block = Color(0xFF0D1220);
  static const Color blockLit = Color(0xFF141B2C);
  static const Color roadMinor = Color(0xFF161D2C);
  static const Color roadMajor = Color(0xFF232C40);
  static const Color roadGlow = Color(0x142E7BFF);
  static const Color label = Color(0xFF4A5670);
}
