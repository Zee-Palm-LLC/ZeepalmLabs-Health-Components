import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'breathing_aura.dart';

/// The calm, self-contained version of [BreathingAura] used over photography.
/// It runs its own slow breath cycle so the hero imagery keeps moving even when
/// no session is in progress.
class GlowOrb extends StatefulWidget {
  const GlowOrb({super.key, required this.diameter, this.animate = true, this.haloScale = 1.9});

  /// Diameter of the luminous core; the halo extends to [haloScale] times this.
  final double diameter;
  final bool animate;
  final double haloScale;

  @override
  State<GlowOrb> createState() => _GlowOrbState();
}

class _GlowOrbState extends State<GlowOrb> with SingleTickerProviderStateMixin {
  /// One turn of the controller is 24 seconds of aura time.
  static const _cycleSeconds = 24.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extent = widget.diameter * widget.haloScale;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final time = _controller.value * _cycleSeconds;
        // A single slow sine stands in for the breath: ~7.5s in, ~7.5s out.
        final breath = 0.5 + 0.5 * math.sin(time * (2 * math.pi / 15));

        return BreathingAura(
          diameter: extent,
          time: time,
          breath: breath,
          turbulence: 0.85,
          particles: widget.diameter > 40,
          ripples: widget.diameter > 40,
        );
      },
    );
  }
}
