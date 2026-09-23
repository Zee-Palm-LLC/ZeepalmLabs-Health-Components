import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme/motion.dart';

class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.955,
    this.haptic = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool value) {
    if (_down == value) return;
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => _set(true),
      onTapCancel: widget.onTap == null ? null : () => _set(false),
      onTapUp: widget.onTap == null ? null : (_) => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.lightImpact();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: Motion.micro,
        curve: Motion.enter,
        child: widget.child,
      ),
    );
  }
}
