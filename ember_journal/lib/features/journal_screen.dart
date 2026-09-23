import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../data/journal.dart';
import '../widgets/chrome.dart';
import '../widgets/mood_faces.dart';
import '../widgets/panel.dart';
import '../widgets/week_strip.dart';

const journalListTop = 241.0;
const entryLeft = 17.0;
const entryWidth = 359.0;

class JournalScreen extends StatefulWidget {
  const JournalScreen({
    super.key,
    required this.enter,
    required this.seconds,
    required this.store,
    required this.landing,
  });

  final Animation<double> enter;
  final double seconds;
  final JournalStore store;
  final Animation<double> landing;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = CanvasScope.of(context);
    final top = scope.top;
    final listTop = top + journalListTop;
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final entries = widget.store.entries;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: entryLeft,
              right: 0,
              top: listTop,
              bottom: 0,
              child: Staged(
                animation: widget.enter,
                begin: 0.18,
                end: 0.72,
                offset: const Offset(0, 40),
                child: ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0x00FFFFFF)],
                    stops: [0.0, 0.035, 0.72, 0.88],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: ListView.separated(
                    controller: _scroll,
                    padding: EdgeInsets.only(top: 4, bottom: scope.height - scope.floor + 96),
                    physics: const BouncingScrollPhysics(),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final card = EntryCard(
                        entry: entries[i],
                        seconds: widget.seconds,
                        fresh: widget.store.highlighted == i,
                      );
                      if (widget.store.highlighted == i) {
                        return AnimatedBuilder(
                          animation: widget.landing,
                          builder: (context, child) {
                            final t = widget.landing.value;
                            return ClipRect(
                              child: Align(
                                alignment: Alignment.topCenter,
                                heightFactor: Curves.easeOutCubic.transform(t.clamp(0.0, 1.0)),
                                child: Opacity(
                                  opacity: span(t, 0.45, 1.0),
                                  child: Transform.scale(
                                    scale: lerp(0.94, 1, span(t, 0.4, 1.0, settle)),
                                    child: child,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: card,
                        );
                      }
                      return Staged(
                        animation: widget.enter,
                        begin: 0.22 + i * 0.07,
                        end: 0.78 + i * 0.07,
                        offset: const Offset(0, 46),
                        scale: 0.96,
                        rotateX: -0.2,
                        child: card,
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: top + 6,
              child: Staged(
                animation: widget.enter,
                begin: 0,
                end: 0.40,
                offset: const Offset(-16, 0),
                child: Text('Journal', style: largeTitle),
              ),
            ),
            Positioned(
              right: 19,
              top: top + 7,
              child: Staged(
                animation: widget.enter,
                begin: 0.04,
                end: 0.44,
                offset: const Offset(14, 0),
                child: Row(
                  children: [
                    CircleButton(glyph: Glyph.search, onTap: () {}, icon: 19),
                    const SizedBox(width: 9),
                    CircleButton(glyph: Glyph.calendar, onTap: () {}, icon: 19, stroke: 1.6),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              top: top + 77,
              height: 72,
              child: Staged(
                animation: widget.enter,
                begin: 0.08,
                end: 0.52,
                offset: const Offset(0, 18),
                child: WeekStrip(
                  days: const [15, 16, 17, 18, 19, 20, 21],
                  selected: widget.store.selectedDay,
                  marked: const {15, 16, 17, 18, 19},
                  seconds: widget.seconds,
                  onSelect: widget.store.selectDay,
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: top + 181,
              child: Staged(
                animation: widget.enter,
                begin: 0.14,
                end: 0.58,
                offset: const Offset(-10, 8),
                child: Text(widget.store.dayLabel, style: font(15.3, 600, shadows: lift)),
              ),
            ),
            Positioned(
              left: 18,
              top: top + 208,
              child: Staged(
                animation: widget.enter,
                begin: 0.18,
                end: 0.62,
                offset: const Offset(-8, 6),
                child: Text(
                  widget.store.summary,
                  style: font(13.6, 400, color: Ember.ash.withValues(alpha: 0.72)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class EntryCard extends StatelessWidget {
  const EntryCard({
    super.key,
    required this.entry,
    required this.seconds,
    this.fresh = false,
    this.ghost = false,
  });

  final Entry entry;
  final double seconds;
  final bool fresh;
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    final glow = fresh ? 0.35 + 0.35 * math.sin(seconds * 2.6) : 0.0;
    return SizedBox(
      width: entryWidth,
      child: Panel(
        radius: 24,
        opacity: ghost ? 0.7 : 0.56,
        glow: glow,
        glowColor: entry.tone.tint,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(21, 24, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: entry.tone.tint),
                    ),
                    const SizedBox(width: 9),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: OverflowBox(
                        maxWidth: 46,
                        maxHeight: 46,
                        child: MoodFace(index: entry.mood, selection: 0, seconds: seconds, size: 21),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(entry.tone.name, style: font(13.4, 500, color: Ember.cream.withValues(alpha: 0.94))),
                    const Spacer(),
                    Text(entry.time, style: meta(0.62)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(entry.title, style: cardTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Text(entry.body, style: body(0.72), maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
