import 'package:flutter/widgets.dart';

class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.animation,
    required this.interval,
    required this.child,
    this.from = Offset.zero,
    this.scaleFrom = 1,
    this.rotateFrom = 0,
    this.curve = Curves.easeOutCubic,
  });

  final Animation<double> animation;
  final (double, double) interval;
  final Offset from;
  final double scaleFrom;
  final double rotateFrom;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Interval is applied manually: a CurvedAnimation built here would register
    // a status listener on the parent every rebuild.
    final timing = Interval(interval.$1, interval.$2, curve: curve);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = timing.transform(animation.value);
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: from * (1 - t),
            child: Transform.rotate(
              angle: rotateFrom * (1 - t),
              child: Transform.scale(scale: scaleFrom + (1 - scaleFrom) * t, child: child),
            ),
          ),
        );
      },
    );
  }
}
