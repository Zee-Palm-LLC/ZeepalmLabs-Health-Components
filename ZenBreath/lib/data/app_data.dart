import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

class AppImages {
  const AppImages._();

  static const _unsplash = 'https://images.unsplash.com/';
  static const _card = '?auto=format&fit=crop&w=800&q=70';
  static const _thumb = '?auto=format&fit=crop&w=240&q=70';
  static const welcomeBackground = 'assets/images/welcome_bg.jpg';
  static const homeHeader = '${_unsplash}photo-1506905925346-21bda4d32df4$_card';
  static const avatar = '${_unsplash}photo-1494790108377-be9c29b29330$_thumb';
  static const quickStart = '${_unsplash}photo-1506905925346-21bda4d32df4$_thumb';

  static List<String> get all => [
    welcomeBackground,
    homeHeader,
    avatar,
    quickStart,
    for (final meditation in kMeditations) meditation.image,
  ];
}

class Meditation {
  const Meditation({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.image,
    required this.fallback,
    required this.category,
  });

  final String title;
  final String subtitle;
  final String duration;
  final String image;
  final List<Color> fallback;
  final String category;
}

const kMeditationFilters = <String>['All', 'Stress', 'Sleep', 'Focus', 'Self Care'];

const _card = '?auto=format&fit=crop&w=600&q=70';

const kMeditations = <Meditation>[
  Meditation(
    title: 'Anxiety Relief',
    subtitle: 'Calm your mind',
    duration: '10 min',
    image: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773$_card',
    fallback: [Color(0xFFDCE9EE), Color(0xFFB6CBD6)],
    category: 'Stress',
  ),
  Meditation(
    title: 'Deep Sleep',
    subtitle: 'Rest & recharge',
    duration: '20 min',
    image: 'https://images.unsplash.com/photo-1419242902214-272b3f66ee7a$_card',
    fallback: [Color(0xFF2C4A6B), Color(0xFF16283F)],
    category: 'Sleep',
  ),
  Meditation(
    title: 'Focus',
    subtitle: 'Clear your thoughts',
    duration: '15 min',
    image: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05$_card',
    fallback: [Color(0xFF9FB6C6), Color(0xFF5D7789)],
    category: 'Focus',
  ),
  Meditation(
    title: 'Relaxation',
    subtitle: 'Let go of tension',
    duration: '15 min',
    image: 'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8$_card',
    fallback: [Color(0xFFE7B98A), Color(0xFF9E7E6B)],
    category: 'Self Care',
  ),
  Meditation(
    title: 'Morning Energy',
    subtitle: 'Start your day right',
    duration: '10 min',
    image: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee$_card',
    fallback: [Color(0xFFE9BE86), Color(0xFF8E6F55)],
    category: 'Focus',
  ),
  Meditation(
    title: 'Stress Reset',
    subtitle: 'Find your balance',
    duration: '12 min',
    image: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e$_card',
    fallback: [Color(0xFF6E9455), Color(0xFF33502C)],
    category: 'Stress',
  ),
];

class SettingsRow {
  const SettingsRow({
    required this.icon,
    required this.title,
    this.value,
    this.valueColor = AppColors.textSecondary,
    this.showDot = false,
    this.showChevron = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final Color valueColor;
  final bool showDot;
  final bool showChevron;
}

const kPreferenceRows = <SettingsRow>[
  SettingsRow(icon: LucideIcons.bell, title: 'Reminders', value: 'Daily • 8:00 AM'),
  SettingsRow(
    icon: LucideIcons.watch,
    title: 'Connected Devices',
    value: 'Apple Watch\nConnected',
    valueColor: AppColors.green,
    showDot: true,
  ),
  SettingsRow(icon: LucideIcons.volume2, title: 'Sound Preferences', value: 'Nature Sounds'),
  SettingsRow(icon: LucideIcons.contrast, title: 'Display & Appearance', value: 'Dark Mode'),
  SettingsRow(
    icon: LucideIcons.wind,
    title: 'Breathing Customization',
    value: '4-7-8 (Default)',
  ),
];

const kSupportRows = <SettingsRow>[
  SettingsRow(icon: LucideIcons.circleHelp, title: 'Help & Support', showChevron: true),
  SettingsRow(icon: LucideIcons.fileText, title: 'Terms & Privacy', showChevron: true),
];
