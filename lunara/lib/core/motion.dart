import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

double lerp(double a, double b, double t) => a + (b - a) * t;

double span(double value, double begin, double end, [Curve curve = Curves.linear]) {
  if (end <= begin) return value >= end ? 1 : 0;
  return curve.transform(((value - begin) / (end - begin)).clamp(0.0, 1.0));
}

double breathe(double t, [double phase = 0]) => math.sin((t + phase) * math.pi * 2);

double wave(double seconds, double period, [double phase = 0]) {
  return math.sin((seconds / period + phase) * math.pi * 2);
}

mixin ClockMixin<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  final clock = ValueNotifier<double>(0);
  Ticker? _ticker;

  void startClock() {
    _ticker = createTicker((elapsed) => clock.value = elapsed.inMicroseconds / 1e6)..start();
  }

  void disposeClock() {
    _ticker?.dispose();
    clock.dispose();
  }
}

class Spring extends Curve {
  const Spring({this.bounce = 0.32, this.frequency = 3.2});

  final double bounce;
  final double frequency;

  @override
  double transformInternal(double t) {
    return 1 - math.exp(-frequency * t * 2) * math.cos(frequency * math.pi * t) * (1 - bounce * (1 - t));
  }
}

const gentle = Cubic(0.22, 1, 0.32, 1);
const swift = Cubic(0.33, 1, 0.45, 1);
const easeInOutSoft = Cubic(0.65, 0, 0.35, 1);

class Staged extends StatelessWidget {
  const Staged({
    super.key,
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
    this.offset = const Offset(0, 18),
    this.scale = 1,
    this.curve = gentle,
    this.blur = 0,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;
  final Offset offset;
  final double scale;
  final Curve curve;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, inner) {
        final t = span(animation.value, begin, end, curve);
        if (t >= 1) return inner!;
        final shifted = Transform.translate(
          offset: Offset(offset.dx * (1 - t), offset.dy * (1 - t)),
          child: Transform.scale(
            scale: lerp(scale, 1, t),
            child: Opacity(opacity: t.clamp(0.0, 1.0), child: inner),
          ),
        );
        if (blur <= 0) return shifted;
        return ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur * (1 - t), sigmaY: blur * (1 - t), tileMode: TileMode.decal),
          child: shifted,
        );
      },
    );
  }
}

class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.94, this.feedback = true});

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool feedback;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420), value: 1);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down(_) {
    _c.animateTo(0, duration: const Duration(milliseconds: 120), curve: Curves.easeOut);
  }

  void _up([_]) {
    _c.animateTo(1, duration: const Duration(milliseconds: 420), curve: const Spring());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.feedback ? _down : null,
      onTapUp: widget.feedback ? _up : null,
      onTapCancel: widget.feedback ? _up : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) => Transform.scale(scale: lerp(widget.scale, 1, _c.value), child: child),
      ),
    );
  }
}

class Shimmer extends StatelessWidget {
  const Shimmer({super.key, required this.animation, required this.child, this.tint = Colors.white});

  final Animation<double> animation;
  final Widget child;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, inner) {
        final t = animation.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            final x = lerp(-rect.width, rect.width * 2, t);
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tint.withValues(alpha: 0), tint.withValues(alpha: 0.42), tint.withValues(alpha: 0)],
              stops: const [0, 0.5, 1],
              transform: _Slide(x / math.max(rect.width, 1)),
            ).createShader(rect);
          },
          child: inner,
        );
      },
    );
  }
}

class _Slide extends GradientTransform {
  const _Slide(this.fraction);

  final double fraction;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * fraction, 0, 0);
  }
}
