import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette sampled from the Compass Care mockups.
abstract final class C {
  static const red = Color(0xFFF0473A); // saturated coral (top-right of the sky)
  static const redDeep = Color(0xFFE23B2E);
  static const orange = Color(0xFFFF7E55);
  static const peach = Color(0xFFFFB59F);
  static const blush = Color(0xFFFBD3CA); // lower sky / setup wash
  static const blushSoft = Color(0xFFFDE8E3);
  static const tagBg = Color(0xFFFDE3DD);
  static const ink = Color(0xFF22262B);
  static const ink2 = Color(0xFF4A4F55);
  static const muted = Color(0xFF8A8F95);
  static const line = Color(0xFFE9E3E1);
  static const button = Color(0xFF1E242A);
  static const card = Color(0xFFFFFFFF);
  static const blue = Color(0xFF4F7CF2);
  static const green = Color(0xFF33B26B);
  static const purple = Color(0xFF8E5CF4);
  static const amber = Color(0xFFE08A3C);
}

/// Display sans for titles (tight, slightly condensed tracking).
TextStyle title(double size, {Color color = C.ink, FontWeight w = FontWeight.w500, double height = 1.12}) =>
    GoogleFonts.interTight(fontSize: size, fontWeight: w, color: color, letterSpacing: -size * 0.035, height: height);

/// UI sans for body copy and buttons.
TextStyle sans(double size, {Color color = C.ink, FontWeight w = FontWeight.w400, double height = 1.35, double ls = 0}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: w, color: color, height: height, letterSpacing: ls);

/// Book serif used on option labels, tags and the finale title.
TextStyle serif(double size, {Color color = C.ink, FontWeight w = FontWeight.w400, double height = 1.25}) =>
    GoogleFonts.sourceSerif4(fontSize: size, fontWeight: w, color: color, height: height, letterSpacing: -0.1);

const softShadow = [
  BoxShadow(color: Color(0x14B4442F), blurRadius: 24, offset: Offset(0, 10)),
  BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
];
