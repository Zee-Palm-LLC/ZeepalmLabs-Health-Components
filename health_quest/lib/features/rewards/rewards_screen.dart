import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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

/// The rewards vault: what the XP is actually for.
///
/// A badge is in one of three states and each one looks different from
/// across the room. Claimed badges are lit and carry a tick. Affordable ones
/// glow and invite a tap. Locked ones are desaturated with the requirement
/// stated plainly, because a reward you cannot reach is only motivating if
/// you can see exactly what it would take.
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: D.pageEntrance,
  )..forward();

  static const Player _player = Player.you;

  /// Claimed during this session, on top of what was already owned.
  final Set<String> _claimed = <String>{};
  int _spent = 0;
  String? _justClaimed;

  int get _balance => _player.balance - _spent;

  bool _owned(Reward r) => r.owned || _claimed.contains(r.name);

  void _claim(Reward r) {
    if (_owned(r)) return;
    if (r.unlocksAtLevel != null && _player.level < r.unlocksAtLevel!) {
      HapticFeedback.heavyImpact();
      return;
    }
    if (r.cost > _balance) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _claimed.add(r.name);
      _spent += r.cost;
      _justClaimed = r.name;
    });
  }

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
          final owned = Reward.all.where(_owned).length;

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                D.pageGutter, 8, D.pageGutter, 12),
            children: <Widget>[
              Rise(
                t: D.headerIn.transform(t),
                distance: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const HudHeading(
                            title: 'REWARDS VAULT',
                            accent: Quests.gold,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '$owned of ${Reward.all.length} badges claimed',
                            style: T.sectionMeta,
                          ),
                        ],
                      ),
                    ),
                    _Balance(balance: _balance, idle: idle),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Rise(
                t: D.xpPanelIn.transform(t),
                distance: 20,
                child: _VaultProgress(
                  owned: owned,
                  total: Reward.all.length,
                  t: D.xpPanelIn.transform(t),
                  idle: idle,
                ),
              ),
              const SizedBox(height: 20),
              Rise(
                t: D.sectionIn.transform(t),
                distance: 12,
                child: const HudHeading(
                  title: 'ALL BADGES',
                  accent: Quests.purple,
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < Reward.all.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: D.questGap),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: _Tile(
                          reward: Reward.all[i],
                          owned: _owned(Reward.all[i]),
                          balance: _balance,
                          level: _player.level,
                          idle: idle,
                          justClaimed: _justClaimed == Reward.all[i].name,
                          t: D.softPop.transform(D.stagger(
                              t, D.rowsStart, i, D.rowStagger * 0.6,
                              D.rowSpan)),
                          onTap: () => _claim(Reward.all[i]),
                        ),
                      ),
                      const SizedBox(width: D.questGap),
                      Expanded(
                        child: i + 1 < Reward.all.length
                            ? _Tile(
                                reward: Reward.all[i + 1],
                                owned: _owned(Reward.all[i + 1]),
                                balance: _balance,
                                level: _player.level,
                                idle: idle,
                                justClaimed:
                                    _justClaimed == Reward.all[i + 1].name,
                                t: D.softPop.transform(D.stagger(
                                    t, D.rowsStart, i + 1,
                                    D.rowStagger * 0.6, D.rowSpan)),
                                onTap: () => _claim(Reward.all[i + 1]),
                              )
                            : const SizedBox(height: 168),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Balance extends StatelessWidget {
  const _Balance({required this.balance, required this.idle});

  final int balance;
  final double idle;

  @override
  Widget build(BuildContext context) {
    return HudPanel(
      cut: 11,
      accent: Quests.gold,
      edge: Quests.gold.withValues(alpha: 0.38),
      glow: 0.25 + 0.2 * math.sin(idle * 1.4),
      bracketLength: 9,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const QuestIcon(
            glyph: QuestGlyph.shield,
            size: 16,
            color: Quests.gold,
            highlight: Quests.goldBright,
          ),
          const SizedBox(width: 7),
          // Rolls when a badge is claimed rather than cutting to the new
          // number, so spending XP is visible.
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: balance.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: D.emphasized,
            builder: (BuildContext context, double v, Widget? _) => Text(
              '${grouped(v.round())} XP',
              style: T.rewardValue.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultProgress extends StatelessWidget {
  const _VaultProgress({
    required this.owned,
    required this.total,
    required this.t,
    required this.idle,
  });

  final int owned;
  final int total;
  final double t;
  final double idle;

  @override
  Widget build(BuildContext context) {
    final fill = D.emphasized.transform(t.clamp(0.0, 1.0));
    return HudPanel(
      cut: 16,
      accent: Quests.gold,
      edge: Quests.gold.withValues(alpha: 0.20),
      rail: true,
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Row(
        children: <Widget>[
          ProgressRing(
            value: owned / total * fill,
            size: 62,
            stroke: 7,
            color: Quests.gold,
            trackColor: const Color(0xFF1B2133),
            glow: 0.4 + 0.15 * math.sin(idle * 1.3),
            child: Text(
              '${(owned / total * 100 * fill).round()}%',
              style: T.questPercent.copyWith(color: Quests.goldBright),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('VAULT COMPLETION', style: T.cardLabel),
                const SizedBox(height: 6),
                Text(
                  'Finish quests to earn XP, then spend it here on badges '
                  'that stay on your profile.',
                  style: T.questBlurb,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.reward,
    required this.owned,
    required this.balance,
    required this.level,
    required this.idle,
    required this.justClaimed,
    required this.t,
    required this.onTap,
  });

  final Reward reward;
  final bool owned;
  final int balance;
  final int level;
  final double idle;
  final bool justClaimed;
  final double t;
  final VoidCallback onTap;

  bool get _levelLocked =>
      reward.unlocksAtLevel != null && level < reward.unlocksAtLevel!;
  bool get _affordable => !owned && !_levelLocked && reward.cost <= balance;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) return const SizedBox(height: 168);

    final tone = owned || _affordable ? reward.tone : Quests.locked;
    final pulse = _affordable ? 0.4 + 0.35 * math.sin(idle * 2.1) : 0.0;

    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: t.clamp(0.02, 1.25),
        child: Pressable(
          onTap: onTap,
          pressedScale: 0.95,
          child: HudPanel(
            cut: 16,
            accent: tone,
            accentStrength: owned ? 1 : (_affordable ? 0.85 : 0.4),
            edge: owned
                ? tone.withValues(alpha: 0.45)
                : (_affordable
                      ? tone.withValues(alpha: 0.30 + pulse * 0.4)
                      : Quests.cardEdge),
            glow: owned ? 0.2 : pulse * 0.5,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                tone.withValues(alpha: owned ? 0.16 : 0.06),
                tone.withValues(alpha: 0),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    PolygonPane(
                      size: const Size(52, 58),
                      sides: 6,
                      cornerRadius: 6,
                      edgeWidth: 1.6,
                      edge: tone.withValues(alpha: owned ? 0.95 : 0.55),
                      glow: tone.withValues(alpha: 0.6),
                      glowStrength: owned ? 0.55 : pulse,
                      fill: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          tone.withValues(alpha: owned ? 0.32 : 0.12),
                          const Color(0xCC080B16),
                        ],
                      ),
                      child: QuestIcon(
                        glyph: _levelLocked && !owned
                            ? QuestGlyph.lock
                            : reward.glyph,
                        size: 26,
                        color: tone,
                        highlight: Color.lerp(tone, Ink2.bright, 0.5)!,
                      ),
                    ),
                    if (owned)
                      Positioned(
                        right: 6,
                        bottom: 0,
                        child: _ClaimTick(justClaimed: justClaimed),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  reward.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: T.rewardName.copyWith(
                    color: owned ? Ink2.bright : Ink2.primary,
                  ),
                ),
                const SizedBox(height: 3),
                Expanded(
                  child: Text(
                    reward.blurb,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: T.questBlurb,
                  ),
                ),
                const SizedBox(height: 6),
                _Footer(
                  owned: owned,
                  levelLocked: _levelLocked,
                  affordable: _affordable,
                  reward: reward,
                  tone: tone,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.owned,
    required this.levelLocked,
    required this.affordable,
    required this.reward,
    required this.tone,
  });

  final bool owned;
  final bool levelLocked;
  final bool affordable;
  final Reward reward;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final (String text, Color color) = switch ((owned, levelLocked)) {
      (true, _) => ('CLAIMED', tone),
      (false, true) => ('LEVEL ${reward.unlocksAtLevel}', Quests.locked),
      _ => ('${grouped(reward.cost)} XP', affordable ? tone : Quests.locked),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      child: SizedBox(
        key: ValueKey<String>(text),
        height: 26,
        child: HudPanel(
          cut: 8,
          fill: color.withValues(alpha: 0.14),
          edge: color.withValues(alpha: 0.45),
          accent: color,
          brackets: false,
          scanlines: false,
          child: Center(
            child: Text(
              text,
              style: T.rewardLabel.copyWith(color: color, letterSpacing: 1.0),
            ),
          ),
        ),
      ),
    );
  }
}

/// The tick that lands on a badge when it is claimed. It draws on the first
/// time you see it and is simply there afterwards.
class _ClaimTick extends StatelessWidget {
  const _ClaimTick({required this.justClaimed});

  final bool justClaimed;

  @override
  Widget build(BuildContext context) {
    final tick = Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0E1018),
        border: Border.all(color: Quests.green.withValues(alpha: 0.8)),
      ),
      child: const Center(
        child: QuestIcon(
          glyph: QuestGlyph.check,
          size: 12,
          color: Quests.greenBright,
        ),
      ),
    );
    if (!justClaimed) return tick;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 620),
      curve: D.softPop,
      builder: (BuildContext context, double v, Widget? child) =>
          Transform.scale(scale: v.clamp(0.02, 1.3), child: child),
      child: tick,
    );
  }
}
