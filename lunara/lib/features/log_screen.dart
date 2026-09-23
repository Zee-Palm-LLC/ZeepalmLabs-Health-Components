import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/theme.dart';
import '../data/cycle.dart';
import '../widgets/surface.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({
    super.key,
    required this.cycle,
    required this.enter,
    required this.pulse,
    required this.onBack,
    required this.onSave,
    this.focus,
  });

  final Cycle cycle;
  final Animation<double> enter;
  final Animation<double> pulse;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final String? focus;

  Widget _card(double begin, double top, double height, Widget child, {double left = 20, double width = 353}) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Staged(
        animation: enter,
        begin: begin,
        end: begin + 0.5,
        offset: const Offset(0, 34),
        scale: 0.97,
        child: Panel(radius: 24, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = CanvasScope.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 20,
          top: 58,
          child: Staged(
            animation: enter,
            begin: 0,
            end: 0.4,
            offset: const Offset(-12, 0),
            child: Pressable(
              onTap: onBack,
              child: const SizedBox(
                width: 34,
                height: 30,
                child: Center(child: GlyphIcon(Glyph.arrowLeft, size: 23, color: Colors.white, stroke: 2)),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 56,
          child: Staged(
            animation: enter,
            begin: 0.04,
            end: 0.44,
            child: Text(
              cycle.dateLabel,
              textAlign: TextAlign.center,
              style: display(18, 600, color: Colors.white, height: 1),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 86,
          child: Staged(
            animation: enter,
            begin: 0.08,
            end: 0.48,
            child: Text(
              '${cycle.phase.name} \u00b7 Day ${cycle.day}',
              textAlign: TextAlign.center,
              style: sans(12.5, 500, color: Hue.amber, height: 1),
            ),
          ),
        ),
        Positioned(
          right: 20,
          top: 56,
          child: Staged(
            animation: enter,
            begin: 0,
            end: 0.4,
            offset: const Offset(12, 0),
            child: Pressable(
              onTap: onBack,
              child: const SizedBox(
                width: 34,
                height: 34,
                child: Center(child: GlyphIcon(Glyph.calendar, size: 22, color: Colors.white, stroke: 1.9)),
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 112,
          width: 353,
          height: 18,
          child: Staged(
            animation: enter,
            begin: 0.1,
            end: 0.5,
            offset: const Offset(0, 10),
            child: _Progress(cycle: cycle, pulse: pulse),
          ),
        ),
        _card(
          0.14,
          136,
          106,
          _Section(
            title: 'Flow intensity',
            highlight: focus == 'Flow',
            pulse: pulse,
            cycle: cycle,
            value: (c) => _Droplet.labels[c.flow].isEmpty ? 'Between' : _Droplet.labels[c.flow],
            tone: Hue.rose,
            child: _Flow(cycle: cycle, pulse: pulse),
          ),
        ),
        _card(
          0.2,
          250,
          84,
          _Section(
            title: 'Mood',
            highlight: focus == 'Mood',
            pulse: pulse,
            cycle: cycle,
            value: (c) => _Face.labels[c.mood],
            tone: Hue.amber,
            child: _Mood(cycle: cycle, pulse: pulse),
          ),
        ),
        _card(
          0.26,
          340,
          86,
          _Section(
            title: 'Energy',
            highlight: focus == 'Energy',
            pulse: pulse,
            cycle: cycle,
            value: (c) => '${(c.energy * 100).round()}%',
            tone: Hue.amber,
            child: _Energy(cycle: cycle, pulse: pulse),
          ),
        ),
        _card(
          0.32,
          432,
          228,
          _Section(
            title: 'Symptoms',
            highlight: focus == 'Symptoms' || focus == 'Cramps',
            pulse: pulse,
            cycle: cycle,
            value: (c) => c.picked.isEmpty ? 'None' : '${c.picked.length} picked',
            tone: Hue.mint,
            child: _Symptoms(cycle: cycle, enter: enter),
          ),
        ),
        _card(
          0.38,
          668,
          104,
          _Section(
            title: 'Notes',
            pulse: pulse,
            cycle: cycle,
            value: (c) => c.notes.isEmpty ? 'Optional' : '${c.notes.length}/300',
            tone: Hue.violet,
            child: _Notes(cycle: cycle),
          ),
        ),
        Positioned(
          left: 24,
          top: math.min(784, scope.height - math.max(scope.bottomInset, 14) - 16 - 54),
          width: 345,
          height: 54,
          child: Staged(
            animation: enter,
            begin: 0.44,
            end: 0.94,
            offset: const Offset(0, 26),
            scale: 0.96,
            child: _Save(cycle: cycle, pulse: pulse, onSave: onSave),
          ),
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.cycle, required this.pulse});

  final Cycle cycle;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cycle,
      builder: (context, _) {
        final done = [true, true, cycle.energy > 0, cycle.picked.isNotEmpty, cycle.notes.isNotEmpty];
        final filled = done.where((d) => d).length;
        return Row(
          children: [
            Text('Today\u2019s log', style: sans(11.5, 500, color: Colors.white.withValues(alpha: 0.6), height: 1)),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  for (final (i, ok) in done.indexed)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 420 + i * 60),
                          curve: gentle,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: ok ? warmGradient : null,
                            color: ok ? null : Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('$filled of 5', style: sans(11.5, 600, color: Colors.white.withValues(alpha: 0.75), height: 1)),
          ],
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    required this.pulse,
    required this.cycle,
    required this.value,
    this.tone = Hue.rose,
    this.highlight = false,
  });

  final String title;
  final Widget child;
  final Animation<double> pulse;
  final Cycle cycle;
  final String Function(Cycle cycle) value;
  final Color tone;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (highlight)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, _) {
                final glow = 0.3 + 0.35 * math.sin(pulse.value * math.pi * 2).abs();
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: tone.withValues(alpha: glow), width: 1.4),
                  ),
                );
              },
            ),
          ),
        Positioned(
          left: 17,
          top: 12.5,
          child: Text(title, style: display(14.5, 600, color: Hue.ink, height: 1)),
        ),
        Positioned(
          right: 14,
          top: 9,
          child: ListenableBuilder(
            listenable: cycle,
            builder: (context, _) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: Tween(begin: 0.8, end: 1.0).animate(animation), child: child),
              ),
              child: Container(
                key: ValueKey(value(cycle)),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: tone.withValues(alpha: 0.16),
                  border: Border.all(color: tone.withValues(alpha: 0.28)),
                ),
                child: Text(value(cycle), style: sans(11, 600, color: tone, height: 1)),
              ),
            ),
          ),
        ),
        Positioned.fill(top: 38, child: child),
      ],
    );
  }
}

class _Flow extends StatelessWidget {
  const _Flow({required this.cycle, required this.pulse});

  final Cycle cycle;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cycle,
      builder: (context, _) {
        return Stack(
          children: [
            for (var i = 0; i < 5; i++)
              Positioned(
                left: 9.0 + i * 67.2,
                top: 0,
                width: 67.2,
                height: 78,
                child: Pressable(
                  onTap: () => cycle.setFlow(i),
                  scale: 0.9,
                  child: _Droplet(level: i, selected: cycle.flow == i, pulse: pulse),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Droplet extends StatelessWidget {
  const _Droplet({required this.level, required this.selected, required this.pulse});

  final int level;
  final bool selected;
  final Animation<double> pulse;

  static const labels = ['None', 'Light', 'Medium', '', 'Heavy'];

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: selected ? 1 : 0),
      duration: const Duration(milliseconds: 620),
      curve: const Spring(bounce: 0.3),
      builder: (context, t, _) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Transform.scale(
              scale: 1 + 0.24 * t,
              child: SizedBox(
                width: 34,
                height: 46,
                child: AnimatedBuilder(
                  animation: pulse,
                  builder: (context, _) => CustomPaint(
                    painter: _DropletPainter(level: level, fill: t, wave: pulse.value),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 54,
              child: Text(
                labels[level],
                style: sans(11.5, selected ? 800 : 500, color: selected ? Hue.ink : Hue.inkMuted, height: 1),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DropletPainter extends CustomPainter {
  const _DropletPainter({required this.level, required this.fill, required this.wave});

  final int level;
  final double fill;
  final double wave;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w / 2, 0)
      ..cubicTo(w * 0.78, h * 0.26, w, h * 0.42, w, h * 0.62)
      ..cubicTo(w, h * 0.86, w * 0.78, h, w / 2, h)
      ..cubicTo(w * 0.22, h, 0, h * 0.86, 0, h * 0.62)
      ..cubicTo(0, h * 0.42, w * 0.22, h * 0.26, w / 2, 0)
      ..close();

    final tone = Color.lerp(const Color(0xFFF3A9A0), Hue.rose, (level / 4).clamp(0.0, 1.0))!;
    final depth = [0.0, 0.32, 0.66, 0.85, 1.0][level.clamp(0, 4)];

    if (fill > 0.02) {
      canvas.drawPath(
        path,
        Paint()
          ..color = Hue.rose.withValues(alpha: 0.38 * fill)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }

    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.09));

    if (depth > 0) {
      canvas.save();
      canvas.clipPath(path);
      final level0 = h * (1 - depth * (0.35 + 0.65 * fill));
      final wavePath = Path()..moveTo(0, level0);
      for (var x = 0.0; x <= w; x += 2) {
        wavePath.lineTo(x, level0 + math.sin((x / w * 2 + wave * 2) * math.pi * 2) * 1.6 * fill);
      }
      wavePath
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(
        wavePath,
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, level0), Offset(0, h), [
            Color.lerp(tone, Colors.white, 0.25 * (1 - fill))!,
            tone,
          ]),
      );
      canvas.restore();
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Color.lerp(Hue.rose.withValues(alpha: 0.55), Hue.rose, fill)!,
    );

    if (fill > 0.3) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.34, h * 0.68), width: w * 0.22, height: h * 0.12),
        Paint()..color = Colors.white.withValues(alpha: 0.45 * fill),
      );
    }
  }

  @override
  bool shouldRepaint(_DropletPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.wave != wave || oldDelegate.level != level;
}

class _Mood extends StatelessWidget {
  const _Mood({required this.cycle, required this.pulse});

  final Cycle cycle;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cycle,
      builder: (context, _) {
        return Stack(
          children: [
            for (var i = 0; i < 5; i++)
              Positioned(
                left: 12.0 + i * 66.5,
                top: 0,
                width: 56,
                height: 44,
                child: Pressable(
                  onTap: () => cycle.setMood(i),
                  scale: 0.88,
                  child: _Face(level: i, selected: cycle.mood == i, pulse: pulse),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Face extends StatelessWidget {
  const _Face({required this.level, required this.selected, required this.pulse});

  static const labels = ['Rough', 'Low', 'Okay', 'Good', 'Great'];

  final int level;
  final bool selected;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: selected ? 1 : 0),
      duration: const Duration(milliseconds: 640),
      curve: const Spring(bounce: 0.36),
      builder: (context, t, _) {
        return Center(
          child: AnimatedBuilder(
            animation: pulse,
            builder: (context, _) {
              final wiggle = selected ? math.sin(pulse.value * math.pi * 2) * 0.06 : 0.0;
              return Transform.rotate(
                angle: wiggle,
                child: Transform.scale(
                  scale: 1 + 0.12 * t,
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: CustomPaint(
                      painter: _FacePainter(level: level, select: t),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FacePainter extends CustomPainter {
  const _FacePainter({required this.level, required this.select});

  final int level;
  final double select;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;
    final mood = level / 4;

    if (select > 0.02) {
      canvas.drawCircle(
        centre,
        r + 5 * select,
        Paint()
          ..color = Hue.amber.withValues(alpha: 0.35 * select)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..shader = ui.Gradient.linear(centre - Offset(r, r), centre + Offset(r, r), [
          Color.lerp(Colors.white.withValues(alpha: 0.13), const Color(0xFFFFD166), select)!,
          Color.lerp(Colors.white.withValues(alpha: 0.07), const Color(0xFFF7A93B), select)!,
        ]),
    );
    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Color.lerp(Colors.white.withValues(alpha: 0.22), const Color(0xFFE8912B), select)!,
    );

    final ink = Color.lerp(Colors.white.withValues(alpha: 0.55), const Color(0xFF6B3C0A), select)!;
    final eye = Paint()
      ..color = ink
      ..style = PaintingStyle.fill;
    final eyeY = centre.dy - r * 0.26;
    final eyeR = 1.7 + 0.5 * select;
    canvas.drawCircle(Offset(centre.dx - r * 0.34, eyeY), eyeR, eye);
    canvas.drawCircle(Offset(centre.dx + r * 0.34, eyeY), eyeR, eye);

    final mouthWidth = r * 0.98;
    final curve = lerp(-0.42, 0.62, mood) * r;
    final mouth = Path()
      ..moveTo(centre.dx - mouthWidth / 2, centre.dy + r * 0.24 - curve * 0.18)
      ..quadraticBezierTo(
        centre.dx,
        centre.dy + r * 0.24 + curve,
        centre.dx + mouthWidth / 2,
        centre.dy + r * 0.24 - curve * 0.18,
      );
    canvas.drawPath(
      mouth,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9 + 0.6 * select
        ..strokeCap = StrokeCap.round
        ..color = ink,
    );
    if (select > 0.5 && mood > 0.7) {
      canvas.drawPath(
        Path()
          ..moveTo(centre.dx - mouthWidth / 2, centre.dy + r * 0.24 - curve * 0.18)
          ..quadraticBezierTo(
            centre.dx,
            centre.dy + r * 0.24 + curve,
            centre.dx + mouthWidth / 2,
            centre.dy + r * 0.24 - curve * 0.18,
          )
          ..close(),
        Paint()..color = ink.withValues(alpha: 0.9 * (select - 0.5) * 2),
      );
    }
  }

  @override
  bool shouldRepaint(_FacePainter oldDelegate) => oldDelegate.select != select || oldDelegate.level != level;
}

class _Energy extends StatelessWidget {
  const _Energy({required this.cycle, required this.pulse});

  final Cycle cycle;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cycle,
      builder: (context, _) {
        return Stack(
          children: [
            Positioned(
              left: 16,
              top: 2,
              child: AnimatedBuilder(
                animation: pulse,
                builder: (context, child) {
                  final glow = 0.6 + 0.4 * cycle.energy + 0.1 * math.sin(pulse.value * math.pi * 2);
                  return Opacity(opacity: glow.clamp(0.0, 1.0), child: child);
                },
                child: const GlyphIcon(Glyph.zap, size: 22, color: Hue.amber, stroke: 1.9, fill: Color(0x33EE9C33)),
              ),
            ),
            Positioned(
              left: 17,
              top: 32,
              child: Text('Low', style: sans(11.5, 500, color: Hue.inkMuted, height: 1)),
            ),
            Positioned(
              right: 17,
              top: 32,
              child: Text('High', style: sans(11.5, 500, color: Hue.inkMuted, height: 1)),
            ),
            Positioned(
              left: 48,
              right: 18,
              top: 0,
              height: 26,
              child: _Slider(cycle: cycle, pulse: pulse),
            ),
          ],
        );
      },
    );
  }
}

class _Slider extends StatefulWidget {
  const _Slider({required this.cycle, required this.pulse});

  final Cycle cycle;
  final Animation<double> pulse;

  @override
  State<_Slider> createState() => _SliderState();
}

class _SliderState extends State<_Slider> {
  bool _dragging = false;

  void _update(Offset local, double width) {
    widget.cycle.setEnergy((local.dx / width).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) {
            setState(() => _dragging = true);
            _update(d.localPosition, box.maxWidth);
          },
          onHorizontalDragUpdate: (d) => _update(d.localPosition, box.maxWidth),
          onHorizontalDragEnd: (_) => setState(() => _dragging = false),
          onTapDown: (d) => _update(d.localPosition, box.maxWidth),
          child: AnimatedBuilder(
            animation: widget.pulse,
            builder: (context, _) => CustomPaint(
              painter: _SliderPainter(value: widget.cycle.energy, active: _dragging, beat: widget.pulse.value),
            ),
          ),
        );
      },
    );
  }
}

class _SliderPainter extends CustomPainter {
  const _SliderPainter({required this.value, required this.active, required this.beat});

  final double value;
  final bool active;
  final double beat;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final trackPaint = Paint()
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.14);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), trackPaint);

    final knobX = size.width * value;
    canvas.drawLine(
      Offset(0, y),
      Offset(knobX, y),
      Paint()
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(Offset(0, y), Offset(knobX, y), const [Color(0xFFE9A22B), Color(0xFFE7841F)]),
    );

    final knob = Offset(knobX, y);
    final halo = active ? 16.0 : 11.0 + math.sin(beat * math.pi * 2) * 1.2;
    canvas.drawCircle(knob, halo, Paint()..color = Hue.amber.withValues(alpha: active ? 0.28 : 0.16));
    canvas.drawCircle(knob, 9.5, Paint()..color = Hue.surface);
    canvas.drawCircle(
      knob,
      9.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFE8912B),
    );
  }

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.active != active || oldDelegate.beat != beat;
}

class _Symptoms extends StatelessWidget {
  const _Symptoms({required this.cycle, required this.enter});

  final Cycle cycle;
  final Animation<double> enter;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cycle,
      builder: (context, _) {
        return Stack(
          children: [
            for (final (i, symptom) in symptoms.indexed)
              Positioned(
                left: 16.0 + (i % 3) * 110.5,
                top: 4.0 + (i ~/ 3) * 51,
                width: 104,
                height: 44,
                child: Staged(
                  animation: enter,
                  begin: 0.4 + i * 0.02,
                  end: 0.85 + i * 0.02,
                  offset: const Offset(0, 12),
                  scale: 0.9,
                  child: _SymptomChip(
                    label: symptom,
                    selected: cycle.picked.contains(symptom),
                    onTap: () => cycle.toggle(symptom),
                  ),
                ),
              ),
            Positioned(
              left: 16,
              top: 157,
              width: 140,
              height: 34,
              child: Staged(
                animation: enter,
                begin: 0.6,
                end: 1.0,
                offset: const Offset(0, 10),
                child: CustomPaint(
                  painter: const _DashedChip(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GlyphIcon(Glyph.plus, size: 14, color: Hue.inkSoft, stroke: 2),
                      const SizedBox(width: 7),
                      Text('Add symptom', style: sans(12.5, 700, color: Hue.inkSoft, height: 1)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SymptomChip extends StatefulWidget {
  const _SymptomChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SymptomChip> createState() => _SymptomChipState();
}

class _SymptomChipState extends State<_SymptomChip> with SingleTickerProviderStateMixin {
  late final AnimationController _ripple;
  Offset _origin = const Offset(52, 22);

  @override
  void initState() {
    super.initState();
    _ripple = AnimationController(vsync: this, duration: const Duration(milliseconds: 620));
  }

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => _origin = d.localPosition,
      onTap: () {
        _ripple.forward(from: 0);
        widget.onTap();
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: widget.selected ? 1 : 0),
        duration: const Duration(milliseconds: 520),
        curve: gentle,
        builder: (context, t, _) {
          return AnimatedBuilder(
            animation: _ripple,
            builder: (context, _) => CustomPaint(
              painter: _ChipPainter(select: t, ripple: _ripple.value, origin: _origin),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: widget.selected ? 26 : 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: widget.selected ? 8 : 0),
                        child: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: sans(
                            12.5,
                            widget.selected ? 800 : 600,
                            color: Color.lerp(Hue.inkSoft, Colors.white, t)!,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (t > 0.02)
                    Positioned(
                      right: 9,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Transform.scale(
                          scale: Curves.easeOutBack.transform(t.clamp(0.0, 1.0)),
                          child: Container(
                            width: 19,
                            height: 19,
                            decoration: const BoxDecoration(color: Color(0xFFE23D3D), shape: BoxShape.circle),
                            child: const Center(
                              child: GlyphIcon(Glyph.check, size: 11, color: Colors.white, stroke: 3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChipPainter extends CustomPainter {
  const _ChipPainter({required this.select, required this.ripple, required this.origin});

  final double select;
  final double ripple;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(15));
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(size.width, size.height), [
          Color.lerp(Colors.white.withValues(alpha: 0.07), const Color(0xFFE8536F), select)!,
          Color.lerp(Colors.white.withValues(alpha: 0.05), const Color(0xFFD9445F), select)!,
        ]),
    );
    if (ripple > 0 && ripple < 1) {
      canvas.save();
      canvas.clipRRect(rect);
      canvas.drawCircle(
        origin,
        ripple * size.width * 1.2,
        Paint()..color = const Color(0xFFE23D3D).withValues(alpha: 0.22 * (1 - ripple)),
      );
      canvas.restore();
    }
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = Color.lerp(Colors.white.withValues(alpha: 0.14), const Color(0xFFFF8FA3), select)!,
    );
  }

  @override
  bool shouldRepaint(_ChipPainter oldDelegate) => oldDelegate.select != select || oldDelegate.ripple != ripple;
}

class _DashedChip extends CustomPainter {
  const _DashedChip();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(15));
    canvas.drawRRect(rect, Paint()..color = Colors.white.withValues(alpha: 0.05));
    final path = Path()..addRRect(rect);
    final dashed = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        dashed.addPath(metric.extractPath(distance, math.min(distance + 5, metric.length)), Offset.zero);
        distance += 9;
      }
    }
    canvas.drawPath(
      dashed,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = Hue.inkMuted.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(_DashedChip oldDelegate) => false;
}

class _Notes extends StatelessWidget {
  const _Notes({required this.cycle});

  final Cycle cycle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 2,
              bottom: 0,
              child: Opacity(
                opacity: 0.6,
                child: CustomPaint(size: const Size(74, 72), painter: const SprigPainter(Hue.rose)),
              ),
            ),
            Positioned(
              left: 14,
              top: 13,
              child: Text('How are you feeling today?', style: sans(12.5, 500, color: Hue.inkMuted, height: 1)),
            ),
            Positioned(
              left: 14,
              top: 35,
              child: Text(
                'Add notes here...',
                style: sans(12.5, 500, color: Hue.inkMuted.withValues(alpha: 0.75), height: 1),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 8,
              child: ListenableBuilder(
                listenable: cycle,
                builder: (context, _) =>
                    Text('${cycle.notes.length}/300', style: sans(11, 600, color: Hue.inkMuted, height: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Save extends StatefulWidget {
  const _Save({required this.cycle, required this.pulse, required this.onSave});

  final Cycle cycle;
  final Animation<double> pulse;
  final VoidCallback onSave;

  @override
  State<_Save> createState() => _SaveState();
}

class _SaveState extends State<_Save> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1250));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_c.isAnimating) return;
    await _c.forward(from: 0);
    if (!mounted) return;
    widget.cycle.save();
    widget.onSave();
    _c.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: _save,
      scale: 0.97,
      child: AnimatedBuilder(
        animation: Listenable.merge([_c, widget.pulse]),
        builder: (context, _) {
          final t = _c.value;
          final label = 1 - span(t, 0.18, 0.36);
          final done = span(t, 0.66, 0.92);
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _SavePainter(progress: t, shimmer: widget.pulse.value),
                ),
              ),
              if (label > 0.02)
                Opacity(
                  opacity: label,
                  child: Text('Save day', style: sans(16.5, 600, color: Colors.white, height: 1)),
                ),
              if (done > 0.02)
                Opacity(
                  opacity: done,
                  child: Transform.translate(
                    offset: Offset(14 * (1 - done), 0),
                    child: Text('Saved', style: sans(16.5, 600, color: Colors.white, height: 1)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SavePainter extends CustomPainter {
  const _SavePainter({required this.progress, required this.shimmer});

  final double progress;
  final double shimmer;

  static final _sparks = List.generate(16, (i) {
    final rand = math.Random(i * 71 + 5);
    return (rand.nextDouble() * math.pi * 2, 0.6 + rand.nextDouble() * 0.9, 1.4 + rand.nextDouble() * 2.2);
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2));

    canvas.drawRRect(
      shape.shift(const Offset(0, 8)),
      Paint()
        ..color = Hue.rose.withValues(alpha: 0.36)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawRRect(shape, Paint()..shader = warmGradient.createShader(rect));

    canvas.save();
    canvas.clipRRect(shape);

    final fill = span(progress, 0.0, 0.52, easeInOutSoft);
    if (fill > 0.001) {
      final level = size.height * (1 - fill) - 6 * (1 - fill);
      final wave = Path()..moveTo(0, level);
      for (var x = 0.0; x <= size.width; x += 4) {
        final y = level + math.sin((x / size.width * 3 + progress * 6) * math.pi * 2) * 4 * (1 - fill);
        wave.lineTo(x, y);
      }
      wave
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        wave,
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, level), Offset(0, size.height), [
            const Color(0xFFE8536F),
            const Color(0xFFC8385A),
          ]),
      );
    }

    if (progress <= 0.02) {
      final sweep = (shimmer * 1.6 % 1.0) * 1.6 - 0.3;
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(size.width * (sweep - 0.18), 0),
            Offset(size.width * (sweep + 0.18), size.height),
            [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.22),
              Colors.white.withValues(alpha: 0),
            ],
            const [0.0, 0.5, 1.0],
          ),
      );
    }
    canvas.restore();

    final tick = span(progress, 0.48, 0.74, Curves.easeOutCubic);
    if (tick > 0.01) {
      final centre = Offset(size.width / 2 - (progress > 0.7 ? 34 : 0), size.height / 2);
      final check = Path()
        ..moveTo(centre.dx - 9, centre.dy + 0.5)
        ..lineTo(centre.dx - 2.5, centre.dy + 7)
        ..lineTo(centre.dx + 10, centre.dy - 6.5);
      final metric = check.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * tick),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.white,
      );
    }

    final burst = span(progress, 0.5, 1.0);
    if (burst > 0.01 && burst < 1) {
      final centre = Offset(size.width / 2, size.height / 2);
      for (final (angle, speed, radius) in _sparks) {
        final distance = burst * speed * 96;
        final at = centre + Offset(math.cos(angle), math.sin(angle) * 0.7) * distance;
        canvas.drawCircle(
          at,
          radius * (1 - burst),
          Paint()..color = (angle > math.pi ? Hue.amber : Colors.white).withValues(alpha: 0.85 * (1 - burst)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SavePainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.shimmer != shimmer;
}
