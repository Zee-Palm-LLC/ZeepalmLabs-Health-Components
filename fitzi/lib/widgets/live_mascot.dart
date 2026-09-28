import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/art.dart';
import '../core/motion.dart';

enum Idle { breathe, run, lunge }

class LiveMascot extends StatefulWidget {
  const LiveMascot({
    super.key,
    required this.sprite,
    required this.entrance,
    this.idle = Idle.breathe,
    this.begin = 0.0,
    this.end = 1.0,
    this.anchor = const Alignment(0, 1),
    this.drop = 60,
    this.parallax = Offset.zero,
    this.interactive = true,
  });

  final Sprite sprite;
  final Animation<double> entrance;
  final Idle idle;
  final double begin;
  final double end;
  final Alignment anchor;
  final double drop;
  final Offset parallax;
  final bool interactive;

  @override
  State<LiveMascot> createState() => _LiveMascotState();
}

class _LiveMascotState extends State<LiveMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _poke;

  @override
  void initState() {
    super.initState();
    _poke = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  }

  @override
  void dispose() {
    _poke.dispose();
    super.dispose();
  }

  void _tap() {
    HapticFeedback.mediumImpact();
    _poke.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.sprite.image();
    final body = Tick(
      builder: (context, seconds, child) {
        return AnimatedBuilder(
          animation: Listenable.merge([widget.entrance, _poke]),
          builder: (context, inner) {
            final t = span(widget.entrance.value, widget.begin, widget.end, Curves.linear);
            final land = spring(t, bounce: 0.55, freq: 2.6);
            final fall = 1 - land;
            final impact = math.max(0.0, math.sin(math.min(t * 2.2, 1.0) * math.pi)) * (t > 0.2 ? 1 : 0);
            final squash = (t < 1 ? impact * 0.09 * (1 - t) : 0.0);
            var sx = 1 + squash;
            var sy = 1 - squash;
            var dy = -widget.drop * fall;
            var rot = 0.0;
            final live = t >= 1 ? 1.0 : t;
            switch (widget.idle) {
              case Idle.breathe:
                final b = wave(seconds, 3.2);
                sy *= 1 + 0.011 * b * live;
                sx *= 1 - 0.006 * b * live;
                rot = 0.018 * wave(seconds, 5.4) * live;
              case Idle.run:
                final stride = wave(seconds, 0.62);
                dy += -3.2 * stride.abs() * live;
                sy *= 1 + 0.018 * stride.abs() * live;
                sx *= 1 - 0.01 * stride.abs() * live;
                rot = 0.03 * stride * live;
              case Idle.lunge:
                final b = wave(seconds, 2.6);
                dy += 2.2 * b * live;
                sy *= 1 - 0.012 * b * live;
                sx *= 1 + 0.008 * b * live;
                rot = 0.012 * wave(seconds, 4.1) * live;
            }
            final p = _poke.value;
            if (p > 0 && p < 1) {
              final hop = math.sin(p * math.pi);
              final wob = math.sin(p * math.pi * 5) * (1 - p);
              dy -= 26 * hop;
              sy *= 1 + 0.06 * wob;
              sx *= 1 - 0.05 * wob;
              rot += 0.08 * wob;
            }
            final m = Matrix4.identity()
              ..translateByDouble(widget.parallax.dx, dy + widget.parallax.dy, 0, 1)
              ..rotateZ(rot)
              ..scaleByDouble(sx, sy, 1, 1);
            return Opacity(
              opacity: span(t, 0, 0.18, Curves.linear),
              child: Transform(alignment: widget.anchor, transform: m, child: inner),
            );
          },
          child: child,
        );
      },
      child: image,
    );
    return SizedBox(
      width: widget.sprite.width,
      height: widget.sprite.height,
      child: widget.interactive
          ? GestureDetector(behavior: HitTestBehavior.translucent, onTap: _tap, child: body)
          : body,
    );
  }
}
