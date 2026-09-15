import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../core/palette.dart';

/// The four stat glyphs, drawn rather than pulled from an icon font so their
/// weights match each other and so each can carry its own inner highlight
/// and animate on its own terms.
enum StatGlyph { heart, brain, bolt, drop }

class StatIcon extends StatelessWidget {
  const StatIcon({
    super.key,
    required this.glyph,
    required this.tone,
    required this.size,
    this.pulse = 0,
    this.draw = 1,
  });

  final StatGlyph glyph;
  final StatTone tone;
  final double size;

  /// 0..1, a repeating phase used by the heart's trace and the bolt's flicker.
  final double pulse;

  /// 0..1 entrance, used to draw the glyph on rather than fade it in.
  final double draw;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _StatIconPainter(
          glyph: glyph,
          tone: tone,
          pulse: pulse,
          draw: draw,
        ),
      );
}

class _StatIconPainter extends CustomPainter {
  const _StatIconPainter({
    required this.glyph,
    required this.tone,
    required this.pulse,
    required this.draw,
  });

  final StatGlyph glyph;
  final StatTone tone;
  final double pulse;
  final double draw;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.save();
    canvas.scale(s / 100);
    switch (glyph) {
      case StatGlyph.heart:
        _heart(canvas);
      case StatGlyph.brain:
        _brain(canvas);
      case StatGlyph.bolt:
        _bolt(canvas);
      case StatGlyph.drop:
        _drop(canvas);
    }
    canvas.restore();
  }

  Paint get _fill => Paint()
    ..isAntiAlias = true
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[tone.tip, tone.core],
    ).createShader(const Rect.fromLTWH(0, 0, 100, 100));

  Paint _stroke(double w, Color c) => Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = c;

  void _glowPath(Canvas canvas, Path p) {
    canvas.drawPath(
      p,
      Paint()
        ..color = tone.core.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
  }

  /// A filled heart with an ECG trace cut through it. The trace sweeps left to
  /// right on [pulse], which is what makes the badge read as a heartbeat and
  /// not a sticker.
  void _heart(Canvas canvas) {
    final heart = Path()
      ..moveTo(50, 88)
      ..cubicTo(6, 58, 4, 34, 20, 22)
      ..cubicTo(33, 12, 45, 18, 50, 29)
      ..cubicTo(55, 18, 67, 12, 80, 22)
      ..cubicTo(96, 34, 94, 58, 50, 88)
      ..close();
    final trace = Path()
      ..moveTo(12, 52)
      ..lineTo(32, 52)
      ..lineTo(39, 38)
      ..lineTo(48, 68)
      ..lineTo(57, 47)
      ..lineTo(63, 52)
      ..lineTo(88, 52);

    _glowPath(canvas, heart);

    // Fill the heart, then punch the trace straight out of it, so the line
    // reads as a window onto the nebula rather than ink laid on top.
    canvas.saveLayer(const Rect.fromLTWH(-10, -10, 120, 120), Paint());
    canvas.drawPath(heart, _fill);
    canvas.drawPath(
      trace,
      _stroke(6.5, const Color(0xFF000000))..blendMode = BlendMode.dstOut,
    );
    canvas.restore();

    final metrics = trace.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final m = metrics.first;
      final at = (pulse % 1.0) * m.length;
      final pos = m.getTangentForOffset(at)?.position;
      if (pos != null) {
        canvas.drawCircle(
          pos,
          4.5,
          Paint()
            ..color = tone.tip
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }
  }

  /// Two hemispheres of lobes with a dividing stem, in outline.
  void _brain(Canvas canvas) {
    final outline = Path()
      ..moveTo(50, 16)
      ..cubicTo(38, 8, 22, 12, 19, 25)
      ..cubicTo(8, 28, 6, 42, 15, 48)
      ..cubicTo(8, 56, 12, 70, 24, 72)
      ..cubicTo(27, 84, 42, 88, 50, 80)
      ..cubicTo(58, 88, 73, 84, 76, 72)
      ..cubicTo(88, 70, 92, 56, 85, 48)
      ..cubicTo(94, 42, 92, 28, 81, 25)
      ..cubicTo(78, 12, 62, 8, 50, 16)
      ..close();
    _glowPath(canvas, outline);
    canvas.drawPath(
      outline,
      Paint()
        ..isAntiAlias = true
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            tone.core.withValues(alpha: 0.30),
            tone.core.withValues(alpha: 0.10),
          ],
        ).createShader(const Rect.fromLTWH(0, 0, 100, 100)),
    );
    canvas.drawPath(outline, _stroke(5, tone.core));

    final folds = Path()
      ..moveTo(50, 18)
      ..lineTo(50, 80)
      ..moveTo(33, 30)
      ..cubicTo(42, 33, 42, 43, 33, 46)
      ..moveTo(67, 30)
      ..cubicTo(58, 33, 58, 43, 67, 46)
      ..moveTo(30, 58)
      ..cubicTo(40, 60, 40, 68, 32, 70)
      ..moveTo(70, 58)
      ..cubicTo(60, 60, 60, 68, 68, 70);
    canvas.drawPath(folds, _stroke(4, tone.tip.withValues(alpha: 0.9)));
  }

  /// A bolt that flickers: the core brightens on [pulse] like a filament.
  void _bolt(Canvas canvas) {
    final bolt = Path()
      ..moveTo(58, 6)
      ..lineTo(24, 54)
      ..lineTo(45, 54)
      ..lineTo(40, 94)
      ..lineTo(76, 44)
      ..lineTo(54, 44)
      ..close();
    final flicker = 0.75 + 0.25 * math.sin(pulse * math.pi * 2);
    canvas.drawPath(
      bolt,
      Paint()
        ..color = tone.core.withValues(alpha: 0.6 * flicker)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + 4 * flicker),
    );
    canvas.drawPath(bolt, _fill);
    canvas.drawPath(
      bolt,
      _stroke(2, tone.tip.withValues(alpha: 0.85 * flicker)),
    );
  }

  /// A droplet with a highlight, and a meniscus that rocks gently.
  void _drop(Canvas canvas) {
    final drop = Path()
      ..moveTo(50, 8)
      ..cubicTo(72, 36, 84, 52, 84, 64)
      ..cubicTo(84, 83, 69, 94, 50, 94)
      ..cubicTo(31, 94, 16, 83, 16, 64)
      ..cubicTo(16, 52, 28, 36, 50, 8)
      ..close();
    _glowPath(canvas, drop);
    canvas.drawPath(drop, _fill);

    // Water line inside the drop, tilting on the pulse.
    canvas.save();
    canvas.clipPath(drop);
    final tilt = math.sin(pulse * math.pi * 2) * 3;
    final water = Path()
      ..moveTo(10, 62 + tilt)
      ..quadraticBezierTo(50, 55 + tilt, 90, 62 - tilt)
      ..lineTo(90, 100)
      ..lineTo(10, 100)
      ..close();
    canvas.drawPath(
      water,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.18),
    );
    canvas.restore();

    canvas.drawPath(
      Path()
        ..moveTo(33, 62)
        ..cubicTo(29, 50, 36, 40, 43, 34),
      _stroke(5, const Color(0xFFFFFFFF).withValues(alpha: 0.75)),
    );
  }

  @override
  bool shouldRepaint(_StatIconPainter old) =>
      old.glyph != glyph ||
      old.tone != tone ||
      old.pulse != pulse ||
      old.draw != draw;
}
