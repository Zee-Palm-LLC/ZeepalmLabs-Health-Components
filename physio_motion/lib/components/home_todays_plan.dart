import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:physio_motion/theme/app_colors.dart';

enum PlanStepState { done, active, upcoming }

class PlanStep {
  const PlanStep({
    required this.time,
    required this.title,
    required this.duration,
    required this.icon,
    required this.state,
  });

  final String time;
  final String title;
  final String duration;
  final IconData icon;
  final PlanStepState state;
}

class HomeTodaysPlan extends StatefulWidget {
  const HomeTodaysPlan({
    super.key,
    this.onViewAll,
    this.steps = const [
      PlanStep(
        time: '9:00 AM',
        title: 'Mobility',
        duration: '15 min',
        icon: Iconsax.people,
        state: PlanStepState.done,
      ),
      PlanStep(
        time: '12:00 PM',
        title: 'Strength',
        duration: '20 min',
        icon: Iconsax.weight,
        state: PlanStepState.active,
      ),
      PlanStep(
        time: '4:00 PM',
        title: 'Therapy',
        duration: '15 min',
        icon: Iconsax.flash_1,
        state: PlanStepState.upcoming,
      ),
      PlanStep(
        time: '7:00 PM',
        title: 'Complete',
        duration: '',
        icon: Iconsax.tick_circle,
        state: PlanStepState.upcoming,
      ),
    ],
  });

  final VoidCallback? onViewAll;
  final List<PlanStep> steps;

  @override
  State<HomeTodaysPlan> createState() => _HomeTodaysPlanState();
}

class _HomeTodaysPlanState extends State<HomeTodaysPlan>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Today's Plan",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: widget.onViewAll,
              child: Text(
                'View all',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cobalt,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.steps.length; i++) ...[
                _PlanTimelineItem(
                  step: widget.steps[i],
                  pulse: _pulse,
                ),
                if (i < widget.steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 34),
                    child: SizedBox(
                      width: 28,
                      height: 2,
                      child: CustomPaint(
                        painter: _ConnectorPainter(
                          color: widget.steps[i].state == PlanStepState.done
                              ? AppColors.lime
                              : AppColors.softGray,
                          dashed: widget.steps[i].state != PlanStepState.done,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanTimelineItem extends StatelessWidget {
  const _PlanTimelineItem({required this.step, required this.pulse});

  final PlanStep step;
  final Animation<double> pulse;

  Color get _circleColor => switch (step.state) {
        PlanStepState.done => AppColors.lime,
        PlanStepState.active => AppColors.cobalt,
        PlanStepState.upcoming => AppColors.softGray,
      };

  Color get _iconColor => switch (step.state) {
        PlanStepState.done => AppColors.textPrimary,
        PlanStepState.active => AppColors.white,
        PlanStepState.upcoming => AppColors.textPrimary,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 16,
            child: Text(
              step.time,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: pulse,
            builder: (context, child) {
              final glow = step.state == PlanStepState.active
                  ? 0.28 + pulse.value * 0.22
                  : 0.35;
              final scale = step.state == PlanStepState.active
                  ? 1 + pulse.value * 0.04
                  : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _circleColor,
                    shape: BoxShape.circle,
                    boxShadow: step.state != PlanStepState.upcoming
                        ? [
                            BoxShadow(
                              color: _circleColor.withValues(alpha: glow),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: child,
                ),
              );
            },
            child: Icon(step.icon, size: 20, color: _iconColor),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: Column(
              children: [
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (step.duration.isNotEmpty)
                  Text(
                    step.duration,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: AppColors.textSecondary,
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

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }

    const dash = 4.0;
    const gap = 3.0;
    var x = 0.0;
    while (x < size.width) {
      final end = (x + dash).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dashed != dashed;
}
