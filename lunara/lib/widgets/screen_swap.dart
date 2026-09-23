import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/motion.dart';

class ScreenSwap extends StatefulWidget {
  const ScreenSwap({
    super.key,
    required this.index,
    required this.builder,
    this.duration = const Duration(milliseconds: 620),
  });

  final int index;
  final Widget Function(BuildContext context, int index) builder;
  final Duration duration;

  @override
  State<ScreenSwap> createState() => _ScreenSwapState();
}

class _ScreenSwapState extends State<ScreenSwap> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late int _current = widget.index;
  int? _previous;
  int _direction = 1;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration, value: 1);
  }

  @override
  void didUpdateWidget(ScreenSwap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != _current) {
      _direction = widget.index > _current ? 1 : -1;
      _previous = _current;
      _current = widget.index;
      _c.forward(from: 0).whenComplete(() {
        if (mounted) setState(() => _previous = null);
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final incoming = gentle.transform(t);
        final previous = _previous;
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            if (previous != null && t < 1)
              Opacity(
                opacity: (1 - span(t, 0, 0.5)).clamp(0.0, 1.0),
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 7 * t, sigmaY: 7 * t, tileMode: TileMode.decal),
                  child: Transform.scale(
                    scale: 1 - 0.05 * t,
                    child: Transform.translate(
                      offset: Offset(-18 * t * _direction, 0),
                      child: IgnorePointer(child: widget.builder(context, previous)),
                    ),
                  ),
                ),
              ),
            Opacity(
              opacity: span(t, 0.18, 0.8).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: lerp(1.04, 1, incoming),
                child: Transform.translate(
                  offset: Offset(26 * (1 - incoming) * _direction, 10 * (1 - incoming)),
                  child: widget.builder(context, _current),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
