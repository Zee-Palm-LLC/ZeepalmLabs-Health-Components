import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reforma palette, sampled from the mockup.
abstract final class C {
  static const bg = Color(0xFFF7F3F2);
  static const bgTop = Color(0xFFEFE4F3);
  static const ink = Color(0xFF1F2A30);
  static const ink2 = Color(0xFF4B545A);
  static const muted = Color(0xFF8B9095);
  static const teal = Color(0xFF2F6E62);
  static const tealSoft = Color(0xFFDDEBE6);
  static const lav = Color(0xFFA68CEB);
  static const lavDeep = Color(0xFF8B6FE0);
  static const lavSoft = Color(0xFFEFE8FC);
  static const orange = Color(0xFFF08A4B);
  static const button = Color(0xFF1E2B33);
  static const card = Color(0xD9FFFFFF);
  static const track = Color(0xFFECE9EE);
  static const line = Color(0x14000000);
}

TextStyle inter(double size, FontWeight weight, Color color, {double ls = 0, double height = 1.2, bool tabular = false}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: ls,
      height: height,
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );

const cardShadow = [
  BoxShadow(color: Color(0x0F3B2A55), blurRadius: 24, offset: Offset(0, 8)),
  BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
];
