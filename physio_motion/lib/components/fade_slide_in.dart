import 'package:flutter/material.dart';

/// Fade + slight slide (+ optional scale) for staged entrance reveals.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.animation,
    required this.child,
    this.begin = 0,
    this.end = 1,
    this.offset = const Offset(0, 18),
    this.curve = Curves.easeOutCubic,
    this.scaleFrom = 1,
  });

  final Animation<double> animation;
  final Widget child;
  final double begin;
  final double end;
  final Offset offset;
  final Curve curve;
  final double scaleFrom;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: curve),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final t = curved.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(offset.dx * (1 - t), offset.dy * (1 - t)),
            child: Transform.scale(
              scale: scaleFrom + (1 - scaleFrom) * t,
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
