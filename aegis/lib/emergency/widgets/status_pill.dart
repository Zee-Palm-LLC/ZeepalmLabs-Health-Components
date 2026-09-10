import 'package:flutter/material.dart';

import '../../theme/motion.dart';

class StatusPill extends StatefulWidget {
  const StatusPill({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.pulsing = false,
  });

  final IconData icon;
  final String label;
  final Color color;

  /// Breathes the pill's border and fill. Reserved for states the user should
  /// keep an eye on, so it stays meaningful.
  final bool pulsing;

  @override
  State<StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<StatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
    value: 0.5,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(StatusPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulsing != widget.pulsing) _sync();
  }

  void _sync() {
    if (widget.pulsing && !reduceMotion(context)) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.08 + 0.06 * t),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.4 + 0.3 * t),
            ),
          ),
          child: child,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 13, color: widget.color),
          const SizedBox(width: 6),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}
