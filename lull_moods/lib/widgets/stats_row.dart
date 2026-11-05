import 'package:flutter/material.dart';

import '../layout.dart';
import '../mood.dart';

/// Five chips at x = 45, 120, 195, 270, 345. Values pop in with a small
/// left-to-right stagger when the mood changes.
class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.mood,
    required this.spec,
    required this.v,
    required this.s,
    this.hovered,
    this.onHover,
  });

  final Mood mood;
  final MoodSpec spec;
  final MoodVisual v;
  final double s;

  /// Index of the chip under the pointer (lights up like the original).
  final int? hovered;
  final ValueChanged<int?>? onHover;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var i = 0; i < 5; i++)
          Positioned(
            left: (45 + 75 * i - 37.5) * s,
            width: 75 * s,
            top: 0,
            child: Column(
              children: [
                MouseRegion(
                  onEnter: (_) => onHover?.call(i),
                  onExit: (_) => onHover?.call(null),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: hovered == i ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    builder: (context, h, child) => Transform.scale(
                      scale: 1 + 0.07 * h,
                      child: Container(
                        width: 56 * s,
                        height: 56 * s,
                        decoration: BoxDecoration(
                          color: Color.lerp(v.chip, Colors.white.withValues(alpha: 0.8), h),
                          shape: BoxShape.circle,
                        ),
                        child: child,
                      ),
                    ),
                    child: _swap(
                      i,
                      i == 4
                          ? Icon(Icons.edit_outlined, key: const ValueKey('customize'), size: 16 * s, color: v.ink)
                          : _ChipValue(key: ValueKey('${mood.name}$i'), stat: spec.stats[i], v: v, s: s),
                    ),
                  ),
                ),
                SizedBox(height: 7 * s),
                _swap(
                  i,
                  Text(
                    i == 4 ? 'Customize' : spec.stats[i].label,
                    key: ValueKey(i == 4 ? 'customize' : '${mood.name}l$i'),
                    maxLines: 1,
                    style: inter(10.5 * s, FontWeight.w500, v.inkSoft),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _swap(int i, Widget child) => AnimatedSwitcher(
    duration: Duration(milliseconds: 460 + i * 60),
    reverseDuration: const Duration(milliseconds: 220),
    switchInCurve: Interval(i * 0.09, 1, curve: Curves.easeOutCubic),
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: (child, anim) => FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: anim.drive(Tween(begin: const Offset(0, 0.35), end: Offset.zero)),
        child: ScaleTransition(
          scale: anim.drive(CurveTween(curve: Curves.easeOutBack)).drive(Tween(begin: 0.6, end: 1.0)),
          child: child,
        ),
      ),
    ),
    child: child,
  );
}

class _ChipValue extends StatelessWidget {
  const _ChipValue({super.key, required this.stat, required this.v, required this.s});

  final StatSpec stat;
  final MoodVisual v;
  final double s;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(stat.icon, size: 11 * s, color: v.ink),
        SizedBox(height: 2.5 * s),
        Text(
          stat.value,
          style: inter(
            stat.value.length > 4 ? 12.5 * s : 14.5 * s,
            FontWeight.w700,
            v.ink,
            ls: -0.3 * s,
            tabular: true,
          ),
        ),
      ],
    );
  }
}
