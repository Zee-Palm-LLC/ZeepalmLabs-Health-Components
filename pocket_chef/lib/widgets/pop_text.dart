import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion.dart';

class PopText extends StatelessWidget {
  const PopText({
    super.key,
    required this.text,
    required this.style,
    required this.animation,
    required this.begin,
    required this.end,
    this.stretch = 1,
    this.rise = 26,
    this.spin = 0.35,
    this.ripple = 0,
    this.ripplePhase = 0,
  });

  final String text;
  final TextStyle style;
  final Animation<double> animation;
  final double begin;
  final double end;
  final double stretch;
  final double rise;
  final double spin;
  final double ripple;
  final double ripplePhase;

  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final xs = [for (var i = 0; i <= text.length; i++) painter.getOffsetForCaret(TextPosition(offset: i), Rect.zero).dx];
    final baseline = painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    final n = text.length;
    final each = (end - begin) * 0.5;
    final step = n > 1 ? (end - begin - each) / (n - 1) : 0.0;
    final letters = <Widget>[];
    for (var i = 0; i < n; i++) {
      if (text[i] == ' ') continue;
      letters.add(
        Positioned(
          left: xs[i],
          top: 0,
          child: _Letter(
            char: text[i],
            style: style,
            animation: animation,
            begin: begin + step * i,
            end: begin + step * i + each,
            rise: rise,
            spin: spin * (i.isEven ? -1 : 1),
            baseline: baseline,
            stretch: stretch,
            ripple: ripple,
            phase: ripplePhase + i / n,
          ),
        ),
      );
    }
    return SizedBox(
      width: painter.width,
      height: painter.height,
      child: Stack(clipBehavior: Clip.none, children: letters),
    );
  }
}

class _Letter extends StatelessWidget {
  const _Letter({
    required this.char,
    required this.style,
    required this.animation,
    required this.begin,
    required this.end,
    required this.rise,
    required this.spin,
    required this.baseline,
    required this.stretch,
    required this.ripple,
    required this.phase,
  });

  final String char;
  final TextStyle style;
  final Animation<double> animation;
  final double begin;
  final double end;
  final double rise;
  final double spin;
  final double baseline;
  final double stretch;
  final double ripple;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final glyph = Text(char, style: style);
    Widget body = AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final raw = ((animation.value - begin) / (end - begin)).clamp(0.0, 1.0);
        final s = spring(raw, bounce: 0.55, freq: 2.6);
        final o = span(animation.value, begin, begin + (end - begin) * 0.35, Curves.easeOut);
        final squash = raw < 1 ? math.sin(raw * math.pi * 2.2) * 0.12 * (1 - raw) : 0.0;
        final m = Matrix4.identity()
          ..translateByDouble(0, rise * (1 - s), 0, 1)
          ..rotateZ(spin * (1 - s))
          ..scaleByDouble(lerp(0.3, 1, s) * (1 + squash), lerp(0.3, 1, s) * stretch * (1 - squash), 1, 1);
        return Opacity(
          opacity: o,
          child: Transform(transform: m, origin: Offset(0, baseline), alignment: Alignment.topCenter, child: child),
        );
      },
      child: glyph,
    );
    if (ripple > 0) {
      body = Tick(
        child: body,
        builder: (context, seconds, child) {
          final u = (seconds / 4.2) % 1.0;
          final front = (u - 0.62) / 0.3 * 1.6 - 0.3;
          final d = (front - phase) * 7;
          final pulse = u < 0.62 ? 0.0 : math.exp(-d * d);
          return Transform.translate(offset: Offset(0, -ripple * pulse), child: child);
        },
      );
    }
    return body;
  }
}
