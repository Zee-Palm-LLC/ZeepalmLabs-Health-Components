import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/data.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/bars.dart';
import '../widgets/kit.dart';
import 'meds_card.dart';

/// The private, deeper pane: shown beside Today when the phone is open, or as
/// its own tab on a single screen.
class TrendsView extends StatefulWidget {
  const TrendsView({super.key, required this.padding, this.showMeds = true});

  final EdgeInsets padding;
  final bool showMeds;

  @override
  State<TrendsView> createState() => TrendsViewState();
}

class TrendsViewState extends State<TrendsView> {
  int days = 30;
  late int selected = _defaultFor(days);

  static int _defaultFor(int days) => Demo.rhr(days).length - 7;

  void setRange(int value) {
    if (value == days) return;
    HapticFeedback.selectionClick();
    setState(() {
      days = value;
      selected = _defaultFor(value);
    });
  }

  void select(int index) {
    if (index == selected) return;
    HapticFeedback.selectionClick();
    setState(() => selected = index);
  }

  @override
  Widget build(BuildContext context) {
    final values = Demo.rhr(days);
    final first = Demo.dayOf(0, values.length);
    return SingleChildScrollView(
      key: const PageStorageKey('trends'),
      padding: widget.padding,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${Demo.label(first)} – ${Demo.label(Demo.today)}', style: Typo.date),
                      const SizedBox(height: 2),
                      Text('Trends', style: Typo.title),
                    ],
                  ),
                ),
                RangeSwitch(value: days, onChanged: setRange),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Reveal(delay: 80, child: RhrCard(values: values, selected: selected, onSelect: select)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) {
              const sleep = Reveal(delay: 180, child: SleepCard());
              const hrv = Reveal(delay: 240, child: HrvCard());
              if (box.maxWidth < 340) return const Column(children: [sleep, SizedBox(height: 12), hrv]);
              return const IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [Expanded(child: sleep), SizedBox(width: 12), Expanded(child: hrv)],
                ),
              );
            },
          ),
          if (widget.showMeds) ...[const SizedBox(height: 12), const Reveal(delay: 320, child: MedsCard(veiled: false))],
        ],
      ),
    );
  }
}

class RangeSwitch extends StatelessWidget {
  const RangeSwitch({super.key, required this.value, required this.onChanged});

  static const options = [7, 30, 90];

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final index = options.indexOf(value);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Tone.card, borderRadius: BorderRadius.circular(999)),
      child: SizedBox(
        width: 3 * 52,
        height: 34,
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: Alignment(-1 + index.toDouble(), 0),
              duration: const Duration(milliseconds: 420),
              curve: settle,
              child: Container(width: 52, height: 34, decoration: BoxDecoration(color: Tone.ink, borderRadius: BorderRadius.circular(999))),
            ),
            Row(
              children: [
                for (final o in options)
                  Semantics(
                    button: true,
                    selected: o == value,
                    label: '$o days',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(o),
                      child: SizedBox(
                        width: 52,
                        height: 34,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 260),
                            style: jakarta(13, 700, color: o == value ? Tone.card : Tone.sub),
                            child: Text('${o}D'),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RhrCard extends StatelessWidget {
  const RhrCard({super.key, required this.values, required this.selected, required this.onSelect});

  final List<int> values;
  final int selected;
  final ValueChanged<int> onSelect;

  static const chartHeight = 104.0;
  static const tipRoom = 34.0;

  @override
  Widget build(BuildContext context) {
    final n = values.length;
    final above = values.where((v) => v > Demo.rangeHigh).length;
    final gap = n > 40 ? 2.0 : (n > 10 ? 5.0 : 10.0);
    final day = Demo.dayOf(selected, n);
    final note = Demo.notes[Demo.label(day)];
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHead(
            accent: Accent.red,
            glyph: Glyph.heart,
            title: 'Resting heart rate',
            trailing: Text.rich(
              TextSpan(children: [TextSpan(text: '${Demo.average(values)}'), TextSpan(text: ' bpm avg', style: Typo.unit)]),
              style: jakarta(20, 700, tracking: -0.4),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              LegendKey(marker: SizedBox(width: 14, height: 8, child: CustomPaint(painter: DashPainter(Tone.red, dash: 3, gap: 2))), label: 'Your range ${Demo.rangeLow}–${Demo.rangeHigh}'),
              LegendKey(marker: const Dot(Tone.red), label: 'Above range · $above ${above == 1 ? 'day' : 'days'}'),
              const LegendKey(marker: Dot(Tone.ink), label: 'Today ${Demo.restingHr}'),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, box) {
              final width = box.maxWidth;
              final cx = PillBarsPainter.centerOf(selected, width, n, gap);
              void pick(Offset local) {
                final pitch = PillBarsPainter.step(width, n, gap);
                final w = PillBarsPainter.barWidth(width, n, gap);
                onSelect(((local.dx - w / 2) / pitch).round().clamp(0, n - 1));
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => pick(d.localPosition),
                onHorizontalDragStart: (d) => pick(d.localPosition),
                onHorizontalDragUpdate: (d) => pick(d.localPosition),
                child: SizedBox(
                  height: tipRoom + chartHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: tipRoom,
                        height: chartHeight,
                        child: Semantics(
                          label: 'Resting heart rate, last $n days. $above days above your range. Today ${Demo.restingHr} bpm.',
                          child: Grow(
                            trigger: n,
                            builder: (context, t) => CustomPaint(
                              painter: PillBarsPainter(
                                values: values,
                                min: 55,
                                max: 70,
                                gap: gap,
                                track: Tone.track,
                                progress: t,
                                rangeLow: Demo.rangeLow.toDouble(),
                                rangeHigh: Demo.rangeHigh.toDouble(),
                                rangeColor: Tone.red.withValues(alpha: 0.55),
                                selected: selected,
                                selectedColor: Tone.ink,
                                fill: (i, v) => v > Demo.rangeHigh ? Tone.red : (i == n - 1 ? Tone.ink : Tone.redSoft),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        bottom: chartHeight + 4,
                        child: CustomSingleChildLayout(
                          delegate: _TipLayout(cx),
                          child: _Tip(key: ValueKey('$n-$selected'), text: '${Demo.label(day)} · ${values[selected]} bpm', note: note),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 160),
                        curve: swift,
                        left: cx - 5,
                        top: tipRoom - 10,
                        child: CustomPaint(size: const Size(10, 5), painter: _CaretPainter()),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final f in [0.0, 1 / 3, 2 / 3])
                  Text(Demo.label(Demo.dayOf(((n - 1) * f).round(), n)), style: Typo.axis),
                Text(Demo.label(Demo.today), style: Typo.axisNow),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({super.key, required this.text, this.note});

  final String text;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: swift,
      builder: (context, t, child) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 4 * (1 - t)), child: child)),
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: Tone.ink, borderRadius: BorderRadius.circular(8)),
        child: Align(
          widthFactor: 1,
          child: Text.rich(
            TextSpan(children: [TextSpan(text: text, style: Typo.tipStrong), if (note != null) TextSpan(text: ' · $note')]),
            style: Typo.tip,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

class _TipLayout extends SingleChildLayoutDelegate {
  _TipLayout(this.center);

  final double center;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size child) {
    final x = (center - child.width / 2).clamp(0.0, (size.width - child.width).clamp(0.0, double.infinity));
    return Offset(x, size.height - child.height);
  }

  @override
  bool shouldRelayout(_TipLayout old) => old.center != center;
}

class _CaretPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(p, Paint()..color = Tone.ink);
  }

  @override
  bool shouldRepaint(_CaretPainter old) => false;
}

class SleepCard extends StatelessWidget {
  const SleepCard({super.key});

  static const colors = [Tone.deep, Tone.rem, Tone.light, Tone.awake];
  static const names = ['Deep', 'REM', 'Light', 'Awake'];

  @override
  Widget build(BuildContext context) {
    final avg = [for (var s = 0; s < 4; s++) (Demo.nights.map((n) => n[s]).reduce((a, b) => a + b) / Demo.nights.length).round()];
    final asleep = (Demo.nights.map((n) => n[0] + n[1] + n[2]).reduce((a, b) => a + b) / Demo.nights.length).round();
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHead(accent: Accent.purple, glyph: Glyph.moon, title: 'Sleep', trailing: Text('avg ${Demo.hm(asleep)}', style: Typo.meta)),
          const SizedBox(height: 12),
          Semantics(
            label: 'Sleep stages, last 7 nights. Averages: ${[for (var s = 0; s < 4; s++) '${names[s]} ${Demo.hm(avg[s])}'].join(', ')}.',
            child: SizedBox(
              height: 72,
              child: Grow(
                trigger: 'sleep',
                delay: 200,
                builder: (context, t) => CustomPaint(size: Size.infinite, painter: _StackPainter(t)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          ExcludeSemantics(
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(child: Text(Demo.weekday(Demo.dayOf(i, 7)), textAlign: TextAlign.center, style: i == 6 ? Typo.axisNow : Typo.axis)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [for (var s = 0; s < 4; s++) LegendKey(marker: Dot(colors[s]), label: names[s], value: Demo.hm(avg[s]))],
          ),
        ],
      ),
    );
  }
}

class _StackPainter extends CustomPainter {
  _StackPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 7, gap = 2.0;
    final colW = size.width / n;
    final w = (colW * 0.56).clamp(8.0, 22.0);
    final maxTotal = Demo.nights.map((x) => x.reduce((a, b) => a + b)).reduce((a, b) => a > b ? a : b);
    final scale = (size.height - gap * 3) / maxTotal;
    for (var i = 0; i < n; i++) {
      final grow = span(progress, i * 0.07, i * 0.07 + 0.55, swift);
      final x = colW * i + (colW - w) / 2;
      var y = size.height;
      for (var s = 0; s < 4; s++) {
        final h = Demo.nights[i][s] * scale * grow;
        if (h <= 0.2) continue;
        final r = Rect.fromLTWH(x, y - h, w, h);
        canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular((h / 2).clamp(0, 5))), Paint()..color = SleepCard.colors[s]);
        y -= h + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_StackPainter old) => old.progress != progress;
}

class HrvCard extends StatelessWidget {
  const HrvCard({super.key});

  static const high = 46;

  static Color colorOf(int v) => v < Demo.hrvLow ? Tone.awake : (v >= high ? Tone.coral : Tone.redSoft);

  @override
  Widget build(BuildContext context) {
    final below = <String>[
      for (var i = 0; i < Demo.hrv30.length; i++)
        if (Demo.hrv30[i] < Demo.hrvLow) Demo.label(Demo.dayOf(i, Demo.hrv30.length)),
    ];
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHead(accent: Accent.red, glyph: Glyph.pulse, title: 'HRV', trailing: Text('avg ${Demo.hrvAvg} ms', style: Typo.meta)),
          const SizedBox(height: 12),
          Semantics(
            label: 'HRV, one dot per day for 30 days. Below range on ${below.join(' and ')}. Today ${Demo.hrv} ms.',
            child: AspectRatio(
              aspectRatio: 10 / 3.15,
              child: Grow(
                trigger: 'hrv',
                delay: 260,
                duration: 1100,
                builder: (context, t) => CustomPaint(size: Size.infinite, painter: _DotsPainter(t, 5, 10)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              const LegendKey(marker: Dot(Tone.coral), label: '$high+ ms'),
              LegendKey(marker: const Dot(Tone.redSoft), label: '${Demo.hrvLow}–${high - 1}'),
              LegendKey(marker: const Dot(Tone.awake), label: 'Below · ${below.join(', ')}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter(this.progress, this.gap, this.cols);

  final double progress;
  final double gap;
  final int cols;

  @override
  void paint(Canvas canvas, Size size) {
    final n = Demo.hrv30.length;
    final rows = (n / cols).ceil();
    final d = [(size.width - gap * (cols - 1)) / cols, (size.height - gap * (rows - 1)) / rows].reduce((a, b) => a < b ? a : b);
    for (var i = 0; i < n; i++) {
      final s = span(progress, i * 0.018, i * 0.018 + 0.42, settle);
      if (s <= 0) continue;
      final c = Offset((i % cols) * (d + gap) + d / 2, (i ~/ cols) * (d + gap) + d / 2);
      canvas.drawCircle(c, d / 2 * s, Paint()..color = HrvCard.colorOf(Demo.hrv30[i]));
      if (i == n - 1) {
        canvas.drawCircle(
          c,
          d / 2 * s - 1,
          Paint()
            ..color = Tone.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.progress != progress;
}
