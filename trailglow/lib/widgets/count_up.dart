import 'package:flutter/widgets.dart';

import '../app/theme/motion.dart';

class CountUp extends StatefulWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.format,
    required this.style,
    this.duration = const Duration(milliseconds: 900),
    this.delay = Duration.zero,
    this.from = 0,
    this.textAlign,
  });

  final double value;
  final String Function(double) format;
  final TextStyle style;
  final Duration duration;
  final Duration delay;
  final double from;
  final TextAlign? textAlign;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late double _start = widget.from;
  late double _end = widget.value;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void didUpdateWidget(CountUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _start = _current;
      _end = widget.value;
      _controller
        ..duration = const Duration(milliseconds: 560)
        ..value = 0
        ..forward();
    }
  }

  double get _current {
    final t = Motion.enter.transform(_controller.value);
    return _start + (_end - _start) * t;
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
      builder: (context, _) => Text(
        widget.format(_current),
        style: widget.style,
        textAlign: widget.textAlign,
      ),
    );
  }
}
