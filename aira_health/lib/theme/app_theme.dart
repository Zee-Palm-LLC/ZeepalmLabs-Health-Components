import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiraColors {
  AiraColors._();

  static const Color ink = Color(0xFF2B2433);
  static const Color muted = Color(0xFF8B8194);
  static const Color blush = Color(0xFFF4D7E4);
  static const Color lilac = Color(0xFFE8D7F4);
  static const Color mist = Color(0xFFF7F2F8);
  static const Color glass = Color(0xCCFFFFFF);
}

class AiraType {
  AiraType._();

  static TextStyle display({double size = 28}) => GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: AiraColors.ink,
    letterSpacing: -0.6,
  );

  static TextStyle title({double size = 16}) => GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: AiraColors.ink,
  );

  static TextStyle body({double size = 13, Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? AiraColors.muted,
        height: 1.45,
      );
}
