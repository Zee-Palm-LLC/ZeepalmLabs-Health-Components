import 'package:flutter/material.dart';

import '../core/motion.dart';

class RevealLine extends StatelessWidget {
  const RevealLine({
    super.key,
    required this.animation,
    required this.begin,
    required this.text,
    required this.style,
    this.end,
    this.align = TextAlign.center,
    this.rise = 0.55,
  });

  final Animation<double> animation;
  final double begin;
  final double? end;
  final String text;
  final TextStyle style;
  final TextAlign align;
  final double rise;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = span(animation.value, begin, end ?? begin + 0.42, gentle);
        return ClipRect(
          clipper: _Riser(t),
          child: Transform.translate(
            offset: Offset(0, (style.fontSize ?? 20) * rise * (1 - t)),
            child: Opacity(opacity: (t * 1.6).clamp(0.0, 1.0), child: child),
          ),
        );
      },
      child: Text(text, textAlign: align, style: style),
    );
  }
}

class _Riser extends CustomClipper<Rect> {
  const _Riser(this.t);

  final double t;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, -size.height * 0.4, size.width, size.height * (t >= 1 ? 2.0 : 1.8 * t));

  @override
  bool shouldReclip(_Riser old) => old.t != t;
}

class ScrambleText extends StatelessWidget {
  const ScrambleText({
    super.key,
    required this.text,
    required this.progress,
    required this.style,
    this.align = TextAlign.left,
  });

  final String text;
  final double progress;
  final TextStyle style;
  final TextAlign align;

  static const _pool = 'abcdefghijklmnopqrstuvwxyz';

  @override
  Widget build(BuildContext context) {
    if (progress >= 1) return Text(text, textAlign: align, style: style);
    final chars = text.split('');
    final seed = (progress * 60).floor();
    final out = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      final settle = (progress * 1.5 - i / chars.length * 0.5).clamp(0.0, 1.0);
      final c = chars[i];
      if (settle >= 1 || c == ' ' || c == '\n') {
        out.write(c);
      } else {
        final k = (i * 31 + seed * 17) % _pool.length;
        out.write(c.toUpperCase() == c && c != c.toLowerCase() ? _pool[k].toUpperCase() : _pool[k]);
      }
    }
    return Text(out.toString(), textAlign: align, style: style);
  }
}
