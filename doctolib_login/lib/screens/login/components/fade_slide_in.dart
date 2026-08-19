import 'dart:ui';

import 'package:flutter/material.dart';

class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 560),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    const curve = Cubic(0.16, 1, 0.3, 1);

    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: widget.duration,
      curve: curve,
      child: AnimatedScale(
        scale: _visible ? 1 : 0.96,
        duration: widget.duration,
        curve: curve,
        child: _BlurReveal(
          visible: _visible,
          duration: widget.duration,
          child: widget.child,
        ),
      ),
    );
  }
}

class _BlurReveal extends StatelessWidget {
  const _BlurReveal({
    required this.visible,
    required this.duration,
    required this.child,
  });

  final bool visible;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: visible ? 8 : 8, end: visible ? 0 : 8),
      duration: duration,
      curve: const Cubic(0.16, 1, 0.3, 1),
      builder: (context, blur, childWidget) {
        if (blur < 0.4) return childWidget!;
        return ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: childWidget,
        );
      },
      child: child,
    );
  }
}
