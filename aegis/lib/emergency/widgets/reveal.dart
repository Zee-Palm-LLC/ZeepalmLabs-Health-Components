import 'package:flutter/widgets.dart';

import '../../theme/motion.dart';

/// Fades and lifts [child] into place as [animation] runs.
///
/// [order] staggers siblings off a single parent controller, so a screen can
/// reveal a dozen pieces without a dozen tickers.
class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.animation,
    required this.order,
    required this.child,
    this.lift = 22,
    this.step = 0.07,
    this.span = 0.55,
  });

  final Animation<double> animation;

  /// Position in the stagger, from zero.
  final int order;

  final Widget child;

  /// How far up the child travels, in logical pixels.
  final double lift;

  /// Delay between consecutive [order]s, as a fraction of the parent.
  final double step;

  /// How much of the parent each child's own move takes.
  final double span;

  @override
  Widget build(BuildContext context) {
    final start = (order * step).clamp(0.0, 1 - span);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, start + span, curve: AegisMotion.enter),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final t = curved.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, lift * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
