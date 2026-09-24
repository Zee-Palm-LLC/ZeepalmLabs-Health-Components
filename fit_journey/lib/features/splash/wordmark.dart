import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';

class Wordmark extends StatelessWidget {
  const Wordmark({super.key, required this.rise, required this.sheen, this.size = 47.5});

  final Animation<double> rise;
  final Animation<double> sheen;
  final double size;

  TextStyle get style => font(size, 800, color: Palette.wordNavy);

  @override
  Widget build(BuildContext context) {
    final painter = _WordmarkPainter(rise: rise, sheen: sheen, style: style);
    return CustomPaint(size: painter.extent, painter: painter);
  }
}

class _WordmarkPainter extends CustomPainter {
  _WordmarkPainter({required this.rise, required this.sheen, required this.style})
    : super(repaint: Listenable.merge([rise, sheen])) {
    _layout = _build(null);
  }

  final Animation<double> rise;
  final Animation<double> sheen;
  final TextStyle style;
  late final TextPainter _layout;

  static const _fit = 'Fit';
  static const _journey = 'Journey';

  Size get extent => Size(_layout.width, _layout.height);

  TextPainter _build(Paint? overlay) {
    final journeyStart = _fitWidth();
    final gradient = ui.Gradient.linear(
      Offset(journeyStart, 0),
      Offset(journeyStart + style.fontSize! * 3.4, 0),
      const [Palette.wordGreenA, Palette.wordGreenB],
    );
    final journeyPaint = Paint()..shader = gradient;
    final base = overlay == null ? style : style.copyWith(foreground: overlay, color: null);
    final span = TextSpan(
      style: base,
      children: [
        const TextSpan(text: _fit),
        TextSpan(text: _journey, style: overlay == null ? TextStyle(foreground: journeyPaint) : null),
      ],
    );
    return TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
  }

  double _fitWidth() {
    final probe = TextPainter(
      text: TextSpan(text: _fit, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return probe.width;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = rise.value;
    final count = _fit.length + _journey.length;
    final lift = style.fontSize! * 1.05;
    for (var i = 0; i < count; i++) {
      final begin = i * 0.055;
      final local = span(t, begin, begin + 0.5, Curves.linear);
      if (local <= 0) continue;
      final e = spring(local, bounce: 0.28, freq: 2.4);
      final boxes = _layout.getBoxesForSelection(TextSelection(baseOffset: i, extentOffset: i + 1));
      if (boxes.isEmpty) continue;
      final box = boxes.first.toRect();
      final clip = Rect.fromLTRB(box.left - 3, -style.fontSize!, box.right + 3, size.height);
      canvas.save();
      canvas.clipRect(clip);
      final tilt = (1 - e) * 0.18;
      canvas.translate(box.center.dx, box.bottom);
      canvas.rotate(tilt);
      canvas.translate(-box.center.dx, -box.bottom + (1 - e) * lift);
      _layout.paint(canvas, Offset.zero);
      canvas.restore();
    }

    final s = sheen.value;
    if (s > 0 && s < 1) {
      final w = size.width;
      final x = lerp(-w * 0.35, w * 1.35, Curves.easeInOut.transform(s));
      final band = Paint()
        ..shader = ui.Gradient.linear(
          Offset(x - 46, 0),
          Offset(x + 46, size.height * 0.4),
          [const Color(0x00FFFFFF), const Color(0x8CFFFFFF), const Color(0x00FFFFFF)],
          const [0.0, 0.5, 1.0],
        );
      _build(band).paint(canvas, Offset.zero);
    }
  }

  @override
  bool shouldRepaint(_WordmarkPainter old) => old.style != style;
}
