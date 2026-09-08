import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/kinora_colors.dart';
import '../../landing_page/components/math_motion.dart';
import 'reveal.dart';

class ActivityItem {
  const ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.unit,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String unit;
  final Color color;
}

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  static const items = <ActivityItem>[
    ActivityItem(
      icon: LucideIcons.sport_shoe,
      title: 'Walking',
      subtitle: 'Today at 12:43pm',
      value: '7890',
      unit: 'Steps',
      color: KinoraColors.lime,
    ),
    ActivityItem(
      icon: LucideIcons.dumbbell,
      title: 'Workout',
      subtitle: 'Yesterday at 6:00pm',
      value: '72',
      unit: 'Min',
      color: KinoraColors.orange,
    ),
    ActivityItem(
      icon: LucideIcons.bike,
      title: 'Cycling',
      subtitle: '2 May at 8:15am',
      value: '23.4',
      unit: 'Km',
      color: KinoraColors.lime,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Recent Activity',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: KinoraColors.text,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              Text(
                'See all',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KinoraColors.lime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Reveal(
              delay: revealDelay(i + 2, stepMs: 70),
              offset: const Offset(0, 20),
              scaleFrom: 0.94,
              twist: 0.015,
              child: _ActivityTile(item: items[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityTile extends StatefulWidget {
  const _ActivityTile({required this.item});

  final ActivityItem item;

  @override
  State<_ActivityTile> createState() => _ActivityTileState();
}

class _ActivityTileState extends State<_ActivityTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        HapticFeedback.selectionClick();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) {
          final t = MathMotion.smootherstep(_press.value);
          return Transform.scale(
            scale: 1 - 0.025 * t,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
          decoration: BoxDecoration(
            color: KinoraColors.cardSoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      item.color.withValues(alpha: 0.28),
                      item.color.withValues(alpha: 0.10),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.22),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(item.icon, size: 22, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: KinoraColors.text,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: KinoraColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.value,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: KinoraColors.text,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.unit,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: KinoraColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
