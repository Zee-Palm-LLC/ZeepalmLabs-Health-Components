import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/palette.dart';

class Aurora extends StatefulWidget {
  const Aurora({super.key, this.height = 380});

  final double height;

  @override
  State<Aurora> createState() => _AuroraState();
}

class _AuroraState extends State<Aurora> with SingleTickerProviderStateMixin, ClockMixin {
  @override
  void initState() {
    super.initState();
    startClock();
  }

  @override
  void dispose() {
    disposeClock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: RepaintBoundary(child: CustomPaint(painter: AuroraPainter(clock))),
    );
  }
}

class AuroraHero extends StatelessWidget {
  const AuroraHero({super.key, this.height = 380});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'aurora',
      flightShuttleBuilder: (context, animation, direction, from, to) => Aurora(height: height),
      child: Aurora(height: height),
    );
  }
}

class AuroraPainter extends CustomPainter {
  AuroraPainter(this.clock) : super(repaint: clock);

  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    final s = clock.value;
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, h),
          const [Color(0xFF55747A), Color(0xFF5B797D), Color(0xFF9FB1B3), Palette.canvas],
          const [0, 0.42, 0.72, 1],
        ),
    );

    void blob(Offset centre, double radius, Color color, double alpha) {
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(
            centre,
            radius,
            [color.withValues(alpha: alpha), color.withValues(alpha: alpha * 0.45), color.withValues(alpha: 0)],
            const [0, 0.5, 1],
          ),
      );
    }

    blob(
      Offset(w * (0.44 + 0.05 * wave(s, 14)), h * (0.2 + 0.03 * wave(s, 11, 0.2))),
      w * 0.72,
      const Color(0xFF173F43),
      0.92,
    );
    blob(Offset(w * (-0.04 + 0.04 * wave(s, 17, 0.5)), h * -0.02), w * 0.48, const Color(0xFF7F979B), 0.75);
    blob(
      Offset(w * (1.06 + 0.04 * wave(s, 13, 0.7)), h * (0.5 + 0.04 * wave(s, 15))),
      w * 0.62,
      const Color(0xFFD2DCDD),
      0.95,
    );
    blob(
      Offset(w * (0.2 + 0.06 * wave(s, 19, 0.1)), h * (0.62 + 0.02 * wave(s, 9))),
      w * 0.5,
      const Color(0xFF3F6468),
      0.35,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, h * 0.56),
          Offset(0, h),
          [Palette.canvas.withValues(alpha: 0), Palette.canvas.withValues(alpha: 0.85), Palette.canvas],
          const [0, 0.7, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(AuroraPainter oldDelegate) => false;
}
