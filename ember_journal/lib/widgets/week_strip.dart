import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';

const weekLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

class WeekStrip extends StatefulWidget {
  const WeekStrip({
    super.key,
    required this.days,
    required this.selected,
    required this.onSelect,
    required this.seconds,
    required this.marked,
  });

  final List<int> days;
  final int selected;
  final ValueChanged<int> onSelect;
  final double seconds;
  final Set<int> marked;

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late double _from;
  late double _to;

  @override
  void initState() {
    super.initState();
    _from = _to = widget.days.indexOf(widget.selected).toDouble();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 620), value: 1);
  }

  @override
  void didUpdateWidget(WeekStrip old) {
    super.didUpdateWidget(old);
    final target = widget.days.indexOf(widget.selected).toDouble();
    if (target != _to) {
      _from = _to;
      _to = target;
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final cell = box.maxWidth / widget.days.length;
        return AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final lead = Curves.easeOutQuint.transform(t);
            final trail = Curves.easeInOutCubic.transform(math.pow(t, 1.45).toDouble());
            final a = lerp(_from, _to, _to > _from ? trail : lead);
            final b = lerp(_from, _to, _to > _from ? lead : trail);
            final active = lerp(_from, _to, Curves.easeInOut.transform(t));
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _BlobPainter(
                      left: cell * math.min(a, b) + 4,
                      right: cell * math.max(a, b) + cell - 4,
                      seconds: widget.seconds,
                      travel: (b - a).abs(),
                    ),
                  ),
                ),
                for (var i = 0; i < widget.days.length; i++)
                  Positioned(
                    left: cell * i,
                    top: 0,
                    width: cell,
                    height: box.maxHeight,
                    child: Pressable(
                      scale: 0.9,
                      onTap: () => widget.onSelect(widget.days[i]),
                      child: _Cell(
                        letter: weekLetters[i % 7],
                        day: widget.days[i],
                        on: (1 - (active - i).abs()).clamp(0.0, 1.0),
                        marked: widget.marked.contains(widget.days[i]),
                        seconds: widget.seconds,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.letter,
    required this.day,
    required this.on,
    required this.marked,
    required this.seconds,
  });

  final String letter;
  final int day;
  final double on;
  final bool marked;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    final ink = Color.lerp(Ember.ash.withValues(alpha: 0.72), Ember.gold, on)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Color.lerp(hairlineSoft, Colors.transparent, on)!),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 13,
            child: Center(
              child: Text(
                letter,
                style: font(11.6, 500, color: ink.withValues(alpha: 0.55 + 0.45 * on)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 40,
            child: Center(
              child: Transform.scale(
                scale: 1 + 0.10 * on,
                child: Text('$day', style: font(15, 600, color: ink)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 9,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 260),
                opacity: marked ? 1 : 0,
                child: Container(
                  width: 3.4 + 0.8 * on,
                  height: 3.4 + 0.8 * on,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.lerp(Ember.amber, Ember.gold, on),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  const _BlobPainter({required this.left, required this.right, required this.seconds, required this.travel});

  final double left;
  final double right;
  final double seconds;
  final double travel;

  @override
  void paint(Canvas canvas, Size size) {
    final squash = 1 - (travel * 0.10).clamp(0.0, 0.16);
    final height = size.height * squash;
    final rect = Rect.fromLTRB(left, (size.height - height) / 2, right, (size.height + height) / 2);
    final shape = RRect.fromRectAndRadius(rect, Radius.circular(height / 2));
    final glow = 0.62 + 0.38 * math.sin(seconds * 2.0);

    canvas.drawRRect(
      shape,
      Paint()
        ..color = Ember.amber.withValues(alpha: 0.30 * glow)
        ..maskFilter = const ui.MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, const [
          Color(0x3DFFC63C),
          Color(0x140A0402),
        ]),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = Ember.gold.withValues(alpha: 0.75),
    );
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.left != left || old.right != right || old.seconds != seconds;
}
