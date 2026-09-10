import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Rolls a metric up from zero when it first appears. Pair the [delay] with the
/// surrounding [Entrance] so the number starts climbing as the card arrives
/// rather than while it is still invisible.
class CountUpText extends StatefulWidget {
  const CountUpText({
    super.key,
    required this.value,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 1100),
  });

  final num value;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final int decimals;
  final Duration delay;
  final Duration duration;

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText> {
  double _target = 0;
  Timer? _start;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _target = widget.value.toDouble();
    } else {
      _start = Timer(widget.delay, () {
        if (mounted) setState(() => _target = widget.value.toDouble());
      });
    }
  }

  @override
  void didUpdateWidget(CountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() => _target = widget.value.toDouble());
    }
  }

  @override
  void dispose() {
    _start?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: _target),
      duration: widget.duration,
      curve: AppMotion.enterCurve,
      builder: (context, value, _) => Text(
        '${widget.prefix}${value.toStringAsFixed(widget.decimals)}${widget.suffix}',
        style: widget.style,
      ),
    );
  }
}
