import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion.dart';

class SplitText extends StatelessWidget {
  const SplitText({
    super.key,
    required this.text,
    required this.style,
    required this.animation,
    required this.begin,
    required this.end,
    this.gradient,
    this.rise = 18,
    this.flip = 0.9,
    this.stretch = 1,
  });

  final String text;
  final TextStyle style;
  final Animation<double> animation;
  final double begin;
  final double end;
  final Gradient? gradient;
  final double rise;
  final double flip;
  final double stretch;

  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final size = painter.size;
    final xs = [
      for (var i = 0; i <= text.length; i++) painter.getOffsetForCaret(TextPosition(offset: i), Rect.zero).dx,
    ];
    final n = text.length;
    final each = (end - begin) * 0.55;
    final step = n > 1 ? (end - begin - each) / (n - 1) : 0.0;
    final pad = style.fontSize! * 0.32;
    final letters = SizedBox(
      width: size.width + 4,
      height: size.height + pad,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < n; i++)
            if (text[i] != ' ')
              Positioned(
                left: xs[i],
                top: 0,
                child: _Letter(
                  char: text[i],
                  style: style.copyWith(color: Colors.white, foreground: null),
                  animation: animation,
                  begin: begin + step * i,
                  end: begin + step * i + each,
                  rise: rise,
                  flip: flip,
                ),
              ),
        ],
      ),
    );
    final painted = gradient == null
        ? letters
        : ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) => gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height + pad)),
            child: letters,
          );
    if (stretch == 1) return painted;
    return Transform(
      alignment: Alignment.centerLeft,
      transform: Matrix4.diagonal3Values(stretch, 1, 1),
      child: painted,
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
    required this.flip,
  });

  final String char;
  final TextStyle style;
  final Animation<double> animation;
  final double begin;
  final double end;
  final double rise;
  final double flip;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = span(animation.value, begin, end, settle);
        final o = span(animation.value, begin, begin + (end - begin) * 0.5, Curves.easeOut);
        final m = Matrix4.identity()
          ..setEntry(3, 2, 0.0022)
          ..translateByDouble(0, rise * (1 - t), 0, 1)
          ..rotateX(-flip * math.max(0, 1 - t));
        return Opacity(
          opacity: o,
          child: Transform(alignment: Alignment.bottomCenter, transform: m, child: child),
        );
      },
      child: Text(char, style: style),
    );
  }
}
