import 'package:flutter/widgets.dart';

/// Rise-and-fade for one element of a staggered entrance. [t] is 0..1 and
/// may overshoot past 1 when the curve is a spring; opacity is clamped, the
/// offset is not, so the overshoot shows as motion and not as a flash.
class Rise extends StatelessWidget {
  const Rise({
    super.key,
    required this.t,
    required this.child,
    this.distance = 22,
    this.scaleFrom = 1,
    this.alignment = Alignment.center,
  });

  final double t;
  final Widget child;
  final double distance;
  final double scaleFrom;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) return Opacity(opacity: 0, child: child);
    final settled = t.clamp(0.0, 1.0);
    final scale = scaleFrom + (1 - scaleFrom) * t;
    return Opacity(
      opacity: settled,
      child: Transform.translate(
        offset: Offset(0, (1 - t) * distance),
        child: scaleFrom == 1
            ? child
            : Transform.scale(scale: scale, alignment: alignment, child: child),
      ),
    );
  }
}

/// Slide in from the side, for list rows dealing themselves out.
class Slide extends StatelessWidget {
  const Slide({
    super.key,
    required this.t,
    required this.child,
    this.distance = 36,
    this.fromLeft = false,
  });

  final double t;
  final Widget child;
  final double distance;
  final bool fromLeft;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) return Opacity(opacity: 0, child: child);
    final settled = t.clamp(0.0, 1.0);
    final dx = (1 - t) * distance * (fromLeft ? -1 : 1);
    return Opacity(
      opacity: settled,
      child: Transform.translate(offset: Offset(dx, 0), child: child),
    );
  }
}

/// A headline that arrives one word at a time. Each word rises through a
/// clip, so the line looks like it is being set, not faded in.
class WordReveal extends StatelessWidget {
  const WordReveal({
    super.key,
    required this.text,
    required this.style,
    required this.t,
    this.textAlign = TextAlign.center,
    this.wordStagger = 0.12,
  });

  final String text;
  final TextStyle style;
  final double t;
  final TextAlign textAlign;
  final double wordStagger;

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    final span = 1 - wordStagger * (words.length - 1);
    return Wrap(
      alignment: textAlign == TextAlign.center
          ? WrapAlignment.center
          : WrapAlignment.start,
      children: <Widget>[
        for (var i = 0; i < words.length; i++)
          ClipRect(
            child: _Word(
              word: i == words.length - 1 ? words[i] : '${words[i]} ',
              style: style,
              t: ((t - i * wordStagger) / span).clamp(0.0, 1.0),
            ),
          ),
      ],
    );
  }
}

class _Word extends StatelessWidget {
  const _Word({required this.word, required this.style, required this.t});

  final String word;
  final TextStyle style;
  final double t;

  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutExpo.transform(t);
    return Opacity(
      opacity: eased.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, (1 - eased) * (style.fontSize ?? 20) * 0.9),
        child: Text(word, style: style),
      ),
    );
  }
}
