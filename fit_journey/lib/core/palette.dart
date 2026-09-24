import 'package:flutter/material.dart';

class Palette {
  static const navy = Color(0xFF0C2B47);
  static const midnight = Color(0xFF11213A);
  static const slate = Color(0xFF273A4E);
  static const steel = Color(0xFF566474);
  static const mist = Color(0xFF7A8593);
  static const fog = Color(0xFF8A94A2);
  static const haze = Color(0xFFCFD9E4);

  static const page = Color(0xFFFBFDFF);
  static const canvas = Color(0xFFF7FAFD);
  static const card = Color(0xFFFFFFFF);

  static const deepTeal = Color(0xFF024B62);
  static const lagoon = Color(0xFF087278);
  static const emerald = Color(0xFF019C80);
  static const mint = Color(0xFF00B486);
  static const jade = Color(0xFF05AB83);
  static const fern = Color(0xFF00A382);
  static const track = Color(0xFFE9F4F2);

  static const cobalt = Color(0xFF0A6DF0);
  static const route = Color(0xFF1479EE);
  static const sun = Color(0xFFFCB208);
  static const coral = Color(0xFFFF5B55);
  static const ember = Color(0xFFF7821B);

  static const wordNavy = Color(0xFF0E3A52);
  static const wordGreenA = Color(0xFF0A9E86);
  static const wordGreenB = Color(0xFF1FC291);

  static const shadow = Color(0xFF1D3A5C);
}

class Swatch {
  const Swatch(this.core, this.halo, [this.glow]);

  final Color core;
  final Color halo;
  final Color? glow;

  Color get light => Color.lerp(core, Colors.white, 0.22)!;

  Color get deep => Color.lerp(core, Colors.black, 0.12)!;

  static const run = Swatch(Color(0xFF03BD8B), Color(0xFF6ADDBC));
  static const gym = Swatch(Color(0xFF7839EA), Color(0xFFD6C5F7));
  static const park = Swatch(Color(0xFF52BA09), Color(0xFFC3E497));
  static const water = Swatch(Color(0xFF0B86FA), Color(0xFFA3CDF6));
  static const yoga = Swatch(Color(0xFFE445AB), Color(0xFFF7A2D9));
  static const sunrise = Swatch(Color(0xFFF7821B), Color(0xFFFBCB98));
  static const heart = Swatch(Color(0xFFF0476A), Color(0xFFF9B1C1));
  static const night = Swatch(Color(0xFF3446D8), Color(0xFFB9C1F5));
  static const teal = Swatch(Color(0xFF0E9AA8), Color(0xFF9CDDE3));
}
