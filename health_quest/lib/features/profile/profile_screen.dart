import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/design.dart';
import '../../core/motion/entrance.dart';
import '../../core/motion/idle.dart';
import '../../core/motion/pressable.dart';
import '../../core/motion/routes.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/game_state.dart';
import '../../data/progress.dart';
import '../../data/quests.dart';
import '../../data/social.dart';
import '../../widgets/hud.dart';
import '../../widgets/hud_kit.dart';
import '../../widgets/painters/polygon.dart';
import '../../widgets/painters/quest_icons.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onOpenVault});

  final VoidCallback? onOpenVault;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
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

  void _push(Widget page) => Navigator.of(context).push<void>(hudRoute(page));

  @override
  Widget build(BuildContext context) {
    final game = GameState.instance;
    return IdleBuilder(
      builder: (BuildContext context, double idle, Widget? _) =>
          AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[_in, game]),
            builder: (BuildContext context, Widget? _) {
              final t = _in.value;
              final achieved = Achievement.all.where((Achievement a) => a.done);
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
                    child: Row(
                      children: <Widget>[
                        const Expanded(
                          child: HudHeading(
                            title: 'PLAYER CARD',
                            accent: Quests.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GlassButton(
                          glyph: QuestGlyph.more,
                          sound: Sfx.open,
                          semanticLabel: 'Settings',
                          size: 40,
                          onTap: () => _push(const SettingsScreen()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Rise(
                    t: D.xpPanelIn.transform(t),
                    distance: 22,
                    scaleFrom: 0.97,
                    child: _PlayerCard(
                      game: game,
                      t: D.xpPanelIn.transform(t),
                      idle: idle,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Rise(
                    t: D.sectionIn.transform(t),
                    distance: 12,
                    child: HudHeading(
                      title: 'BADGE SHOWCASE',
                      accent: Quests.gold,
                      trailing: Pressable(
                        sound: Sfx.nav,
                        onTap: widget.onOpenVault,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            'VAULT  ›',
                            style: T.rewardLabel.copyWith(color: Quests.gold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Rise(
                    t: D.sectionIn.transform(t),
                    distance: 16,
                    child: _Showcase(owned: game.ownedRewards, idle: idle),
                  ),
                  const SizedBox(height: 20),
                  Rise(
                    t: D.sectionIn.transform(t),
                    distance: 12,
                    child: HudHeading(
                      title: 'ACHIEVEMENTS',
                      accent: Quests.purple,
                      trailing: Text(
                        '${achieved.length}/${Achievement.all.length}',
                        style: T.rewardLabel,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < Achievement.all.length; i++) ...<Widget>[
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
                          child: _AchievementRow(
                            achievement: Achievement.all[i],
                            t: p,
                            idle: idle,
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  Rise(
                    t: D.navIn.transform(t),
                    distance: 12,
                    child: HudHeading(
                      title: 'ACTIVITY',
                      accent: Quests.green,
                      trailing: Text('LAST 5 WEEKS', style: T.rewardLabel),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Rise(
                    t: D.navIn.transform(t),
                    distance: 18,
                    child: _ActivityGrid(
                      t: D.emphasized.transform(
                        ((t - 0.5) / 0.5).clamp(0.0, 1.0),
                      ),
                      idle: idle,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Rise(
                    t: D.navIn.transform(t),
                    distance: 12,
                    child: const HudHeading(
                      title: 'COMMAND',
                      accent: Quests.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Rise(
                    t: D.navIn.transform(t),
                    distance: 16,
                    child: Column(
                      children: <Widget>[
                        MenuRow(
                          glyph: QuestGlyph.crown,
                          tone: Quests.gold,
                          title: 'Leaderboard',
                          subtitle: 'Weekly league with your friends',
                          trailing: HudChip(
                            label: '#${Rival.rankIn(Rival.friends)}',
                            tone: Quests.gold,
                          ),
                          onTap: () => _push(const LeaderboardScreen()),
                        ),
                        const SizedBox(height: 8),
                        MenuRow(
                          glyph: QuestGlyph.bell,
                          tone: Quests.rose,
                          title: 'Notifications',
                          subtitle: 'Quests, streaks and rivals',
                          trailing: game.unreadCount > 0
                              ? HudChip(
                                  label: '${game.unreadCount} NEW',
                                  tone: Quests.rose,
                                )
                              : null,
                          onTap: () => _push(const NotificationsScreen()),
                        ),
                        const SizedBox(height: 8),
                        MenuRow(
                          glyph: QuestGlyph.more,
                          tone: Quests.blue,
                          title: 'Settings',
                          subtitle: 'Sound, haptics and reminders',
                          onTap: () => _push(const SettingsScreen()),
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

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.game, required this.t, required this.idle});

  final GameState game;
  final double t;
  final double idle;

  @override
  Widget build(BuildContext context) {
    final fill = D.emphasized.transform(t.clamp(0.0, 1.0));
    const player = Player.you;
    return HudPanel(
      cut: 20,
      accent: Quests.purple,
      edge: Quests.purple.withValues(alpha: 0.32),
      glow: 0.25 + 0.1 * math.sin(idle * 1.2),
      rail: true,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Quests.purple.withValues(alpha: 0.18),
          Quests.blue.withValues(alpha: 0.04),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 14),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: 92,
                height: 102,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    HexAvatar(
                      tone: Quests.purple,
                      size: 86,
                      image: 'assets/hero/face.png',
                      glow: 0.5 + 0.25 * math.sin(idle * 1.6),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -4,
                      child: PolygonPane(
                        size: const Size(34, 38),
                        sides: 6,
                        cornerRadius: 4,
                        edgeWidth: 1.6,
                        edge: Quests.goldBright,
                        glow: Quests.gold.withValues(alpha: 0.6),
                        glowStrength: 0.5,
                        fill: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Color(0xFFF7C64B), Color(0xFF6A4405)],
                        ),
                        child: Text(
                          '${game.level}',
                          style: T.disp(
                            15,
                            weight: 900,
                            italic: false,
                            color: const Color(0xFF2A1A02),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(game.name, style: T.playerName),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: <Widget>[
                        const HudChip(
                          label: 'WELLNESS WARRIOR',
                          tone: Quests.purpleBright,
                        ),
                        if (game.mainQuest case final quest?)
                          HudChip(label: quest.label, tone: quest.tone),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SegmentedMeter(
                      value: game.xpFraction * fill,
                      color: Quests.purple,
                      height: 10,
                      segments: 14,
                      shimmer: idle,
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'LV ${game.level}  ·  ${grouped((game.xp * fill).round())}'
                        ' / ${grouped(game.xpToNext)} XP',
                        style: T.playerMeta,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Quests.divider),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                _CardFigure(
                  glyph: QuestGlyph.flame,
                  tone: Quests.gold,
                  value: '${player.streakDays}',
                  label: 'DAY STREAK',
                  idle: idle,
                ),
                Container(width: 1, color: Quests.divider),
                _CardFigure(
                  glyph: QuestGlyph.swords,
                  tone: Quests.green,
                  value: '148',
                  label: 'QUESTS',
                  idle: idle,
                ),
                Container(width: 1, color: Quests.divider),
                _CardFigure(
                  glyph: QuestGlyph.trophy,
                  tone: Quests.blueBright,
                  value: '${game.badgesOwned}',
                  label: 'BADGES',
                  idle: idle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFigure extends StatelessWidget {
  const _CardFigure({
    required this.glyph,
    required this.tone,
    required this.value,
    required this.label,
    required this.idle,
  });

  final QuestGlyph glyph;
  final Color tone;
  final String value;
  final String label;
  final double idle;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QuestIcon(
              glyph: glyph,
              size: 17,
              color: tone,
              highlight: Color.lerp(tone, Ink2.bright, 0.5),
              progress: glyph == QuestGlyph.flame ? (idle * 0.6) % 1.0 : 1,
            ),
            const SizedBox(width: 5),
            Text(value, style: T.streakValue.copyWith(color: tone)),
          ],
        ),
        const SizedBox(height: 3),
        Text(label, style: T.rewardLabel.copyWith(fontSize: 10)),
      ],
    ),
  );
}

class _Showcase extends StatelessWidget {
  const _Showcase({required this.owned, required this.idle});

  final List<Reward> owned;
  final double idle;

  @override
  Widget build(BuildContext context) {
    const slots = 6;
    return HudPanel(
      cut: 16,
      accent: Quests.gold,
      edge: Quests.gold.withValues(alpha: 0.18),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      child: SizedBox(
        height: 86,
        child: Row(
          children: <Widget>[
            for (var i = 0; i < slots; i++)
              Expanded(
                child: i < owned.length
                    ? _Badge(reward: owned[i], idle: idle, index: i)
                    : const _EmptySlot(),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.reward, required this.idle, required this.index});

  final Reward reward;
  final double idle;
  final int index;

  @override
  Widget build(BuildContext context) {
    final pulse = 0.5 + 0.5 * math.sin(idle * 1.4 + index);
    return Pressable(
      sound: Sfx.confirm,
      onTap: () => showHudToast(
        context,
        '${reward.name}: ${reward.blurb}',
        tone: reward.tone,
        glyph: reward.glyph,
      ),
      child: Column(
        children: <Widget>[
          PolygonPane(
            size: const Size(44, 50),
            sides: 6,
            cornerRadius: 5,
            edgeWidth: 1.6,
            edge: reward.tone,
            glow: reward.tone.withValues(alpha: 0.7),
            glowStrength: 0.35 + 0.3 * pulse,
            fill: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                reward.tone.withValues(alpha: 0.35),
                const Color(0xCC080B16),
              ],
            ),
            child: QuestIcon(
              glyph: reward.glyph,
              size: 22,
              color: reward.tone,
              highlight: Color.lerp(reward.tone, Ink2.bright, 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                reward.name.toUpperCase(),
                maxLines: 1,
                style: T.navLabel.copyWith(fontSize: 9, color: Ink2.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot();

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      PolygonPane(
        size: const Size(44, 50),
        sides: 6,
        cornerRadius: 5,
        edgeWidth: 1.2,
        edge: Quests.locked.withValues(alpha: 0.35),
        fill: const LinearGradient(
          colors: <Color>[Color(0x66101320), Color(0x66101320)],
        ),
        child: QuestIcon(
          glyph: QuestGlyph.lock,
          size: 16,
          color: Quests.locked.withValues(alpha: 0.6),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'LOCKED',
        style: T.navLabel.copyWith(fontSize: 9, color: Ink2.faint),
      ),
    ],
  );
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({
    required this.achievement,
    required this.t,
    required this.idle,
  });

  final Achievement achievement;
  final double t;
  final double idle;

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    final fill = D.emphasized.transform(t.clamp(0.0, 1.0));
    final tone = a.done ? a.tone : Color.lerp(a.tone, Quests.locked, 0.35)!;
    return HudPanel(
      cut: 14,
      accent: tone,
      accentStrength: a.done ? 1 : 0.6,
      edge: tone.withValues(alpha: a.done ? 0.35 : 0.16),
      rail: true,
      glow: a.done ? 0.15 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 68,
        child: Row(
          children: <Widget>[
            PolygonPane(
              size: const Size(40, 45),
              sides: 6,
              cornerRadius: 5,
              edgeWidth: 1.6,
              edge: tone.withValues(alpha: 0.9),
              glow: tone.withValues(alpha: 0.6),
              glowStrength: a.done ? 0.45 : 0,
              fill: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  tone.withValues(alpha: a.done ? 0.3 : 0.12),
                  const Color(0xCC080B16),
                ],
              ),
              child: QuestIcon(
                glyph: a.done ? QuestGlyph.check : a.glyph,
                size: 19,
                color: tone,
                highlight: Color.lerp(tone, Ink2.bright, 0.5),
                progress: a.done ? ((t - 0.4) / 0.6).clamp(0.0, 1.0) : 1,
                strokeWidth: a.done ? 9 : null,
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
                      Expanded(
                        child: Text(
                          a.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: T.questTitle.copyWith(fontSize: 14.5),
                        ),
                      ),
                      Text(
                        a.done
                            ? 'DONE'
                            : '${grouped((a.current * fill).round())}/${grouped(a.target)}',
                        style: T.questPercent.copyWith(
                          color: tone,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    a.blurb,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: T.questBlurb.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 7),
                  SegmentedMeter(
                    value: a.progress * fill,
                    color: tone,
                    height: 7,
                    segments: 18,
                    shimmer: a.done ? idle : 0,
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

class _ActivityGrid extends StatelessWidget {
  const _ActivityGrid({required this.t, required this.idle});

  final double t;
  final double idle;

  @override
  Widget build(BuildContext context) {
    return HudPanel(
      cut: 16,
      accent: Quests.green,
      edge: Quests.green.withValues(alpha: 0.18),
      rail: true,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 7 / 3.4,
            child: CustomPaint(
              painter: _GridPainter(
                t: t,
                pulse: 0.5 + 0.5 * math.sin(idle * 2.2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text('LESS', style: T.rewardLabel.copyWith(fontSize: 9.5)),
              const SizedBox(width: 6),
              for (var level = 0; level <= 4; level++)
                Container(
                  width: 11,
                  height: 11,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: _GridPainter.colourFor(level),
                ),
              const SizedBox(width: 6),
              Text('MORE', style: T.rewardLabel.copyWith(fontSize: 9.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.t, required this.pulse});

  final double t;
  final double pulse;

  static Color colourFor(int level) => level == 0
      ? const Color(0xFF161B2B)
      : Color.lerp(
          Quests.greenDeep.withValues(alpha: 0.35),
          Quests.greenBright,
          (level - 1) / 3,
        )!;

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 7;
    const rows = 5;
    const gap = 6.0;
    final cell = math.min(
      (size.width - gap * (cols - 1)) / cols,
      (size.height - gap * (rows - 1)) / rows,
    );
    final inset = (size.width - (cell * cols + gap * (cols - 1))) / 2;
    canvas.translate(inset, 0);
    final total = activityGrid.length;
    for (var i = 0; i < total; i++) {
      final r = i ~/ cols;
      final c = i % cols;
      final local = ((t * 1.6) - (r + c) / (rows + cols)).clamp(0.0, 1.0);
      final level = activityGrid[i];
      final rect = Rect.fromLTWH(
        c * (cell + gap),
        r * (cell + gap),
        cell,
        cell,
      );
      final path = chamferPath(rect.size, cut: cell * 0.16).shift(rect.topLeft);
      final colour = Color.lerp(colourFor(0), colourFor(level), local)!;
      if (level == 4 && local >= 1) {
        canvas.drawPath(
          path,
          Paint()
            ..color = Quests.green.withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
      canvas.drawPath(path, Paint()..color = colour);
      if (i == total - 1) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..color = Ink2.bright.withValues(alpha: 0.4 + 0.5 * pulse),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.t != t || old.pulse != pulse;
}
