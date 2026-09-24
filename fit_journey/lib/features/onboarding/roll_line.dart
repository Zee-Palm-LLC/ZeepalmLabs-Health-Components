import 'package:flutter/material.dart';

import '../../core/motion.dart';
import '../../core/type.dart';

class RollLine extends StatelessWidget {
  const RollLine({
    super.key,
    required this.previous,
    required this.current,
    required this.progress,
    required this.x,
    required this.base,
    required this.style,
    this.tilt = true,
  });

  final String? previous;
  final String current;
  final double progress;
  final double x;
  final double base;
  final TextStyle style;
  final bool tilt;

  @override
  Widget build(BuildContext context) {
    final size = style.fontSize!;
    final above = size * 1.02;
    final below = size * 0.32;
    final travel = above + below;
    final offset = baselineOffset(style);
    final p = progress.clamp(0.0, 1.0);
    return Positioned(
      left: x - 6,
      top: base - above,
      width: 393 - x,
      height: travel,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (previous != null && p < 1)
              Positioned(
                left: 6,
                top: above - offset - travel * p,
                child: Opacity(
                  opacity: (1 - p * 1.4).clamp(0.0, 1.0),
                  child: Text(previous!, style: style, maxLines: 1, softWrap: false),
                ),
              ),
            Positioned(
              left: 6,
              top: above - offset + travel * (1 - p),
              child: Transform.rotate(
                angle: tilt ? (1 - p) * 0.07 : 0,
                alignment: Alignment.bottomLeft,
                child: Opacity(
                  opacity: span(p, 0.0, 0.5, Curves.easeOut),
                  child: Text(current, style: style, maxLines: 1, softWrap: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
