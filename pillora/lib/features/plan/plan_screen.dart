import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/icons/glyphs.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/aurora.dart';
import '../../data/medications.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key, required this.onScrollDirection});

  final ValueChanged<ScrollDirection> onScrollDirection;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _intro;

  static const _day = [
    (Cabinet.omeprazole, true),
    (Cabinet.metformin, true),
    (Cabinet.amlodipine, false),
    (Cabinet.lisinopril, false),
    (Cabinet.amoxicillin, false),
    (Cabinet.vitaminD, false),
    (Cabinet.atorvastatin, false),
  ];

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final style = TextStyles.headline.copyWith(color: Colors.white.withValues(alpha: 0.94));
    return ColoredBox(
      color: Palette.canvas,
      child: Stack(
        children: [
          const Positioned(top: 0, left: 0, right: 0, child: Aurora()),
          NotificationListener<UserScrollNotification>(
            onNotification: (n) {
              widget.onScrollDirection(n.direction);
              return false;
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, top + 18, 16, 130),
              children: [
                Entrance(
                  animation: stage(_intro, 0, 0.3),
                  offset: const Offset(0, -10),
                  child: Row(
                    children: [
                      Text(
                        'Medication plan',
                        style: TextStyles.label.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                      ),
                      const Spacer(),
                      Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Row(
                          children: [
                            const GlyphIcon(Glyph.calendar, size: 15, color: Colors.white, stroke: 1.5),
                            const SizedBox(width: 6),
                            Text(_monthLabel(DateTime.now()), style: TextStyles.label.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Entrance(
                  animation: stage(_intro, 0.06, 0.4),
                  blur: 10,
                  child: Text('Every dose, right', style: style),
                ),
                Entrance(
                  animation: stage(_intro, 0.12, 0.46),
                  blur: 10,
                  child: Text('on time', style: style),
                ),
                const SizedBox(height: 18),
                Entrance(
                  animation: stage(_intro, 0.16, 0.6, curve: const Cubic(0.2, 0.9, 0.25, 1.05)),
                  offset: const Offset(0, 50),
                  scale: 0.95,
                  child: _AdherenceCard(intro: _intro),
                ),
                const SizedBox(height: 20),
                Entrance(
                  animation: stage(_intro, 0.3, 0.6),
                  child: const Text("Today's doses", style: TextStyles.section),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < _day.length; i++)
                  Entrance(
                    animation: stage(_intro, 0.34 + i * 0.05, 0.7 + i * 0.04),
                    offset: const Offset(40, 0),
                    child: _TimelineRow(
                      medication: _day[i].$1,
                      done: _day[i].$2,
                      next: i == 2,
                      first: i == 0,
                      last: i == _day.length - 1,
                      intro: _intro,
                      index: i,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _AdherenceCard extends StatelessWidget {
  const _AdherenceCard({required this.intro});

  final Animation<double> intro;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x0F0B2A2D), blurRadius: 30, offset: Offset(0, 12))],
      ),
      child: AnimatedBuilder(
        animation: intro,
        builder: (context, _) {
          final fill = window(intro.value, 0.35, 0.95, const Cubic(0.3, 0, 0.1, 1));
          return Row(
            children: [
              SizedBox(
                width: 108,
                height: 108,
                child: CustomPaint(
                  painter: _RingPainter(fill * 0.86),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(fill * 86).round()}%',
                          style: TextStyles.section.copyWith(fontSize: 24, fontWeight: FontWeight.w500),
                        ),
                        Text('this week', style: TextStyles.caption.copyWith(fontSize: 11.5)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Adherence', style: TextStyles.title),
                    const SizedBox(height: 10),
                    _stat('Taken', (fill * 18).round(), Palette.deep),
                    const SizedBox(height: 6),
                    _stat('Missed', (fill * 1).round(), Palette.alert),
                    const SizedBox(height: 6),
                    _stat('Upcoming', (fill * 5).round(), Palette.inkFaint),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyles.caption.copyWith(fontSize: 13))),
        Text('$value', style: TextStyles.label.copyWith(fontSize: 14)),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.width / 2 - 7;
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..color = Palette.mist,
    );
    if (value <= 0) return;
    final rect = Rect.fromCircle(center: centre, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          colors: [Color(0xFF5FB3A6), Palette.deep],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
    final end = -math.pi / 2 + math.pi * 2 * value;
    final tip = centre + Offset(math.cos(end), math.sin(end)) * radius;
    canvas.drawCircle(tip, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.value != value;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.medication,
    required this.done,
    required this.next,
    required this.first,
    required this.last,
    required this.intro,
    required this.index,
  });

  final Medication medication;
  final bool done;
  final bool next;
  final bool first;
  final bool last;
  final Animation<double> intro;
  final int index;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 58,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                medication.time.replaceAll('AM', ' AM').replaceAll('PM', ' PM'),
                style: TextStyles.caption.copyWith(
                  fontSize: 12,
                  color: next ? Palette.deep : Palette.inkMuted,
                  fontWeight: next ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 24,
            child: AnimatedBuilder(
              animation: intro,
              builder: (context, _) {
                final grow = window(intro.value, 0.4 + index * 0.05, 0.62 + index * 0.05, Curves.easeInOut);
                return CustomPaint(
                  painter: _RailPainter(done: done, next: next, first: first, last: last, grow: grow),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: next ? Palette.deep : Palette.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: next ? Palette.tealChip : Palette.tile,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: medication.shape == PillShape.capsule
                          ? const CapsuleArt(size: 24)
                          : const TabletArt(size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.title,
                            style: TextStyles.label.copyWith(fontSize: 14, color: next ? Colors.white : Palette.ink),
                          ),
                          Text(
                            '${medication.dose} · ${medication.timing}',
                            style: TextStyles.caption.copyWith(
                              fontSize: 12,
                              color: next ? Colors.white60 : Palette.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (done) const GlyphIcon(Glyph.check, size: 20, color: Palette.deep, stroke: 2),
                    if (next)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCFEDE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Next',
                          style: TextStyles.caption.copyWith(
                            color: Palette.deep,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailPainter extends CustomPainter {
  _RailPainter({required this.done, required this.next, required this.first, required this.last, required this.grow});

  final bool done;
  final bool next;
  final bool first;
  final bool last;
  final double grow;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    const dotY = 30.0;
    final base = Paint()
      ..color = const Color(0xFFD9E0E2)
      ..strokeWidth = 2;
    if (!first) canvas.drawLine(Offset(x, 0), Offset(x, dotY), base);
    if (!last) canvas.drawLine(Offset(x, dotY), Offset(x, size.height), base);
    if (done) {
      final active = Paint()
        ..color = Palette.deep
        ..strokeWidth = 2;
      if (!first) canvas.drawLine(Offset(x, 0), Offset(x, dotY * math.min(1, grow * 2)), active);
      if (!last) canvas.drawLine(Offset(x, dotY), Offset(x, dotY + (size.height - dotY) * grow), active);
    }
    final dot = done || next ? Palette.deep : Palette.mistDeep;
    canvas.drawCircle(Offset(x, dotY), next ? 7 : 5, Paint()..color = dot);
    if (next) {
      canvas.drawCircle(Offset(x, dotY), 11 + 3 * grow, Paint()..color = Palette.deep.withValues(alpha: 0.15));
      canvas.drawCircle(Offset(x, dotY), 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_RailPainter oldDelegate) => oldDelegate.grow != grow;
}
