import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../scene/director.dart';
import '../../scene/frame.dart';
import '../../scene/orb.dart';
import '../../scene/stage.dart';

class VoiceView extends StatelessWidget {
  const VoiceView({
    super.key,
    required this.presence,
    required this.arriving,
    required this.partner,
    required this.stage,
  });

  final Animation<double> presence;
  final bool arriving;
  final Scene? partner;
  final StageState stage;

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final director = stage.director;
    return AnimatedBuilder(
      animation: presence,
      builder: (context, _) {
        final flow = presence.value;
        final settled = arriving && flow >= 1;
        final double chrome;
        final double words;
        final double controls;
        if (arriving) {
          chrome = span(flow, 0.55, 1.0, Curves.easeOutCubic);
          words = span(flow, 0.6, 1.0, Curves.easeOut);
          controls = span(flow, 0.38, 0.95, Curves.easeOutCubic);
        } else {
          chrome = 1 - span(flow, 0.0, 0.3, Curves.easeIn);
          words = partner == Scene.chat ? 0 : 1 - span(flow, 0.0, 0.35);
          controls = 1 - span(flow, 0.0, 0.45, Curves.easeInCubic);
        }
        final stack = frame.voiceStack;
        return Stack(
          children: [
            if (settled)
              Positioned(
                left: frame.midX - stack.orbSize / 2,
                top: stack.orbTop,
                child: GestureDetector(
                  onTap: () => director.paused.value = !director.paused.value,
                  child: Orb(size: stack.orbSize, level: director.level, seed: 0.3),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              top: frame.listeningY - 7 + 6 * (1 - chrome),
              child: Opacity(
                opacity: chrome,
                child: Center(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: director.paused,
                    builder: (context, paused, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        child: ShimmerText(
                          paused ? 'Paused' : 'Aira is listening...',
                          key: ValueKey(paused),
                          active: !paused,
                          style: inter(11.25, 450, color: const Color(0xFF7A7472), height: 14 / 11.25),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (words > 0)
              Positioned(
                left: 0,
                right: 0,
                top: frame.transcriptTop,
                child: Opacity(
                  opacity: words,
                  child: _Transcript(director: director),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              top: frame.controlsY - 54 + 30 * (1 - controls) * (arriving ? 0.4 : 1),
              height: 108,
              child: Opacity(
                opacity: controls.clamp(0.0, 1.0),
                child: _Controls(director: director, spread: controls, showMic: settled),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Transcript extends StatelessWidget {
  const _Transcript({required this.director});

  final Director director;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([director.heard, director.confirmed]),
      builder: (context, _) {
        final heard = director.heard.value;
        final confirmed = director.confirmed.value;
        final base = transcriptStyle;
        var index = 0;
        final lines = <Widget>[];
        for (final line in Director.voiceLines) {
          final spans = <InlineSpan>[];
          final parts = line.split(' ');
          for (var i = 0; i < parts.length; i++) {
            final seen = (heard - index).clamp(0.0, 1.0);
            final sure = (confirmed - index).clamp(0.0, 1.0);
            final grey = Color.lerp(const Color(0xFF6E6E6E), const Color(0xFFF4F2F2), sure)!;
            final color = grey.withValues(alpha: Curves.easeOut.transform(seen));
            spans.add(TextSpan(text: i == parts.length - 1 ? parts[i] : '${parts[i]} ', style: base.copyWith(color: color)));
            index++;
          }
          lines.add(Text.rich(TextSpan(children: spans), textAlign: TextAlign.center, maxLines: 1, softWrap: false));
        }
        return Column(mainAxisSize: MainAxisSize.min, children: lines);
      },
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.director, required this.spread, required this.showMic});

  final Director director;
  final double spread;
  final bool showMic;

  @override
  Widget build(BuildContext context) {
    final mid = MediaQuery.sizeOf(context).width / 2;
    final reach = lerp(40, 101, spread);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: mid - 54,
          top: 0,
          child: RepaintBoundary(
            child: CustomPaint(
              size: const Size(108, 108),
              painter: _RingPainter(director.level, lerp(0.7, 1, spread)),
            ),
          ),
        ),
        if (showMic)
          Positioned(
            left: mid - 36,
            top: 18,
            child: Pressable(
              onTap: () => director.paused.value = !director.paused.value,
              child: const MicDisc(size: 72, glyphSize: 37),
            ),
          ),
        Positioned(
          left: mid - reach - 22,
          top: 32,
          child: Pressable(
            onTap: () => director.paused.value = !director.paused.value,
            child: SizedBox.square(
              dimension: 44,
              child: Center(
                child: ValueListenableBuilder<bool>(
                  valueListenable: director.paused,
                  builder: (context, paused, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                      child: GlyphIcon(
                        paused ? Glyph.play : Glyph.pause,
                        key: ValueKey(paused),
                        size: 19,
                        color: paused ? const Color(0xFFE8E2DF) : const Color(0xFF8D8886),
                        stroke: 1.1,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: mid + reach + 2 - 22,
          top: 32,
          child: Pressable(
            onTap: director.sendVoice,
            child: SizedBox.square(
              dimension: 44,
              child: Center(
                child: AnimatedBuilder(
                  animation: director.confirmed,
                  builder: (context, _) {
                    final ready = director.confirmed.value >= Director.voiceWords.length;
                    return GlyphIcon(
                      Glyph.send,
                      size: 19,
                      color: ready ? const Color(0xFFF4EEEA) : const Color(0xFF8D8886),
                      stroke: 1.1,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.level, this.scale) : super(repaint: level);

  final ValueListenable<double> level;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final energy = level.value;
    final base = 53.5 * scale;
    canvas.drawCircle(
      c,
      base + energy * 2.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Color.lerp(const Color(0xFF2A1812), const Color(0xFF5A2A14), energy)!,
    );
    final ripple = (OrbShader.now * 0.8) % 1.0;
    final alpha = (1 - ripple) * energy * 0.5;
    if (alpha > 0.01) {
      canvas.drawCircle(
        c,
        36 + ripple * (base - 36 + 4),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4 * (1 - ripple) + 0.4
          ..color = Tone.flame.withValues(alpha: alpha),
      );
    }
    final second = (ripple + 0.5) % 1.0;
    final alpha2 = (1 - second) * energy * 0.35;
    if (alpha2 > 0.01) {
      canvas.drawCircle(
        c,
        36 + second * (base - 36 + 4),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 * (1 - second) + 0.3
          ..color = Tone.flame.withValues(alpha: alpha2),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.scale != scale;
}
