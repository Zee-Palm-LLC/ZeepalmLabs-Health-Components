import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Soft vertical bob + optional micro-rotation for floating UI pieces.
class FloatingMotion extends StatefulWidget {
  const FloatingMotion({
    super.key,
    required this.child,
    this.amplitude = 6,
    this.duration = const Duration(milliseconds: 2800),
    this.delay = Duration.zero,
    this.rotationAmplitude = 0.012,
    this.enabled = true,
  });

  final Widget child;
  final double amplitude;
  final Duration duration;
  final Duration delay;
  final double rotationAmplitude;
  final bool enabled;

  @override
  State<FloatingMotion> createState() => _FloatingMotionState();
}

class _FloatingMotionState extends State<FloatingMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.enabled) {
      if (widget.delay == Duration.zero) {
        _controller.repeat(reverse: true);
      } else {
        _startTimer = Timer(widget.delay, () {
          if (mounted) _controller.repeat(reverse: true);
        });
      }
    }
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final dy = (t * 2 - 1) * widget.amplitude;
        final angle = math.sin(t * math.pi) * widget.rotationAmplitude;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.rotate(angle: angle, child: child),
        );
      },
      child: widget.child,
    );
  }
}
