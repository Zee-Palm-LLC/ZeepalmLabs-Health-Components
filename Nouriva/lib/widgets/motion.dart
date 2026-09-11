import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Fade + rise with critically-damped spring curve.
class SpringEnter extends StatelessWidget {
  const SpringEnter({
    super.key,
    required this.animation,
    required this.child,
    this.dy = 22,
    this.interval,
  });

  final Animation<double> animation;
  final Widget child;
  final double dy;
  final Interval? interval;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: interval ?? AppMotion.soft,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final t = curved.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, dy * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.94,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  void _set(bool v) {
    if (_down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: AppMotion.press,
        curve: AppMotion.softTight,
        child: widget.child,
      ),
    );
  }
}
