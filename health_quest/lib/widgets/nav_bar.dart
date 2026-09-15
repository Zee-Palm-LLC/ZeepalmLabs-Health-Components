import 'package:flutter/widgets.dart';

import '../core/design.dart';
import '../core/motion/pressable.dart';
import '../core/palette.dart';
import '../core/type.dart';
import 'painters/quest_icons.dart';

/// The four tabs from the reference.
enum NavTab { quests, stats, rewards, profile }

extension NavTabInfo on NavTab {
  String get label => switch (this) {
        NavTab.quests => 'QUESTS',
        NavTab.stats => 'STATS',
        NavTab.rewards => 'REWARDS',
        NavTab.profile => 'PROFILE',
      };

  QuestGlyph get glyph => switch (this) {
        NavTab.quests => QuestGlyph.swords,
        NavTab.stats => QuestGlyph.bars,
        NavTab.rewards => QuestGlyph.trophy,
        NavTab.profile => QuestGlyph.person,
      };
}

/// The bottom bar.
///
/// The selected tab sits in a violet pane that slides between slots rather
/// than cutting, so the eye can follow where it went. The icon and label
/// brighten on arrival; nothing else moves.
class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.current,
    required this.onChanged,
    this.t = 1,
  });

  final NavTab current;
  final ValueChanged<NavTab> onChanged;

  /// Entrance progress.
  final double t;

  @override
  Widget build(BuildContext context) {
    final settled = t.clamp(0.0, 1.0);
    return Opacity(
      opacity: settled,
      child: Transform.translate(
        offset: Offset(0, (1 - t) * 26),
        child: Container(
          height: D.navHeight,
          decoration: BoxDecoration(
            color: Quests.card.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(D.navRadius),
            border: Border.all(color: Quests.cardEdge),
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final slot = c.maxWidth / NavTab.values.length;
              return Stack(
                children: <Widget>[
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 420),
                    curve: D.emphasized,
                    left: slot * current.index + 5,
                    top: 5,
                    width: slot - 10,
                    bottom: 5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Quests.purple.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(D.navRadius - 7),
                        border: Border.all(
                          color: Quests.purple.withValues(alpha: 0.55),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Quests.purple.withValues(alpha: 0.28),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      for (final tab in NavTab.values)
                        Expanded(
                          child: Pressable(
                            onTap: () => onChanged(tab),
                            pressedScale: 0.9,
                            child: _Tab(tab: tab, selected: tab == current),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.tab, required this.selected});

  final NavTab tab;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Quests.purpleBright : Ink2.muted;
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedScale(
            duration: const Duration(milliseconds: 320),
            curve: D.softPop,
            scale: selected ? 1.08 : 1,
            child: QuestIcon(
              glyph: tab.glyph,
              size: 24,
              color: color,
              highlight: selected ? Ink2.bright : color,
              strokeWidth: 7,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 320),
            style: T.navLabel.copyWith(color: color),
            child: Text(tab.label),
          ),
        ],
      ),
    );
  }
}
