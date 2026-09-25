import 'package:flutter/painting.dart';

abstract final class Palette {
  static const night = Color(0xFF000817);
  static const nightTop = Color(0xFF010D25);
  static const nightLow = Color(0xFF010611);
  static const abyss = Color(0xFF000512);

  static const snow = Color(0xFFF1F3F8);
  static const frost = Color(0xFFD8DDE7);
  static const mist = Color(0xFFA6B0C8);
  static const haze = Color(0xFF7B86A3);
  static const dusk = Color(0xFF69738B);

  static const violet = Color(0xFF8D4EF7);
  static const lilac = Color(0xFF9A7BFF);
  static const orchid = Color(0xFFB08CFF);
  static const mint = Color(0xFF2CDAA2);
  static const jade = Color(0xFF3BC692);
  static const amber = Color(0xFFFCA743);
  static const tangerine = Color(0xFFFDA544);
  static const rose = Color(0xFFED4053);
  static const sky = Color(0xFF4C8DFF);
  static const cyan = Color(0xFF7FE9F2);
  static const gold = Color(0xFFF2B34A);

  static const card = Color(0xFF0B1837);
  static const cardEdge = Color(0xFF223457);
  static const field = Color(0xFF0F1E3F);
  static const fieldEdge = Color(0xFF1C2D52);

  static const cta = [
    Color(0xFF4533FC),
    Color(0xFF6435FC),
    Color(0xFF8A47F7),
    Color(0xFFB648E7),
    Color(0xFFD647CA),
    Color(0xFFF4569F),
    Color(0xFFFF6D78),
  ];
  static const ctaStops = [0.0, 0.18, 0.4, 0.55, 0.68, 0.84, 1.0];

  static const headlineTop = [Color(0xFFDDD1F7), Color(0xFFE6D3F8), Color(0xFFF8E3F9)];
  static const headlineLow = [Color(0xFF9D8BF7), Color(0xFFB08FF4), Color(0xFFD790F7), Color(0xFFF398EA)];
}
