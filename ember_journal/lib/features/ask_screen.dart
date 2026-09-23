import 'package:flutter/material.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../data/prompts.dart';
import '../widgets/chrome.dart';
import '../widgets/ember_button.dart';
import '../widgets/reveal_text.dart';
import '../widgets/shake_phone.dart';

class AskScreen extends StatefulWidget {
  const AskScreen({
    super.key,
    required this.enter,
    required this.seconds,
    required this.deck,
    required this.onBack,
    required this.onAsk,
    required this.onDepth,
  });

  final Animation<double> enter;
  final double seconds;
  final PromptDeck deck;
  final VoidCallback onBack;
  final void Function(Offset origin) onAsk;
  final VoidCallback onDepth;

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _roll;
  double _phoneCentre = 560;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _roll = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  }

  @override
  void dispose() {
    _roll.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    if (_busy) return;
    _busy = true;
    widget.deck.roll();
    await _roll.forward(from: 0);
    if (!mounted) return;
    _roll.value = 0;
    widget.onAsk(Offset(196.5, _phoneCentre));
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    final scope = CanvasScope.of(context);
    final top = scope.top;
    final heroTop = top + 147;
    final phoneCentre = (heroTop + 150 + scope.floor - 76) / 2;
    _phoneCentre = phoneCentre;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 18,
          top: top + 3,
          child: Staged(
            animation: widget.enter,
            begin: 0,
            end: 0.38,
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
            begin: 0.04,
            end: 0.42,
            offset: const Offset(0, -10),
            child: Text('Random question', textAlign: TextAlign.center, style: navTitle),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: top + 63,
          height: 36,
          child: Staged(
            animation: widget.enter,
            begin: 0.10,
            end: 0.52,
            offset: const Offset(0, 16),
            child: SegmentChips(
              labels: Depth.values.map((d) => d.label).toList(),
              selected: Depth.values.indexOf(widget.deck.depth),
              seconds: widget.seconds,
              onSelect: (i) {
                setState(() => widget.deck.setDepth(Depth.values[i]));
                widget.onDepth();
              },
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: heroTop,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RevealLine(animation: widget.enter, begin: 0.18, text: 'Shake your', style: heroStyle),
              RevealLine(animation: widget.enter, begin: 0.25, text: 'phone to get a', style: heroStyle),
              RevealLine(animation: widget.enter, begin: 0.32, text: 'random question', style: heroStyle),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: heroTop + 152,
          child: Staged(
            animation: widget.enter,
            begin: 0.42,
            end: 0.80,
            offset: const Offset(0, 12),
            child: Text(
              '1 question · for reflection',
              textAlign: TextAlign.center,
              style: font(11, 400, color: Ember.ash.withValues(alpha: 0.82), spacing: 0.2),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: phoneCentre - 194,
          height: 388,
          child: Staged(
            animation: widget.enter,
            begin: 0.30,
            end: 0.95,
            offset: const Offset(0, 54),
            scale: 0.82,
            rotateX: -0.28,
            curve: settle,
            child: Center(
              child: AnimatedBuilder(
                animation: _roll,
                builder: (context, _) => ShakePhone(
                  seconds: widget.seconds,
                  roll: Curves.easeInOutCubic.transform(_roll.value),
                  onShake: _ask,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          top: scope.floor - 76,
          child: Staged(
            animation: widget.enter,
            begin: 0.52,
            end: 1.0,
            offset: const Offset(0, 34),
            child: GhostBar(label: 'Get a question', seconds: widget.seconds, onTap: _ask),
          ),
        ),
      ],
    );
  }
}
