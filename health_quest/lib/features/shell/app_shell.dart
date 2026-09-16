import 'package:flutter/material.dart';

import '../../core/design.dart';
import '../../core/motion/routes.dart';
import '../../core/palette.dart';
import '../../data/quests.dart';
import '../../widgets/hud_kit.dart';
import '../../widgets/nav_bar.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../quest/quest_screen.dart';
import '../rewards/rewards_screen.dart';
import '../stats/stats_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialTab = NavTab.quests});

  final NavTab initialTab;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late NavTab _tab = widget.initialTab;

  void _openQuest(Quest quest) {
    Navigator.of(context).push<void>(hudRoute(QuestScreen(quest: quest)));
  }

  void _go(NavTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
  }

  Widget _body() => switch (_tab) {
    NavTab.quests => HomeScreen(
      key: const ValueKey<String>('quests'),
      onOpenQuest: _openQuest,
      onOpenProfile: () => _go(NavTab.profile),
    ),
    NavTab.stats => const StatsScreen(key: ValueKey<String>('stats')),
    NavTab.rewards => const RewardsScreen(key: ValueKey<String>('rewards')),
    NavTab.profile => ProfileScreen(
      key: const ValueKey<String>('profile'),
      onOpenVault: () => _go(NavTab.rewards),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: Quests.page,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const ShellGlow(),
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
