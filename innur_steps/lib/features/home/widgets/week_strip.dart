import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design.dart';
import '../../../core/palette.dart';
import '../../../data/today.dart';

/// Seven days, each a progress ring around its date.
///
/// The arcs sweep in rather than appearing at full length, staggered left to
/// right, so the week reads as being filled in. Today's ring is brighter and
/// its letter sits in full white, which puts the eye on the current day with
/// no highlight box.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.days, required this.t});

  final List<DayRing> days;

  /// Entrance progress, 0..1, shared with the rest of the page.
  final double t;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: D.weekLetterHeight + D.weekRingSize + 4,
      child: Row(
        children: <Widget>[
          for (var i = 0; i < days.length; i++)
            Expanded(
              child: _Day(
                day: days[i],
                // Each ring waits its turn, but they all finish together —
                // a stagger that also delays the end would drag.
                t: ((t - i * D.ringStagger) / (1 - i * D.ringStagger))
                    .clamp(0.0, 1.0),
              ),
            ),
        ],
      ),
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({required this.day, required this.t});

  final DayRing day;
  final double t;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: D.weekLetterHeight,
          child: Text(
            day.letter,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: D.weekLetterSize,
              height: 1.2,
              letterSpacing: 0.2,
              color: day.isToday ? Paper.primary : Paper.muted,
              fontVariations: <FontVariation>[
                FontVariation('wght', day.isToday ? 600 : 500),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox.square(
          dimension: D.weekRingSize,
          child: CustomPaint(painter: _RingPainter(day: day, t: t)),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.day, required this.t});

  final DayRing day;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (size.width - D.weekRingStroke) / 2;
    final centre = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = D.weekRingStroke
        ..color =
            day.isToday ? const Color(0xFF232838) : const Color(0xFF1A1E28),
    );

    final swept = day.progress.clamp(0.0, 1.0) * t;
    if (swept > 0.001) {
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: r),
        // From twelve o'clock, like every other ring the user has seen.
        -math.pi / 2,
        math.pi * 2 * swept,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = D.weekRingStroke
          ..strokeCap = StrokeCap.round
          ..color = day.isToday ? Accent.blue : Accent.blueDim,
      );
    }

    final label = TextPainter(
      text: TextSpan(
        text: '${day.day}',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14.5,
          height: 1,
          color: day.isToday ? Paper.primary : Paper.secondary,
          fontVariations: <FontVariation>[
            FontVariation('wght', day.isToday ? 600 : 500),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    label.paint(canvas, centre - Offset(label.width / 2, label.height / 2));
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.day != day || old.t != t;
}
