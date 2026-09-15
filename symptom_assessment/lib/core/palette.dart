import 'package:flutter/widgets.dart';

/// Colours, lifted from the reference frames.
///
/// The page is a cool mint wash that fades to white; ink is a near-black
/// slate rather than pure black; the one accent is a leaf green, with a warm
/// orange used only where the design uses it (the padlock, a pill).
class Slate {
  Slate._();

  static const Color primary = Color(0xFF1F272C);
  static const Color secondary = Color(0xFF3A4247);
  static const Color muted = Color(0xFF8A9391);
  static const Color faint = Color(0xFFB4BBBA);
}

class Paper {
  Paper._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color washTop = Color(0xFFE0F2F4);
  static const Color washMid = Color(0xFFF1F7F3);
  static const Color card = Color(0xFFFFFFFF);
  static const Color tile = Color(0xFFF6F6F7);
  static const Color chip = Color(0xFFF5F6F6);
  static const Color edge = Color(0xFFE9ECEC);
  static const Color halo = Color(0xFFE9F3F4);
  static const Color haloInner = Color(0xFFF3F9FA);
  static const Color mintCard = Color(0xFFE4F7EA);
  static const Color mintCardEnd = Color(0xFFEFF7F2);
  static const Color reportCard = Color(0xFFE2F1F2);
  static const Color reportCardEnd = Color(0xFFEAF6F7);
}

class Leaf {
  Leaf._();

  static const Color bright = Color(0xFF8FD689);
  static const Color base = Color(0xFF7BCD73);
  static const Color deep = Color(0xFF63BB5C);
  static const Color soft = Color(0xFFE3F5E1);
  static const Color border = Color(0xFFA7D4A4);
  static const Color glow = Color(0x668FD689);
  static const Color orange = Color(0xFFF29A3C);
  static const Color sky = Color(0xFF6DB7E8);
  static const Color alert = Color(0xFFE8613C);

  static const LinearGradient button = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFF93D98C), Color(0xFF74C86C)],
  );

  static const LinearGradient mic = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFFA9DEA3), Color(0xFF7CCB74)],
  );
}
