import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const bgTop = Color(0xFF060A16);
  static const bgMid = Color(0xFF0A1122);
  static const bgBottom = Color(0xFF0C1428);

  static const card = Color(0xFF121B31);
  static const cardSoft = Color(0xFF16203A);
  static const stroke = Color(0x1FFFFFFF);
  static const strokeSoft = Color(0x14FFFFFF);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9AA7C4);
  static const textTertiary = Color(0xFF6B7899);

  static const indigo = Color(0xFF6366F1);
  static const violet = Color(0xFF8B5CF6);
  static const purple = Color(0xFFA855F7);
  static const magenta = Color(0xFFEC4899);
  static const cyan = Color(0xFF22D3EE);
  static const blue = Color(0xFF3B82F6);
  static const green = Color(0xFF34D399);
  static const amber = Color(0xFFFBBF24);
  static const orange = Color(0xFFF97316);
  static const rose = Color(0xFFF43F5E);

  static const scaffold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgMid, bgBottom],
    stops: [0.0, 0.55, 1.0],
  );

  static const primaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899)],
  );

  static const accentEdge = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x998B5CF6), Color(0x2222D3EE), Color(0x00000000)],
  );

  static const glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x26FFFFFF), Color(0x0DFFFFFF)],
  );

  static const sheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xCC141E36), Color(0x99101828)],
  );

  static LinearGradient tintedEdge(Color color) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.55),
          color.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      );
}
