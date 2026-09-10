import 'package:flutter/material.dart';

/// Slides a soft band of light across its child on a long loop. Used sparingly:
/// the primary call to action and the premium badge only.
class ShimmerSweep extends StatefulWidget {
  const ShimmerSweep({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 4200),
    this.strength = 0.32,
  });

  final Widget child;
  final Duration period;
  final double strength;

  @override
  State<ShimmerSweep> createState() => _ShimmerSweepState();
}

class _ShimmerSweepState extends State<ShimmerSweep> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        // The band spends most of the loop off-screen, so the highlight reads
        // as an occasional glint rather than a constant sweep.
        final t = Curves.easeInOut.transform(_controller.value) * 2.6 - 1.3;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(t - 0.4, -0.6),
            end: Alignment(t + 0.4, 0.6),
            colors: [
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: widget.strength),
              Colors.white.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}
