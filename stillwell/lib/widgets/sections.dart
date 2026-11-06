import 'package:flutter/material.dart';

import '../theme.dart';
import 'orb.dart';

/// White surface with the shared radius and lift.
class Surface extends StatelessWidget {
  const Surface({super.key, required this.child, this.padding = EdgeInsets.zero, this.height});

  final Widget child;
  final EdgeInsets padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(color: Tone.surface, borderRadius: BorderRadius.circular(24), boxShadow: softShadow),
      child: child,
    );
  }
}

class WeekCard extends StatelessWidget {
  const WeekCard({super.key});

  static const _days = [
    ('M', Mood.green),
    ('T', Mood.lilac),
    ('W', null),
    ('T', Mood.peach),
    ('F', null),
    ('S', Mood.lilac),
    ('S', Mood.amber),
  ];

  @override
  Widget build(BuildContext context) {
    return Surface(
      height: 121,
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 0),
      child: Column(
        children: [
          Row(
            children: [
              Text('Workouts this week', style: sans(15.3, spacing: -0.2)),
              const Spacer(),
              const Icon(Icons.local_fire_department_rounded, size: 14, color: Tone.night),
              const SizedBox(width: 3),
              Text('4 of 5 goal', style: sans(11.9, color: const Color(0xFF6F6B67))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [for (final (i, (day, mood)) in _days.indexed) _Day(day: day, mood: mood, today: i == _days.length - 1)],
          ),
        ],
      ),
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({required this.day, required this.mood, required this.today});

  final String day;
  final Mood? mood;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final m = mood;
    return SizedBox(
      width: 36,
      child: Column(
        children: [
          SizedBox.square(
            dimension: 34,
            child: m == null
                ? const DashedRing(size: 34)
                : CustomPaint(
                    painter: OrbPainter(base: m.base, light: m.light, deep: m.deep, glow: today ? 1.3 : 0.7),
                    child: Center(
                      child: today
                          ? Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            )
                          : const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                    ),
                  ),
          ),
          const SizedBox(height: 7),
          Text(
            day,
            style: sans(11, weight: today ? FontWeight.w600 : FontWeight.w400, color: today ? Tone.text : Tone.soft),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 20),
      child: Row(
        children: [
          Text(title, style: sans(19.5, spacing: -0.4, color: const Color(0xFF2B2A28))),
          const Spacer(),
          if (action != null) Text(action!, style: sans(11.4, color: const Color(0xFF77736F))),
        ],
      ),
    );
  }
}

class Chip extends StatelessWidget {
  const Chip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      padding: const EdgeInsets.only(left: 8, right: 10),
      decoration: BoxDecoration(color: Tone.chip, borderRadius: BorderRadius.circular(13)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Tone.night),
          const SizedBox(width: 4),
          Text(label, style: sans(10.9, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}
