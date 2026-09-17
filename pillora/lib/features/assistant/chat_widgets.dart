import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/text_styles.dart';

class UserBubble extends StatefulWidget {
  const UserBubble({super.key, required this.text});

  final String text;

  @override
  State<UserBubble> createState() => _UserBubbleState();
}

class _UserBubbleState extends State<UserBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AnimatedBuilder(
        animation: _enter,
        builder: (context, child) {
          final t = _enter.value;
          final pop = const ElasticOutCurve(0.8).transform(t);
          return Opacity(
            opacity: window(t, 0, 0.25),
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - Curves.easeOutCubic.transform(t))),
              child: Transform.scale(scale: lerp(0.4, 1, pop), alignment: Alignment.bottomRight, child: child),
            ),
          );
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.66),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
            decoration: const BoxDecoration(
              color: Palette.deep,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Text(widget.text, style: TextStyles.body.copyWith(color: Colors.white, fontSize: 14, height: 1.45)),
          ),
        ),
      ),
    );
  }
}

class HelperBubble extends StatefulWidget {
  const HelperBubble({super.key, required this.text, this.animate = true, this.onDone});

  final String text;
  final bool animate;
  final VoidCallback? onDone;

  @override
  State<HelperBubble> createState() => _HelperBubbleState();
}

class _HelperBubbleState extends State<HelperBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _stream;
  late final List<String> _words;

  static const _perWord = 55;

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');
    _stream = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _words.length * _perWord + 400),
      value: widget.animate ? 0 : 1,
    );
    if (widget.animate) {
      _stream.forward().whenComplete(() => widget.onDone?.call());
    }
  }

  @override
  void dispose() {
    _stream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const MiniOrb(size: 26),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
            decoration: const BoxDecoration(
              color: Palette.mist,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: AnimatedBuilder(
              animation: _stream,
              builder: (context, _) {
                final total = _stream.duration!.inMilliseconds;
                final elapsed = _stream.value * total;
                final spans = <InlineSpan>[];
                for (var i = 0; i < _words.length; i++) {
                  final start = i * _perWord.toDouble();
                  final alpha = ((elapsed - start) / 260).clamp(0.0, 1.0);
                  spans.add(
                    TextSpan(
                      text: i == _words.length - 1 ? _words[i] : '${_words[i]} ',
                      style: TextStyle(color: Palette.ink.withValues(alpha: Curves.easeOut.transform(alpha))),
                    ),
                  );
                }
                return Text.rich(TextSpan(children: spans), style: TextStyles.body.copyWith(fontSize: 14, height: 1.5));
              },
            ),
          ),
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}

class ThinkingBubble extends StatefulWidget {
  const ThinkingBubble({super.key});

  @override
  State<ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<ThinkingBubble> with SingleTickerProviderStateMixin, ClockMixin {
  @override
  void initState() {
    super.initState();
    startClock();
  }

  @override
  void dispose() {
    disposeClock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const MiniOrb(size: 26),
        const SizedBox(width: 8),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Palette.mist, borderRadius: BorderRadius.circular(19)),
          child: ValueListenableBuilder<double>(
            valueListenable: clock,
            builder: (context, seconds, _) {
              return Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: Transform.translate(
                        offset: Offset(0, math.min(0, math.sin(seconds * 7 - i * 0.9)) * 5),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              Palette.inkFaint,
                              Palette.deep,
                              (math.sin(seconds * 7 - i * 0.9) * -0.5 + 0.5).clamp(0.0, 1.0),
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class MiniOrb extends StatelessWidget {
  const MiniOrb({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-0.3, -0.35),
          colors: [Color(0xFFE6F7F3), Color(0xFFA6DDD1), Color(0xFF5E958D)],
          stops: [0, 0.45, 1],
        ),
        boxShadow: [BoxShadow(color: Color(0x5589CFC0), blurRadius: 10)],
      ),
    );
  }
}

class VoiceBars extends StatelessWidget {
  const VoiceBars({super.key, required this.clock, this.color = Palette.deep});

  final ValueNotifier<double> clock;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: clock,
      builder: (context, s, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 5; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 3,
                height:
                    5 +
                    11 *
                        (0.5 + 0.5 * math.sin(s * (8 + i * 1.7) + i)).abs() *
                        (0.6 + 0.4 * math.sin(s * 3.1 + i * 2)).abs(),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
          ],
        );
      },
    );
  }
}
