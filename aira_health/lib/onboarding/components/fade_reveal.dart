import 'package:flutter/material.dart';

class FadeReveal extends StatefulWidget {
  const FadeReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 520),
    this.offsetY = 10,
    this.scaleBegin = 0.97,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;
  final double scaleBegin;

  @override
  State<FadeReveal> createState() => _FadeRevealState();
}

class _FadeRevealState extends State<FadeReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    const curve = Cubic(0.16, 1, 0.3, 1);
    final curved = CurvedAnimation(parent: _controller, curve: curve);

    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 100),
      end: Offset.zero,
    ).animate(curved);
    _scale = Tween<double>(begin: widget.scaleBegin, end: 1).animate(curved);

    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
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
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Transform.translate(
              offset: Offset(0, _slide.value.dy * 100),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
