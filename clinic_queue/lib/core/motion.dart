import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

double lerp(double a, double b, double t) => a + (b - a) * t;

double span(double t, double begin, double end, [Curve curve = Curves.linear]) {
  if (t <= begin) return 0;
  if (t >= end) return 1;
  return curve.transform((t - begin) / (end - begin));
}

Offset lerpOffset(Offset a, Offset b, double t) => Offset(lerp(a.dx, b.dx, t), lerp(a.dy, b.dy, t));

Rect lerpRect(Rect a, Rect b, double t) => Rect.lerp(a, b, t)!;

class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.t,
    required this.child,
    this.offset = const Offset(0, 16),
    this.scale = 1,
    this.alignment = Alignment.center,
  });

  final double t;
  final Widget child;
  final Offset offset;
  final double scale;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final v = t.clamp(0.0, 1.0);
    return Opacity(
      opacity: v,
      child: Transform.translate(
        offset: offset * (1 - t),
        child: Transform.scale(scale: lerp(scale, 1, t), alignment: alignment, child: child),
      ),
    );
  }
}

class Staged extends StatelessWidget {
  const Staged({
    super.key,
    required this.animation,
    required this.child,
    this.begin = 0,
    this.end = 1,
    this.curve = Curves.easeOutCubic,
    this.offset = const Offset(0, 16),
    this.scale = 1,
    this.fade = true,
    this.alignment = Alignment.center,
  });

  final Animation<double> animation;
  final Widget child;
  final double begin;
  final double end;
  final Curve curve;
  final Offset offset;
  final double scale;
  final bool fade;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = span(animation.value, begin, end, curve);
        return Opacity(
          opacity: fade ? t.clamp(0.0, 1.0) : 1,
          child: Transform.translate(
            offset: offset * (1 - t),
            child: Transform.scale(scale: lerp(scale, 1, t), alignment: alignment, child: child),
          ),
        );
      },
    );
  }
}

class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.93, this.haptic = true});

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  static const _spring = SpringDescription(mass: 1, stiffness: 560, damping: 20);

  @override
  void initState() {
    super.initState();
    _press = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _down() {
    if (widget.haptic) HapticFeedback.selectionClick();
    _press.animateTo(1, duration: const Duration(milliseconds: 90), curve: Curves.easeOut);
  }

  void _up() {
    _press.animateWith(SpringSimulation(_spring, _press.value, 0, 0));
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _down() : null,
      onTapUp: enabled ? (_) => _up() : null,
      onTapCancel: enabled ? _up : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _press,
        child: widget.child,
        builder: (context, child) {
          final s = 1 - (1 - widget.scale) * _press.value;
          return Transform.scale(scale: s, child: child);
        },
      ),
    );
  }
}
