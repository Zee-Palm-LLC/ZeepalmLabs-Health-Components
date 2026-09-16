import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.size,
    required this.color,
    this.trackColor = const Color(0xFF1A2030),
    this.stroke = 12,
    this.glow = 0.55,
    this.child,
  });

  final double value;
  final double size;
  final Color color;
  final Color trackColor;
  final double stroke;
  final double glow;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value,
          color: color,
          trackColor: trackColor,
          stroke: stroke,
          glow: glow,
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.stroke,
    required this.glow,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double stroke;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    const start = -math.pi / 2;
    final sweep = (value.clamp(0.0, 1.0)) * math.pi * 2;

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = trackColor
        ..isAntiAlias = true,
    );

    if (sweep <= 0.001) return;

    if (glow > 0) {
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 0.9),
      );
    }

    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..shader = SweepGradient(
          startAngle: start,
          endAngle: start + math.pi * 2,
          colors: <Color>[
            color.withValues(alpha: 0.72),
            color,
            color,
          ],
          stops: const <double>[0, 0.55, 1],
          transform: GradientRotation(start),
        ).createShader(rect),
    );

    final head = Offset(
      rect.center.dx + rect.width / 2 * math.cos(start + sweep),
      rect.center.dy + rect.height / 2 * math.sin(start + sweep),
    );
    canvas.drawCircle(
      head,
      stroke * 0.62,
      Paint()
        ..color = color.withValues(alpha: 0.85)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 0.7),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.stroke != stroke ||
      old.glow != glow;
}

class MeterBar extends StatelessWidget {
  const MeterBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
    this.trackColor = const Color(0xFF1A2030),
    this.shimmer = 0,
  });

  final double value;
  final Color color;
  final double height;
  final Color trackColor;

  final double shimmer;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: CustomPaint(
          painter: _MeterPainter(
            value: value,
            color: color,
            trackColor: trackColor,
            shimmer: shimmer,
          ),
          child: const SizedBox.expand(),
        ),
      );
}

class _MeterPainter extends CustomPainter {
  const _MeterPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.shimmer,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double shimmer;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, r),
      Paint()..color = trackColor,
    );

    final w = size.width * value.clamp(0.0, 1.0);
    if (w < 1) return;

    final fill = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, size.height),
      r,
    );
    canvas.drawRRect(
      fill,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[color.withValues(alpha: 0.78), color],
        ).createShader(Rect.fromLTWH(0, 0, w, size.height)),
    );
    canvas.drawRRect(
      fill,
      Paint()
        ..color = color.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.height * 0.7),
    );

    if (shimmer > 0) {
      final x = ((shimmer * 0.5) % 1.0) * 1.5 - 0.25;
      canvas.save();
      canvas.clipRRect(fill);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, size.height),
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = LinearGradient(
            begin: Alignment(x - 0.5, 0),
            end: Alignment(x + 0.5, 0),
            colors: const <Color>[
              Color(0x00FFFFFF),
              Color(0x4DFFFFFF),
              Color(0x00FFFFFF),
            ],
          ).createShader(Rect.fromLTWH(0, 0, w, size.height)),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_MeterPainter old) =>
      old.value != value ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.shimmer != shimmer;
}
