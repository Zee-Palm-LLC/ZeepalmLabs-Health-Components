import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/palette.dart';

class RunnerPuck extends StatefulWidget {
  const RunnerPuck({super.key, this.active = true, this.size = 120});

  final bool active;
  final double size;

  @override
  State<RunnerPuck> createState() => _RunnerPuckState();
}

class _RunnerPuckState extends State<RunnerPuck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void initState() {
    super.initState();
    _pulse.repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) => CustomPaint(
            painter: _PuckPainter(phase: _pulse.value, active: widget.active),
          ),
        ),
      ),
    );
  }
}

class _PuckPainter extends CustomPainter {
  _PuckPainter({required this.phase, required this.active});

  final double phase;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    if (active) {
      for (var i = 0; i < 2; i++) {
        final t = (phase + i * 0.5) % 1.0;
        final radius = 14 + t * (maxRadius - 14);
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..color = Spectrum.cyan.withValues(alpha: 0.30 * (1 - t)),
        );
      }
    }

    final breathe = 0.5 + 0.5 * math.sin(phase * math.pi * 2);
    canvas.drawCircle(
      center,
      26 + breathe * 4,
      Paint()
        ..color = Spectrum.cyan.withValues(alpha: active ? 0.20 : 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    canvas.drawCircle(center, 13, Paint()..color = const Color(0xFF060A12));
    canvas.drawCircle(
      center,
      13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..color = active ? Spectrum.cyan : Tone.muted,
    );
    canvas.drawCircle(
      center,
      5.2,
      Paint()..color = active ? Colors.white : Tone.secondary,
    );
  }

  @override
  bool shouldRepaint(_PuckPainter old) =>
      old.phase != phase || old.active != active;
}
