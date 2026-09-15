import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/design.dart';
import '../core/motion/pressable.dart';
import '../core/palette.dart';
import 'icons/glyphs.dart';

/// Hold to talk. While held, rings ripple out from the disc and the waveform
/// bars breathe; releasing lets the last ring finish and settles the bars.
/// There is no microphone behind it - the surface is the deliverable.
class MicButton extends StatefulWidget {
  const MicButton({
    super.key,
    this.size = D.fieldHeight,
    this.onListeningChanged,
    this.heroTag = 'mic-button',
  });

  final double size;
  final ValueChanged<bool>? onListeningChanged;
  final Object heroTag;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  bool _listening = false;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _set(bool on) {
    if (_listening == on) return;
    setState(() => _listening = on);
    widget.onListeningChanged?.call(on);
    if (on) {
      HapticFeedback.mediumImpact();
      _pulse.repeat();
    } else {
      HapticFeedback.selectionClick();
      // let the current ring finish, then stop
      _pulse.animateTo(1, duration: const Duration(milliseconds: 500)).then(
        (_) {
          if (mounted && !_listening) _pulse.stop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final disc = AnimatedBuilder(
      animation: _pulse,
      builder: (BuildContext context, Widget? _) {
        final p = _pulse.value;
        return SizedBox(
          width: s,
          height: s,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              if (_listening || _pulse.isAnimating) ...<Widget>[
                _Ring(size: s, t: p),
                _Ring(size: s, t: (p + 0.5) % 1),
              ],
              Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: Leaf.mic,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Leaf.base.withValues(alpha: _listening ? 0.55 : 0.38),
                      blurRadius: _listening ? 26 : 18,
                      spreadRadius: _listening ? 2 : 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon2(
                    Glyph.waveform,
                    size: s * 0.42,
                    color: Paper.white,
                    strokeWidth: 2.2,
                    progress: _listening ? p : 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    return Hero(
      tag: widget.heroTag,
      child: Material(
        type: MaterialType.transparency,
        child: HoldDetector(
          onChanged: _set,
          child: Pressable(
            pressedScale: 0.9,
            haptic: false,
            child: disc,
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.t});

  final double size;
  final double t;

  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutCubic.transform(t);
    final scale = 1 + eased * 0.9;
    final alpha = (1 - eased) * 0.45;
    return IgnorePointer(
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Leaf.base.withValues(alpha: alpha),
              width: math.max(1, 3 * (1 - eased)),
            ),
          ),
        ),
      ),
    );
  }
}
