import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/motion/idle.dart';
import '../../core/motion/pressable.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/game_state.dart';
import '../../data/main_quest.dart';
import '../../widgets/hud.dart';
import '../../widgets/hud_kit.dart';
import '../../widgets/painters/polygon.dart';
import '../../widgets/painters/quest_icons.dart';
import 'auth_flow.dart';
import 'widgets/auth_widgets.dart';

class MainQuestScreen extends StatefulWidget {
  const MainQuestScreen({super.key});

  @override
  State<MainQuestScreen> createState() => _MainQuestScreenState();
}

class _MainQuestScreenState extends State<MainQuestScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _charge = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  MainQuest? _quest;
  Difficulty _difficulty = Difficulty.warrior;
  bool _busy = false;
  int _shake = 0;

  @override
  void dispose() {
    _charge.dispose();
    super.dispose();
  }

  Future<void> _begin() async {
    if (_busy) return;
    final quest = _quest;
    if (quest == null) {
      GameAudio.play(Sfx.denied);
      Haptics.buzz(Buzz.heavy);
      setState(() => _shake++);
      return;
    }
    setState(() => _busy = true);
    GameAudio.play(Sfx.charge);
    Haptics.buzz(Buzz.medium);
    await _charge.forward(from: 0);
    if (!mounted) return;
    GameAudio.play(Sfx.levelUp);
    Haptics.buzz(Buzz.heavy);
    final game = GameState.instance..chooseMainQuest(quest, _difficulty);
    final greeting = game.name.endsWith('!') ? game.name : '${game.name}!';
    showHudToast(
      context,
      'Welcome, $greeting Your first quest is ready.',
      tone: quest.tone,
      glyph: QuestGlyph.crown,
    );
    enterGame(context);
  }

  @override
  Widget build(BuildContext context) {
    final tone = _quest?.tone ?? Quests.purple;
    return AuthScaffold(
      kicker: 'STEP 2 OF 2',
      lineOne: 'CHOOSE YOUR',
      lineTwo: 'MAIN QUEST',
      subtitle: 'Pick the path your first quests follow. You can change it '
          'later.',
      tone: tone,
      children: <Widget>[
        Shake(
          trigger: _shake,
          child: Column(
            children: <Widget>[
              for (final q in MainQuest.values) ...<Widget>[
                _PathCard(
                  quest: q,
                  selected: q == _quest,
                  dimmed: _quest != null && q != _quest,
                  onTap: _busy ? null : () => setState(() => _quest = q),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          alignment: Alignment.topCenter,
          child: _shake > 0 && _quest == null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Pick a path to begin.',
                    style: T.questBlurb.copyWith(
                      color: Quests.rose,
                      fontSize: 13,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: 12),
        HudHeading(title: 'DIFFICULTY', accent: tone),
        const SizedBox(height: 12),
        HudSegmented<Difficulty>(
          options: <Difficulty, String>{
            for (final d in Difficulty.values) d: d.label,
          },
          value: _difficulty,
          tone: tone,
          height: 42,
          onChanged: (Difficulty d) => setState(() => _difficulty = d),
        ),
        const SizedBox(height: 10),
        _DifficultyNote(difficulty: _difficulty, tone: tone),
        const SizedBox(height: 26),
        AnimatedBuilder(
          animation: _charge,
          builder: (BuildContext context, Widget? _) => AuthCta(
            label: 'BEGIN ADVENTURE',
            busyLabel: 'OPENING THE GATES',
            busy: _busy,
            charge: _charge.value,
            onTap: () => unawaited(_begin()),
          ),
        ),
      ],
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.quest,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final MainQuest quest;
  final bool selected;
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = quest.tone;
    return Semantics(
      selected: selected,
      button: true,
      child: Pressable(
        sound: selected ? null : Sfx.toggleOn,
        pressedScale: 0.97,
        enabled: onTap != null,
        onTap: onTap,
        child: IdleBuilder(
          builder: (BuildContext context, double idle, Widget? _) =>
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: selected ? 1 : 0),
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                builder: (BuildContext context, double v, Widget? _) {
                  final pulse = 0.5 + 0.5 * math.sin(idle * 2.2);
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 260),
                    opacity: dimmed ? 0.55 : 1,
                    child: HudPanel(
                      cut: 15,
                      fill: const Color(0xE60B0E19),
                      accent: tone,
                      accentStrength: 0.45 + 0.55 * v,
                      edge: Color.lerp(
                        tone.withValues(alpha: 0.18),
                        tone.withValues(alpha: 0.8),
                        v,
                      )!,
                      rail: true,
                      glow: v * (0.3 + 0.15 * pulse),
                      gradient: LinearGradient(
                        colors: <Color>[
                          tone.withValues(alpha: 0.08 + 0.16 * v),
                          tone.withValues(alpha: 0),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Row(
                        children: <Widget>[
                          PolygonPane(
                            size: const Size(50, 56),
                            sides: 6,
                            cornerRadius: 6,
                            edgeWidth: 1.7,
                            edge: tone.withValues(alpha: 0.55 + 0.4 * v),
                            glow: tone.withValues(alpha: 0.7),
                            glowStrength: 0.15 + 0.5 * v,
                            fill: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                tone.withValues(alpha: 0.18 + 0.2 * v),
                                const Color(0xCC080B16),
                              ],
                            ),
                            child: Transform.scale(
                              scale: 1 + 0.15 * math.sin(v * math.pi),
                              child: QuestIcon(
                                glyph: quest.glyph,
                                size: 26,
                                color: tone,
                                highlight: Color.lerp(tone, Ink2.bright, 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  quest.label,
                                  style: T.sectionTitle.copyWith(
                                    fontSize: 15.5,
                                    color: Color.lerp(
                                      Ink2.primary,
                                      Ink2.bright,
                                      v,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  quest.blurb,
                                  style: T.questBlurb.copyWith(fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: <Widget>[
                                    QuestIcon(
                                      glyph: QuestGlyph.swords,
                                      size: 12,
                                      color: tone,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        quest.starter,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: T.questBlurb.copyWith(
                                          fontSize: 12,
                                          color: Color.lerp(tone, Ink2.bright, 0.3),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          _Radio(tone: tone, value: v),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.tone, required this.value});

  final Color tone;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tone.withValues(alpha: 0.2 * value),
        border: Border.all(
          color: Color.lerp(Quests.locked, tone, value)!,
          width: 1.6,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(color: tone.withValues(alpha: 0.4 * value), blurRadius: 10),
        ],
      ),
      child: value <= 0.01
          ? null
          : Center(
              child: QuestIcon(
                glyph: QuestGlyph.check,
                size: 14,
                color: Color.lerp(tone, Ink2.bright, 0.35)!,
                progress: value,
              ),
            ),
    );
  }
}

class _DifficultyNote extends StatelessWidget {
  const _DifficultyNote({required this.difficulty, required this.tone});

  final Difficulty difficulty;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 240),
              opacity: i < difficulty.stars ? 1 : 0.25,
              child: QuestIcon(
                glyph: QuestGlyph.flame,
                size: 15,
                color: Quests.gold,
                highlight: Quests.goldBright,
              ),
            ),
          ),
        const SizedBox(width: 10),
        Text(
          difficulty.blurb,
          style: T.questBlurb.copyWith(fontSize: 13, color: Ink2.secondary),
        ),
      ],
    );
  }
}
