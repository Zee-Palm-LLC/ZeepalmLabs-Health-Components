import 'package:flutter/widgets.dart';

class Rise extends StatelessWidget {
  const Rise({
    super.key,
    required this.t,
    required this.child,
    this.distance = 24,
    this.scaleFrom = 1,
    this.alignment = Alignment.center,
  });

  final double t;
  final Widget child;
  final double distance;
  final double scaleFrom;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) return Opacity(opacity: 0, child: child);
    final settled = t.clamp(0.0, 1.0);
    final body = Transform.translate(
      offset: Offset(0, (1 - t) * distance),
      child: child,
    );
    return Opacity(
      opacity: settled,
      child: scaleFrom == 1
          ? body
          : Transform.scale(
              scale: scaleFrom + (1 - scaleFrom) * t,
              alignment: alignment,
              child: body,
            ),
    );
  }
}

class Slide extends StatelessWidget {
  const Slide({
    super.key,
    required this.t,
    required this.child,
    this.distance = 34,
    this.fromLeft = false,
  });

  final double t;
  final Widget child;
  final double distance;
  final bool fromLeft;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) return Opacity(opacity: 0, child: child);
    final settled = t.clamp(0.0, 1.0);
    return Opacity(
      opacity: settled,
      child: Transform.translate(
        offset: Offset((1 - t) * distance * (fromLeft ? -1 : 1), 0),
        child: child,
      ),
    );
  }
}

class SweepReveal extends StatelessWidget {
  const SweepReveal({
    super.key,
    required this.child,
    required this.t,
    this.feather = 0.22,
  });

  final Widget child;
  final double t;

  final double feather;

  @override
  Widget build(BuildContext context) {
    final p = t.clamp(0.0, 1.0);
    if (p <= 0) return Opacity(opacity: 0, child: child);
    if (p >= 1) return child;

    final head = -feather + p * (1 + feather * 2);
    final start = (head - feather).clamp(-1.0, 2.0);
    final end = (head + feather).clamp(-1.0, 2.0);

    return ShaderMask(
      blendMode: BlendMode.modulate,
      shaderCallback: (Rect bounds) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const <Color>[
          Color(0xFFFFFFFF),
          Color(0xFFFFFFFF),
          Color(0x00FFFFFF),
        ],
        stops: <double>[
          0,
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0) == start.clamp(0.0, 1.0)
              ? (start.clamp(0.0, 1.0) + 0.001).clamp(0.0, 1.0)
              : end.clamp(0.0, 1.0),
        ],
      ).createShader(bounds),
      child: child,
    );
  }
}
