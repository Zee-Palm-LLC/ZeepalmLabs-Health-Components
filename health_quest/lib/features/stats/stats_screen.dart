import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../core/audio/sfx.dart';
import '../../core/design.dart';
import '../../core/motion/entrance.dart';
import '../../core/motion/idle.dart';
import '../../core/motion/pressable.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/game_state.dart';
import '../../data/progress.dart';
import '../../data/quests.dart';
import '../../widgets/hud.dart';
import '../../widgets/hud_kit.dart';
import '../../widgets/painters/polygon.dart';
import '../../widgets/painters/quest_icons.dart';
import '../../widgets/painters/stat_icons.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: D.pageEntrance,
  )..forward();

  Period _period = Period.week;
  int? _selected;

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IdleBuilder(
      builder: (BuildContext context, double idle, Widget? _) =>
          AnimatedBuilder(
            animation: _in,
            builder: (BuildContext context, Widget? _) {
              final t = _in.value;
              final history = XpHistory.of(_period);
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  D.pageGutter,
                  8,
                  D.pageGutter,
                  12,
                ),
                children: <Widget>[
                  Rise(
                    t: D.headerIn.transform(t),
                    distance: 16,
                    child: ListenableBuilder(
                      listenable: GameState.instance,
                      builder: (BuildContext context, Widget? _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const HudHeading(
                            title: 'CHARACTER STATS',
                            accent: Quests.blue,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Level ${GameState.instance.level}  ·  '
                            '${StatStanding.power} power across four stats',
                            style: T.sectionMeta,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Rise(
                    t: D.scoreIn.transform(t),
                    distance: 24,
                    scaleFrom: 0.97,
                    child: _PowerPanel(t: D.scoreIn.transform(t), idle: idle),
                  ),
                  const SizedBox(height: 20),
                  Rise(
                    t: D.sectionIn.transform(t),
                    distance: 12,
                    child: const HudHeading(
                      title: 'ATTRIBUTES',
                      accent: Quests.purple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < StatStanding.all.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: 8),
                    Builder(
                      builder: (BuildContext context) {
                        final p = D.stagger(
                          t,
                          D.rowsStart,
                          i,
                          D.rowStagger,
                          D.rowSpan,
                        );
                        return Slide(
                          t: D.outExpo.transform(p),
                          child: _AttributeRow(
                            standing: StatStanding.all[i],
                            t: p,
                            idle: idle,
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 22),
                  Rise(
                    t: D.navIn.transform(t),
                    distance: 14,
                    child: Row(
                      children: <Widget>[
                        const Expanded(
                          child: HudHeading(
                            title: 'XP EARNED',
                            accent: Quests.gold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 148,
                          child: HudSegmented<Period>(
                            options: const <Period, String>{
                              Period.week: 'WEEK',
                              Period.month: 'MONTH',
                            },
                            value: _period,
                            tone: Quests.gold,
                            onChanged: (Period p) => setState(() {
                              _period = p;
                              _selected = null;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Rise(
                    t: D.navIn.transform(t),
                    distance: 20,
                    child: _XpChart(
                      history: history,
                      selected: _selected ?? history.values.length - 1,
                      t: D.emphasized.transform(
                        ((t - 0.55) / 0.45).clamp(0.0, 1.0),
                      ),
                      onSelect: (int i) => setState(() => _selected = i),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Rise(
                    t: D.navIn.transform(t),
                    distance: 12,
                    child: const HudHeading(
                      title: 'PERSONAL RECORDS',
                      accent: Quests.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var r = 0; r < PersonalRecord.all.length; r += 2)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Rise(
                        t: D.navIn.transform(t),
                        distance: 18,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: _RecordTile(record: PersonalRecord.all[r]),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _RecordTile(
                                record: PersonalRecord.all[r + 1],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
    );
  }
}

class _PowerPanel extends StatelessWidget {
  const _PowerPanel({required this.t, required this.idle});

  final double t;
  final double idle;

  @override
  Widget build(BuildContext context) {
    final grow = t.clamp(0.0, 1.0);
    final standings = StatStanding.all;
    return HudPanel(
      cut: 18,
      accent: Quests.blue,
      edge: Quests.blue.withValues(alpha: 0.22),
      rail: true,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('POWER PROFILE', style: T.cardLabel),
              const Spacer(),
              HudChip(
                label: 'POWER ${(StatStanding.power * grow).round()}',
                tone: Quests.blueBright,
              ),
            ],
          ),
          SizedBox(
            height: 246,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                CustomPaint(
                  size: const Size(148, 148),
                  painter: _RadarPainter(
                    values: <double>[
                      for (final s in standings)
                        s.level / StatStanding.cap * grow,
                    ],
                    tones: <Color>[for (final s in standings) s.stat.tone.core],
                    pulse: 0.5 + 0.5 * math.sin(idle * 1.6),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: _RadarLabel(standing: standings[0], idle: idle),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _RadarLabel(standing: standings[1], idle: idle),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _RadarLabel(standing: standings[2], idle: idle),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _RadarLabel(standing: standings[3], idle: idle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarLabel extends StatelessWidget {
  const _RadarLabel({required this.standing, required this.idle});

  final StatStanding standing;
  final double idle;

  @override
  Widget build(BuildContext context) {
    final s = standing.stat;
    return SizedBox(
      width: 68,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          StatIcon(
            glyph: s.glyph,
            tone: s.tone,
            size: 18,
            pulse: (idle * 0.5) % 1.0,
          ),
          const SizedBox(height: 2),
          Text(
            s.label,
            maxLines: 1,
            style: T.statLabel.copyWith(fontSize: 10, color: s.tone.tip),
          ),
          Text(
            'LV ${standing.level}',
            style: T.statLevel.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({
    required this.values,
    required this.tones,
    required this.pulse,
  });

  final List<double> values;
  final List<Color> tones;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final n = values.length;
    Offset at(int i, double f) {
      final a = -math.pi / 2 + i * 2 * math.pi / n;
      return c + Offset(math.cos(a), math.sin(a)) * r * f;
    }

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x1FFFFFFF);
    for (var band = 1; band <= 4; band++) {
      final path = Path()..moveTo(at(0, band / 4).dx, at(0, band / 4).dy);
      for (var i = 1; i < n; i++) {
        path.lineTo(at(i, band / 4).dx, at(i, band / 4).dy);
      }
      canvas.drawPath(path..close(), grid);
    }
    for (var i = 0; i < n; i++) {
      canvas.drawLine(c, at(i, 1), grid);
    }

    final shape = Path();
    for (var i = 0; i < n; i++) {
      final p = at(i, values[i].clamp(0.0, 1.0));
      i == 0 ? shape.moveTo(p.dx, p.dy) : shape.lineTo(p.dx, p.dy);
    }
    shape.close();
    final bounds = Offset.zero & size;
    canvas.drawPath(
      shape,
      Paint()
        ..color = Quests.purple.withValues(alpha: 0.35 + 0.2 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawPath(
      shape,
      Paint()
        ..shader = SweepGradient(
          colors: <Color>[
            ...tones,
            tones.first,
          ].map((Color x) => x.withValues(alpha: 0.42)).toList(),
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(bounds),
    );
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xE6FFFFFF),
    );
    for (var i = 0; i < n; i++) {
      final p = at(i, values[i].clamp(0.0, 1.0));
      canvas.drawCircle(
        p,
        6 + 2 * pulse,
        Paint()
          ..color = tones[i].withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(p, 4, Paint()..color = tones[i]);
      canvas.drawCircle(p, 1.6, Paint()..color = const Color(0xFFFFFFFF));
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.pulse != pulse || !_same(old.values, values);

  static bool _same(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _AttributeRow extends StatelessWidget {
  const _AttributeRow({
    required this.standing,
    required this.t,
    required this.idle,
  });

  final StatStanding standing;
  final double t;
  final double idle;

  @override
  Widget build(BuildContext context) {
    final s = standing.stat;
    final fill = D.emphasized.transform(t.clamp(0.0, 1.0));
    return HudPanel(
      cut: 14,
      accent: s.tone.core,
      accentStrength: 0.8,
      edge: s.tone.core.withValues(alpha: 0.2),
      rail: true,
      gradient: LinearGradient(
        colors: <Color>[
          s.tone.core.withValues(alpha: 0.10),
          s.tone.core.withValues(alpha: 0),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 66,
        child: Row(
          children: <Widget>[
            PolygonPane(
              size: const Size(40, 45),
              sides: 6,
              cornerRadius: 5,
              edgeWidth: 1.6,
              edge: s.tone.core.withValues(alpha: 0.85),
              glow: s.tone.glow,
              glowStrength: 0.4,
              fill: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  s.tone.core.withValues(alpha: 0.25),
                  const Color(0xCC080B16),
                ],
              ),
              child: StatIcon(
                glyph: s.glyph,
                tone: s.tone,
                size: 21,
                pulse: (idle * 0.5) % 1.0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(s.label, style: T.statLabel),
                      const SizedBox(width: 8),
                      Text(
                        'LV ${standing.level}',
                        style: T.questPercent.copyWith(color: s.tone.tip),
                      ),
                      const Spacer(),
                      Text(
                        '+${grouped(standing.weekGain)} XP',
                        style: T.questPercent.copyWith(
                          color: Ink2.muted,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SegmentedMeter(
                          value: standing.progress * fill,
                          color: s.tone.core,
                          height: 9,
                          segments: 16,
                          shimmer: idle,
                        ),
                      ),
                      const SizedBox(width: 9),
                      SizedBox(
                        width: 34,
                        child: Text(
                          '${(standing.progress * 100 * fill).round()}%',
                          textAlign: TextAlign.right,
                          style: T.questPercent.copyWith(color: s.tone.core),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _XpChart extends StatelessWidget {
  const _XpChart({
    required this.history,
    required this.selected,
    required this.t,
    required this.onSelect,
  });

  final XpHistory history;
  final int selected;
  final double t;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final labels = history.labels(DateTime.now());
    final best = history.best;
    final perLabel = history.period == Period.week ? 'DAILY AVG' : 'WEEKLY AVG';
    return HudPanel(
      cut: 16,
      accent: Quests.gold,
      edge: Quests.gold.withValues(alpha: 0.2),
      rail: true,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _Figure(label: 'TOTAL', value: grouped(history.total)),
              _Figure(label: perLabel, value: grouped(history.average)),
              _Figure(label: 'BEST', value: grouped(best)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 170,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (var i = 0; i < history.values.length; i++)
                  Expanded(
                    child: Pressable(
                      sound: i == selected ? null : Sfx.tick,
                      haptic: false,
                      pressedScale: 0.94,
                      onTap: () {
                        Haptics.buzz(Buzz.selection);
                        onSelect(i);
                      },
                      child: _Bar(
                        key: ValueKey<String>('${history.period}-$i'),
                        value: history.values[i],
                        fraction: history.values[i] / best,
                        label: labels[i],
                        selected: i == selected,
                        t: t,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, maxLines: 1, style: T.rewardLabel.copyWith(fontSize: 10)),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text('$value XP', style: T.rewardValue.copyWith(fontSize: 17)),
        ),
      ],
    ),
  );
}

class _Bar extends StatelessWidget {
  const _Bar({
    super.key,
    required this.value,
    required this.fraction,
    required this.label,
    required this.selected,
    required this.t,
  });

  final int value;
  final double fraction;
  final String label;
  final bool selected;
  final double t;

  @override
  Widget build(BuildContext context) {
    final tone = selected ? Quests.goldBright : Quests.gold;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: <Widget>[
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: fraction),
              duration: const Duration(milliseconds: 700),
              curve: D.emphasized,
              builder: (BuildContext context, double f, Widget? _) =>
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints c) {
                      const readout = 22.0;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            height: readout,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: selected ? 1 : 0,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  grouped(value),
                                  style: T.questPercent.copyWith(
                                    color: Quests.goldBright,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: math.max(
                              4,
                              (c.maxHeight - readout) * f * t,
                            ),
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _BarPainter(
                                tone: tone,
                                selected: selected,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: T.navLabel.copyWith(
                fontSize: 9.5,
                color: selected ? Quests.goldBright : Ink2.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  const _BarPainter({required this.tone, required this.selected});

  final Color tone;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final cut = math.min(6.0, size.height / 2);
    final path = chamferPath(
      size,
      cut: cut,
      bottomLeft: false,
      bottomRight: false,
    );
    if (selected) {
      canvas.drawPath(
        path,
        Paint()
          ..color = tone.withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(tone, const Color(0xFFFFFFFF), selected ? 0.35 : 0.1)!,
            tone.withValues(alpha: selected ? 0.55 : 0.18),
          ],
        ).createShader(Offset.zero & size),
    );
    final gap = Paint()..color = const Color(0x66000000);
    for (var y = size.height - 7.0; y > cut; y -= 7) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1.4), gap);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = tone.withValues(alpha: selected ? 0.9 : 0.4),
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.tone != tone || old.selected != selected;
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: HudPanel(
        cut: 14,
        accent: record.tone,
        accentStrength: 0.7,
        edge: record.tone.withValues(alpha: 0.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            record.tone.withValues(alpha: 0.12),
            record.tone.withValues(alpha: 0),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                QuestIcon(
                  glyph: record.glyph,
                  size: 15,
                  color: record.tone,
                  highlight: Color.lerp(record.tone, Ink2.bright, 0.5),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    record.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: T.rewardLabel.copyWith(fontSize: 10.5),
                  ),
                ),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                record.value,
                style: T.bigScore.copyWith(fontSize: 28),
              ),
            ),
            Text(
              record.unit,
              style: T.rewardLabel.copyWith(fontSize: 10, color: record.tone),
            ),
          ],
        ),
      ),
    );
  }
}
