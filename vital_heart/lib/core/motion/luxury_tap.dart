import 'package:vital_heart/core/motion/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LuxuryTap extends StatefulWidget {
  const LuxuryTap({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.enableHaptic = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool enableHaptic;

  @override
  State<LuxuryTap> createState() => _LuxuryTapState();
}

class _LuxuryTapState extends State<LuxuryTap> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? widget.scale : 1.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: () {
        if (widget.enableHaptic) {
          HapticFeedback.lightImpact();
        }
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: scale,
        duration: AppMotion.fast,
        curve: AppMotion.curve,
        child: widget.child,
      ),
    );
  }
}
