import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/sfx.dart';
import '../../../core/design.dart';
import '../../../core/motion/entrance.dart';
import '../../../core/motion/idle.dart';
import '../../../core/motion/pressable.dart';
import '../../../core/palette.dart';
import '../../../core/type.dart';
import '../../../data/quests.dart';
import '../../../widgets/hud.dart';
import '../../../widgets/painters/polygon.dart';
import '../../../widgets/painters/quest_icons.dart';

Future<void> showVictory(
  BuildContext context, {
  required Quest quest,
  required int xp,
  required int levelsGained,
  required int newLevel,
}) {
  GameAudio.play(Sfx.victory);
  Haptics.buzz(Buzz.heavy);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0xE6020309),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder:
        (BuildContext context, Animation<double> a1, Animation<double> a2) =>
            _Victory(
              quest: quest,
              xp: xp,
              levelsGained: levelsGained,
              newLevel: newLevel,
            ),
    transitionBuilder:
        (
          BuildContext context,
          Animation<double> a,
          Animation<double> s,
          Widget child,
        ) => FadeTransition(opacity: a, child: child),
  );
}

class _Victory extends StatefulWidget {
  const _Victory({
    required this.quest,
    required this.xp,
    required this.levelsGained,
    required this.newLevel,
  });

  final Quest quest;
  final int xp;
  final int levelsGained;
  final int newLevel;

  @override
  State<_Victory> createState() => _VictoryState();
}

class _VictoryState extends State<_Victory>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  bool _coinPlayed = false;
  bool _levelPlayed = false;

  static const Interval _trophy = Interval(0.0, 0.4, curve: D.pop);
  static const Interval _title = Interval(0.18, 0.46, curve: D.outExpo);
  static const Interval _count = Interval(
    0.3,
    0.62,
    curve: Curves.easeOutCubic,
  );
  static const Interval _level = Interval(0.62, 0.86, curve: D.softPop);
  static const Interval _button = Interval(0.7, 1.0, curve: D.softPop);

  @override
  void initState() {
    super.initState();
    _c.addListener(_cues);
    _c.forward();
  }

  void _cues() {
    if (!_coinPlayed && _c.value >= _count.end) {
      _coinPlayed = true;
      GameAudio.play(Sfx.coin);
    }
    if (widget.levelsGained > 0 && !_levelPlayed && _c.value >= _level.begin) {
      _levelPlayed = true;
      GameAudio.play(Sfx.levelUp);
      Haptics.buzz(Buzz.heavy);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tone = widget.quest.tone;
    return Material(
      type: MaterialType.transparency,
      child: IdleBuilder(
        builder: (BuildContext context, double idle, Widget? _) => AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? _) {
            final t = _c.value;
            final trophy = _trophy.transform(t);
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CustomPaint(
                  painter: _RaysPainter(
                    turn: idle * 0.12,
                    strength: Curves.easeOut.transform(
                      (t / 0.4).clamp(0.0, 1.0),
                    ),
                    tone: Quests.gold,
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Transform.scale(
                          scale: trophy.clamp(0.0, 1.4),
                          child: Transform.rotate(
                            angle: (1 - trophy) * -0.5,
                            child: PolygonPane(
                              size: const Size(128, 144),
                              sides: 6,
                              cornerRadius: 12,
                              edgeWidth: 2.4,
                              edge: Quests.goldBright,
                              glow: Quests.gold.withValues(alpha: 0.9),
                              glowStrength: 0.7 + 0.3 * math.sin(idle * 2.4),
                              fill: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[
                                  Color(0xFF6B4A0B),
                                  Color(0xFF140D02),
                                ],
                              ),
                              child: const QuestIcon(
                                glyph: QuestGlyph.trophy,
                                size: 64,
                                color: Quests.gold,
                                highlight: Quests.goldBright,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Rise(
                          t: _title.transform(t),
                          distance: 18,
                          child: Column(
                            children: <Widget>[
                              Text(
                                'QUEST COMPLETE',
                                style: T.questKicker.copyWith(color: tone),
                              ),
                              const SizedBox(height: 8),
                              SweepReveal(
                                t: _title.transform(t),
                                child: Text(
                                  'VICTORY!',
                                  style: T.yourHealth.copyWith(
                                    fontSize: 48,
                                    shadows: <Shadow>[
                                      Shadow(
                                        color: Quests.gold.withValues(
                                          alpha: 0.6,
                                        ),
                                        blurRadius: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.quest.title,
                                textAlign: TextAlign.center,
                                style: T.questCheer,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Rise(
                          t: _count.transform(t) > 0 ? 1 : 0,
                          distance: 0,
                          child: HudPanel(
                            cut: 14,
                            fill: const Color(0xE60E1120),
                            accent: Quests.gold,
                            edge: Quests.gold.withValues(alpha: 0.5),
                            glow: 0.4,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const QuestIcon(
                                    glyph: QuestGlyph.shield,
                                    size: 22,
                                    color: Quests.gold,
                                    highlight: Quests.goldBright,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '+${grouped((widget.xp * _count.transform(t)).round())} XP',
                                    style: T.rewardValue.copyWith(fontSize: 30),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '×${Player.you.multiplier} STREAK',
                                    style: T.rewardLabel.copyWith(
                                      color: Quests.blueBright,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (widget.levelsGained > 0) ...<Widget>[
                          const SizedBox(height: 14),
                          Transform.scale(
                            scale: _level.transform(t).clamp(0.0, 1.3),
                            child: Text(
                              'LEVEL UP!  LV ${widget.newLevel}',
                              style: T.levelUp.copyWith(
                                color: Quests.purpleBright,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 34),
                        Rise(
                          t: _button.transform(t),
                          distance: 24,
                          scaleFrom: 0.9,
                          child: Pressable(
                            sound: Sfx.confirm,
                            enabled: t > 0.7,
                            onTap: () {
                              unawaited(Navigator.of(context).maybePop());
                            },
                            child: BevelButton(
                              height: D.ctaHeight,
                              cut: 17,
                              gradient: const LinearGradient(
                                colors: <Color>[
                                  Color(0xFFFFD166),
                                  Color(0xFFF5A623),
                                ],
                              ),
                              glowColor: Quests.gold,
                              idle: idle,
                              child: Text(
                                'CONTINUE',
                                style: T.ctaDark.copyWith(
                                  color: const Color(0xFF2A1A02),
                                ),
                              ),
                            ),
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
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  const _RaysPainter({
    required this.turn,
    required this.strength,
    required this.tone,
  });

  final double turn;
  final double strength;
  final Color tone;

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0) return;
    final c = Offset(size.width / 2, size.height * 0.36);
    final r = size.longestSide;
    const rays = 14;
    for (var i = 0; i < rays; i++) {
      final a = turn + i * 2 * math.pi / rays;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + math.cos(a - 0.09) * r, c.dy + math.sin(a - 0.09) * r)
        ..lineTo(c.dx + math.cos(a + 0.09) * r, c.dy + math.sin(a + 0.09) * r)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              tone.withValues(alpha: 0.22 * strength),
              tone.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r * 0.55)),
      );
    }
    canvas.drawCircle(
      c,
      140,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            tone.withValues(alpha: 0.35 * strength),
            tone.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: 140)),
    );
  }

  @override
  bool shouldRepaint(_RaysPainter old) =>
      old.turn != turn || old.strength != strength || old.tone != tone;
}
