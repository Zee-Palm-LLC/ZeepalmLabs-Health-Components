import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../data/sessions.dart';
import '../theme.dart';
import '../widgets/arc_header.dart';
import '../widgets/fitness_cards.dart';
import '../widgets/nav_bar.dart';
import '../widgets/sections.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with SingleTickerProviderStateMixin {
  /// Fractional carousel page, driven by the finger and then a spring.
  late final AnimationController _page = AnimationController.unbounded(vsync: this, value: 2);
  final _scroll = ScrollController();

  static const _spring = SpringDescription(mass: 1, stiffness: 165, damping: 23);

  @override
  void dispose() {
    _page.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _settle(double target, double velocity) {
    _page.animateWith(
      SpringSimulation(_spring, _page.value, target, velocity, tolerance: const Tolerance(distance: 0.0005, velocity: 0.01)),
    );
  }

  void _dragUpdate(double dx, double pageWidth) {
    final next = _page.value - dx / pageWidth;
    // Rubber band past the first and last card.
    final over = next < 0 ? next : (next > sessions.length - 1 ? next - (sessions.length - 1) : 0.0);
    _page.value = over == 0 ? next : _page.value - dx / pageWidth * 0.35;
  }

  void _dragEnd(double velocity, double pageWidth) {
    final v = -velocity / pageWidth;
    final projected = _page.value + v * 0.16;
    final target = projected.round().clamp(0, sessions.length - 1).toDouble();
    if (target != _page.value.roundToDouble()) HapticFeedback.selectionClick();
    _settle(target, v);
  }

  void _select(int i) {
    HapticFeedback.selectionClick();
    _settle(i.toDouble(), 0);
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    // Layout is measured against a 59 pt status bar; screens without one
    // (browser, older phones) still get a 44 pt breathing space up top.
    final dy = math.max(pad.top, 44.0) - 59;
    final range = HeaderMetrics.maxExtent - HeaderMetrics.minExtent;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Tone.canvas,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scroll,
              physics: FoldSnapPhysics(range: range, parent: const AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ArcHeaderDelegate(
                    page: _page,
                    scroll: _scroll,
                    dy: dy,
                    onDragStart: _page.stop,
                    onDragUpdate: _dragUpdate,
                    onDragEnd: _dragEnd,
                    onSelect: _select,
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(17, 10, 17, 120 + pad.bottom),
                  sliver: SliverList.list(
                    children: [
                      const WeekCard(),
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Body today', action: 'Details'),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Expanded(child: StepsCard()),
                          SizedBox(width: 13),
                          Expanded(child: HeartCard()),
                        ],
                      ),
                      const SizedBox(height: 13),
                      const RecoveryCard(),
                      const SizedBox(height: 13),
                      const FuelCard(),
                      const SizedBox(height: 26),
                      const SectionHeader(title: 'Up next'),
                      const SizedBox(height: 10),
                      const UpNextCard(),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(left: 0, right: 0, bottom: 34, child: const Center(child: FloatingNav())),
          ],
        ),
      ),
    );
  }
}

/// iOS bounce everywhere, but the page never comes to rest half folded:
/// any fling that would stop inside the morph range springs to fully open or
/// fully folded instead, carrying the finger's velocity into the spring.
class FoldSnapPhysics extends BouncingScrollPhysics {
  const FoldSnapPhysics({required this.range, super.parent});

  final double range;

  static const _snap = SpringDescription(mass: 1, stiffness: 140, damping: 22);

  @override
  FoldSnapPhysics applyTo(ScrollPhysics? ancestor) => FoldSnapPhysics(range: range, parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final sim = super.createBallisticSimulation(position, velocity);
    final px = position.pixels;
    // Outside the fold (or bouncing back from an edge): plain iOS physics.
    if (px < 0 || px > position.maxScrollExtent || px >= range && (sim == null || sim.x(10) >= range)) return sim;
    final rest = sim?.x(10) ?? px;
    if (rest <= 0.5 || rest >= range - 0.5) return sim;
    final target = velocity.abs() > 150 ? (velocity > 0 ? range : 0.0) : (rest > range * 0.45 ? range : 0.0);
    return ScrollSpringSimulation(_snap, px, math.min(target, position.maxScrollExtent), velocity, tolerance: toleranceFor(position));
  }
}
