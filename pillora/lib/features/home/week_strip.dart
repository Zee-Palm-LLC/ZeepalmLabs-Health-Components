import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/text_styles.dart';
import '../../data/medications.dart';

class WeekStrip extends StatefulWidget {
  const WeekStrip({super.key, required this.plan, required this.selected, required this.onSelect, required this.intro});

  final WeekPlan plan;
  final int selected;
  final ValueChanged<int> onSelect;
  final Animation<double> intro;

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> with SingleTickerProviderStateMixin {
  late final AnimationController _move;
  late int _from;

  static const circle = 40.0;

  @override
  void initState() {
    super.initState();
    _from = widget.selected;
    _move = AnimationController(vsync: this, duration: const Duration(milliseconds: 680), value: 1);
  }

  @override
  void didUpdateWidget(WeekStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _from = oldWidget.selected;
      _move.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final column = constraints.maxWidth / 7;
        double centre(int i) => column * (i + 0.5);

        return AnimatedBuilder(
          animation: Listenable.merge([_move, widget.intro]),
          builder: (context, _) {
            final blob = _blob(centre, _move.value);
            final appear = window(widget.intro.value, 0.34, 0.62, Curves.easeOutBack);
            return Column(
              children: [
                Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Center(
                          child: Opacity(
                            opacity: window(widget.intro.value, 0.3 + i * 0.025, 0.5 + i * 0.025),
                            child: Text(
                              WeekPlan.letters[i],
                              style: TextStyles.label.copyWith(fontSize: 12.5, color: Palette.inkSoft),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 52,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DaysPainter(
                            centres: [for (var i = 0; i < 7; i++) centre(i)],
                            todayIndex: widget.plan.todayIndex,
                            appear: [
                              for (var i = 0; i < 7; i++)
                                window(widget.intro.value, 0.34 + i * 0.03, 0.6 + i * 0.03, Curves.easeOutBack),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(child: _numbers(centre, Palette.inkMuted, false)),
                      Positioned.fill(
                        child: IgnorePointer(child: CustomPaint(painter: _BlobPainter(blob, appear, _move.value))),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ClipPath(
                            clipper: _RRectClipper(_scaled(blob, appear)),
                            child: _numbers(centre, Colors.white, true),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  RRect _scaled(RRect blob, double appear) {
    final c = blob.center;
    return RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: blob.width * appear, height: blob.height * appear),
      Radius.circular(blob.height * appear / 2),
    );
  }

  RRect _blob(double Function(int) centre, double t) {
    final to = widget.selected;
    final forward = to >= _from;
    const lead = Cubic(0.2, 0.95, 0.3, 1);
    const trail = Cubic(0.75, 0, 0.3, 1);
    final fromLeft = centre(_from) - circle / 2;
    final toLeft = centre(to) - circle / 2;
    final leftEdge = lerp(fromLeft, toLeft, (forward ? trail : lead).transform(t));
    final rightEdge = lerp(fromLeft + circle, toLeft + circle, (forward ? lead : trail).transform(t));
    final stretch = ((rightEdge - leftEdge) - circle) / circle;
    final height = circle * (1 - 0.12 * stretch.clamp(0.0, 1.0));
    const midY = 20.0;
    return RRect.fromLTRBR(leftEdge, midY - height / 2, rightEdge, midY + height / 2, Radius.circular(height / 2));
  }

  Widget _numbers(double Function(int) centre, Color color, bool selectedLayer) {
    return Stack(
      children: [
        for (var i = 0; i < 7; i++)
          Positioned(
            left: centre(i) - circle / 2,
            top: 0,
            width: circle,
            height: circle,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: selectedLayer ? null : () => widget.onSelect(i),
              child: Center(
                child: Opacity(
                  opacity: window(widget.intro.value, 0.4 + i * 0.03, 0.62 + i * 0.03),
                  child: Text(
                    '${widget.plan.day(i).day}',
                    style: TextStyles.caption.copyWith(
                      color: color,
                      fontSize: 12.5,
                      fontWeight: selectedLayer ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DaysPainter extends CustomPainter {
  _DaysPainter({required this.centres, required this.todayIndex, required this.appear});

  final List<double> centres;
  final int todayIndex;
  final List<double> appear;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < centres.length; i++) {
      final scale = appear[i];
      if (scale <= 0) continue;
      final c = Offset(centres[i], 20);
      final r = 20 * scale;
      final past = i < todayIndex;
      canvas.drawCircle(c, r, Paint()..color = past ? Palette.mistDeep : Palette.mist);
      if (past) {
        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
        final stripe = Paint()
          ..color = const Color(0xFFF8FAFA)
          ..strokeWidth = 2.2;
        for (var d = -2 * r; d < 2 * r; d += 5.2) {
          canvas.drawLine(c + Offset(d - r, r), c + Offset(d + r, -r), stripe);
        }
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_DaysPainter oldDelegate) => true;
}

class _BlobPainter extends CustomPainter {
  _BlobPainter(this.blob, this.appear, this.t);

  final RRect blob;
  final double appear;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (appear <= 0) return;
    final c = blob.center;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(appear);
    canvas.translate(-c.dx, -c.dy);
    canvas.drawRRect(
      blob.shift(const Offset(0, 4)),
      Paint()
        ..color = const Color(0x33154044)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(blob, Paint()..color = Palette.deep);
    canvas.restore();

    final settle = window(t, 0.45, 1, Curves.elasticOut);
    for (final dx in const [-2.6, 2.6]) {
      final bounce = (1 - settle) * 6 * (dx < 0 ? 1 : 1.4);
      canvas.drawCircle(
        Offset(c.dx + dx, c.dy + 12.5 + bounce),
        1.3 * appear * math.max(settle, 0.2),
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) => true;
}

class _RRectClipper extends CustomClipper<Path> {
  _RRectClipper(this.rrect);

  final RRect rrect;

  @override
  Path getClip(Size size) => Path()..addRRect(rrect);

  @override
  bool shouldReclip(_RRectClipper oldClipper) => oldClipper.rrect != rrect;
}
