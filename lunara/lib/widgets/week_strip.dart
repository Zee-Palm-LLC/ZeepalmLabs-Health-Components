import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/theme.dart';
import '../data/cycle.dart';

class WeekStrip extends StatefulWidget {
  const WeekStrip({super.key, required this.cycle, required this.onDay});

  static const width = 353.0;
  static const height = 84.0;
  static const item = 44.0;

  final Cycle cycle;
  final ValueChanged<int> onDay;

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> with SingleTickerProviderStateMixin {
  late final AnimationController _move;
  late List<int> _days = widget.cycle.weekDays;
  late int _from = _days.indexOf(widget.cycle.day).clamp(0, 6);
  late int _to = _from;

  @override
  void initState() {
    super.initState();
    _move = AnimationController(vsync: this, duration: const Duration(milliseconds: 760), value: 1);
    widget.cycle.addListener(_sync);
  }

  void _sync() {
    final next = _days.indexOf(widget.cycle.day);
    if (next < 0 || next == _to) {
      if (next < 0) setState(() => _days = widget.cycle.weekDays);
      return;
    }
    setState(() {
      _from = _to;
      _to = next;
    });
    _move.forward(from: 0);
  }

  @override
  void dispose() {
    widget.cycle.removeListener(_sync);
    _move.dispose();
    super.dispose();
  }

  static double _left(int i) {
    const gap = (WeekStrip.width - WeekStrip.item * 7) / 6;
    return i * (WeekStrip.item + gap);
  }

  RRect _blob(double t) {
    final fromLeft = _left(_from);
    final toLeft = _left(_to);
    final forward = _to >= _from;
    const lead = Cubic(0.24, 0.9, 0.3, 1);
    const trail = Cubic(0.72, 0, 0.35, 1);
    final leftEdge = lerp(fromLeft, toLeft, (forward ? trail : lead).transform(t));
    final rightEdge = lerp(fromLeft + WeekStrip.item, toLeft + WeekStrip.item, (forward ? lead : trail).transform(t));
    final stretch = ((rightEdge - leftEdge) - WeekStrip.item) / WeekStrip.item;
    final squash = 1 - 0.07 * stretch.clamp(0.0, 1.0);
    final height = WeekStrip.height * squash;
    final top = (WeekStrip.height - height) / 2;
    return RRect.fromLTRBR(leftEdge, top, rightEdge, top + height, Radius.circular(WeekStrip.item * 0.46));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: WeekStrip.width,
      height: WeekStrip.height,
      child: AnimatedBuilder(
        animation: _move,
        builder: (context, _) {
          final blob = _blob(_move.value);
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _StripPainter(blob: blob, cycle: widget.cycle, days: _days),
                ),
              ),
              Positioned.fill(child: _labels(Hue.inkMuted, Hue.ink, null)),
              Positioned.fill(
                child: ClipPath(
                  clipper: _BlobClipper(blob),
                  child: _labels(Colors.white.withValues(alpha: 0.85), Colors.white, blob),
                ),
              ),
              for (var i = 0; i < 7; i++)
                Positioned(
                  left: _left(i),
                  top: 0,
                  width: WeekStrip.item,
                  height: WeekStrip.height,
                  child: Pressable(onTap: () => widget.onDay(_days[i]), scale: 0.9, child: const SizedBox.expand()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _labels(Color muted, Color strong, RRect? clip) {
    return IgnorePointer(
      child: Stack(
        children: [
          for (var i = 0; i < 7; i++) ...[
            Positioned(
              left: _left(i),
              top: 14,
              width: WeekStrip.item,
              child: Text(
                Cycle.weekInitials[i],
                textAlign: TextAlign.center,
                style: sans(11, 500, color: muted, height: 1),
              ),
            ),
            Positioned(
              left: _left(i),
              top: 33,
              width: WeekStrip.item,
              child: Text(
                '${_days[i]}',
                textAlign: TextAlign.center,
                style: sans(15, 600, color: strong, height: 1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StripPainter extends CustomPainter {
  const _StripPainter({required this.blob, required this.cycle, required this.days});

  final RRect blob;
  final Cycle cycle;
  final List<int> days;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(26)),
      Paint()..color = Hue.surface,
    );
    canvas.drawRRect(
      blob.shift(const Offset(0, 5)),
      Paint()
        ..color = Hue.rose.withValues(alpha: 0.38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawRRect(blob, Paint()..shader = warmGradient.createShader(blob.outerRect));

    for (var i = 0; i < days.length; i++) {
      final left = _StripPainter.itemLeft(i);
      final centre = Offset(left + WeekStrip.item / 2, size.height - 20);
      final phase = cycle.phaseOfDay(days[i]);
      final covered = blob.outerRect.contains(centre);
      canvas.drawCircle(centre, 3.4, Paint()..color = covered ? Colors.white.withValues(alpha: 0.9) : phase.colour);
    }
  }

  static double itemLeft(int i) {
    const gap = (WeekStrip.width - WeekStrip.item * 7) / 6;
    return i * (WeekStrip.item + gap);
  }

  @override
  bool shouldRepaint(_StripPainter oldDelegate) => oldDelegate.blob != blob || oldDelegate.days != days;
}

class _BlobClipper extends CustomClipper<Path> {
  const _BlobClipper(this.blob);

  final RRect blob;

  @override
  Path getClip(Size size) => Path()..addRRect(blob);

  @override
  bool shouldReclip(_BlobClipper oldClipper) => oldClipper.blob != blob;
}
