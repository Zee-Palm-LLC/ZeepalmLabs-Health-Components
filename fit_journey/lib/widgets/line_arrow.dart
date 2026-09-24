import 'package:flutter/material.dart';
import '../core/phosphor.dart';

class LineArrow extends StatelessWidget {
  const LineArrow({super.key, this.size = 19, this.color = Colors.white, this.shift = 0});

  final double size;
  final Color color;
  final double shift;

  @override
  Widget build(BuildContext context) {
    final travel = size * 1.3;
    return SizedBox.square(
      dimension: size,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final offset in [shift * travel, (shift - 1) * travel])
              if (offset.abs() < travel)
                Positioned(
                  left: offset,
                  top: 0,
                  child: Icon(PhosphorBold.arrowRight, size: size, color: color),
                ),
          ],
        ),
      ),
    );
  }
}
