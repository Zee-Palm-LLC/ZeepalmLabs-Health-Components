import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/data.dart';
import '../core/fold.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../today/today_view.dart';
import '../trends/meds_card.dart';
import '../trends/trends_view.dart';
import '../widgets/kit.dart';

/// Picks the layout from the space it gets: a single column with tabs on a
/// phone, or Today | hinge | Trends when the screen is open or wide.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  int tab = 0;

  void go(int index) {
    if (index == tab) return;
    HapticFeedback.selectionClick();
    setState(() => tab = index);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Tone.canvas,
        body: LayoutBuilder(
          builder: (context, box) {
            final fold = Fold.of(context, box.biggest);
            return fold.spanned ? _Spread(fold: fold) : _Column(tab: tab, onTab: go);
          },
        ),
      ),
    );
  }
}

class _Spread extends StatelessWidget {
  const _Spread({required this.fold});

  final Fold fold;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final seam = fold.seam;
    return Row(
      key: const ValueKey('spread'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: seam.left,
          child: TodayView(spanned: true, padding: EdgeInsets.fromLTRB(20 + pad.left, pad.top + 16, Fold.clearance, pad.bottom + 20)),
        ),
        SizedBox(width: seam.width),
        Expanded(
          child: Reveal(
            delay: 140,
            duration: 760,
            rise: 0,
            from: const Offset(56, 0),
            child: TrendsView(padding: EdgeInsets.fromLTRB(Fold.clearance, pad.top + 16, 20 + pad.right, pad.bottom + 20)),
          ),
        ),
      ],
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.tab, required this.onTab});

  final int tab;
  final ValueChanged<int> onTab;

  static const barHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final inset = EdgeInsets.fromLTRB(20 + pad.left, pad.top + 12, 20 + pad.right, pad.bottom + barHeight + 20);
    final pages = [
      TodayView(spanned: false, padding: inset),
      TrendsView(padding: inset, showMeds: false),
      _MedsPage(padding: inset),
      _ProfilePage(padding: inset),
    ];
    return Stack(
      key: const ValueKey('column'),
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            reverseDuration: const Duration(milliseconds: 160),
            switchInCurve: const Interval(0.3, 1, curve: swift),
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
            transitionBuilder: (child, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(a), child: child),
            ),
            child: KeyedSubtree(key: ValueKey(tab), child: pages[tab]),
          ),
        ),
        Positioned(left: 0, right: 0, bottom: 0, child: TabBarStrip(tab: tab, onTab: onTab)),
      ],
    );
  }
}

class TabBarStrip extends StatelessWidget {
  const TabBarStrip({super.key, required this.tab, required this.onTab});

  static const items = [(Glyph.grid, 'Today'), (Glyph.trend, 'Trends'), (Glyph.pill, 'Meds'), (Glyph.user, 'Profile')];

  final int tab;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Container(
      padding: EdgeInsets.only(bottom: pad.bottom, left: 8 + pad.left, right: 8 + pad.right),
      decoration: const BoxDecoration(color: Tone.card, border: Border(top: BorderSide(color: Tone.line))),
      child: SizedBox(
        height: _Column.barHeight,
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth / items.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 420),
                  curve: settle,
                  top: 0,
                  left: w * tab + w / 2 - 12,
                  child: Container(width: 24, height: 3, decoration: BoxDecoration(color: Tone.ink, borderRadius: BorderRadius.circular(999))),
                ),
                Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: i == tab,
                          label: items[i].$2,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onTab(i),
                            child: ExcludeSemantics(
                              child: TweenAnimationBuilder<Color?>(
                                tween: ColorTween(end: i == tab ? Tone.ink : Tone.sub),
                                duration: const Duration(milliseconds: 260),
                                builder: (context, c, _) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedScale(
                                      scale: i == tab ? 1.08 : 1,
                                      duration: const Duration(milliseconds: 360),
                                      curve: settle,
                                      child: GlyphIcon(items[i].$1, size: 22, color: c!, weight: i == tab ? 18 : 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(items[i].$2, style: Typo.tab.copyWith(color: c)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MedsPage extends StatelessWidget {
  const _MedsPage({required this.padding});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Tue, Oct 27', style: Typo.date), const SizedBox(height: 2), Text('Medications', style: Typo.title)],
            ),
          ),
          const SizedBox(height: 14),
          const Reveal(delay: 80, child: MedsCard(veiled: true)),
          const SizedBox(height: 12),
          Reveal(
            delay: 160,
            child: Panel(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const IconBadge(Accent.ink, Glyph.lock),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Names stay off any screen others can see. Open iPhone Duo to see them alongside your trends.',
                      style: Typo.context,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage({required this.padding});

  final EdgeInsets padding;

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  bool hideNames = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: Text('Profile', style: Typo.title)),
          const SizedBox(height: 14),
          Reveal(
            delay: 80,
            child: Panel(
              child: Column(
                children: [
                  _source(Accent.red, Glyph.watch, 'Apple Watch', 'Synced ${Demo.updated}'),
                  const DashRule(vertical: 10),
                  _source(Accent.orange, Glyph.steps, 'iPhone motion', 'Synced 7:40'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Reveal(
            delay: 160,
            child: Panel(
              padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
              child: Row(
                children: [
                  const IconBadge(Accent.ink, Glyph.lock),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Hide medication names on the cover screen', style: Typo.row)),
                  Switch.adaptive(
                    value: hideNames,
                    activeThumbColor: Tone.card,
                    activeTrackColor: Tone.ink,
                    onChanged: (v) => setState(() => hideNames = v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _source(Accent accent, Glyph glyph, String name, String meta) {
    return Row(
      children: [
        IconBadge(accent, glyph),
        const SizedBox(width: 12),
        Expanded(child: Text(name, style: Typo.row)),
        Tag(meta, glyph: Glyph.sync, color: Tone.slate),
      ],
    );
  }
}
