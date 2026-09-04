import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medicify/theme/app_colors.dart';

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.progress,
    required this.step,
  });

  /// 0.0 → 1.0
  final double progress;
  final int step;

  static const _chapters = [
    (0, 2, 'Personalize'),
    (3, 3, 'About you'),
    (4, 5, 'Body'),
  ];

  int get _activeChapter {
    for (var i = 0; i < _chapters.length; i++) {
      final (from, to, _) = _chapters[i];
      if (step >= from && step <= to) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeChapter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 8,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.border.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.clamp(0.08, 1.0)),
                duration: const Duration(milliseconds: 480),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          colors: [AppColors.purple, AppColors.purpleDeep],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withValues(alpha: 0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < _chapters.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 9,
                    color: AppColors.textSecondary.withValues(alpha: 0.35),
                  ),
                ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: i == active ? FontWeight.w800 : FontWeight.w500,
                  letterSpacing: i == active ? 0.1 : 0,
                  color: i == active
                      ? AppColors.purple
                      : i < active
                          ? AppColors.textPrimary.withValues(alpha: 0.45)
                          : AppColors.textSecondary.withValues(alpha: 0.4),
                ),
                child: Text(_chapters[i].$3),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
