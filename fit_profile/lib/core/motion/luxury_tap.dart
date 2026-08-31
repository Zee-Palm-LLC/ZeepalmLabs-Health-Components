import 'package:fit_profile/core/motion/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium press feedback — scale only, no blur/shaders.
class LuxuryTap extends StatefulWidget {
  const LuxuryTap({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.enableHaptic = true,
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
    if (_pressed == value || widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.dur(context, AppMotion.fast);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              _setPressed(false);
              if (widget.enableHaptic) {
                HapticFeedback.lightImpact();
              }
              widget.onTap?.call();
            },
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: duration,
        curve: AppMotion.curve,
        child: widget.child,
      ),
    );
  }
}
