import 'package:flutter/material.dart';

import '../core/data.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/bars.dart';
import '../widgets/kit.dart';

/// The public, at-a-glance column. Shown alone on a phone and as the left
/// pane of the open spread; never names a medication.
class TodayView extends StatelessWidget {
  const TodayView({super.key, required this.spanned, required this.padding});

  final bool spanned;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('today'),
      padding: padding,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Reveal(child: _TopBar()),
          const SizedBox(height: 14),
          Reveal(
            delay: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tue, Oct 27 · Updated ${Demo.updated}', style: Typo.date),
                const SizedBox(height: 2),
                Text('Today', style: Typo.title),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Reveal(delay: 120, child: HeroCard()),
          const SizedBox(height: 12),
          const _Metrics(),
          const SizedBox(height: 12),
          Reveal(delay: 440, child: DosesCard(spanned: spanned)),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const HeloraMark(),
        const SizedBox(width: 8),
        Text('Helora', style: Typo.brand),
        const Spacer(),
        Semantics(
          button: true,
          label: 'Notifications, 1 new',
          child: Material(
            color: Tone.card,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {},
              child: SizedBox.square(
                dimension: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const GlyphIcon(Glyph.bell, size: 20),
                    Positioned(
                      top: 11,
                      right: 12,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(color: Tone.red, shape: BoxShape.circle, border: Border.all(color: Tone.card, width: 2)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final week = Demo.rhr(7);
    final days = [for (var i = 0; i < 7; i++) Demo.dayOf(i, 7)];
    return Panel(
      color: Tone.hero,
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHead(
            accent: Accent.red,
            glyph: Glyph.heart,
            title: 'Resting heart rate',
            color: Tone.card,
            trailing: Text('Apple Watch · ${Demo.updated}', style: Typo.meta.copyWith(color: Tone.heroSub)),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 122,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        CountUp(value: Demo.restingHr.toDouble(), style: Typo.hero, delay: 200),
                        const SizedBox(width: 4),
                        Text('bpm', style: Typo.heroUnit),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Tag('−${Demo.restingAvg - Demo.restingHr}', background: Tone.heroChip, color: Tone.card),
                        const SizedBox(width: 6),
                        Flexible(child: Text('vs 30-day avg', style: Typo.context.copyWith(color: Tone.heroSub), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Range ${Demo.rangeLow}–${Demo.rangeHigh}', style: Typo.context.copyWith(color: Tone.heroSub)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Semantics(
                      label: 'Last 7 days resting heart rate: ${week.join(', ')} bpm',
                      child: SizedBox(
                        height: 84,
                        child: Grow(
                          trigger: 'hero',
                          delay: 260,
                          builder: (context, t) => CustomPaint(
                            size: Size.infinite,
                            painter: PillBarsPainter(
                              values: week,
                              min: 55,
                              max: 70,
                              gap: 7,
                              maxBar: 40,
                              track: Tone.heroTrack,
                              progress: t,
                              rangeLow: Demo.rangeLow.toDouble(),
                              rangeHigh: Demo.rangeHigh.toDouble(),
                              rangeColor: Tone.heroRange.withValues(alpha: 0.6),
                              fill: (i, v) => v > Demo.rangeHigh ? Tone.red : (i == week.length - 1 ? Tone.card : Tone.heroBar),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ExcludeSemantics(
                      child: Row(
                        children: [
                          for (var i = 0; i < 7; i++)
                            Expanded(
                              child: Text(
                                Demo.weekday(days[i]),
                                textAlign: TextAlign.center,
                                style: i == 6 ? Typo.axisNow.copyWith(color: Tone.card) : Typo.axis.copyWith(color: Tone.heroSub),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics();

  @override
  Widget build(BuildContext context) {
    final sleepPct = (Demo.sleepMinutes / Demo.sleepNeed * 100).round();
    final cards = <Widget>[
      MetricCard(
        accent: Accent.red,
        glyph: Glyph.pulse,
        title: 'HRV',
        value: _Num(Demo.hrv.toDouble(), unit: ' ms'),
        tag: '+${Demo.hrv - Demo.hrvAvg}',
        note: 'vs 30-day avg',
      ),
      MetricCard(
        accent: Accent.purple,
        glyph: Glyph.moon,
        title: 'Sleep',
        value: Text.rich(
          TextSpan(children: [
            TextSpan(text: '${Demo.sleepMinutes ~/ 60}'),
            TextSpan(text: 'h ', style: Typo.unit),
            TextSpan(text: '${Demo.sleepMinutes % 60}'),
            TextSpan(text: 'm', style: Typo.unit),
          ]),
          style: Typo.value,
        ),
        tag: '$sleepPct%',
        note: 'of ${Demo.hm(Demo.sleepNeed)} need',
      ),
      MetricCard(
        accent: Accent.orange,
        glyph: Glyph.steps,
        title: 'Steps',
        value: _Num(Demo.steps.toDouble(), unit: '/${Demo.thousands(Demo.stepGoal)}', format: (v) => Demo.thousands(v.round())),
        progress: Demo.steps / Demo.stepGoal,
        note: '${Demo.thousands(Demo.stepGoal - Demo.steps)} to go · iPhone',
      ),
      MetricCard(
        accent: Accent.blue,
        glyph: Glyph.wind,
        title: 'Breathing',
        value: _Num(Demo.respiratory, unit: ' /min', format: (v) => v.toStringAsFixed(1)),
        tag: '+0.2',
        note: 'overnight',
      ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final cols = box.maxWidth >= 600 ? 4 : 2;
        final rows = <Widget>[];
        for (var r = 0; r < cards.length; r += cols) {
          if (r > 0) rows.add(const SizedBox(height: 12));
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var c = 0; c < cols; c++) ...[
                    if (c > 0) const SizedBox(width: 12),
                    Expanded(child: Reveal(delay: 200 + (r + c) * 60, child: cards[r + c])),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}

class _Num extends StatelessWidget {
  const _Num(this.value, {required this.unit, this.format});

  final double value;
  final String unit;
  final String Function(double v)? format;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        CountUp(value: value, style: Typo.value, format: format, delay: 260),
        Flexible(child: Text(unit, style: Typo.unit, maxLines: 1, overflow: TextOverflow.clip)),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.accent, required this.glyph, required this.title, required this.value, required this.note, this.tag, this.progress});

  final Accent accent;
  final Glyph glyph;
  final String title;
  final Widget value;
  final String note;
  final String? tag;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHead(accent: accent, glyph: glyph, title: title),
          const DashRule(vertical: 11),
          value,
          const SizedBox(height: 6),
          if (progress != null) ...[
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1300),
              curve: const Interval(0.25, 1, curve: swift),
              builder: (context, p, _) => _Progress(p),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              if (tag != null) ...[Tag(tag!), const SizedBox(width: 6)],
              Expanded(child: Text(note, style: Typo.context, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress(this.value);

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(color: Tone.track, borderRadius: BorderRadius.circular(999)),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(colors: [Accent.orange.hi, Accent.orange.lo]),
          ),
        ),
      ),
    );
  }
}

class DosesCard extends StatelessWidget {
  const DosesCard({super.key, required this.spanned});

  final bool spanned;

  @override
  Widget build(BuildContext context) {
    final taken = Demo.meds.where((m) => m.taken != null).length;
    final next = Demo.meds.firstWhere((m) => m.taken == null);
    return Panel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const IconBadge(Accent.ink, Glyph.pill),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${Demo.meds.length} doses today · next at ${next.time}', style: Typo.row, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  spanned ? '$taken of ${Demo.meds.length} taken · details in Medications' : '$taken of ${Demo.meds.length} taken',
                  style: Typo.meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!spanned) ...[const SizedBox(width: 8), const Tag('Private', glyph: Glyph.lock, color: Tone.slate)],
        ],
      ),
    );
  }
}
