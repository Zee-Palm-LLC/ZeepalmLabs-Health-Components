import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:physio_motion/theme/app_colors.dart';

/// Compact 7-day streak strip — social-share friendly, one-job section.
class HomeStreakStrip extends StatelessWidget {
  const HomeStreakStrip({
    super.key,
    this.streakDays = 5,
    this.done = const [true, true, true, true, true, false, false],
    this.labels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
  });

  final int streakDays;
  final List<bool> done;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEKLY STREAK',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$streakDays',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          letterSpacing: -0.6,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '  days hot',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                _DayDot(
                  label: labels[i],
                  active: i < done.length && done[i],
                  today: i == streakDays - 1,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.label,
    required this.active,
    required this.today,
  });

  final String label;
  final bool active;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final bg = active ? AppColors.lime : AppColors.bg;
    final fg = active ? AppColors.dark : AppColors.textSecondary;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: today
                ? Border.all(color: AppColors.dark, width: 1.4)
                : null,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.lime.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: active
              ? const Icon(Icons.check, size: 12, color: AppColors.dark)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ],
    );
  }
}
