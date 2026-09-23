import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/canvas.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../data/journal.dart';
import '../widgets/panel.dart';

class YouSheet extends StatelessWidget {
  const YouSheet({
    super.key,
    required this.reveal,
    required this.seconds,
    required this.store,
    required this.onClose,
  });

  final Animation<double> reveal;
  final double seconds;
  final JournalStore store;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scope = CanvasScope.of(context);
    return AnimatedBuilder(
      animation: reveal,
      builder: (context, _) {
        final t = reveal.value;
        if (t <= 0.001) return const SizedBox.shrink();
        final rise = Curves.easeOutCubic.transform(t);
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: onClose,
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.52 * t)),
              ),
            ),
            Positioned(
              left: 17,
              right: 17,
              bottom: (scope.height - scope.floor) + 118 - 360 * (1 - rise),
              height: 268,
              child: Opacity(
                opacity: span(t, 0.05, 0.55),
                child: Panel(
                  radius: 30,
                  opacity: 0.74,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 13,
                        child: Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Ember.ash.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        top: 36,
                        child: _Ring(seconds: seconds, progress: span(t, 0.2, 1.0), days: 5),
                      ),
                      Positioned(
                        left: 132,
                        top: 46,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ava Moreau', style: font(19, 500)),
                            const SizedBox(height: 5),
                            Text('reflecting since March', style: meta(0.7)),
                            const SizedBox(height: 18),
                            _Stat(label: 'entries', value: '${store.entries.length}'),
                            const SizedBox(height: 10),
                            _Stat(label: 'day streak', value: '5'),
                            const SizedBox(height: 10),
                            _Stat(label: 'words written', value: '1,284'),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 22,
                        child: Pressable(
                          onTap: onClose,
                          scale: 0.97,
                          child: Hairpill(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text('Close', style: font(13.8, 500, color: Ember.gold)),
                              ),
                            ),
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
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 46,
          child: Text(value, style: font(15, 600, color: Ember.gold)),
        ),
        Text(label, style: font(12.6, 400, color: Ember.ash.withValues(alpha: 0.72))),
      ],
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.seconds, required this.progress, required this.days});

  final double seconds;
  final double progress;
  final int days;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: 92, child: CustomPaint(painter: _RingPainter(seconds, progress, days)));
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.seconds, this.progress, this.days);

  final double seconds;
  final double progress;
  final int days;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final r = size.width / 2 - 7;
    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = Ember.rust.withValues(alpha: 0.6),
    );
    final sweep = math.pi * 2 * (days / 7) * progress;
    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: r),
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.sweep(
          centre,
          const [Color(0xFFF5821A), Color(0xFFFFC63C), Color(0xFFFFE9A8), Color(0xFFF5821A)],
          const [0.0, 0.4, 0.7, 1.0],
          TileMode.clamp,
          -math.pi / 2,
          math.pi * 1.5,
        ),
    );
    final head = centre + Offset(math.cos(sweep - math.pi / 2), math.sin(sweep - math.pi / 2)) * r;
    canvas.drawCircle(
      head,
      5 + 1.4 * math.sin(seconds * 2.4),
      Paint()
        ..color = Ember.gold.withValues(alpha: 0.6)
        ..maskFilter = const ui.MaskFilter.blur(BlurStyle.normal, 7),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '$days',
        style: font(26, 600, color: Ember.cream, height: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, centre - Offset(tp.width / 2, tp.height / 2 + 4));
    final tp2 = TextPainter(
      text: TextSpan(text: 'days', style: meta(0.66)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(canvas, centre - Offset(tp2.width / 2, -12));
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.seconds != seconds || old.progress != progress;
}
