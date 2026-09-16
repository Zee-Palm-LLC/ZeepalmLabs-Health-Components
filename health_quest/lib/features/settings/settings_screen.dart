import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/design.dart';
import '../../core/motion/entrance.dart';
import '../../core/motion/pressable.dart';
import '../../core/palette.dart';
import '../../core/settings.dart';
import '../../core/type.dart';
import '../../widgets/hud.dart';
import '../../widgets/hud_kit.dart';
import '../../widgets/painters/quest_icons.dart';
import '../auth/auth_flow.dart';
import '../auth/login_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
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

  void _toOnboarding() {
    Navigator.of(context).pushAndRemoveUntil<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (
              BuildContext context,
              Animation<double> a1,
              Animation<double> a2,
            ) => const OnboardingScreen(),
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> a,
              Animation<double> s,
              Widget child,
            ) => FadeTransition(opacity: a, child: child),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _signOut() async {
    final ok = await showHudConfirm(
      context,
      title: 'LEAVE THE REALM?',
      message:
          'You will be signed out. Your level, streak and badges are '
          'saved and waiting when you return.',
      confirmLabel: 'SIGN OUT',
    );
    if (!ok || !mounted) return;
    Navigator.of(context).pushAndRemoveUntil<void>(
      authRoute(const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = GameSettings.instance;
    return HudPage(
      kicker: 'SYSTEM',
      title: 'SETTINGS',
      tint: Quests.blue,
      body: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_in, settings]),
        builder: (BuildContext context, Widget? _) {
          final t = _in.value;
          var section = 0;
          Widget block(String title, Color accent, List<Widget> rows) {
            final p = D.outExpo.transform(
              D.stagger(t, 0.05, section++, 0.1, 0.4),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Rise(
                t: p,
                distance: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    HudHeading(title: title, accent: accent),
                    const SizedBox(height: 12),
                    HudPanel(
                      cut: 16,
                      accent: accent,
                      edge: accent.withValues(alpha: 0.18),
                      rail: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      child: Column(
                        children: <Widget>[
                          for (var i = 0; i < rows.length; i++) ...<Widget>[
                            if (i > 0)
                              Container(height: 1, color: Quests.divider),
                            rows[i],
                          ],
                        ],
                      ),
                    ),
                  ],
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
              block('AUDIO', Quests.purple, <Widget>[
                _SettingRow(
                  glyph: QuestGlyph.bell,
                  tone: Quests.purple,
                  title: 'Sound effects',
                  subtitle: 'Taps, rewards and level-ups',
                  control: HudSwitch(
                    value: settings.sound,
                    tone: Quests.purple,
                    onChanged: (bool v) => settings.sound = v,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: settings.sound ? 1 : 0.35,
                  child: IgnorePointer(
                    ignoring: !settings.sound,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text('VOLUME', style: T.cardLabel),
                              const Spacer(),
                              Text(
                                '${(settings.volume * 100).round()}%',
                                style: T.questPercent.copyWith(
                                  color: Quests.purpleBright,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          VolumeDial(
                            value: settings.volume,
                            onChanged: (double v) => settings.volume = v,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _SettingRow(
                  glyph: QuestGlyph.crown,
                  tone: Quests.gold,
                  title: 'Test the fanfare',
                  subtitle: 'Hear a level-up at this volume',
                  control: Pressable(
                    sound: Sfx.levelUp,
                    onTap: () {},
                    child: const HudChip(label: 'PLAY', tone: Quests.gold),
                  ),
                ),
              ]),
              block('FEEL', Quests.blue, <Widget>[
                _SettingRow(
                  glyph: QuestGlyph.shield,
                  tone: Quests.blue,
                  title: 'Haptics',
                  subtitle: 'A buzz on every press',
                  control: HudSwitch(
                    value: settings.haptics,
                    tone: Quests.blue,
                    onChanged: (bool v) {
                      settings.haptics = v;
                      if (v) Haptics.buzz(Buzz.medium);
                    },
                  ),
                ),
              ]),
              block('REMINDERS', Quests.green, <Widget>[
                _SettingRow(
                  glyph: QuestGlyph.swords,
                  tone: Quests.green,
                  title: 'Daily quest reminder',
                  subtitle: 'A nudge at 9:00 each morning',
                  control: HudSwitch(
                    value: settings.reminders,
                    onChanged: (bool v) => settings.reminders = v,
                  ),
                ),
                _SettingRow(
                  glyph: QuestGlyph.flame,
                  tone: Quests.rose,
                  title: 'Streak alerts',
                  subtitle: 'Warn me before a streak breaks',
                  control: HudSwitch(
                    value: settings.streakAlerts,
                    tone: Quests.rose,
                    onChanged: (bool v) => settings.streakAlerts = v,
                  ),
                ),
              ]),
              block('ACCOUNT', Quests.rose, <Widget>[
                _SettingRow(
                  glyph: QuestGlyph.back,
                  tone: Quests.blueBright,
                  title: 'Replay the intro',
                  subtitle: 'Watch the opening again',
                  onTap: _toOnboarding,
                ),
                _SettingRow(
                  glyph: QuestGlyph.lock,
                  tone: Quests.rose,
                  title: 'Sign out',
                  subtitle: 'player@healthquest.app',
                  onTap: _signOut,
                ),
              ]),
              Center(
                child: Text(
                  'HEALTH QUEST  ·  v1.0.0',
                  style: T.rewardLabel.copyWith(color: Ink2.faint),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.glyph,
    required this.tone,
    required this.title,
    required this.subtitle,
    this.control,
    this.onTap,
  });

  final QuestGlyph glyph;
  final Color tone;
  final String title;
  final String subtitle;
  final Widget? control;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = SizedBox(
      height: 64,
      child: Row(
        children: <Widget>[
          QuestIcon(
            glyph: glyph,
            size: 20,
            color: tone,
            highlight: Color.lerp(tone, Ink2.bright, 0.45),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: T.questTitle.copyWith(fontSize: 14.5),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: T.questBlurb.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          control ??
              const QuestIcon(
                glyph: QuestGlyph.chevron,
                size: 16,
                color: Ink2.muted,
                strokeWidth: 8,
              ),
        ],
      ),
    );
    if (onTap == null) return row;
    return Pressable(
      onTap: onTap,
      sound: Sfx.open,
      pressedScale: 0.98,
      child: row,
    );
  }
}

class VolumeDial extends StatefulWidget {
  const VolumeDial({super.key, required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<VolumeDial> createState() => _VolumeDialState();
}

class _VolumeDialState extends State<VolumeDial> {
  static const int _steps = 10;

  void _setFrom(Offset local, double width) {
    final step = ((local.dx / width) * _steps).ceil().clamp(0, _steps);
    final v = step / _steps;
    if ((v - widget.value).abs() < 0.001) return;
    widget.onChanged(v);
    Haptics.buzz(Buzz.selection);
    GameAudio.play(Sfx.tick);
  }

  @override
  Widget build(BuildContext context) {
    final lit = (widget.value * _steps).round();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) => Semantics(
        slider: true,
        value: '${(widget.value * 100).round()}%',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (TapDownDetails d) =>
              _setFrom(d.localPosition, c.maxWidth),
          onHorizontalDragUpdate: (DragUpdateDetails d) =>
              _setFrom(d.localPosition, c.maxWidth),
          child: SizedBox(
            height: 34,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (var i = 0; i < _steps; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        height: 12 + 22 * (i + 1) / _steps,
                        child: CustomPaint(
                          painter: _CellPainter(
                            on: i < lit,
                            colour: Color.lerp(
                              Quests.purple,
                              Quests.blue,
                              i / (_steps - 1),
                            )!,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CellPainter extends CustomPainter {
  const _CellPainter({required this.on, required this.colour});

  final bool on;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final path = chamferPath(
      size,
      cut: 3,
      bottomLeft: false,
      bottomRight: false,
    );
    if (on) {
      canvas.drawPath(
        path,
        Paint()
          ..color = colour.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: on
              ? <Color>[Color.lerp(colour, Colors.white, 0.35)!, colour]
              : const <Color>[Color(0xFF1B2133), Color(0xFF151A29)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_CellPainter old) => old.on != on || old.colour != colour;
}
