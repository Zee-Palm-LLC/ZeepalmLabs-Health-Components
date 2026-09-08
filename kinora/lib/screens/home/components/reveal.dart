import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../landing_page/components/math_motion.dart';

/// Premium entrance driven by layered parametric channels:
/// magnetic fade → tanh/settle rise → critical scale → soft depth tip.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 780),
    this.offset = const Offset(0, 20),
    this.scaleFrom = 0.94,
    this.twist = 0.0,
    this.curve = MathCurves.premiumRise,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final double scaleFrom;
  final double twist;
  final Curve curve;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    Future<void>.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;

        // Phase-offset channels — opacity leads, travel follows, scale lands last.
        final uFade = MathMotion.channel(t, start: 0.00, end: 0.50);
        final uRise = MathMotion.channel(t, start: 0.03, end: 0.82);
        final uScale = MathMotion.channel(t, start: 0.08, end: 0.95);
        final uDepth = MathMotion.channel(t, start: 0.00, end: 0.72);

        final fade = MathMotion.premiumFade(uFade);
        final rise = MathMotion.premiumRise(uRise);
        final grow = MathMotion.premiumScale(uScale);

        // Non-uniform scale: Y lifts a touch harder than X → organic “place”.
        final sy = widget.scaleFrom + (1 - widget.scaleFrom) * grow;
        final sx = (widget.scaleFrom + 0.025) +
            (1 - widget.scaleFrom - 0.025) * MathMotion.magnetic(uScale);

        final dx = widget.offset.dx * (1 - rise);
        final dy = widget.offset.dy * (1 - rise);

        // Soft perspective tip while rising — flattens as it settles.
        final tipX = 0.055 * (1 - MathMotion.critical(uDepth, lambda: 8.2));
        final twistZ = widget.twist == 0
            ? 0.0
            : widget.twist *
                MathMotion.wobble(t, amp: 0.85, freq: 1.65) *
                (1 - MathMotion.magnetic(t, sharpness: 2.2));

        final m = Matrix4.identity()
          ..setEntry(3, 2, 0.00115)
          ..translateByDouble(dx, dy, 0, 1)
          ..rotateX(tipX)
          ..rotateZ(twistZ)
          ..scaleByDouble(sx, sy, 1, 1);

        return Opacity(
          opacity: fade,
          child: Transform(
            alignment: Alignment.bottomCenter,
            transform: m,
            filterQuality: FilterQuality.medium,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Golden-ratio cascade — denser early, airier later.
Duration revealDelay(int index, {int stepMs = 54}) {
  const phi = 1.618033988749895;
  // Closed form of Σ φ^(−0.38 i) for i in 0..index-1
  final r = math.pow(phi, -0.38).toDouble();
  final sum = index == 0 ? 0.0 : (1 - math.pow(r, index).toDouble()) / (1 - r);
  return Duration(milliseconds: (sum * stepMs).round());
}
