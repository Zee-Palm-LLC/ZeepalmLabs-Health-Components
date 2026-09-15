import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../../core/design.dart';
import '../../core/motion/entrance.dart';
import '../../core/motion/idle.dart';
import '../../core/motion/pressable.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/quests.dart';
import '../../widgets/painters/polygon.dart';
import '../../widgets/painters/quest_icons.dart';
import '../../widgets/hud.dart';
import '../../widgets/progress_ring.dart';
import 'widgets/quest_backdrop.dart';

/// One quest, in full: where you are, what it pays, and what is still ahead.
///
/// The ring is the screen. It dials from zero on arrival and the count runs
/// with it, so opening the quest shows you the progress being made rather
/// than a number that was already there.
class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key, required this.quest});

  final Quest quest;

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: D.pageEntrance,
  )..forward();

  Offset _parallax = Offset.zero;

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  void _onHover(PointerHoverEvent e, Size size) {
    setState(() {
      _parallax = Offset(
        (e.localPosition.dx / size.width - 0.5) * 2,
        (e.localPosition.dy / size.height - 0.5) * 2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quest;
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);

    return IdleBuilder(
      builder: (BuildContext context, double idle, Widget? _) => AnimatedBuilder(
        animation: _in,
        builder: (BuildContext context, Widget? _) {
          final t = _in.value;
          final dial = D.questRingIn.transform(t);
          final count = D.questCountIn.transform(t).clamp(0.0, 1.0);

          return Scaffold(
            backgroundColor: Quests.page,
            body: MouseRegion(
              onHover: (PointerHoverEvent e) => _onHover(e, size),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  QuestBackdropHost(
                    idle: idle,
                    tone: q.tone,
                    parallax: _parallax,
                  ),
                  SafeArea(
                    bottom: false,
                    child: Column(
                      children: <Widget>[
                        Rise(
                          t: D.questHeadIn.transform(t),
                          distance: 16,
                          child: _TopBar(quest: q, idle: idle),
                        ),
                        Expanded(
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              D.pageGutter,
                              4,
                              D.pageGutter,
                              8,
                            ),
                            children: <Widget>[
                              Rise(
                                t: D.questHeadIn.transform(t),
                                distance: 20,
                                child: Column(
                                  children: <Widget>[
                                    Text('QUEST DETAILS', style: T.questKicker),
                                    const SizedBox(height: 7),
                                    SweepReveal(
                                      t: D.questHeadIn.transform(t),
                                      child: Text(
                                        q.title.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: T.questHeadline.copyWith(
                                          shadows: const <Shadow>[
                                            Shadow(
                                              color: Color(0xCC000000),
                                              blurRadius: 14,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(q.cheer, style: T.questCheer),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                              Center(
                                child: _Dial(
                                  quest: q,
                                  dial: dial,
                                  count: count,
                                  idle: idle,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Center(
                                child: Rise(
                                  t: count,
                                  distance: 10,
                                  child: Text(
                                    '${(q.percent * count).round()}% COMPLETED',
                                    style: T.completed.copyWith(color: q.tone),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Rise(
                                t: D.questRewardIn.transform(t),
                                distance: 22,
                                child: _RewardCard(quest: q, idle: idle),
                              ),
                              const SizedBox(height: 20),
                              Rise(
                                t: D.questRewardIn.transform(t),
                                distance: 12,
                                child: HudHeading(
                                  title: 'MILESTONES',
                                  accent: q.tone,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _Milestones(quest: q, t: t, idle: idle),
                              const SizedBox(height: 22),
                              Rise(
                                t: D.questCtaIn.transform(t),
                                distance: 20,
                                scaleFrom: 0.95,
                                child: _KeepGoing(
                                  quest: q,
                                  idle: idle,
                                  onTap: () => Navigator.maybePop(context),
                                ),
                              ),
                              SizedBox(height: 10 + pad.bottom),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Keeps the painter out of the rebuild path of everything above it.
class QuestBackdropHost extends StatelessWidget {
  const QuestBackdropHost({
    super.key,
    required this.idle,
    required this.tone,
    required this.parallax,
  });

  final double idle;
  final Color tone;
  final Offset parallax;

  @override
  Widget build(BuildContext context) =>
      QuestBackdrop(idle: idle, tone: tone, parallax: parallax);
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.quest, required this.idle});

  final Quest quest;
  final double idle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(D.pageGutter, 6, D.pageGutter, 0),
      child: SizedBox(
        height: 74,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: _GlassButton(
                glyph: QuestGlyph.back,
                onTap: () => Navigator.maybePop(context),
              ),
            ),
            // The quest's own crest, breathing.
            Builder(
              builder: (BuildContext context) {
                final breathe = 1 + 0.03 * math.sin(idle * 1.3);
                return Transform.scale(
                  scale: breathe,
                  child: PolygonPane(
                    size: const Size(62, 70),
                    sides: 6,
                    cornerRadius: 7,
                    edgeWidth: 1.6,
                    edge: quest.tone.withValues(alpha: 0.75),
                    glow: quest.tone.withValues(alpha: 0.55),
                    glowStrength: 0.55 + 0.25 * math.sin(idle * 1.3),
                    fill: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        quest.tone.withValues(alpha: 0.22),
                        const Color(0xCC070A16),
                      ],
                    ),
                    child: QuestIcon(
                      glyph: quest.id == 'steps'
                          ? QuestGlyph.shoe
                          : quest.glyph,
                      size: 34,
                      color: quest.tone,
                      highlight: Color.lerp(quest.tone, Ink2.bright, 0.5)!,
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _GlassButton(glyph: QuestGlyph.more, onTap: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.glyph, required this.onTap});

  final QuestGlyph glyph;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    pressedScale: 0.88,
    child: SizedBox(
      width: 46,
      height: 46,
      child: HudPanel(
        cut: 12,
        fill: const Color(0x99111731),
        accent: Quests.purple,
        bracketLength: 9,
        child: Center(
          child: QuestIcon(glyph: glyph, size: 20, color: Ink2.primary),
        ),
      ),
    ),
  );
}

class _Dial extends StatelessWidget {
  const _Dial({
    required this.quest,
    required this.dial,
    required this.count,
    required this.idle,
  });

  final Quest quest;
  final double dial;
  final double count;
  final double idle;

  @override
  Widget build(BuildContext context) {
    final shown = (quest.current * count).round();
    return ProgressRing(
      value: quest.progress * dial.clamp(0.0, 1.0),
      size: D.questRing,
      stroke: D.questRingStroke,
      color: quest.tone,
      trackColor: const Color(0xFF1B2133),
      glow: 0.5 + 0.18 * math.sin(idle * 1.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          QuestIcon(
            glyph: quest.glyph,
            size: 30,
            color: quest.tone,
            highlight: Color.lerp(quest.tone, Ink2.bright, 0.45)!,
          ),
          const SizedBox(height: 8),
          Text(grouped(shown), style: T.bigCount),
          const SizedBox(height: 2),
          Text('/ ${grouped(quest.target)}', style: T.bigCountOf),
          const SizedBox(height: 4),
          Text(quest.unit, style: T.bigCountUnit),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.quest, required this.idle});

  final Quest quest;
  final double idle;

  @override
  Widget build(BuildContext context) {
    return HudPanel(
      cut: 16,
      fill: const Color(0xB30C1020),
      accent: Quests.gold,
      edge: Quests.gold.withValues(alpha: 0.28),
      rail: true,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            PolygonPane(
              size: const Size(48, 54),
              sides: 6,
              cornerRadius: 5,
              edgeWidth: 1.6,
              edge: Quests.goldBright,
              glow: Quests.gold.withValues(alpha: 0.6),
              glowStrength: 0.45 + 0.25 * math.sin(idle * 1.6),
              fill: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFFF7C64B), Color(0xFF6A4405)],
              ),
              child: Text(
                'XP',
                style: T.rewardValue.copyWith(
                  fontSize: 15,
                  color: const Color(0xFF3A2503),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('REWARD', style: T.rewardLabel),
                  const SizedBox(height: 3),
                  Text('+${quest.xp} XP', style: T.rewardValue),
                ],
              ),
            ),
            Container(width: 1, color: Quests.divider),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text('NEXT REWARD', style: T.rewardLabel),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          quest.nextReward,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: T.rewardName,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const QuestIcon(
                        glyph: QuestGlyph.trophy,
                        size: 24,
                        color: Quests.gold,
                        highlight: Quests.goldBright,
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

class _Milestones extends StatelessWidget {
  const _Milestones({required this.quest, required this.t, required this.idle});

  final Quest quest;
  final double t;
  final double idle;

  @override
  Widget build(BuildContext context) {
    final reached = <bool>[
      for (final m in quest.milestones) quest.current >= m,
    ];
    // The one you are working toward: the first not yet reached.
    final nextIndex = reached.indexOf(false);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final n = quest.milestones.length;
        final slot = c.maxWidth / n;
        final railProgress = D.emphasized.transform(
          D.stagger(t, D.milestonesStart, 0, 0, D.milestoneSpan * 1.6),
        );

        return SizedBox(
          height: 78,
          child: Stack(
            children: <Widget>[
              // The rail, drawn behind the nodes and filled to the last
              // milestone actually reached.
              Positioned(
                left: slot / 2,
                right: slot / 2,
                top: D.milestoneHex / 2 - 1.5,
                height: 3,
                child: CustomPaint(
                  painter: _RailPainter(
                    filled: reached.lastIndexOf(true) < 0
                        ? 0
                        : reached.lastIndexOf(true) / (n - 1),
                    progress: railProgress,
                    color: quest.tone,
                  ),
                ),
              ),
              for (var i = 0; i < n; i++)
                Positioned(
                  left: slot * i,
                  width: slot,
                  top: 0,
                  child: _Milestone(
                    value: quest.milestones[i],
                    unit: quest.unit == 'STEPS' ? 'Steps' : quest.unit,
                    reached: reached[i],
                    isNext: i == nextIndex,
                    tone: quest.tone,
                    idle: idle,
                    t: D.softPop.transform(
                      D.stagger(
                        t,
                        D.milestonesStart,
                        i,
                        D.milestoneStagger,
                        D.milestoneSpan,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RailPainter extends CustomPainter {
  const _RailPainter({
    required this.filled,
    required this.progress,
    required this.color,
  });

  final double filled;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..strokeWidth = size.height
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF232A3E),
    );
    final w = size.width * filled * progress.clamp(0.0, 1.0);
    if (w <= 0) return;
    canvas.drawLine(
      Offset(0, y),
      Offset(w, y),
      Paint()
        ..strokeWidth = size.height
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
    canvas.drawLine(
      Offset(0, y),
      Offset(w, y),
      Paint()
        ..strokeWidth = size.height
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  @override
  bool shouldRepaint(_RailPainter old) =>
      old.filled != filled || old.progress != progress || old.color != color;
}

class _Milestone extends StatelessWidget {
  const _Milestone({
    required this.value,
    required this.unit,
    required this.reached,
    required this.isNext,
    required this.tone,
    required this.idle,
    required this.t,
  });

  final int value;
  final String unit;
  final bool reached;
  final bool isNext;
  final Color tone;
  final double idle;
  final double t;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) return const SizedBox.shrink();
    final settled = t.clamp(0.0, 1.0);
    final glowPulse = isNext ? 0.4 + 0.4 * math.sin(idle * 2.0) : 0.0;
    final colour = reached ? tone : (isNext ? Quests.gold : Quests.locked);

    return Opacity(
      opacity: settled,
      child: Transform.scale(
        scale: t.clamp(0.02, 1.3),
        child: Column(
          children: <Widget>[
            PolygonPane(
              size: const Size(D.milestoneHex, D.milestoneHex + 5),
              sides: 6,
              cornerRadius: 4,
              edgeWidth: 1.6,
              edge: colour.withValues(alpha: reached || isNext ? 0.95 : 0.5),
              glow: colour.withValues(alpha: 0.6),
              glowStrength: reached ? 0.5 : glowPulse,
              fill: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  colour.withValues(alpha: reached ? 0.30 : 0.14),
                  const Color(0xCC090D1A),
                ],
              ),
              child: QuestIcon(
                glyph: reached ? QuestGlyph.check : QuestGlyph.lock,
                size: reached ? 16 : 15,
                color: colour,
                highlight: Color.lerp(colour, Ink2.bright, 0.5)!,
                progress: reached ? ((t - 0.4) / 0.6).clamp(0.0, 1.0) : 1,
                strokeWidth: 9,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              grouped(value),
              style: T.milestoneValue.copyWith(
                color: reached ? tone : Ink2.bright,
              ),
            ),
            Text(unit, style: T.milestoneUnit),
          ],
        ),
      ),
    );
  }
}

class _KeepGoing extends StatelessWidget {
  const _KeepGoing({
    required this.quest,
    required this.idle,
    required this.onTap,
  });

  final Quest quest;
  final double idle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      pressedScale: 0.965,
      child: BevelButton(
        height: D.ctaHeight,
        cut: 17,
        gradient: Quests.keepGoing,
        glowColor: Quests.green,
        idle: idle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('KEEP GOING', style: T.ctaDark),
                ),
              ),
              const SizedBox(width: 22),
              const QuestIcon(
                glyph: QuestGlyph.chevron,
                size: 20,
                color: Color(0xFF0B1405),
                strokeWidth: 9,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
