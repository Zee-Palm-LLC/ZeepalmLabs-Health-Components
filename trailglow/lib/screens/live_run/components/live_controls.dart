import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/motion.dart';
import '../../../app/theme/palette.dart';
import '../../../app/theme/typography.dart';
import '../../../widgets/glow_button.dart';

class LiveControls extends StatelessWidget {
  const LiveControls({
    super.key,
    required this.running,
    required this.onToggle,
    required this.onFinish,
    required this.onMusic,
  });

  final bool running;
  final VoidCallback onToggle;
  final VoidCallback onFinish;
  final VoidCallback onMusic;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        CircleAction(
          icon: Icons.music_note_rounded,
          onTap: onMusic,
          size: 52,
          color: Tone.secondary,
        ),
        _PlayPause(running: running, onTap: onToggle),
        HoldToFinish(onFinish: onFinish),
      ],
    );
  }
}

class _PlayPause extends StatelessWidget {
  const _PlayPause({required this.running, required this.onTap});

  final bool running;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.quick,
        curve: Motion.enter,
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: running
                ? const <Color>[Spectrum.deep, Spectrum.blue, Spectrum.cyan]
                : const <Color>[Color(0xFF16203A), Color(0xFF1E2C4C)],
            stops: running
                ? const <double>[0.0, 0.55, 1.0]
                : const <double>[0.0, 1.0],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: (running ? Spectrum.cyan : Spectrum.blue).withValues(
                alpha: running ? 0.32 : 0.16,
              ),
              blurRadius: 30,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Icon(
          running ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 34,
          color: Colors.white,
        ),
      ),
    );
  }
}

class HoldToFinish extends StatefulWidget {
  const HoldToFinish({super.key, required this.onFinish, this.size = 52});

  final VoidCallback onFinish;
  final double size;

  @override
  State<HoldToFinish> createState() => _HoldToFinishState();
}

class _HoldToFinishState extends State<HoldToFinish>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 820),
  );

  @override
  void initState() {
    super.initState();
    _hold.addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onFinish();
      _hold.value = 0;
    }
  }

  @override
  void dispose() {
    _hold.removeStatusListener(_onStatus);
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _hold.forward(),
      onTapUp: (_) => _hold.reverse(),
      onTapCancel: () => _hold.reverse(),
      child: AnimatedBuilder(
        animation: _hold,
        builder: (context, _) => SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _HoldPainter(_hold.value),
            child: Center(
              child: Icon(
                Icons.stop_rounded,
                size: widget.size * 0.38,
                color: Color.lerp(Spectrum.amber, Colors.white, _hold.value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HoldPainter extends CustomPainter {
  _HoldPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    canvas.drawCircle(center, radius, Paint()..color = Night.panel);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Night.hairline,
    );

    if (value <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..color = Spectrum.amber,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Spectrum.amber.withValues(alpha: 0.22 * value)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  @override
  bool shouldRepaint(_HoldPainter old) => old.value != value;
}

class HoldHint extends StatelessWidget {
  const HoldHint({super.key});

  @override
  Widget build(BuildContext context) => Text(
    'HOLD TO FINISH',
    style: Typo.label(8.5, color: Tone.faint, letterSpacing: 1.8),
  );
}
