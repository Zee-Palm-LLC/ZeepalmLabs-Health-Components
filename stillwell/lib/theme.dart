import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colours measured from the reference recording.
abstract final class Tone {
  static const canvas = Color(0xFFF4F2EE);
  static const surface = Color(0xFFFFFFFF);
  static const chip = Color(0xFFF3F1EE);
  static const text = Color(0xFF232221);
  static const soft = Color(0xFF8B8783);
  static const faint = Color(0xFFA9A5A1);
  static const hair = Color(0xFFE6E2DD);
  static const dot = Color(0xFFCBC7C2);
  static const night = Color(0xFF1D1D1C);
  static const alert = Color(0xFFF0453A);
}

/// The five sessions, with their orb and card palettes.
enum Mood {
  lilac(Color(0xFFB7A4F3), Color(0xFFD9CCFA), Color(0xFF8D73E8)),
  orange(Color(0xFFF2692A), Color(0xFFF9A879), Color(0xFFE2541A)),
  green(Color(0xFFA6CF83), Color(0xFFCDE6B5), Color(0xFF7FB55A)),
  sky(Color(0xFF8FB4F0), Color(0xFFC6D9F8), Color(0xFF5F8FE0)),
  rose(Color(0xFFF2A0B8), Color(0xFFF8CBD8), Color(0xFFE47596)),
  peach(Color(0xFFF5BE7E), Color(0xFFFBDDB6), Color(0xFFEDA055)),
  amber(Color(0xFFF3A23C), Color(0xFFFBCB86), Color(0xFFE5801C));

  const Mood(this.base, this.light, this.deep);

  final Color base;
  final Color light;
  final Color deep;
}

/// Inter Tight for everything readable, Geist Mono for counters (and, as dots, the clock).
TextStyle sans(double size, {FontWeight weight = FontWeight.w400, Color color = Tone.text, double? height, double spacing = 0}) =>
    GoogleFonts.interTight(fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: spacing);

TextStyle mono(double size, {FontWeight weight = FontWeight.w300, Color color = Colors.white, double spacing = 0}) =>
    GoogleFonts.geistMono(fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing, height: 1);

/// Soft lift used by every white surface.
const softShadow = [
  BoxShadow(color: Color(0x0D2A1E10), blurRadius: 24, offset: Offset(0, 8)),
  BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
];
