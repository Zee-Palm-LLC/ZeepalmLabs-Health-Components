import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette sampled from the reference video (warm blush off-white UI).
abstract final class W {
  static const bg = Color(0xFFF3E4DE);
  static const ink = Color(0xFF2A2321);
  static const muted = Color(0xFFB5A29C);
  static const hint = Color(0xFFA9958F);
  static const status = Color(0xFF9E8D88);
  static const googleBtn = Color(0xFFFCF3EF);
  static const googleLine = Color(0xFFEAD9D2);
  static const appleBtn = Color(0xFF1E1615);
  static const tagline = Color(0xFFA9918A); // second headline line
  static const body = Color(0xFF7D6A65); // description copy
  static const accent = Color(0xFFB8607A); // muted rose for small accents
}

TextStyle sf(double size, {Color color = W.ink, FontWeight w = FontWeight.w400, double height = 1.3, double ls = 0}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: w, color: color, height: height, letterSpacing: ls);

/// Phosphor glyphs (font in assets/fonts, MIT).
abstract final class Ph {
  static const apple = IconData(0xe516, fontFamily: 'PhosphorFill');
  static const signal = IconData(0xe142, fontFamily: 'PhosphorFill');
  static const wifi = IconData(0xe4ea, fontFamily: 'PhosphorFill');
  static const battery = IconData(0xe0c0, fontFamily: 'PhosphorFill');
  static const sparkle = IconData(0xe6a2, fontFamily: 'PhosphorFill');
  static const lock = IconData(0xe2fe, fontFamily: 'PhosphorFill');
  static const heartbeat = IconData(0xe2ac, fontFamily: 'PhosphorFill');
  static const gift = IconData(0xe276, fontFamily: 'PhosphorFill');
  static const handTap = IconData(0xec90, fontFamily: 'PhosphorFill');
  static const handGrabbing = IconData(0xe57c, fontFamily: 'PhosphorFill');
  static const handSwipeLeft = IconData(0xec94, fontFamily: 'PhosphorFill');
}
