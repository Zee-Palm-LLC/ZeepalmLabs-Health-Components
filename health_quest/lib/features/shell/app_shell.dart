import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/design.dart';
import '../../core/motion/idle.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/quests.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/painters/polygon.dart';
import '../../widgets/painters/quest_icons.dart';
import '../../widgets/progress_ring.dart';
import '../home/home_screen.dart';
import '../quest/quest_screen.dart';
import '../rewards/rewards_screen.dart';

/// The app after onboarding: four tabs over one background.
///
/// The background is shared, so switching tabs moves only the content. Each
/// tab keeps its own state while it is off-screen, which matters here because
/// the vault remembers what you claimed.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialTab = NavTab.quests});

  final NavTab initialTab;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late NavTab _tab = widget.initialTab;

  void _openQuest(Quest quest) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 520),
        reverseTransitionDuration: const Duration(milliseconds: 420),
        pageBuilder:
            (
              BuildContext context,
              Animation<double> a1,
              Animation<double> a2,
            ) => QuestScreen(quest: quest),
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondary,
              Widget child,
            ) {
              final a = CurvedAnimation(
                parent: animation,
                curve: D.emphasized,
                reverseCurve: D.emphasized.flipped,
              );
              return FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(a),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.97, end: 1).animate(a),
                    child: child,
                  ),
                ),
              );
            },
      ),
    );
  }

  Widget _body() => switch (_tab) {
    NavTab.quests => HomeScreen(
      key: const ValueKey<String>('quests'),
      onOpenQuest: _openQuest,
    ),
    NavTab.rewards => const RewardsScreen(key: ValueKey<String>('rewards')),
    NavTab.stats => const LockedTab(
      key: ValueKey<String>('stats'),
      tab: NavTab.stats,
      unlocksAt: 15,
      blurb:
          'Charts for every stat, week by week. Keep levelling and '
          'the whole history opens up.',
    ),
    NavTab.profile => const LockedTab(
      key: ValueKey<String>('profile'),
      tab: NavTab.profile,
      unlocksAt: 20,
      blurb:
          'Your title, your badges and your guild. Reserved for '
          'warriors who have put the work in.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    // A Scaffold, not a ColoredBox: this is pushed as its own route, and
    // without a Material ancestor every Text renders with Flutter's yellow
    // unmaterialised underline.
    return Scaffold(
      backgroundColor: Quests.page,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _ShellGlow(),
          SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (Widget child, Animation<double> a) =>
                        FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.03),
                              end: Offset.zero,
                            ).animate(a),
                            child: child,
                          ),
                        ),
                    child: _body(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    D.pageGutter,
                    4,
                    D.pageGutter,
                    10 + pad.bottom,
                  ),
                  child: NavBar(
                    current: _tab,
                    onChanged: (NavTab t) => setState(() => _tab = t),
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

/// A violet bloom at the top of the page, drifting. It keeps the dashboard
/// from being flat black and ties it to the onboarding's nebula.
class _ShellGlow extends StatelessWidget {
  const _ShellGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: IdleBuilder(
        builder: (BuildContext context, double s, Widget? _) => CustomPaint(
          painter: _GlowPainter(s),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter(this.seconds);

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    void blob(Offset c, double r, Color color, double alpha) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    blob(
      Offset(
        size.width * (0.22 + 0.05 * math.sin(seconds * 0.16)),
        size.height * 0.06,
      ),
      size.width * 0.8,
      Quests.purple,
      0.16,
    );
    blob(
      Offset(
        size.width * (0.86 + 0.04 * math.cos(seconds * 0.12)),
        size.height * 0.34,
      ),
      size.width * 0.6,
      Quests.blue,
      0.09,
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.seconds != seconds;
}

/// Stats and Profile, gated on level.
///
/// A tab that does nothing is worse than one that says why. This one states
/// the requirement and shows how far off it is, which is how a game handles
/// a feature you have not earned yet.
class LockedTab extends StatelessWidget {
  const LockedTab({
    super.key,
    required this.tab,
    required this.unlocksAt,
    required this.blurb,
  });

  final NavTab tab;
  final int unlocksAt;
  final String blurb;

  @override
  Widget build(BuildContext context) {
    const player = Player.you;
    final progress = (player.level / unlocksAt).clamp(0.0, 1.0);

    return IdleBuilder(
      builder: (BuildContext context, double idle, Widget? _) {
        final pulse = 0.5 + 0.5 * math.sin(idle * 1.5);
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ProgressRing(
                  value: progress,
                  size: 132,
                  stroke: 8,
                  color: Quests.purple,
                  trackColor: const Color(0xFF1B2133),
                  glow: 0.35 + 0.2 * pulse,
                  child: PolygonPane(
                    size: const Size(62, 70),
                    sides: 6,
                    cornerRadius: 7,
                    edgeWidth: 1.6,
                    edge: Quests.purpleBright.withValues(alpha: 0.7),
                    glow: Quests.purple.withValues(alpha: 0.5),
                    glowStrength: 0.3 + 0.3 * pulse,
                    fill: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0xFF241344), Color(0xFF0C0E1C)],
                    ),
                    child: QuestIcon(
                      glyph: QuestGlyph.lock,
                      size: 26,
                      color: Quests.purpleBright,
                      highlight: Ink2.bright,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(tab.label, style: T.questHeadline.copyWith(fontSize: 26)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Quests.purple.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: Quests.purple.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    'UNLOCKS AT LEVEL $unlocksAt',
                    style: T.rewardLabel.copyWith(color: Quests.purpleBright),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  blurb,
                  textAlign: TextAlign.center,
                  style: T.questBlurb.copyWith(height: 1.5),
                ),
                const SizedBox(height: 18),
                Text(
                  'Level ${player.level} · ${unlocksAt - player.level} to go',
                  style: T.sectionMeta,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
