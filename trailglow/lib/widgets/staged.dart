import 'package:flutter/widgets.dart';

import '../app/theme/motion.dart';

class Staged extends StatelessWidget {
  const Staged({
    super.key,
    required this.animation,
    required this.index,
    required this.child,
    this.total = 7,
    this.shift = const Offset(0, 22),
    this.scaleFrom = 1.0,
    this.span = 0.55,
  });

  final Animation<double> animation;
  final int index;
  final int total;
  final Widget child;
  final Offset shift;
  final double scaleFrom;
  final double span;

  @override
  Widget build(BuildContext context) {
    final start = total <= 1 ? 0.0 : (index / total) * (1 - span);
    final curve = CurvedAnimation(
      parent: animation,
      curve: Interval(
        start.clamp(0.0, 1.0),
        (start + span).clamp(0.0, 1.0),
        curve: Motion.enter,
      ),
    );
    return AnimatedBuilder(
      animation: curve,
      child: child,
      builder: (context, inner) {
        final t = curve.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(shift.dx * (1 - t), shift.dy * (1 - t)),
            child: Transform.scale(
              scale: scaleFrom + (1 - scaleFrom) * t,
              child: inner,
            ),
          ),
        );
      },
    );
  }
}
