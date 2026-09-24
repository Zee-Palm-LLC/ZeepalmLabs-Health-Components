import 'package:flutter/material.dart';

import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/phosphor.dart';
import '../../core/type.dart';

class JourneyButton extends StatefulWidget {
  const JourneyButton({
    super.key,
    required this.rect,
    required this.enter,
    required this.progress,
    required this.running,
    required this.onTap,
  });

  final Rect rect;
  final double enter;
  final double progress;
  final bool running;
  final VoidCallback onTap;

  @override
  State<JourneyButton> createState() => _JourneyButtonState();
}

class _JourneyButtonState extends State<JourneyButton> with TickerProviderStateMixin {
  late final AnimationController _roll;
  late final AnimationController _morph;
  String _previous = 'Start Journey';
  String _label = 'Start Journey';

  @override
  void initState() {
    super.initState();
    _roll = AnimationController(vsync: this, duration: const Duration(milliseconds: 520), value: 1);
    _morph = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  }

  @override
  void didUpdateWidget(JourneyButton old) {
    super.didUpdateWidget(old);
    final next = _labelFor(widget.progress, widget.running);
    if (next != _label) {
      _previous = _label;
      _label = next;
      _roll.forward(from: 0);
    }
    if (widget.running != old.running) {
      widget.running ? _morph.forward() : _morph.reverse();
    }
  }

  @override
  void dispose() {
    _roll.dispose();
    _morph.dispose();
    super.dispose();
  }

  static String _labelFor(double progress, bool running) {
    if (progress >= 1) return 'Journey Complete';
    if (running) return 'Pause Journey';
    if (progress > 0) return 'Resume Journey';
    return 'Start Journey';
  }

  static double _width(String text, TextStyle style) {
    final p = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    return p.width;
  }

  @override
  Widget build(BuildContext context) {
    final rect = widget.rect;
    final grow = span(widget.enter, 0.0, 0.8, const Cubic(0.2, 0.9, 0.3, 1.0));
    final width = lerp(rect.height, rect.width, grow);
    final style = font(16.8, 700, color: Colors.white);
    return Positioned(
      left: rect.center.dx - width / 2,
      top: rect.top + (1 - span(widget.enter, 0.0, 0.5)) * 20,
      width: width,
      height: rect.height,
      child: Opacity(
        opacity: span(widget.enter, 0.0, 0.3).clamp(0.0, 1.0),
        child: Pressable(
          onTap: widget.onTap,
          scale: 0.97,
          child: AnimatedBuilder(
            animation: Listenable.merge([_roll, _morph]),
            builder: (context, _) {
              final roll = swift.transform(_roll.value);
              final textWidth = lerp(_width(_previous, style), _width(_label, style), Curves.easeInOut.transform(_roll.value));
              final group = 19 + 11.8 + textWidth;
              final left = rect.width / 2 - group / 2 + 2.7;
              final done = widget.progress >= 1;
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: Palette.mint,
                  borderRadius: BorderRadius.circular(rect.height / 2),
                  boxShadow: [BoxShadow(color: Palette.mint.withValues(alpha: 0.28), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(rect.height / 2),
                  child: OverflowBox(
                    minWidth: rect.width,
                    maxWidth: rect.width,
                    child: SizedBox(
                      width: rect.width,
                      height: rect.height,
                      child: Opacity(
                        opacity: span(widget.enter, 0.4, 1.0),
                        child: Stack(
                          children: [
                            if (widget.progress > 0)
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                width: rect.width * widget.progress,
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [Color(0xFF12C495), Color(0xFF2BD6A6)]),
                                  ),
                                ),
                              ),
                            Positioned(
                              left: left - 1,
                              top: 16.7,
                              width: 21,
                              height: 21,
                              child: _PlayPause(t: done ? 1 : _morph.value, done: done),
                            ),
                            Positioned(
                              left: left + 19 + 11.8 - 0.4,
                              top: 0,
                              width: textWidth + 4,
                              height: rect.height,
                              child: ClipRect(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    if (_roll.value < 1)
                                      Positioned(
                                        left: 0,
                                        top: 33.3 - baselineOffset(style) - 30 * roll,
                                        child: Opacity(opacity: 1 - roll, child: Text(_previous, style: style, softWrap: false)),
                                      ),
                                    Positioned(
                                      left: 0,
                                      top: 33.3 - baselineOffset(style) + 30 * (1 - roll),
                                      child: Text(_label, style: style, softWrap: false),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PlayPause extends StatelessWidget {
  const _PlayPause({required this.t, required this.done});

  final double t;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final e = Curves.easeInOutBack.transform(t.clamp(0.0, 1.0));
    final second = done ? PhosphorBold.check : PhosphorFill.pause;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: (1 - t * 2).clamp(0.0, 1.0),
          child: Transform.rotate(
            angle: e * 1.6,
            child: Transform.scale(scale: 1 - 0.6 * t, child: const Icon(PhosphorFill.play, size: 21, color: Colors.white)),
          ),
        ),
        Opacity(
          opacity: (t * 2 - 1).clamp(0.0, 1.0),
          child: Transform.rotate(
            angle: (1 - e) * -1.6,
            child: Transform.scale(scale: 0.4 + 0.6 * e, child: Icon(second, size: 21, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
