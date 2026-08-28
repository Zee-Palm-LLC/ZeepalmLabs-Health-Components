import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

abstract final class DashboardCopy {
  static const greeting = 'Stay Healthy';
  static const userName = 'Jenny Wilson';
  static const planTitle = 'Health Assistant Plan';
  static const planBody =
      'Unlock your AI Health Assistant and access all health features';
  static const planCta = 'Upgrade Health Plan';
  static const quickTitle = 'Quick Health Access';
  static const quickSeeAll = 'See all';
  static const slideLabel = 'Start Health Check';
  static const insightTitle = 'Aira Insight';
  static const insightBody =
      'Your sleep quality improved 12% this week. A short walk after lunch can help maintain energy.';
  static const activityTitle = 'Recent Activity';
}

class QuickAccessItem {
  const QuickAccessItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.badge,
    required this.meta,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String badge;
  final String meta;
}

class HealthStatItem {
  const HealthStatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accent,
    required this.trend,
    required this.progress,
    required this.goalLabel,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accent;
  final String trend;
  final double progress;
  final String goalLabel;
}

class ActivityItem {
  const ActivityItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.accent,
    required this.status,
  });

  final String title;
  final String time;
  final IconData icon;
  final Color accent;
  final String status;
}

abstract final class DashboardData {
  static const planFeatures = [
    '24/7 AI chat support',
    'Unlimited health scans',
    'Personal wellness reports',
  ];

  static const healthStats = [
    HealthStatItem(
      label: 'Heart',
      value: '72',
      unit: 'bpm',
      icon: Iconsax.heart,
      accent: Color(0xFFFF7A96),
      trend: '+2%',
      progress: 0.72,
      goalLabel: 'Resting zone',
    ),
    HealthStatItem(
      label: 'Steps',
      value: '8.4k',
      unit: 'today',
      icon: Iconsax.activity,
      accent: Color(0xFF7B8CFF),
      trend: '+18%',
      progress: 0.84,
      goalLabel: 'Goal 10k',
    ),
    HealthStatItem(
      label: 'Sleep',
      value: '7.5',
      unit: 'hrs',
      icon: Iconsax.moon,
      accent: Color(0xFFB07CFF),
      trend: '+12%',
      progress: 0.94,
      goalLabel: 'Target 8h',
    ),
  ];

  static const quickAccess = [
    QuickAccessItem(
      title: 'Symptoms',
      subtitle: 'Tell Symptoms Voice',
      icon: Iconsax.sound,
      accent: Color(0xFFFF8FAB),
      badge: 'Voice ready',
      meta: 'Last used 2h ago',
    ),
    QuickAccessItem(
      title: 'Reports',
      subtitle: 'Scan Medical Report',
      icon: Iconsax.scan,
      accent: Color(0xFF7B9BFF),
      badge: '3 new',
      meta: '2 pending review',
    ),
    QuickAccessItem(
      title: 'Consult',
      subtitle: 'Recent Health Consult',
      icon: Iconsax.health,
      accent: Color(0xFF9B7BFF),
      badge: 'Live',
      meta: 'Dr. Aira online',
    ),
    QuickAccessItem(
      title: 'Tools',
      subtitle: 'View Health Tools',
      icon: Iconsax.magic_star,
      accent: Color(0xFFFFB86B),
      badge: '6 tools',
      meta: 'BMI · Meds · More',
    ),
  ];

  static const recentActivity = [
    ActivityItem(
      title: 'Morning check-in',
      time: '8:12 AM',
      icon: Iconsax.tick_circle,
      accent: Color(0xFF6ED6A0),
      status: 'Completed',
    ),
    ActivityItem(
      title: 'Hydration goal',
      time: '10:40 AM',
      icon: Iconsax.drop,
      accent: Color(0xFF6EB8FF),
      status: '6/8 glasses',
    ),
    ActivityItem(
      title: 'Mood log',
      time: '1:05 PM',
      icon: Iconsax.emoji_happy,
      accent: Color(0xFFFFB4D6),
      status: 'Feeling calm',
    ),
  ];
}

String dashboardGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}
