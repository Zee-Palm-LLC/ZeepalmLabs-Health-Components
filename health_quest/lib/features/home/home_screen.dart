import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../core/audio/sfx.dart';
import '../../core/design.dart';
import '../../core/motion/entrance.dart';
import '../../core/motion/idle.dart';
import '../../core/motion/pressable.dart';
import '../../core/motion/routes.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/game_state.dart';
import '../../data/quests.dart';
import '../../widgets/painters/polygon.dart';
import '../../widgets/painters/quest_icons.dart';
import '../../widgets/hud.dart';
import '../../widgets/progress_ring.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenQuest, this.onOpenProfile});

  final ValueChanged<Quest> onOpenQuest;
  final VoidCallback? onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: D.pageEntrance,
  )..forward();

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const player = Player.you;
    return IdleBuilder(
      builder: (BuildContext context, double idle, Widget? _) =>
          AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[_in, GameState.instance]),
            builder: (BuildContext context, Widget? _) {
              final t = _in.value;
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  D.pageGutter,
                  4,
                  D.pageGutter,
                  12,
                ),
                children: <Widget>[
                  Rise(
                    t: D.headerIn.transform(t),
                    distance: 18,
                    child: _Header(
                      player: player,
                      onOpenProfile: widget.onOpenProfile,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Rise(
                    t: D.xpPanelIn.transform(t),
                    distance: 20,
                    child: _XpPanel(
                      player: player,
                      t: D.xpPanelIn.transform(t),
                      idle: idle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Rise(
                    t: D.scoreIn.transform(t),
                    distance: 26,
                    scaleFrom: 0.97,
                    child: _ScoreCard(
                      player: player,
                      t: D.scoreIn.transform(t),
                      idle: idle,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Rise(
                    t: D.sectionIn.transform(t),
                    distance: 12,
                    child: HudHeading(
                      title: "TODAY'S QUESTS",
                      accent: Quests.purple,
                      trailing: Text(
                        '${Quest.completed}/${Quest.today.length} DONE',
                        maxLines: 1,
                        style: T.rewardLabel,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < Quest.today.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: D.questGap),
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
                          distance: 34,
                          child: QuestRow(
                            quest: Quest.today[i],
                            t: p,
                            idle: idle,
                            onTap: () => widget.onOpenQuest(Quest.today[i]),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.player, this.onOpenProfile});

  final Player player;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: D.headerAvatar + 4,
      child: Row(
        children: <Widget>[
          Pressable(
            sound: Sfx.nav,
            pressedScale: 0.9,
            onTap: onOpenProfile,
            child: Container(
              width: D.headerAvatar,
              height: D.headerAvatar,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Quests.cardRaised,
                border: Border.all(color: Quests.blueBright, width: 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Quests.blue.withValues(alpha: 0.45),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/hero/face.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('GOOD MORNING,', style: T.greeting),
                const SizedBox(height: 1),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        GameState.instance.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: T.playerName,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const _Wave(),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const QuestIcon(
                      glyph: QuestGlyph.shield,
                      size: 14,
                      color: Quests.purple,
                      highlight: Quests.purpleBright,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'LEVEL ${GameState.instance.level}  ·  ${player.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: T.playerMeta,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const _BellButton(),
        ],
      ),
    );
  }
}

class _Wave extends StatelessWidget {
  const _Wave();

  @override
  Widget build(BuildContext context) {
    return IdleBuilder(
      builder: (BuildContext context, double s, Widget? _) {
        final cycle = (s / 4.5) % 1.0;
        final wave = cycle < 0.22
            ? math.sin(cycle / 0.22 * math.pi * 3) * 0.32
            : 0.0;
        return Transform.rotate(
          angle: wave,
          alignment: Alignment.bottomCenter,
          child: const Text('👋', style: TextStyle(fontSize: 18)),
        );
      },
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton();

  @override
  Widget build(BuildContext context) {
    return Pressable(
      pressedScale: 0.88,
      sound: Sfx.open,
      onTap: () => Navigator.of(
        context,
      ).push<void>(hudRoute(const NotificationsScreen())),
      child: SizedBox(
        width: D.headerButton + 6,
        height: D.headerButton + 6,
        child: Stack(
          children: <Widget>[
            Container(
              width: D.headerButton,
              height: D.headerButton,
              margin: const EdgeInsets.only(top: 6),
              child: const HudPanel(
                cut: 11,
                accent: Quests.purple,
                bracketLength: 9,
                child: Center(
                  child: QuestIcon(
                    glyph: QuestGlyph.bell,
                    size: 21,
                    color: Ink2.primary,
                  ),
                ),
              ),
            ),
            if (GameState.instance.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: IdleBuilder(
                  builder: (BuildContext context, double s, Widget? _) {
                    final pulse = 0.5 + 0.5 * math.sin(s * 2.4);
                    return Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Quests.rose,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Quests.rose.withValues(
                              alpha: 0.4 + 0.4 * pulse,
                            ),
                            blurRadius: 6 + 5 * pulse,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _XpPanel extends StatelessWidget {
  const _XpPanel({required this.player, required this.t, required this.idle});

  final Player player;
  final double t;
  final double idle;

  @override
  Widget build(BuildContext context) {
    final fill = D.emphasized.transform(t.clamp(0.0, 1.0));
    final game = GameState.instance;
    return HudPanel(
      cut: 12,
      accent: Quests.purple,
      edge: Quests.purple.withValues(alpha: 0.30),
      rail: true,
      bracketLength: 12,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: SizedBox(
        height: D.xpPanelHeight,
        child: Row(
          children: <Widget>[
            PolygonPane(
              size: const Size(D.levelHex, D.levelHex),
              sides: 6,
              cornerRadius: 4,
              edgeWidth: 1.8,
              edge: Quests.purpleBright,
              glow: Quests.purple.withValues(alpha: 0.6),
              glowStrength: 0.5,
              fill: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFF3A1D6B), Color(0xFF1B0F33)],
              ),
              child: Text(
                '${game.level}',
                style: T.questXp.copyWith(
                  color: Ink2.bright,
                  fontFamily: T.display,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SegmentedMeter(
                value: game.xpFraction * fill,
                color: Quests.purple,
                height: 12,
                segments: 18,
                shimmer: idle,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${grouped((game.xp * fill).round())} / '
                  '${grouped(game.xpToNext)} XP',
                  maxLines: 1,
                  style: T.questTitle,
                ),
              ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.player, required this.t, required this.idle});

  final Player player;
  final double t;
  final double idle;

  @override
  Widget build(BuildContext context) {
    final dial = t.clamp(0.0, 1.0);
    final score = (player.healthScore * dial).round();

    return HudPanel(
      cut: 18,
      accent: Quests.green,
      edge: Quests.green.withValues(alpha: 0.22),
      rail: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 18),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('DAILY HEALTH SCORE', style: T.cardLabel),
                  const SizedBox(height: 14),
                  Center(
                    child: ProgressRing(
                      value: player.healthScore / 100 * dial,
                      size: D.scoreRing,
                      stroke: D.scoreRingStroke,
                      color: Quests.green,
                      trackColor: const Color(0xFF1B2133),
                      glow: 0.45 + 0.15 * math.sin(idle * 1.2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          QuestIcon(
                            glyph: QuestGlyph.heart,
                            size: 20,
                            color: Quests.green,
                            highlight: Quests.greenBright,
                          ),
                          const SizedBox(height: 2),
                          Text('$score', style: T.bigScore),
                          Text('/100', style: T.scoreOutOf),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const VerticalDivider2(),
            const SizedBox(width: 10),
            Expanded(
              flex: 45,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 2),
                  Text('STREAK', style: T.cardLabel),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _Flame(idle: idle),
                        const SizedBox(width: 7),
                        Text('${player.streakDays} DAYS', style: T.streakValue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _Divider(),
                  const SizedBox(height: 16),
                  Text('MULTIPLIER', style: T.cardLabel),
                  const SizedBox(height: 10),
                  Text('X${player.multiplier}', style: T.multiplier),
                  Text('XP', style: T.cardLabel.copyWith(color: Quests.blue)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Flame extends StatelessWidget {
  const _Flame({required this.idle});

  final double idle;

  @override
  Widget build(BuildContext context) => QuestIcon(
    glyph: QuestGlyph.flame,
    size: 22,
    color: Quests.gold,
    highlight: Quests.goldBright,
    progress: (idle * 0.6) % 1.0,
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: Quests.divider,
  );
}

class VerticalDivider2 extends StatelessWidget {
  const VerticalDivider2({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, color: Quests.divider);
}

class QuestRow extends StatelessWidget {
  const QuestRow({
    super.key,
    required this.quest,
    required this.t,
    required this.idle,
    this.onTap,
  });

  final Quest quest;

  final double t;
  final double idle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fill = D.emphasized.transform(t.clamp(0.0, 1.0));
    final shown = (quest.percent * fill).round();

    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: HudPanel(
        cut: 15,
        accent: quest.tone,
        accentStrength: quest.done ? 1 : 0.75,
        edge: quest.tone.withValues(alpha: quest.done ? 0.40 : 0.20),
        rail: true,
        glow: quest.done ? 0.25 : 0,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            quest.tone.withValues(alpha: 0.13),
            quest.tone.withValues(alpha: 0.0),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: SizedBox(
          height: D.questCardHeight,
          child: Row(
            children: <Widget>[
              Container(
                width: D.questIconSize,
                height: D.questIconSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: quest.tone.withValues(alpha: 0.14),
                  border: Border.all(color: quest.tone.withValues(alpha: 0.30)),
                ),
                child: Center(
                  child: QuestIcon(
                    glyph: quest.glyph,
                    size: 24,
                    color: quest.tone,
                    highlight: Color.lerp(quest.tone, Ink2.bright, 0.45)!,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      quest.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: T.questTitle,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      quest.blurb,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: T.questBlurb,
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: SegmentedMeter(
                            value: quest.progress * fill,
                            color: quest.tone,
                            height: 9,
                            segments: 14,
                            shimmer: quest.done ? idle : 0,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          '$shown%',
                          style: T.questPercent.copyWith(color: quest.tone),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '+${quest.xp} XP',
                    style: T.questXp.copyWith(color: quest.tone),
                  ),
                  const SizedBox(height: 6),
                  if (quest.done && !GameState.instance.questClaimed(quest))
                    _ClaimPip(idle: idle)
                  else if (quest.done)
                    _DoneBadge(t: fill)
                  else
                    const QuestIcon(
                      glyph: QuestGlyph.chevron,
                      size: 18,
                      color: Ink2.muted,
                      strokeWidth: 8,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClaimPip extends StatelessWidget {
  const _ClaimPip({required this.idle});

  final double idle;

  @override
  Widget build(BuildContext context) {
    final pulse = 0.5 + 0.5 * math.sin(idle * 3.2);
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Quests.gold.withValues(alpha: 0.16 + 0.1 * pulse),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Quests.gold.withValues(alpha: 0.6 + 0.4 * pulse),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Quests.gold.withValues(alpha: 0.25 + 0.3 * pulse),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          'CLAIM',
          style: T.rewardLabel.copyWith(
            color: Quests.goldBright,
            fontSize: 10.5,
          ),
        ),
      ),
    );
  }
}

class _DoneBadge extends StatelessWidget {
  const _DoneBadge({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final draw = ((t - 0.45) / 0.55).clamp(0.0, 1.0);
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Quests.greenDeep.withValues(alpha: 0.25),
        border: Border.all(color: Quests.green.withValues(alpha: 0.7)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Quests.green.withValues(alpha: 0.35 * draw),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: QuestIcon(
          glyph: QuestGlyph.check,
          size: 15,
          color: Quests.greenBright,
          progress: draw,
        ),
      ),
    );
  }
}
