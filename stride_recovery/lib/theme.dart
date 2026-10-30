import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette sampled from the design: icy blue-white page, navy ink, sky-blue
/// accents and warm orange for streaks and pain hotspots.
abstract final class C {
  static const bgTop = Color(0xFFE8F1FB);
  static const bgBottom = Color(0xFFF7FAFE);
  static const ink = Color(0xFF0E1A2B);
  static const sub = Color(0xFF66768C);
  static const hint = Color(0xFF9AA6B6);
  static const line = Color(0xFFE6ECF3);
  static const card = Color(0xFFFFFFFF);
  static const blue = Color(0xFF2F8CF0);
  static const sky = Color(0xFF8FD3FF);
  static const track = Color(0xFFE4F0FB);
  static const orange = Color(0xFFFF8A1F);
  static const amber = Color(0xFFF2A51C);
  static const green = Color(0xFF22B573);
  static const red = Color(0xFFFF4D4F);
}

TextStyle tx(double size, {Color color = C.ink, FontWeight w = FontWeight.w400, double height = 1.25, double ls = 0}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: w, color: color, height: height, letterSpacing: ls);

double clamp01(double v) => v.clamp(0.0, 1.0);

/// Progress of [v] through the window [a, b], eased.
double win(double v, double a, double b, [Curve curve = Curves.easeOutCubic]) => curve.transform(clamp01((v - a) / (b - a)));
