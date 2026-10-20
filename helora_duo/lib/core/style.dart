import 'package:flutter/widgets.dart';

abstract final class Tone {
  static const canvas = Color(0xFFEEF0F4);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF16181D);
  static const sub = Color(0xFF6B7280);
  static const line = Color(0xFFE4E7EC);
  static const track = Color(0xFFF2F4F7);
  static const slate = Color(0xFF475467);

  static const red = Color(0xFFF04438);
  static const redSoft = Color(0xFFFECDCA);
  static const coral = Color(0xFFF97066);
  static const dueBg = Color(0xFFFEE4E2);
  static const dueInk = Color(0xFFB42318);

  static const deep = Color(0xFF6D28D9);
  static const rem = Color(0xFFA78BFA);
  static const light = Color(0xFFE4DAFF);
  static const awake = Color(0xFFFB8C3C);

  static const hero = Color(0xFF16181D);
  static const heroTrack = Color(0xFF262A31);
  static const heroChip = Color(0xFF2A2E36);
  static const heroSub = Color(0xFFA1A7B3);
  static const heroBar = Color(0xFF7F3A33);
  static const heroRange = Color(0xFFFDA29B);
}

enum Accent {
  red(Color(0xFFFF8F80), Color(0xFFF04438)),
  purple(Color(0xFFC3A6FF), Color(0xFF7C3AED)),
  blue(Color(0xFF8CC4FF), Color(0xFF2F7FEA)),
  orange(Color(0xFFFFC58C), Color(0xFFF97316)),
  ink(Color(0xFF4B5563), Color(0xFF16181D));

  const Accent(this.hi, this.lo);

  final Color hi;
  final Color lo;

  LinearGradient get gradient => LinearGradient(begin: const Alignment(-0.7, -1), end: const Alignment(0.7, 1), colors: [hi, lo]);
}

TextStyle jakarta(double size, double weight, {Color color = Tone.ink, double tracking = 0, double? height}) {
  return TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: size,
    fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
    fontVariations: [FontVariation('wght', weight)],
    fontFeatures: const [FontFeature.tabularFigures()],
    letterSpacing: tracking,
    color: color,
    height: height,
    leadingDistribution: height == null ? null : TextLeadingDistribution.even,
  );
}

abstract final class Typo {
  static final brand = jakarta(18, 700, tracking: -0.36);
  static final date = jakarta(13, 500, color: Tone.sub, height: 18 / 13);
  static final title = jakarta(32, 800, tracking: -0.96, height: 38 / 32);
  static final cardTitle = jakarta(14, 600, height: 20 / 14);
  static final meta = jakarta(12, 500, color: Tone.sub, height: 16 / 12);
  static final value = jakarta(26, 700, tracking: -0.52, height: 30 / 26);
  static final unit = jakarta(13, 500, color: Tone.sub);
  static final context = jakarta(12, 500, color: Tone.sub, height: 18 / 12);
  static final chip = jakarta(12, 600, height: 1);
  static final axis = jakarta(11, 500, color: Tone.sub, height: 14 / 11);
  static final axisNow = jakarta(11, 700, height: 14 / 11);
  static final legend = jakarta(11, 500, color: Tone.sub, height: 14 / 11);
  static final legendValue = jakarta(11, 700, height: 14 / 11);
  static final hero = jakarta(52, 800, color: Tone.card, tracking: -2.08, height: 1);
  static final heroUnit = jakarta(15, 500, color: Tone.heroSub);
  static final tab = jakarta(11, 600, height: 14 / 11);
  static final row = jakarta(14, 600, height: 20 / 14);
  static final tip = jakarta(12, 500, color: Tone.card, height: 16 / 12);
  static final tipStrong = jakarta(12, 700, color: Tone.card, height: 16 / 12);
}
