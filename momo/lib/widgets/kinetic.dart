import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/motion.dart';

class Typed extends StatelessWidget {
  const Typed(
    this.text, {
    super.key,
    required this.progress,
    required this.style,
  });

  final String text;
  final double progress;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final exact = text.length * progress.clamp(0.0, 1.0);
    final shown = exact.floor();
    final fade = exact - shown;
    final color = style.color ?? const Color(0xFF000000);
    final spans = <TextSpan>[TextSpan(text: text.substring(0, shown))];
    if (shown < text.length) {
      spans.add(
        TextSpan(
          text: text[shown],
          style: TextStyle(color: color.withValues(alpha: color.a * fade)),
        ),
      );
      if (shown + 1 < text.length) {
        spans.add(
          TextSpan(
            text: text.substring(shown + 1),
            style: const TextStyle(color: Color(0x00000000)),
          ),
        );
      }
    }
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
    );
  }
}

class Odometer extends StatelessWidget {
  const Odometer({
    super.key,
    required this.value,
    required this.progress,
    required this.style,
    this.grouped = false,
  });

  final int value;
  final double progress;
  final TextStyle style;
  final bool grouped;

  String _format(int v) {
    final s = v.toString();
    if (!grouped || s.length <= 3) return s;
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final finalText = _format(value);
    if (progress >= 1) {
      return Text(
        finalText,
        style: style,
        maxLines: 1,
        softWrap: false,
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,
        ),
      );
    }
    final p = progress.clamp(0.0, 1.0);
    final painter = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final h = painter.height;
    final digits = finalText.replaceAll(',', '').length;
    final cells = <Widget>[];
    var index = 0;
    for (final ch in finalText.split('')) {
      if (ch == ',') {
        cells.add(
          Opacity(
            opacity: span(p, 0.1, 0.4),
            child: Text(',', style: style),
          ),
        );
        continue;
      }
      final target = int.parse(ch);
      final begin = digits <= 1 ? 0.0 : index / (digits - 1) * 0.28;
      final local = ((p - begin) / (1 - begin)).clamp(0.0, 1.0);
      final travel = target + 10.0;
      final pos = Curves.easeOutCubic.transform(local) * travel;
      final speed = (1 - local) * (1 - local);
      final glyphW = (TextPainter(
        text: TextSpan(text: ch, style: style),
        textDirection: TextDirection.ltr,
      )..layout()).width;
      cells.add(
        SizedBox(
          width: glyphW,
          height: h,
          child: ClipRect(
            child: Opacity(
              opacity: (local * 6).clamp(0.0, 1.0),
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: h * 21,
                child: Transform.translate(
                  offset: Offset(0, -pos * h),
                  child: ImageFiltered(
                    enabled: speed > 0.05,
                    imageFilter: ui.ImageFilter.blur(
                      sigmaX: 0,
                      sigmaY: 2.4 * speed,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var d = 0; d <= 20; d++)
                          SizedBox(
                            height: h,
                            child: Center(
                              child: Text(
                                '${d % 10}',
                                style: style,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      index++;
    }
    return Row(mainAxisSize: MainAxisSize.min, children: cells);
  }
}

class Dots extends StatelessWidget {
  const Dots({
    super.key,
    this.color = const Color(0xFFBDBBB5),
    this.size = 6,
    this.gap = 5,
  });

  final Color color;
  final double size;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, t, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Builder(
              builder: (context) {
                final phase = ((t * 1.6 - i * 0.16) % 1.0);
                final lift = phase < 0.4
                    ? math.sin(phase / 0.4 * math.pi)
                    : 0.0;
                return Transform.translate(
                  offset: Offset(0, -3.2 * lift),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(color, const Color(0xFF8E8A82), lift)!,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class Pop extends StatelessWidget {
  const Pop({
    super.key,
    required this.t,
    required this.child,
    this.from = 0.6,
    this.alignment = Alignment.center,
    this.dy = 0,
  });

  final double t;
  final double from;
  final double dy;
  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = spring(t, bounce: 0.3, freq: 2.2);
    return Opacity(
      opacity: t.clamp(0.0, 1.0) < 1
          ? Curves.easeOut.transform((t * 1.8).clamp(0.0, 1.0))
          : 1,
      child: Transform.translate(
        offset: Offset(0, dy * (1 - s)),
        child: Transform.scale(
          scale: lerp(from, 1, s),
          alignment: alignment,
          child: child,
        ),
      ),
    );
  }
}
