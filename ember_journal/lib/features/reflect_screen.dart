import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../data/journal.dart';
import '../data/prompts.dart';
import '../widgets/chrome.dart';
import '../widgets/ember_button.dart';
import '../widgets/mood_faces.dart';
import '../widgets/panel.dart';
import '../widgets/reveal_text.dart';
import '../widgets/waveform.dart';

const _answer =
    '1. The quiet morning moments\n'
    'I really appreciated the time I took to sit with '
    'my coffee this morning, without rushing anywhere. It felt grounding to just be prese...';

class ReflectScreen extends StatefulWidget {
  const ReflectScreen({
    super.key,
    required this.enter,
    required this.seconds,
    required this.deck,
    required this.onBack,
    required this.onMood,
    required this.onAdd,
  });

  final Animation<double> enter;
  final double seconds;
  final PromptDeck deck;
  final VoidCallback onBack;
  final ValueChanged<int> onMood;
  final Future<void> Function(Entry entry, Rect from) onAdd;

  @override
  State<ReflectScreen> createState() => _ReflectScreenState();
}

class _ReflectScreenState extends State<ReflectScreen> with TickerProviderStateMixin {
  late final AnimationController _shuffle;
  late final AnimationController _moodMove;

  int _mood = 2;
  int _previous = 2;
  String _question = '';
  double _answerTop = 356;

  @override
  void initState() {
    super.initState();
    _question = widget.deck.current;
    _shuffle = AnimationController(vsync: this, duration: const Duration(milliseconds: 760));
    _moodMove = AnimationController(vsync: this, duration: const Duration(milliseconds: 520), value: 1);
  }

  @override
  void didUpdateWidget(ReflectScreen old) {
    super.didUpdateWidget(old);
    if (widget.deck.current != _question && !_shuffle.isAnimating) {
      _question = widget.deck.current;
    }
  }

  @override
  void dispose() {
    _shuffle.dispose();
    _moodMove.dispose();
    super.dispose();
  }

  Future<void> _doShuffle() async {
    if (_shuffle.isAnimating) return;
    final next = widget.deck.roll();
    _shuffle.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _question = next);
  }

  void _pick(int i) {
    if (i == _mood) return;
    setState(() {
      _previous = _mood;
      _mood = i;
    });
    _moodMove.forward(from: 0);
    widget.onMood(i);
  }

  Future<void> _commit() async {
    final rect = Rect.fromLTWH(17, _answerTop, 359, 208);
    final now = DateTime.now();
    await widget.onAdd(
      Entry(
        mood: _mood,
        time: clockLabel(now),
        title: _question.replaceAll(' ?', '').replaceAll('?', ''),
        body: _answer,
      ),
      rect,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = CanvasScope.of(context);
    final top = scope.top;
    final cardTop = top + 69;
    final answerTop = cardTop + 228;
    _answerTop = answerTop;
    final feelTop = math.max(answerTop + 245, scope.floor - 218);
    final tint = Mood.all[_mood].tint;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 18,
          top: top + 3,
          child: Staged(
            animation: widget.enter,
            begin: 0,
            end: 0.36,
            offset: const Offset(-14, 0),
            child: CircleButton(glyph: Glyph.arrowLeft, onTap: widget.onBack),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: top + 14,
          child: Staged(
            animation: widget.enter,
            begin: 0.03,
            end: 0.40,
            offset: const Offset(0, -10),
            child: Text('Your reflection', textAlign: TextAlign.center, style: navTitle),
          ),
        ),
        Positioned(
          left: 17,
          top: cardTop,
          width: 359,
          height: 189,
          child: Staged(
            animation: widget.enter,
            begin: 0.08,
            end: 0.58,
            offset: const Offset(0, 30),
            scale: 0.95,
            rotateX: -0.14,
            child: AnimatedBuilder(
              animation: _shuffle,
              builder: (context, _) {
                final t = _shuffle.value;
                final flip = math.sin(t * math.pi) * 0.42;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0016)
                    ..rotateY(t < 0.5 ? flip : -flip)
                    ..rotateX(-flip * 0.25),
                  child: _QuestionCard(
                    question: _question,
                    settle: t == 0 ? 1.0 : span(t, 0.42, 0.95),
                    glow: math.sin(t * math.pi),
                    onShuffle: _doShuffle,
                    spin: t,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 17,
          top: answerTop,
          width: 359,
          height: 208,
          child: Staged(
            animation: widget.enter,
            begin: 0.16,
            end: 0.70,
            offset: const Offset(0, 36),
            scale: 0.95,
            rotateX: -0.12,
            child: _AnswerCard(mood: _mood, seconds: widget.seconds),
          ),
        ),
        Positioned(
          left: 18,
          top: feelTop,
          child: Staged(
            animation: widget.enter,
            begin: 0.26,
            end: 0.74,
            offset: const Offset(-10, 8),
            child: Text('How are you feeling ?', style: font(15.2, 500, shadows: lift)),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: feelTop + 26,
          height: 74,
          child: Staged(
            animation: widget.enter,
            begin: 0.32,
            end: 0.86,
            offset: const Offset(0, 22),
            child: LayoutBuilder(
              builder: (context, box) {
                final step = (box.maxWidth - 80) / 4;
                return Stack(
                  children: [
                    for (var i = 0; i < Mood.all.length; i++)
                      Positioned(
                        left: 40 + step * i - 37,
                        top: 0,
                        width: 74,
                        height: 74,
                        child: Pressable(
                          scale: 0.86,
                          onTap: () => _pick(i),
                          child: AnimatedBuilder(
                            animation: _moodMove,
                            builder: (context, _) {
                              final t = Curves.easeOutBack.transform(_moodMove.value.clamp(0.0, 1.0));
                              final sel = i == _mood ? t : (i == _previous ? 1 - t : 0.0);
                              return MoodFace(
                                index: i,
                                selection: sel.clamp(0.0, 1.0),
                                seconds: widget.seconds,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: feelTop + 86,
          child: Staged(
            animation: widget.enter,
            begin: 0.40,
            end: 0.90,
            offset: const Offset(0, 10),
            child: Center(
              child: MoodLabel(
                text: Mood.all[_mood].name,
                style: font(11.8, 500, color: tint, shadows: lift),
              ),
            ),
          ),
        ),
        Positioned(
          left: 60,
          right: 60,
          top: feelTop + 106,
          height: 50,
          child: Staged(
            animation: widget.enter,
            begin: 0.46,
            end: 0.96,
            offset: const Offset(0, 14),
            child: AnimatedBuilder(
              animation: _moodMove,
              builder: (context, _) {
                final t = Curves.easeInOutCubic.transform(_moodMove.value.clamp(0.0, 1.0));
                final focus = lerp(_previous / 4, _mood / 4, t);
                return Waveform(
                  seconds: widget.seconds,
                  focus: 0.08 + focus * 0.84,
                  energy: 0.55 + 0.45 * ((_mood + 1) / 5),
                  tint: Color.lerp(Mood.all[_previous].tint, tint, t)!,
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          top: scope.floor - 50,
          child: Staged(
            animation: widget.enter,
            begin: 0.54,
            end: 1.0,
            offset: const Offset(0, 30),
            child: GoldButton(
              label: 'Add to Journal',
              done: 'Saved',
              seconds: widget.seconds,
              onCommit: _commit,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.settle,
    required this.glow,
    required this.onShuffle,
    required this.spin,
  });

  final String question;
  final double settle;
  final double glow;
  final VoidCallback onShuffle;
  final double spin;

  @override
  Widget build(BuildContext context) {
    return Panel(
      radius: 26,
      tailAt: 28,
      glow: glow,
      child: Stack(
        children: [
          Positioned(
            left: 38,
            top: 30,
            child: Row(
              children: [
                Transform.rotate(
                  angle: spin * math.pi * 2,
                  child: const GlyphIcon(Glyph.die, size: 14, color: Ember.cream),
                ),
                const SizedBox(width: 6),
                Text('Random Question', style: font(13.2, 400, color: Ember.cream.withValues(alpha: 0.92))),
              ],
            ),
          ),
          Positioned(
            right: 26,
            top: 27,
            child: Pressable(
              onTap: onShuffle,
              scale: 0.92,
              child: Hairpill(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: -spin * math.pi * 2,
                      child: const GlyphIcon(Glyph.repeat, size: 15, color: Ember.cream, stroke: 1.5),
                    ),
                    const SizedBox(width: 7),
                    Text('Shuffle', style: font(12.6, 500)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 28,
            right: 22,
            top: 74,
            child: ScrambleText(text: question, progress: settle, style: quoteStyle),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.mood, required this.seconds});

  final int mood;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    return Panel(
      radius: 26,
      child: Stack(
        children: [
          Positioned(left: 21, top: 30, child: Text('Your answer', style: font(15, 500))),
          Positioned(
            right: 20,
            top: 24,
            child: CircleButton(glyph: Glyph.dots, onTap: () {}, size: 30, icon: 17, ring: false),
          ),
          Positioned(
            left: 21,
            top: 66,
            child: Row(
              children: [
                GlyphIcon(Glyph.calendar, size: 13, stroke: 1.4, color: Ember.ash.withValues(alpha: 0.7)),
                const SizedBox(width: 7),
                Text('${dateLabel(DateTime.now())} · ${clockLabel(DateTime.now())}', style: meta(0.72)),
              ],
            ),
          ),
          Positioned(
            left: 21,
            right: 20,
            top: 96,
            child: Text(_answer, style: body(0.86), maxLines: 4, overflow: TextOverflow.clip),
          ),
        ],
      ),
    );
  }
}
