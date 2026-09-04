import 'package:flutter/material.dart';

/// Cascading list item entrance for option rows.
class StaggeredItem extends StatelessWidget {
  const StaggeredItem({
    super.key,
    required this.index,
    required this.animation,
    required this.child,
    this.baseBegin = 0.18,
    this.gap = 0.065,
  });

  final int index;
  final Animation<double> animation;
  final Widget child;
  final double baseBegin;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final begin = (baseBegin + index * gap).clamp(0.0, 0.82);
    final end = (begin + 0.32).clamp(0.0, 1.0);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final t = curved.value.clamp(0.0, 1.0);
        final eased = Curves.easeOut.transform(t);
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - eased)),
            child: Transform.scale(
              scale: 0.97 + 0.03 * eased,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
