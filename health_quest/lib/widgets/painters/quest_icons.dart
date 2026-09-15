import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Every glyph on the dashboard, the quest detail and the vault.
///
/// All drawn, for the same reason the stat icons are: one stroke weight, one
/// highlight convention, and each one can animate. An icon font would give
/// none of that and would not match the stat badges it sits beside.
enum QuestGlyph {
  drop,
  footprints,
  lotus,
  swords,
  bars,
  trophy,
  person,
  bell,
  lock,
  check,
  chevron,
  back,
  more,
  flame,
  moon,
  crown,
  shoe,
  heart,
  shield,
}

class QuestIcon extends StatelessWidget {
  const QuestIcon({
    super.key,
    required this.glyph,
    required this.size,
    required this.color,
    this.highlight,
    this.progress = 1,
    this.strokeWidth,
  });

  final QuestGlyph glyph;
  final double size;
  final Color color;
  final Color? highlight;

  /// Used by the animated glyphs: the check draws on, the flame flickers.
  final double progress;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: QuestIconPainter(
          glyph: glyph,
          color: color,
          highlight: highlight ?? color,
          progress: progress,
          strokeWidth: strokeWidth ?? 7,
        ),
      );
}

class QuestIconPainter extends CustomPainter {
  const QuestIconPainter({
    required this.glyph,
    required this.color,
    required this.highlight,
    required this.progress,
    required this.strokeWidth,
  });

  final QuestGlyph glyph;
  final Color color;
  final Color highlight;
  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.shortestSide / 100);
    switch (glyph) {
      case QuestGlyph.drop:
        _drop(canvas);
      case QuestGlyph.footprints:
        _footprints(canvas);
      case QuestGlyph.lotus:
        _lotus(canvas);
      case QuestGlyph.swords:
        _swords(canvas);
      case QuestGlyph.bars:
        _bars(canvas);
      case QuestGlyph.trophy:
        _trophy(canvas);
      case QuestGlyph.person:
        _person(canvas);
      case QuestGlyph.bell:
        _bell(canvas);
      case QuestGlyph.lock:
        _lock(canvas);
      case QuestGlyph.check:
        _check(canvas);
      case QuestGlyph.chevron:
        _chevron(canvas);
      case QuestGlyph.back:
        _back(canvas);
      case QuestGlyph.more:
        _more(canvas);
      case QuestGlyph.flame:
        _flame(canvas);
      case QuestGlyph.moon:
        _moon(canvas);
      case QuestGlyph.crown:
        _crown(canvas);
      case QuestGlyph.shoe:
        _shoe(canvas);
      case QuestGlyph.heart:
        _heart(canvas);
      case QuestGlyph.shield:
        _shield(canvas);
    }
    canvas.restore();
  }

  Paint get _fill => Paint()
    ..isAntiAlias = true
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[highlight, color],
    ).createShader(const Rect.fromLTWH(0, 0, 100, 100));

  Paint _line([double? w, Color? c]) => Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = w ?? strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = c ?? color;

  void _drop(Canvas c) {
    final p = Path()
      ..moveTo(50, 8)
      ..cubicTo(72, 36, 84, 52, 84, 64)
      ..cubicTo(84, 83, 69, 94, 50, 94)
      ..cubicTo(31, 94, 16, 83, 16, 64)
      ..cubicTo(16, 52, 28, 36, 50, 8)
      ..close();
    c.drawPath(p, _fill);
    c.drawPath(
      Path()
        ..moveTo(33, 64)
        ..cubicTo(29, 52, 36, 42, 43, 36),
      _line(6, const Color(0xCCFFFFFF)),
    );
  }

  void _footprints(Canvas c) {
    void foot(double x, double y, double tilt, double scale) {
      c.save();
      c.translate(x, y);
      c.rotate(tilt);
      c.scale(scale);
      c.drawPath(
        Path()
          ..addOval(const Rect.fromLTWH(-13, -22, 26, 34))
          ..addOval(const Rect.fromLTWH(-12, 14, 22, 16)),
        _fill,
      );
      c.restore();
    }

    foot(34, 38, -0.12, 0.92);
    foot(66, 62, -0.12, 0.92);
  }

  void _lotus(Canvas c) {
    void petal(double angle, double len, double wide) {
      c.save();
      c.translate(50, 62);
      c.rotate(angle);
      c.drawPath(
        Path()
          ..moveTo(0, 0)
          ..cubicTo(-wide, -len * 0.55, -wide * 0.6, -len, 0, -len)
          ..cubicTo(wide * 0.6, -len, wide, -len * 0.55, 0, 0)
          ..close(),
        _fill,
      );
      c.restore();
    }

    petal(-1.02, 34, 15);
    petal(1.02, 34, 15);
    petal(-0.52, 44, 16);
    petal(0.52, 44, 16);
    petal(0, 50, 18);
  }

  void _swords(Canvas c) {
    void blade(bool mirror) {
      c.save();
      c.translate(50, 50);
      c.scale(mirror ? -1 : 1, 1);
      c.drawPath(
        Path()
          ..moveTo(28, -34)
          ..lineTo(36, -26)
          ..lineTo(-8, 22)
          ..lineTo(-18, 12)
          ..close(),
        _fill,
      );
      c.drawLine(const Offset(-14, 18), const Offset(-30, 34), _line(8));
      c.drawLine(const Offset(-26, 16), const Offset(-12, 30), _line(7));
      c.restore();
    }

    blade(false);
    blade(true);
  }

  void _bars(Canvas c) {
    const heights = <double>[30, 52, 72];
    for (var i = 0; i < 3; i++) {
      final x = 24.0 + i * 26;
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 8, 84 - heights[i], 16, heights[i]),
          const Radius.circular(5),
        ),
        _fill,
      );
    }
  }

  void _trophy(Canvas c) {
    c.drawPath(
      Path()
        ..moveTo(30, 14)
        ..lineTo(70, 14)
        ..lineTo(68, 48)
        ..cubicTo(68, 62, 60, 68, 50, 68)
        ..cubicTo(40, 68, 32, 62, 32, 48)
        ..close(),
      _fill,
    );
    c.drawPath(
      Path()
        ..moveTo(30, 22)
        ..cubicTo(16, 22, 14, 42, 30, 44),
      _line(6),
    );
    c.drawPath(
      Path()
        ..moveTo(70, 22)
        ..cubicTo(84, 22, 86, 42, 70, 44),
      _line(6),
    );
    c.drawLine(const Offset(50, 68), const Offset(50, 80), _line(8));
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(32, 80, 36, 10),
        const Radius.circular(4),
      ),
      _fill,
    );
  }

  void _person(Canvas c) {
    c.drawCircle(const Offset(50, 34), 17, _line(7));
    c.drawPath(
      Path()
        ..moveTo(20, 86)
        ..cubicTo(20, 64, 36, 56, 50, 56)
        ..cubicTo(64, 56, 80, 64, 80, 86),
      _line(7),
    );
  }

  void _bell(Canvas c) {
    c.drawPath(
      Path()
        ..moveTo(26, 68)
        ..cubicTo(26, 46, 28, 26, 50, 26)
        ..cubicTo(72, 26, 74, 46, 74, 68)
        ..lineTo(80, 74)
        ..lineTo(20, 74)
        ..close(),
      _line(7),
    );
    c.drawLine(const Offset(50, 18), const Offset(50, 26), _line(7));
    c.drawPath(
      Path()
        ..moveTo(42, 80)
        ..cubicTo(44, 88, 56, 88, 58, 80),
      _line(7),
    );
  }

  void _lock(Canvas c) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(24, 44, 52, 42),
        const Radius.circular(10),
      ),
      _fill,
    );
    c.drawPath(
      Path()
        ..moveTo(34, 44)
        ..lineTo(34, 32)
        ..cubicTo(34, 18, 66, 18, 66, 32)
        ..lineTo(66, 44),
      _line(8),
    );
  }

  void _check(Canvas c) {
    final p = Path()
      ..moveTo(24, 52)
      ..lineTo(43, 70)
      ..lineTo(77, 32);
    if (progress >= 1) {
      c.drawPath(p, _line(10));
      return;
    }
    for (final m in p.computeMetrics()) {
      c.drawPath(m.extractPath(0, m.length * progress.clamp(0.0, 1.0)),
          _line(10));
    }
  }

  void _chevron(Canvas c) {
    c.drawPath(
      Path()
        ..moveTo(40, 24)
        ..lineTo(64, 50)
        ..lineTo(40, 76),
      _line(8),
    );
  }

  void _back(Canvas c) {
    c.drawPath(
      Path()
        ..moveTo(60, 24)
        ..lineTo(36, 50)
        ..lineTo(60, 76),
      _line(8),
    );
  }

  void _more(Canvas c) {
    for (var i = 0; i < 3; i++) {
      c.drawCircle(Offset(28.0 + i * 22, 50), 5.5, Paint()..color = color);
    }
  }

  void _flame(Canvas c) {
    final wobble = math.sin(progress * math.pi * 2) * 3;
    c.drawPath(
      Path()
        ..moveTo(52, 6)
        ..cubicTo(86 + wobble, 34, 98, 52, 90, 68)
        ..cubicTo(80, 96, 18, 98, 10, 68)
        ..cubicTo(4, 48, 24 - wobble, 40, 33, 54)
        ..cubicTo(33, 28, 42, 14, 52, 6)
        ..close(),
      _fill,
    );
  }

  void _moon(Canvas c) {
    c.saveLayer(const Rect.fromLTWH(0, 0, 100, 100), Paint());
    c.drawCircle(const Offset(52, 50), 34, _fill);
    c.drawCircle(
      const Offset(70, 36),
      30,
      Paint()..blendMode = BlendMode.dstOut,
    );
    c.restore();
  }

  void _crown(Canvas c) {
    c.drawPath(
      Path()
        ..moveTo(16, 74)
        ..lineTo(22, 30)
        ..lineTo(38, 48)
        ..lineTo(50, 20)
        ..lineTo(62, 48)
        ..lineTo(78, 30)
        ..lineTo(84, 74)
        ..close(),
      _fill,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, 78, 68, 10),
        const Radius.circular(4),
      ),
      _fill,
    );
  }

  /// A side-on trainer: collar, instep, toe, then the sole as its own bar.
  /// Drawn as separate pieces because at 24 px a single outline turns to mush.
  void _shoe(Canvas c) {
    c.drawPath(
      Path()
        ..moveTo(16, 38)
        ..lineTo(38, 34)
        ..lineTo(46, 52)
        ..cubicTo(60, 54, 74, 59, 86, 66)
        ..cubicTo(92, 69, 91, 74, 84, 74)
        ..lineTo(16, 74)
        ..close(),
      _fill,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 72, 82, 13),
        const Radius.circular(6),
      ),
      _fill,
    );
    final lace = _line(4.5, const Color(0xE6FFFFFF));
    c.drawLine(const Offset(27, 44), const Offset(41, 49), lace);
    c.drawLine(const Offset(25, 54), const Offset(39, 59), lace);
    c.drawLine(const Offset(10, 79), const Offset(92, 79),
        _line(3, const Color(0x59000000)));
  }

  void _heart(Canvas c) {
    c.drawPath(
      Path()
        ..moveTo(50, 86)
        ..cubicTo(8, 58, 6, 34, 22, 22)
        ..cubicTo(34, 13, 45, 18, 50, 29)
        ..cubicTo(55, 18, 66, 13, 78, 22)
        ..cubicTo(94, 34, 92, 58, 50, 86)
        ..close(),
      _fill,
    );
  }

  void _shield(Canvas c) {
    c.drawPath(
      Path()
        ..moveTo(50, 10)
        ..lineTo(82, 24)
        ..lineTo(82, 52)
        ..cubicTo(82, 74, 66, 86, 50, 92)
        ..cubicTo(34, 86, 18, 74, 18, 52)
        ..lineTo(18, 24)
        ..close(),
      _fill,
    );
  }

  @override
  bool shouldRepaint(QuestIconPainter old) =>
      old.glyph != glyph ||
      old.color != color ||
      old.highlight != highlight ||
      old.progress != progress ||
      old.strokeWidth != strokeWidth;
}
