import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/design.dart';
import '../../core/motion/entrance.dart';
import '../../core/motion/idle.dart';
import '../../core/motion/pressable.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/game_state.dart';
import '../../data/social.dart';
import '../../widgets/hud.dart';
import '../../widgets/hud_kit.dart';
import '../../widgets/painters/polygon.dart';
import '../../widgets/painters/quest_icons.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
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
    final game = GameState.instance;
    return HudPage(
      kicker: 'INBOX',
      title: 'NOTIFICATIONS',
      tint: Quests.rose,
      trailing: ListenableBuilder(
        listenable: game,
        builder: (BuildContext context, Widget? _) => AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: game.unreadCount > 0 ? 1 : 0.4,
          child: Pressable(
            sound: game.unreadCount > 0 ? Sfx.confirm : Sfx.denied,
            onTap: () {
              if (game.unreadCount == 0) return;
              game.markAllRead();
              showHudToast(
                context,
                'All caught up.',
                tone: Quests.green,
                glyph: QuestGlyph.check,
              );
            },
            child: const HudChip(label: 'READ ALL', tone: Quests.rose),
          ),
        ),
      ),
      body: IdleBuilder(
        builder: (BuildContext context, double idle, Widget? _) =>
            AnimatedBuilder(
              animation: Listenable.merge(<Listenable>[_in, game]),
              builder: (BuildContext context, Widget? _) {
                final t = _in.value;
                final today = GameNotification.all
                    .where((GameNotification n) => n.today)
                    .toList();
                final earlier = GameNotification.all
                    .where((GameNotification n) => !n.today)
                    .toList();
                var index = 0;

                Widget item(GameNotification n) {
                  final p = D.stagger(t, 0.12, index++, 0.07, 0.34);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Slide(
                      t: D.outExpo.transform(p),
                      child: _NotificationCard(
                        notification: n,
                        read: game.isRead(n),
                        idle: idle,
                        onTap: () => game.markRead(n),
                      ),
                    ),
                  );
                }

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    D.pageGutter,
                    6,
                    D.pageGutter,
                    16 + MediaQuery.paddingOf(context).bottom,
                  ),
                  children: <Widget>[
                    Rise(
                      t: D.headerIn.transform(t),
                      distance: 10,
                      child: HudHeading(
                        title: 'TODAY',
                        accent: Quests.rose,
                        trailing: Text(
                          game.unreadCount == 0
                              ? 'ALL READ'
                              : '${game.unreadCount} UNREAD',
                          style: T.rewardLabel,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final n in today) item(n),
                    const SizedBox(height: 12),
                    Rise(
                      t: D.sectionIn.transform(t),
                      distance: 10,
                      child: const HudHeading(
                        title: 'EARLIER',
                        accent: Quests.purple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final n in earlier) item(n),
                  ],
                );
              },
            ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.read,
    required this.idle,
    required this.onTap,
  });

  final GameNotification notification;
  final bool read;
  final double idle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final tone = n.tone;
    final pulse = 0.5 + 0.5 * math.sin(idle * 2.6);
    return Pressable(
      sound: read ? Sfx.tap : Sfx.tick,
      pressedScale: 0.98,
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: read ? 0.72 : 1,
        child: HudPanel(
          cut: 14,
          accent: tone,
          accentStrength: read ? 0.4 : 1,
          edge: tone.withValues(alpha: read ? 0.12 : 0.4),
          rail: !read,
          glow: read ? 0 : 0.15 + 0.1 * pulse,
          gradient: LinearGradient(
            colors: <Color>[
              tone.withValues(alpha: read ? 0.04 : 0.14),
              tone.withValues(alpha: 0),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PolygonPane(
                size: const Size(38, 43),
                sides: 6,
                cornerRadius: 5,
                edgeWidth: 1.5,
                edge: tone.withValues(alpha: 0.85),
                glow: tone.withValues(alpha: 0.6),
                glowStrength: read ? 0 : 0.4,
                fill: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    tone.withValues(alpha: 0.25),
                    const Color(0xCC080B16),
                  ],
                ),
                child: QuestIcon(
                  glyph: n.glyph,
                  size: 18,
                  color: tone,
                  highlight: Color.lerp(tone, Ink2.bright, 0.5),
                  progress: n.glyph == QuestGlyph.flame
                      ? (idle * 0.6) % 1.0
                      : 1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            n.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: T.questTitle.copyWith(fontSize: 14.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          n.time,
                          style: T.questBlurb.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.body,
                      style: T.questBlurb.copyWith(fontSize: 12.5, height: 1.4),
                    ),
                  ],
                ),
              ),
              if (!read) ...<Widget>[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tone,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: tone.withValues(alpha: 0.4 + 0.4 * pulse),
                          blurRadius: 5 + 4 * pulse,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
