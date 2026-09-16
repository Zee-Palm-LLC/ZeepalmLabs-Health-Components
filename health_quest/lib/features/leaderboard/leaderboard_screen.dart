import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/design.dart';
import '../../core/motion/entrance.dart';
import '../../core/motion/idle.dart';
import '../../core/motion/pressable.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/quests.dart';
import '../../data/social.dart';
import '../../widgets/hud.dart';
import '../../widgets/hud_kit.dart';
import '../../widgets/painters/quest_icons.dart';

enum Board { friends, global }

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: D.pageEntrance,
  )..forward();

  Board _board = Board.friends;

  List<Rival> get _rivals =>
      _board == Board.friends ? Rival.friends : Rival.global;

  void _switch(Board b) {
    setState(() => _board = b);
    _in.forward(from: 0.25);
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HudPage(
      kicker: 'WEEKLY LEAGUE',
      title: 'LEADERBOARD',
      tint: Quests.gold,
      body: IdleBuilder(
        builder: (BuildContext context, double idle, Widget? _) =>
            AnimatedBuilder(
              animation: _in,
              builder: (BuildContext context, Widget? _) {
                final t = _in.value;
                final rivals = _rivals;
                final rest = rivals.sublist(3);
                final you = Rival.rankIn(rivals);
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    D.pageGutter,
                    6,
                    D.pageGutter,
                    16 + MediaQuery.paddingOf(context).bottom,
                  ),
                  children: <Widget>[
                    HudSegmented<Board>(
                      options: const <Board, String>{
                        Board.friends: 'FRIENDS',
                        Board.global: 'GLOBAL',
                      },
                      value: _board,
                      tone: Quests.gold,
                      height: 40,
                      onChanged: _switch,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        QuestIcon(
                          glyph: QuestGlyph.flame,
                          size: 14,
                          color: Quests.rose,
                          progress: (idle * 0.6) % 1.0,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Season resets in 2d 14h',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: T.sectionMeta,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'YOU  #${grouped(you)}',
                          style: T.rewardLabel.copyWith(
                            color: Quests.purpleBright,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _Podium(top: rivals.sublist(0, 3), t: t, idle: idle),
                    const SizedBox(height: 16),
                    for (var i = 0; i < rest.length; i++) ...<Widget>[
                      if (_board == Board.global && rest[i].isYou)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Center(
                            child: Text(
                              '· · ·',
                              style: T.sectionTitle.copyWith(color: Ink2.faint),
                            ),
                          ),
                        ),
                      Builder(
                        builder: (BuildContext context) {
                          final p = D.stagger(t, 0.45, i, 0.06, 0.3);
                          final rank = rest[i].isYou ? you : i + 4;
                          return Slide(
                            t: D.outExpo.transform(p),
                            child: _RankRow(
                              rival: rest[i],
                              rank: rank,
                              idle: idle,
                              onTap: rest[i].isYou
                                  ? null
                                  : () => showHudToast(
                                      context,
                                      'Challenge sent to ${rest[i].name}. '
                                      'Most XP by Sunday wins.',
                                      tone: Quests.gold,
                                      glyph: QuestGlyph.swords,
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top, required this.t, required this.idle});

  final List<Rival> top;
  final double t;
  final double idle;

  @override
  Widget build(BuildContext context) {
    const order = <int>[1, 0, 2];
    const heights = <double>[78, 104, 62];
    return SizedBox(
      height: 276,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (var k = 0; k < 3; k++)
            Expanded(
              child: _Step(
                rival: top[order[k]],
                place: order[k] + 1,
                pedestal: heights[k],
                t: D.softPop.transform(D.stagger(t, 0.12, k, 0.09, 0.4)),
                idle: idle,
              ),
            ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.rival,
    required this.place,
    required this.pedestal,
    required this.t,
    required this.idle,
  });

  final Rival rival;
  final int place;
  final double pedestal;
  final double t;
  final double idle;

  static const List<Color> _medal = <Color>[
    Quests.goldBright,
    Color(0xFFCBD5E8),
    Color(0xFFE59A5C),
  ];

  @override
  Widget build(BuildContext context) {
    if (t <= 0) return const SizedBox.shrink();
    final medal = _medal[place - 1];
    final first = place == 1;
    final bob = first ? 3 * math.sin(idle * 1.8) : 0.0;
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Transform.translate(
              offset: Offset(0, (1 - t) * 40 + bob),
              child: Column(
                children: <Widget>[
                  if (first)
                    QuestIcon(
                      glyph: QuestGlyph.crown,
                      size: 26,
                      color: Quests.gold,
                      highlight: Quests.goldBright,
                    ),
                  const SizedBox(height: 4),
                  HexAvatar(
                    tone: rival.tone,
                    size: first ? 62 : 52,
                    initials: rival.initials,
                    glow: first ? 0.6 + 0.2 * math.sin(idle * 2) : 0.35,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rival.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: T.questTitle.copyWith(fontSize: 14),
                  ),
                  Text(
                    '${grouped(rival.weeklyXp)} XP',
                    style: T.questPercent.copyWith(color: medal, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            SizedBox(
              height: pedestal * t.clamp(0.0, 1.0),
              child: HudPanel(
                cut: 10,
                accent: medal,
                edge: medal.withValues(alpha: 0.45),
                glow: first ? 0.35 : 0.15,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    medal.withValues(alpha: 0.30),
                    medal.withValues(alpha: 0.02),
                  ],
                ),
                child: Align(
                  alignment: const Alignment(0, -0.4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$place',
                      style: T.disp(first ? 38 : 30, weight: 900, color: medal),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rival,
    required this.rank,
    required this.idle,
    this.onTap,
  });

  final Rival rival;
  final int rank;
  final double idle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final you = rival.isYou;
    final tone = you ? Quests.purple : rival.tone;
    final row = HudPanel(
      cut: 13,
      accent: tone,
      accentStrength: you ? 1 : 0.5,
      edge: tone.withValues(alpha: you ? 0.55 : 0.14),
      rail: you,
      glow: you ? 0.3 + 0.15 * math.sin(idle * 2) : 0,
      gradient: you
          ? LinearGradient(
              colors: <Color>[
                Quests.purple.withValues(alpha: 0.22),
                Quests.purple.withValues(alpha: 0.02),
              ],
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 62,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 42,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '#${grouped(rank)}',
                  style: T.disp(
                    16,
                    weight: 900,
                    italic: false,
                    color: you ? Quests.purpleBright : Ink2.muted,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            HexAvatar(
              tone: rival.tone,
              size: 36,
              initials: rival.initials,
              glow: 0.2,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    you ? 'You' : rival.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: T.questTitle.copyWith(fontSize: 14.5),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'LV ${rival.level}  ·  ${rival.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: T.questBlurb.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${grouped(rival.weeklyXp)} XP',
              style: T.questXp.copyWith(
                color: you ? Quests.purpleBright : Ink2.primary,
              ),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) return row;
    return Pressable(
      onTap: onTap,
      sound: Sfx.confirm,
      pressedScale: 0.98,
      child: row,
    );
  }
}
