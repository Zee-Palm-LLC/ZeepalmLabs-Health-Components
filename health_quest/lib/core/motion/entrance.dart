import 'package:flutter/widgets.dart';

/// Rise-and-fade for one element of a staggered entrance.
///
/// [t] may overshoot past 1 when the curve is a spring. Opacity is clamped;
/// the offset and scale are not, so the overshoot shows as movement instead
/// of a flash.
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

/// Slide-and-fade from the side, for rows dealing themselves out.
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

/// A line of display type that wipes in behind a travelling highlight.
///
/// The text is drawn once; a gradient shader masks it from left to right so
/// the letters appear to be struck rather than faded, and a brighter band
/// rides the leading edge. This is what stops a big headline from looking
/// like a plain opacity tween.
class SweepReveal extends StatelessWidget {
  const SweepReveal({
    super.key,
    required this.child,
    required this.t,
    this.feather = 0.22,
  });

  final Widget child;
  final double t;

  /// How soft the wipe's leading edge is, as a fraction of the width.
  final double feather;

  @override
  Widget build(BuildContext context) {
    final p = t.clamp(0.0, 1.0);
    if (p <= 0) return Opacity(opacity: 0, child: child);
    if (p >= 1) return child;

    // The wipe runs from -feather to 1+feather so the text is fully lit at 1.
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
