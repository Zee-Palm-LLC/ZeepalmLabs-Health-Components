import 'package:flutter/material.dart';

abstract final class AppColors {
  static const bg = Color(0xFFF8F9FE);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8ECF4);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const blue = Color(0xFF2E5BFF);
  static const blueLight = Color(0xFF1DA1F2);
  static const purple = Color(0xFF7C3AED);
  static const success = Color(0xFF22C55E);
  static const successSoft = Color(0xFFDCFCE7);
  static const successText = Color(0xFF16A34A);
  static const heart = Color(0xFFEF4444);
  static const heartSoft = Color(0xFFFEE2E2);
  static const bp = Color(0xFF3B82F6);
  static const bpSoft = Color(0xFFDBEAFE);
  static const oxygen = Color(0xFF10B981);
  static const oxygenSoft = Color(0xFFD1FAE5);
  static const calories = Color(0xFFF97316);
  static const caloriesSoft = Color(0xFFFFEDD5);
  static const sleep = Color(0xFF8B5CF6);
  static const sleepSoft = Color(0xFFEDE9FE);
  static const stress = Color(0xFFF59E0B);
  static const stressSoft = Color(0xFFFEF3C7);
  static const water = Color(0xFF38BDF8);
  static const waterEmpty = Color(0xFFE5E7EB);
  static const navInactive = Color(0xFF9CA3AF);
  static const white = Color(0xFFFFFFFF);
  static const shadow = Color(0x0D000000);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E5BFF), Color(0xFF6366F1), Color(0xFF7C3AED)],
  );

  static const buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2E5BFF), Color(0xFF6366F1)],
  );
}
