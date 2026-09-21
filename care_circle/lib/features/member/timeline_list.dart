import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/store.dart';

class TimelineList extends StatefulWidget {
  const TimelineList({super.key, required this.enter, this.begin = 0, this.onMissed, this.moments});

  final Animation<double> enter;
  final double begin;
  final VoidCallback? onMissed;
  final List<Moment>? moments;

  @override
  State<TimelineList> createState() => _TimelineListState();
}

class _TimelineListState extends State<TimelineList> {
  final Map<Moment, int> _bursts = {};

  @override
  Widget build(BuildContext context) {
    final store = CareStore.instance;
    final moments = widget.moments ?? store.moments;
    final enter = widget.enter;
    final start = widget.begin;
    final length = 1 - start;
    const rowHeight = 72.0;
    const gap = 10.0;
    final total = moments.length * rowHeight + (moments.length - 1) * gap;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: total,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              width: 26,
              height: total,
              child: CustomPaint(
                painter: _RailPainter(
                  enter: enter,
                  from: start,
                  to: start + length * 0.7,
                  tones: [for (final m in moments) m.tone],
                  rowHeight: rowHeight,
                  gap: gap,
                ),
              ),
            ),
            for (final (i, moment) in moments.indexed)
              Positioned(
                left: 32,
                right: 0,
                top: i * (rowHeight + gap),
                height: rowHeight,
                child: Staged(
                  animation: enter,
                  begin: start + length * math.min(0.08 + i * 0.1, 0.6),
                  end: start + length * math.min(0.5 + i * 0.1, 1),
                  offset: const Offset(28, 0),
                  child: _Card(
                    moment: moment,
                    burst: _bursts[moment] ?? 0,
                    onReact: () {
                      store.toggleLike(moment);
                      setState(() => _bursts[moment] = (_bursts[moment] ?? 0) + 1);
                    },
                    onTap: moment.title.startsWith('Metformin') ? widget.onMissed : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.moment, required this.burst, required this.onReact, this.onTap});

  final Moment moment;
  final int burst;
  final VoidCallback onReact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final missed = moment.detail == 'missed' && moment.tone == Hue.coral;
    final taken = moment.detail == 'missed' && !missed;
    final tone = moment.tone;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(14, 0, 10, 0),
      decoration: BoxDecoration(
        color: missed ? const Color(0xFFFFF1EE) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: missed ? const Color(0xFFF9CFC9) : const Color(0xFFF1ECF4)),
        boxShadow: missed
            ? [BoxShadow(color: Hue.coral.withValues(alpha: 0.12), blurRadius: 18, offset: const Offset(0, 8))]
            : softShadow(0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: tone.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
            alignment: Alignment.center,
            child: GlyphIcon(moment.glyph, size: 21, color: tone, stroke: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: moment.time,
                        style: jakarta(11.5, 700, color: tone),
                      ),
                      if (moment.detail != null)
                        TextSpan(
                          text: taken ? '  ·  Taken' : '  ·  Missed',
                          style: jakarta(11.5, 800, color: taken ? Hue.sage : Hue.coral),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(moment.title, style: jakarta(14.5, 650), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (moment.title == 'Breakfast logged')
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: GlyphIcon(Glyph.check, size: 16, color: Hue.sage, stroke: 2.4),
            ),
          ClipOval(child: Portrait('assets/people/${moment.by}.webp', size: 34)),
          const SizedBox(width: 4),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onReact,
            child: SizedBox(
              width: 34,
              height: 44,
              child: Center(
                child: HeartBurst(
                  trigger: burst,
                  color: moment.thumb ? Hue.iris : Hue.coral,
                  child: moment.thumb
                      ? GlyphIcon(
                          Glyph.thumb,
                          size: 19,
                          color: moment.liked ? Hue.iris : Hue.inkMute,
                          fill: moment.liked ? Hue.iris.withValues(alpha: 0.2) : null,
                          stroke: 1.8,
                        )
                      : GlyphIcon(
                          Glyph.heart,
                          size: 19,
                          color: moment.liked ? Hue.coral : Hue.inkMute,
                          fill: moment.liked ? Hue.coral : null,
                          stroke: 1.8,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return card;
    return Pressable(onTap: onTap, scale: 0.97, child: card);
  }
}

class _RailPainter extends CustomPainter {
  _RailPainter({
    required this.enter,
    required this.from,
    required this.to,
    required this.tones,
    required this.rowHeight,
    required this.gap,
  }) : super(repaint: enter);

  final Animation<double> enter;
  final double from;
  final double to;
  final List<Color> tones;
  final double rowHeight;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final draw = span(enter.value, from, to, Curves.easeInOutCubic);
    final x = size.width / 2;
    final first = rowHeight / 2;
    final last = (tones.length - 1) * (rowHeight + gap) + rowHeight / 2;
    final end = first + (last - first) * draw;
    canvas.drawLine(
      Offset(x, first),
      Offset(x, math.max(first, end)),
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            for (final t in [...tones, tones.last]) t.withValues(alpha: 0.35),
          ],
        ).createShader(Rect.fromLTRB(0, first, size.width, last)),
    );
    for (var i = 0; i < tones.length; i++) {
      final y = i * (rowHeight + gap) + rowHeight / 2;
      if (y > end + 0.5) break;
      canvas.drawCircle(Offset(x, y), 7.5, Paint()..color = tones[i].withValues(alpha: 0.18));
      canvas.drawCircle(Offset(x, y), 4.5, Paint()..color = tones[i]);
      canvas.drawCircle(
        Offset(x, y),
        4.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_RailPainter oldDelegate) => oldDelegate.tones.toString() != tones.toString();
}
