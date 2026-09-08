import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/kinora_colors.dart';
import '../home/components/reveal.dart';
import '../landing_page/components/floating_bottom_nav.dart';
import '../landing_page/components/math_motion.dart';
import 'components/progress_chart_section.dart';
import 'components/target_muscle_section.dart';
import 'components/workout_info_section.dart';
import 'components/workout_video_player.dart';

class WorkoutDetailView extends StatefulWidget {
  const WorkoutDetailView({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambience;
  late final ScrollController _scroll;
  double _scrollY = 0;

  @override
  void initState() {
    super.initState();
    _ambience = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6400),
    )..repeat();
    _scroll = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final y = _scroll.offset.clamp(0.0, 220.0);
    if ((y - _scrollY).abs() < 0.5) return;
    setState(() => _scrollY = y);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _ambience.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomClear = FloatingBottomNav.contentClearance(context);
    final parallax = _scrollY / 220;

    return ColoredBox(
      color: KinoraColors.bg,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambience,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0, -14 * parallax),
                  child: CustomPaint(
                    painter: _WorkoutAmbiencePainter(
                      phase: _ambience.value * math.pi * 2,
                      depth: 1 - parallax * 0.4,
                    ),
                  ),
                );
              },
            ),
          ),
          ListView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.only(bottom: bottomClear),
            children: [
              Reveal(
                delay: revealDelay(0),
                offset: const Offset(0, 16),
                scaleFrom: 0.97,
                twist: 0,
                child: WorkoutVideoPlayer(
                  onBack: widget.onBack,
                  scrollCollapse: parallax,
                ),
              ),
              Reveal(
                delay: revealDelay(1),
                offset: const Offset(0, 18),
                scaleFrom: 0.95,
                twist: 0.01,
                child: const WorkoutInfoSection(),
              ),
              const SizedBox(height: 8),
              Reveal(
                delay: revealDelay(2),
                offset: const Offset(0, 16),
                scaleFrom: 0.95,
                twist: 0.012,
                child: const TargetMuscleSection(),
              ),
              const SizedBox(height: 8),
              Reveal(
                delay: revealDelay(3),
                offset: const Offset(0, 22),
                scaleFrom: 0.93,
                twist: 0.015,
                duration: const Duration(milliseconds: 980),
                child: const ProgressChartSection(),
              ),
              const SizedBox(height: 16),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: bottomClear * 0.5,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      KinoraColors.bg.withValues(alpha: 0),
                      KinoraColors.bg.withValues(alpha: 0.8),
                      KinoraColors.bg,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutAmbiencePainter extends CustomPainter {
  _WorkoutAmbiencePainter({required this.phase, required this.depth});

  final double phase;
  final double depth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final breath = MathMotion.breath(phase, lo: 0.9, hi: 1.12) * depth;

    canvas.drawRect(rect, Paint()..color = KinoraColors.bg);

    final top = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.5, size.height * 0.12),
        size.width * 0.85 * breath,
        [
          KinoraColors.lime.withValues(alpha: 0.08 * depth),
          Colors.transparent,
        ],
      );
    canvas.drawRect(rect, top);

    final mid = Paint()
      ..shader = ui.Gradient.radial(
        Offset(
          size.width * (0.15 + 0.03 * math.sin(phase)),
          size.height * 0.55,
        ),
        size.width * 0.55,
        [
          KinoraColors.limeDeep.withValues(alpha: 0.04 * depth),
          Colors.transparent,
        ],
      );
    canvas.drawRect(rect, mid);

    final vig = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        [
          Colors.black.withValues(alpha: 0.2),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.5),
        ],
        const [0, 0.35, 1],
      );
    canvas.drawRect(rect, vig);
  }

  @override
  bool shouldRepaint(covariant _WorkoutAmbiencePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.depth != depth;
}
