import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../theme/nutrx_colors.dart';
import '../../../theme/nutrx_text.dart';
import 'reveal.dart';

class WorkoutSection extends StatefulWidget {
  const WorkoutSection({super.key});

  @override
  State<WorkoutSection> createState() => _WorkoutSectionState();
}

class _WorkoutSectionState extends State<WorkoutSection> {
  static const _chips = ['All types', 'Full body', 'Upper', 'Lower'];
  static const _workouts = [
    _Workout(
      title: 'Upper body',
      subtitle: 'Shoulders, biceps, triceps',
      duration: '30 min',
      kcal: '140-300 kcal',
      image:
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=640&q=80',
    ),
    _Workout(
      title: 'Stretching',
      subtitle: 'Flexibility, mobility, recovery',
      duration: '20 min',
      kcal: '80-160 kcal',
      image:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=640&q=80',
    ),
    _Workout(
      title: 'Full body',
      subtitle: 'Strength, cardio, endurance',
      duration: '45 min',
      kcal: '250-420 kcal',
      image:
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=640&q=80',
    ),
  ];

  int _chip = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(
          delay: revealDelay(3),
          child: Text('Find your workout', style: NutrxText.section),
        ),
        const SizedBox(height: 14),
        Reveal(
          delay: revealDelay(4),
          offset: const Offset(0, 16),
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final selected = _chip == i;
                return GestureDetector(
                  onTap: () => setState(() => _chip = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? NutrxColors.yellow : NutrxColors.chip,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: NutrxColors.yellow.withValues(alpha: 0.28),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      _chips[i],
                      style: NutrxText.chip.copyWith(
                        color: selected
                            ? NutrxColors.onYellow
                            : NutrxColors.text,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < _workouts.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Reveal(
            delay: revealDelay(5 + i, stepMs: 90),
            offset: const Offset(0, 28),
            scaleFrom: 0.96,
            child: _WorkoutCard(data: _workouts[i]),
          ),
        ],
      ],
    );
  }
}

class _Workout {
  const _Workout({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.kcal,
    required this.image,
  });

  final String title;
  final String subtitle;
  final String duration;
  final String kcal;
  final String image;
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.data});

  final _Workout data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      decoration: BoxDecoration(
        color: NutrxColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            flex: 11,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title, style: NutrxText.workoutTitle),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NutrxText.body,
                  ),
                  const Spacer(),
                  _Meta(icon: LucideIcons.clock, label: data.duration),
                  const SizedBox(height: 6),
                  _Meta(icon: LucideIcons.droplet, label: data.kcal),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Image.network(
                    data.image,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.15, -0.1),
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: NutrxColors.cardSoft,
                      child: Center(
                        child: Icon(
                          LucideIcons.dumbbell,
                          color: NutrxColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        NutrxColors.card,
                        Color(0x591A1C22),
                        Colors.transparent,
                      ],
                      stops: [0, 0.28, 0.55],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: NutrxColors.textMuted),
        const SizedBox(width: 6),
        Text(label, style: NutrxText.meta),
      ],
    );
  }
}
