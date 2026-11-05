import 'package:flutter/widgets.dart';

const gentle = Cubic(0.22, 1.0, 0.32, 1.0);
const swift = Cubic(0.16, 0.9, 0.24, 1.0);
const settle = Cubic(0.34, 1.45, 0.42, 1.0);
const glide = Cubic(0.65, 0.0, 0.35, 1.0);

double span(double t, double begin, double end, [Curve curve = gentle]) {
  if (end <= begin) return t >= end ? 1 : 0;
  return curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));
}

double lerp(double a, double b, double t) => a + (b - a) * t;

/// Fades and lifts its child in once, [delay] after it first builds.
class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.child, this.delay = 0, this.rise = 16, this.from = Offset.zero, this.duration = 620});

  final Widget child;
  final int delay;
  final double rise;
  final Offset from;
  final int duration;

  @override
  Widget build(BuildContext context) {
    final total = delay + duration;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      builder: (context, v, child) {
        final t = span(v, delay / total, 1);
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(from.dx * (1 - t), rise * (1 - t) + from.dy * (1 - t)), child: child),
        );
      },
      child: child,
    );
  }
}

/// Rolls a number up from zero; [format] turns the running value into text.
class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.value, required this.style, this.format, this.delay = 0, this.duration = 1100});

  final double value;
  final TextStyle style;
  final String Function(double v)? format;
  final int delay;
  final int duration;

  @override
  Widget build(BuildContext context) {
    final total = delay + duration;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      builder: (context, t, _) {
        final v = value * span(t, delay / total, 1, swift);
        return Text(format?.call(v) ?? v.round().toString(), style: style, maxLines: 1, softWrap: false);
      },
    );
  }
}
