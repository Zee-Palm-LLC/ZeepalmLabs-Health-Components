import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../data/visit.dart';
import 'live_queue.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key, required this.visit, required this.onRoute});

  final Visit visit;
  final VoidCallback onRoute;

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _pulse;
  QueueSim get _sim => widget.visit.sim;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  }

  @override
  void dispose() {
    _enter.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Widget _stage(double begin, Widget child, {Offset offset = const Offset(0, 16)}) {
    return Staged(animation: _enter, begin: begin, end: begin + 0.5, offset: offset, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final shift = CanvasScope.of(context).barTop - DesignCanvas.breathing - DesignCanvas.contentFloor;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 17.5,
          top: 54.5,
          child: _stage(
            0,
            Text('LIVE QUEUE', style: caps(10, color: const Color(0xFF5E7370), tracking: 0.14, height: 1.2)),
          ),
        ),
        Positioned(
          left: 304.5,
          top: 54.5,
          child: _stage(
            0,
            Row(
              children: [
                _Blink(animation: _pulse),
                const SizedBox(width: 7),
                Text('UPDATING', style: caps(10, color: Hue.teal, tracking: 0.12, height: 1.2)),
              ],
            ),
          ),
        ),
        Positioned(left: 18, top: 85.5, width: 356, height: 170.5, child: _stage(0.05, _TokenCard(sim: _sim))),
        Positioned(
          left: 18.5,
          top: 273.5,
          width: 355,
          height: 274.5 + shift,
          child: _stage(
            0.15,
            DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), boxShadow: cardShadow(1.1)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    Positioned.fill(child: LiveLine(sim: _sim)),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      child: ListenableBuilder(
                        listenable: _sim,
                        builder: (context, _) => _RoutePrompt(sim: _sim, onTap: widget.onRoute),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 17.5,
          top: 565.5 + shift,
          width: 112.5,
          height: 96,
          child: _stage(
            0.3,
            ListenableBuilder(
              listenable: _sim,
              builder: (context, _) => _Stat(
                glyph: Glyph.pin,
                tone: const Color(0xFFD96A3A),
                value: '${_sim.rank}',
                unit: suffix(_sim.rank),
                caption: 'Your position',
                unitTone: const Color(0xFFD9541E),
              ),
            ),
          ),
        ),
        Positioned(
          left: 140.5,
          top: 565.5 + shift,
          width: 112.5,
          height: 96,
          child: _stage(
            0.37,
            ListenableBuilder(
              listenable: _sim,
              builder: (context, _) => _Stat(
                glyph: Glyph.timer,
                tone: Hue.teal,
                value: '${_sim.wait}',
                unit: 'min',
                caption: 'Estimated wait',
                unitTone: Hue.teal,
              ),
            ),
          ),
        ),
        Positioned(
          left: 263,
          top: 565.5 + shift,
          width: 112.5,
          height: 96,
          child: _stage(
            0.44,
            ListenableBuilder(
              listenable: _sim,
              builder: (context, _) => _Stat(
                glyph: Glyph.calendar,
                tone: Hue.teal,
                value: _sim.turnTime,
                unit: 'AM',
                caption: 'Your turn',
                unitTone: Hue.teal,
              ),
            ),
          ),
        ),
        Positioned(
          left: 18.5,
          top: 678.5 + shift,
          width: 355.5,
          height: 88,
          child: _stage(0.45, _Progress(pulse: _pulse, sim: _sim)),
        ),
      ],
    );
  }
}

class _Blink extends StatelessWidget {
  const _Blink({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(size: const Size(7, 7), painter: _BlinkPainter(animation)),
    );
  }
}

class _BlinkPainter extends CustomPainter {
  _BlinkPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, 3.5 * (1 + t * 1.6), Paint()..color = Hue.teal.withValues(alpha: 0.35 * (1 - t)));
    canvas.drawCircle(c, 3.5, Paint()..color = Hue.teal);
  }

  @override
  bool shouldRepaint(_BlinkPainter oldDelegate) => false;
}

class _TokenCard extends StatelessWidget {
  const _TokenCard({required this.sim});

  final QueueSim sim;

  static const _clip = NotchClipper(radius: 20, notch: 7, vertical: false, at: 122);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(
          child: CustomPaint(
            painter: ShadowPath(_clip, color: Color(0x400F3B3A), blur: 26, offset: Offset(0, 12)),
          ),
        ),
        Positioned.fill(
          child: ClipPath(
            clipper: _clip,
            child: CustomPaint(
              painter: const _TokenBackground(),
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Text(
                      'YOUR TOKEN',
                      style: caps(9.5, color: const Color(0xFFB8CFCB), tracking: 0.16, height: 1.2),
                    ),
                  ),
                  Positioned(
                    left: 17.5,
                    top: 32,
                    child: Text('A–27', style: jakarta(57.5, 800, color: Colors.white, spacing: -2.9, height: 1.2)),
                  ),
                  Positioned(
                    right: 20,
                    top: 20,
                    child: Text(
                      'NOW SERVING',
                      style: caps(9.5, color: const Color(0xFFB8CFCB), tracking: 0.16, height: 1.2),
                    ),
                  ),
                  Positioned(
                    right: 19.5,
                    top: 36,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (b) =>
                          const LinearGradient(colors: [Color(0xFF6EE7A3), Color(0xFF4ADE80)]).createShader(b),
                      child: ListenableBuilder(
                        listenable: sim,
                        builder: (context, _) => _Rolling(
                          text: 'A–${sim.serving}',
                          style: jakarta(28.75, 800, color: Colors.white, spacing: -0.86, height: 1.2),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 70.5,
                    height: 22.5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      decoration: BoxDecoration(
                        color: const Color(0x1FFFFFFF),
                        borderRadius: BorderRadius.circular(11.25),
                        border: Border.all(color: const Color(0x29FFFFFF)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GlyphIcon(Glyph.door, size: 11.5, color: Color(0xFF7FE0B0), stroke: 2),
                          const SizedBox(width: 5),
                          Text('Room 3', style: jakarta(10.5, 800, color: Colors.white, spacing: -0.2)),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 20,
                    top: 118,
                    width: 316,
                    height: 1,
                    child: DashedLine(dash: 3, gap: 3, color: Color(0x40FFFFFF)),
                  ),
                  Positioned(
                    left: 19.5,
                    top: 132.5,
                    child: Text(
                      'CityCare Family Clinic · Dr. Oliver Hayes',
                      style: jakarta(11, 700, color: const Color(0xFFD5E6E3), spacing: -0.22),
                    ),
                  ),
                  Positioned(
                    left: 258,
                    top: 128,
                    width: 77.5,
                    height: 21.5,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFBC02D), Color(0xFFFBBF24)]),
                        borderRadius: BorderRadius.circular(10.75),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'GET READY',
                        style: caps(9.5, color: const Color(0xFF4A3304), tracking: 0.1, height: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TokenBackground extends CustomPainter {
  const _TokenBackground();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), const [
          Color(0xFF0F5550),
          Color(0xFF0E403C),
        ]),
    );
    final c = Offset(size.width * 0.84, 0);
    canvas.drawCircle(
      c,
      150,
      Paint()..shader = ui.Gradient.radial(c, 150, const [Color(0x7314B8A6), Color(0x0014B8A6)]),
    );
    final w = Offset(size.width * 0.3, size.height * 0.75);
    canvas.drawCircle(w, 90, Paint()..shader = ui.Gradient.radial(w, 90, const [Color(0x2EFBBF24), Color(0x00FBBF24)]));
  }

  @override
  bool shouldRepaint(_TokenBackground oldDelegate) => false;
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.glyph,
    required this.tone,
    required this.value,
    required this.unit,
    required this.caption,
    required this.unitTone,
  });

  final Glyph glyph;
  final Color tone;
  final String value;
  final String unit;
  final String caption;
  final Color unitTone;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7FCFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFFFFF)),
        boxShadow: cardShadow(0.8),
      ),
      child: Stack(
        children: [
          Positioned(left: 14, top: 13.5, child: GlyphIcon(glyph, size: 14, color: tone, stroke: 2)),
          Positioned(
            left: 13.5,
            top: 36,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: value, style: jakarta(21.5, 800, spacing: -0.65, height: 1.2)),
                  TextSpan(
                    text: ' $unit',
                    style: jakarta(10.5, 800, color: unitTone, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 13.5,
            top: 64.5,
            child: Text(caption, style: jakarta(11, 600, color: const Color(0xFF5E7370), spacing: -0.1, height: 1.2)),
          ),
        ],
      ),
    );
  }
}

class _Progress extends StatefulWidget {
  const _Progress({required this.pulse, required this.sim});

  final Animation<double> pulse;
  final QueueSim sim;

  @override
  State<_Progress> createState() => _ProgressState();
}

class _ProgressState extends State<_Progress> with SingleTickerProviderStateMixin {
  late final AnimationController _fill;
  final _level = ValueNotifier<double>(0);
  double _from = 0;
  double _to = 0;

  @override
  void initState() {
    super.initState();
    _to = widget.sim.fill;
    _fill = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..addListener(() => _level.value = lerp(_from, _to, Curves.easeOutCubic.transform(_fill.value)))
      ..forward();
    widget.sim.addListener(_moved);
  }

  void _moved() {
    _from = _level.value;
    _to = widget.sim.fill;
    _fill.duration = const Duration(milliseconds: 900);
    _fill.forward(from: 0);
  }

  @override
  void dispose() {
    widget.sim.removeListener(_moved);
    _fill.dispose();
    _level.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: cardShadow(0.9),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 16.5,
            top: 17,
            child: Text('The line is moving steadily', style: jakarta(12.25, 800, spacing: -0.25, height: 1.2)),
          ),
          Positioned(
            right: 16.5,
            top: 17.5,
            child: Text('~4 min each', style: jakarta(10.5, 500, color: const Color(0xFF6B7F7C), height: 1.2)),
          ),
          Positioned(
            left: 4.5,
            right: 4.5,
            top: 28.5,
            height: 36.5,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _BarPainter(level: _level, pulse: widget.pulse),
              ),
            ),
          ),
          Positioned(
            left: 16.5,
            top: 63.5,
            child: ListenableBuilder(
              listenable: widget.sim,
              builder: (context, _) => Text(
                'A–${widget.sim.serving} in Room 3',
                style: jakarta(10.5, 600, color: const Color(0xFF6B7F7C), spacing: -0.1, height: 1.2),
              ),
            ),
          ),
          Positioned(
            left: 157,
            top: 65.5,
            child: RepaintBoundary(
              child: CustomPaint(size: const Size(52, 8), painter: _Footprints(widget.pulse)),
            ),
          ),
          Positioned(
            right: 16.5,
            top: 63.5,
            child: Text('You · A–27', style: jakarta(10.5, 800, color: Hue.teal, height: 1.2)),
          ),
        ],
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({required this.level, required this.pulse}) : super(repaint: Listenable.merge([level, pulse]));

  final ValueListenable<double> level;
  final Animation<double> pulse;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 12.0;
    final track = Rect.fromLTWH(inset, 14, size.width - inset * 2, 8.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(track, const Radius.circular(4.25)),
      Paint()..color = const Color(0xFFE4EFEC),
    );
    final v = level.value;
    final done = Rect.fromLTWH(track.left, track.top, track.width * v, track.height);
    if (done.width > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(done, const Radius.circular(4.25)),
        Paint()
          ..shader = ui.Gradient.linear(track.centerLeft, track.centerRight, const [
            Color(0xFF0F766E),
            Color(0xFF14B8A6),
          ]),
      );
    }
    final knob = Offset(track.left + track.width * v, track.center.dy);
    final t = pulse.value;
    canvas.drawCircle(knob, 12 + t * 7, Paint()..color = Hue.orange.withValues(alpha: 0.28 * (1 - t)));
    canvas.drawCircle(
      knob + const Offset(0, 3),
      12,
      Paint()
        ..color = const Color(0x4DFF8A3D)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(knob, 12, Paint()..color = Colors.white);
    canvas.drawCircle(knob, 9.5, Paint()..color = Hue.orange);
  }

  @override
  bool shouldRepaint(_BarPainter oldDelegate) => false;
}

class _Footprints extends CustomPainter {
  _Footprints(this.pulse) : super(repaint: pulse);

  final Animation<double> pulse;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 5; i++) {
      final phase = (pulse.value * 5 - i) % 5;
      final alpha = phase < 1 ? 0.55 + 0.45 * (1 - phase) : 0.55;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(4 + i * 11.0, i.isEven ? 5.5 : 3), width: 7.5, height: 3.8),
        Paint()..color = const Color(0xFFC9D3D1).withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_Footprints oldDelegate) => false;
}

class _Rolling extends StatelessWidget {
  const _Rolling({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 520),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(alignment: Alignment.centerRight, children: [...previous, ?current]),
      transitionBuilder: (child, animation) {
        final incoming = child.key == ValueKey(text);
        final slide = Tween(begin: Offset(0, incoming ? 0.6 : -0.6), end: Offset.zero).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: Text(text, key: ValueKey(text), style: style),
    );
  }
}

class _RoutePrompt extends StatelessWidget {
  const _RoutePrompt({required this.sim, required this.onTap});

  final QueueSim sim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final show = sim.almost;
    return IgnorePointer(
      ignoring: !show,
      child: AnimatedSlide(
        offset: show ? Offset.zero : const Offset(0, 1.6),
        duration: const Duration(milliseconds: 520),
        curve: show ? Curves.easeOutBack : Curves.easeInCubic,
        child: AnimatedOpacity(
          opacity: show ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: Pressable(
              onTap: onTap,
              child: Container(
                height: 38,
                padding: const EdgeInsets.fromLTRB(8, 0, 14, 0),
                decoration: BoxDecoration(
                  color: Hue.ink,
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: const [BoxShadow(color: Color(0x4D0F3B3A), blurRadius: 16, offset: Offset(0, 7))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(color: Hue.orange, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const GlyphIcon(Glyph.car, size: 13, color: Colors.white, stroke: 2.2),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      sim.next ? "You're next · leave now" : 'Almost your turn · plan route',
                      style: jakarta(12.5, 800, color: Colors.white, spacing: -0.15),
                    ),
                    const SizedBox(width: 8),
                    const GlyphIcon(Glyph.arrow, size: 14, color: Colors.white, stroke: 2.2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
