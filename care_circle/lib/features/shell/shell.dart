import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/scenery.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../home/home_screen.dart';
import '../meds/meds_tab.dart';
import '../profile/profile_tab.dart';
import '../timeline/timeline_tab.dart';
import 'nav_bar.dart';

class Shell extends StatefulWidget {
  const Shell({super.key, this.initial = 0});

  final int initial;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  late int _index = widget.initial;
  final Set<int> _opened = {};
  late final List<Widget> _pages = [
    HomeScreen(onTab: _select),
    const TimelineTab(),
    const MedsTab(),
    const ProfileTab(),
  ];

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  void _add() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x552A2230),
      builder: (context) => const _AddSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _opened.add(_index);
    final bottom = math.max(MediaQuery.viewPaddingOf(context).bottom, 12.0);
    final pages = _pages;
    final nav = NavBar(index: _index, onSelect: _select, onAdd: _add);
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: Wash()),
          for (var i = 0; i < pages.length; i++)
            if (_opened.contains(i))
              Positioned.fill(
                key: ValueKey('page$i'),
                child: Offstage(
                  offstage: i != _index,
                  child: TickerMode(
                    enabled: i == _index,
                    child: _TabEntrance(active: i == _index, child: pages[i]),
                  ),
                ),
              ),
          Positioned(
            key: const ValueKey('nav'),
            left: 16,
            right: 16,
            bottom: bottom - 4,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1100),
              curve: const Interval(0.45, 1, curve: Curves.easeOutBack),
              builder: (context, t, child) => Transform.translate(offset: Offset(0, 110 * (1 - t)), child: child),
              child: nav,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabEntrance extends StatefulWidget {
  const _TabEntrance({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_TabEntrance> createState() => _TabEntranceState();
}

class _TabEntranceState extends State<_TabEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
    value: 1,
  );

  @override
  void didUpdateWidget(_TabEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_c.value);
        if (t >= 1) return child!;
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
        );
      },
    );
  }
}

class _AddSheet extends StatelessWidget {
  const _AddSheet();

  @override
  Widget build(BuildContext context) {
    final options = [
      (Glyph.pill, 'Log a dose', 'Mark a medicine as taken', Hue.iris),
      (Glyph.heart, 'Share a moment', 'Post a photo or a note', Hue.coral),
      (Glyph.drop, 'Add a reading', 'Blood pressure, sugar, weight', Hue.sage),
      (Glyph.calendar, 'Plan a visit', 'Doctor, pharmacy or family', Hue.honey),
    ];
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      margin: EdgeInsets.fromLTRB(12, 0, 12, bottom + 12),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Hue.line, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Add to your circle', style: jakarta(19, 800, spacing: -0.3)),
          const SizedBox(height: 14),
          for (var i = 0; i < options.length; i++)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 360 + i * 70),
              curve: Curves.easeOutCubic,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(offset: Offset(0, 20 * (1 - t)), child: child),
              ),
              child: Pressable(
                onTap: () => Navigator.of(context).pop(),
                scale: 0.97,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      IconChip(glyph: options[i].$1, tone: options[i].$4, size: 46),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(options[i].$2, style: jakarta(15.5, 700)),
                            const SizedBox(height: 2),
                            Text(options[i].$3, style: jakarta(12.5, 500, color: Hue.inkSoft)),
                          ],
                        ),
                      ),
                      const GlyphIcon(Glyph.forward, size: 18, color: Hue.inkMute),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
