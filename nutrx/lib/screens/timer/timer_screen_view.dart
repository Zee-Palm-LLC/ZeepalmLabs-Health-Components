import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/nutrx_colors.dart';
import '../landing_page/components/floating_bottom_nav.dart';
import 'components/calendar_screen_view.dart';
import 'components/math_motion.dart';
import 'components/progress_chrome.dart';
import 'components/reveal.dart';
import 'components/stats_grid.dart';
import 'components/workout_section.dart';

class TimerScreenView extends StatefulWidget {
  const TimerScreenView({super.key});

  @override
  State<TimerScreenView> createState() => _TimerScreenViewState();
}

class _TimerScreenViewState extends State<TimerScreenView> {
  int _segment = 0;
  int _direction = 1;

  void _onSegment(int i) {
    if (i == _segment) return;
    setState(() {
      _direction = i > _segment ? 1 : -1;
      _segment = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutrxColors.bg,
      appBar: const ProgressHeader(),
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          FloatingBottomNav.contentClearance(context),
        ),
        children: [
          Reveal(
            offset: const Offset(0, 18),
            scaleFrom: 0.92,
            twist: 0.03,
            child: ElasticSegmentTab(
              index: _segment,
              onChanged: _onSegment,
            ),
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 620),
            reverseDuration: const Duration(milliseconds: 420),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            transitionBuilder: (child, animation) {
              final incoming =
                  (child.key as ValueKey<int>?)?.value == _segment;

              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final t = animation.value;
                  final fade = MathMotion.spiralBlend(t).clamp(0.0, 1.0);
                  final move = incoming
                      ? MathMotion.anticipate(t)
                      : MathMotion.smootherstep(t);
                  final x = (incoming ? 0.08 : -0.06) *
                      _direction *
                      (1 - move);
                  final y = 0.035 * (1 - MathMotion.settle(t));
                  final rot = incoming
                      ? 0.025 *
                          _direction *
                          MathMotion.wobble(t, amp: 1, freq: 1.4)
                      : 0.0;
                  final scale = 0.94 +
                      0.06 * MathMotion.softBounce(t) +
                      0.02 * math.sin(MathMotion.settle(t) * math.pi);

                  return Opacity(
                    opacity: fade,
                    child: Transform.translate(
                      offset: Offset(
                        x * MediaQuery.sizeOf(context).width,
                        y * 120,
                      ),
                      child: Transform.rotate(
                        angle: rot,
                        child: Transform.scale(
                          scale: scale.clamp(0.9, 1.08),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_segment),
              child: _segment == 0
                  ? const _DailyBody()
                  : const CalendarScreenView(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyBody extends StatelessWidget {
  const _DailyBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatsGrid(),
        SizedBox(height: 28),
        WorkoutSection(),
      ],
    );
  }
}
