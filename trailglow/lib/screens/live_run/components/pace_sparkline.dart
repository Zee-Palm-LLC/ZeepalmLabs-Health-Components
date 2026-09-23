import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../app/theme/palette.dart';
import '../../../data/mock/runs.dart';

class PaceSparkline extends StatelessWidget {
  const PaceSparkline({
    super.key,
    required this.progress,
    required this.targetPace,
    this.height = 46,
  });

  final double progress;
  final int targetPace;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparkPainter(progress: progress, targetPace: targetPace),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.progress, required this.targetPace});

  final double progress;
  final int targetPace;

  @override
  void paint(Canvas canvas, Size size) {
    const samples = 56;
    const window = 0.26;
    final start = math.max(0.0, progress - window);
    final span = math.max(0.02, progress - start);

    final values = List<double>.generate(samples, (i) {
      final t = start + span * (i / (samples - 1));
      return targetPace * MockRuns.paceFactorAt(t);
    });

    var min = values.reduce(math.min);
    var max = values.reduce(math.max);
    if (max - min < 12) {
      final mid = (max + min) / 2;
      min = mid - 6;
      max = mid + 6;
    }

    Offset pointAt(int i) {
      final x = size.width * (i / (samples - 1));
      final norm = (values[i] - min) / (max - min);
      final y = size.height * (0.16 + norm * 0.72);
      return Offset(x, y);
    }

    final line = Path();
    for (var i = 0; i < samples; i++) {
      final p = pointAt(i);
      if (i == 0) {
        line.moveTo(p.dx, p.dy);
      } else {
        line.lineTo(p.dx, p.dy);
      }
    }

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(0, size.height),
          <Color>[
            Spectrum.cyan.withValues(alpha: 0.22),
            Spectrum.blue.withValues(alpha: 0.04),
            const Color(0x00000000),
          ],
          const <double>[0.0, 0.6, 1.0],
        ),
    );

    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..color = Spectrum.cyan.withValues(alpha: 0.35),
    );

    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, 0),
          const <Color>[Spectrum.deep, Spectrum.blue, Spectrum.cyan],
          const <double>[0.0, 0.5, 1.0],
        ),
    );

    final head = pointAt(samples - 1);
    canvas.drawCircle(
      head,
      7,
      Paint()
        ..color = Spectrum.cyan.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(head, 3.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_SparkPainter old) =>
      old.progress != progress || old.targetPace != targetPace;
}
