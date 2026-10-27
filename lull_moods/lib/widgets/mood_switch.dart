import 'package:flutter/material.dart';

import '../mood.dart';

/// The pill toggle from the original, turned into a 5-stop mood slider:
/// tap to step, or drag the knob and the whole scene morphs live.
class MoodSwitch extends StatelessWidget {
  const MoodSwitch({
    super.key,
    required this.position,
    required this.v,
    required this.s,
    required this.stops,
    required this.onTap,
    required this.onDrag,
    required this.onDragEnd,
  });

  /// 0..1 (may overshoot slightly while springing).
  final double position;
  final MoodVisual v;
  final double s;
  final int stops;
  final VoidCallback onTap;
  final ValueChanged<double> onDrag;
  final ValueChanged<double> onDragEnd;

  @override
  Widget build(BuildContext context) {
    final border = 2.2 * s;
    final w = 118 * s - border * 2;
    final h = 46 * s - border * 2;
    final pad = 3 * s;
    final kd = h - pad * 2;
    final travel = w - pad * 2 - kd;

    return GestureDetector(
      onTap: onTap,
      onHorizontalDragUpdate: (d) => onDrag(position + d.delta.dx / travel),
      onHorizontalDragEnd: (d) => onDragEnd(d.velocity.pixelsPerSecond.dx / travel),
      child: Container(
        decoration: BoxDecoration(
          color: v.track,
          borderRadius: BorderRadius.circular(23 * s),
          border: Border.all(color: v.ink, width: border),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < stops; i++)
              Positioned(
                left: pad + kd / 2 + travel * i / (stops - 1) - 1.5 * s,
                top: h / 2 - 1.5 * s,
                child: Container(
                  width: 3 * s,
                  height: 3 * s,
                  decoration: BoxDecoration(color: v.ink.withValues(alpha: 0.28), shape: BoxShape.circle),
                ),
              ),
            Positioned(
              left: pad + travel * position,
              top: pad,
              child: Container(
                width: kd,
                height: kd,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.35),
                    radius: 0.9,
                    colors: [v.knobHi, v.knob],
                  ),
                  boxShadow: [
                    BoxShadow(color: v.knob.withValues(alpha: 0.45), blurRadius: 8 * s, offset: Offset(0, 2 * s)),
                  ],
                ),
                child: Align(
                  alignment: const Alignment(-0.38, -0.5),
                  child: Container(
                    width: kd * 0.28,
                    height: kd * 0.18,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(kd),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
