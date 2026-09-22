import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../core/widgets.dart';
import '../home/home_screen.dart';
import '../library/library_screen.dart';
import '../mix/mix_screen.dart';
import '../sleep/sleep_screen.dart';
import '../../sound/mixer.dart';

enum Section { home, mix, sleep, library }

class Shell extends StatefulWidget {
  const Shell({super.key, this.initial = Section.home});

  final Section initial;

  @override
  State<Shell> createState() => ShellState();
}

class ShellState extends State<Shell> {
  late Section _tab = widget.initial;
  Section? _flash;

  void select(Section tab) {
    switch (tab) {
      case Section.home:
      case Section.library:
        setState(() => _tab = tab);
      case Section.mix:
        openMix();
      case Section.sleep:
        openSleep();
    }
  }

  bool _pushing = false;

  Future<void> _open(Section section, Route<void> route) async {
    if (_pushing) return;
    _pushing = true;
    Toast.dismiss();
    setState(() => _flash = section);
    final done = Navigator.of(context).push(route);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _pushing = false;
    await done;
    if (mounted) setState(() => _flash = null);
  }

  Future<void> openMix() => _open(Section.mix, mixRoute(const MixScreen()));

  Future<void> openSleep() =>
      _open(Section.sleep, riseRoute(const SleepScreen()));

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final s = w / 393;
    return PopScope(
      canPop: _tab == Section.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _tab = Section.home);
      },
      child: Scaffold(
        backgroundColor: Night.base,
        body: Stack(
          children: [
            const Positioned.fill(child: _Backdrop()),
            Positioned.fill(
              child: _TabFade(
                index: _tab == Section.library ? 1 : 0,
                children: [
                  HeroMode(
                    enabled: _tab == Section.home,
                    child: HomeScreen(onOpenMix: openMix),
                  ),
                  HeroMode(
                    enabled: _tab == Section.library,
                    child: LibraryScreen(onOpenMix: openMix),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 5 * s,
              right: 5 * s,
              bottom: 0,
              child: NavBar(
                current: _flash ?? _tab,
                onSelect: select,
                scale: s,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E1328), Color(0xFF0B0F20), Color(0xFF0C1022)],
          stops: [0, 0.5, 1],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.9, -1.0),
            radius: 0.9,
            colors: [Color(0x1A3A4C9A), Color(0x003A4C9A)],
          ),
        ),
      ),
    );
  }
}

class _TabFade extends StatefulWidget {
  const _TabFade({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_TabFade> createState() => _TabFadeState();
}

class _TabFadeState extends State<_TabFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late int _shown = widget.index;
  int? _leaving;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(_TabFade old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _leaving = _shown;
      _shown = widget.index;
      _c.forward(from: 0);
    }
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
      builder: (context, _) {
        final t = Ease.out.transform(_c.value);
        return Stack(
          children: [
            for (var i = 0; i < widget.children.length; i++)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: i != _shown,
                  child: TickerMode(
                    enabled: i == _shown || (i == _leaving && t < 1),
                    child: Opacity(
                      opacity: i == _shown ? t : (i == _leaving ? 1 - t : 0),
                      child: Transform.translate(
                        offset: Offset(0, i == _shown ? 12 * (1 - t) : 0),
                        child: widget.children[i],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.current,
    required this.onSelect,
    required this.scale,
  });

  final Section current;
  final ValueChanged<Section> onSelect;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final bottom = MediaQuery.of(context).padding.bottom;
    final radius = BorderRadius.vertical(
      top: Radius.circular(36 * s),
      bottom: Radius.circular(bottom > 0 ? 44 : 0),
    );
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: 78 * s + bottom,
          padding: EdgeInsets.only(bottom: bottom, left: 8 * s, right: 8 * s),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xD91A1D3A), Color(0xE6121531), Color(0xF2111429)],
              stops: [0, 0.45, 1],
            ),
            border: const Border(
              top: BorderSide(color: Color(0x2EB9B2FF), width: 1),
            ),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0),
              ],
              stops: const [0, 0.3],
            ),
          ),
          child: Row(
            children: [
              for (final (tab, glyph, label) in [
                (Section.home, G.home, 'Home'),
                (Section.mix, G.mix, 'Mix'),
                (Section.sleep, G.moonStar, 'Sleep'),
                (Section.library, G.library, 'Library'),
              ])
                Expanded(
                  child: _NavItem(
                    badge: tab == Section.mix ? const _MixBadge() : null,
                    glyph: glyph,
                    label: label,
                    active: current == tab,
                    scale: s,
                    onTap: () => onSelect(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.glyph,
    required this.label,
    required this.active,
    required this.scale,
    required this.onTap,
    this.badge,
  });

  final Widget? badge;
  final G glyph;
  final String label;
  final bool active;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: active ? 1 : 0),
        duration: const Duration(milliseconds: 380),
        curve: Ease.out,
        builder: (context, t, _) {
          final color = Color.lerp(const Color(0xFF8F8BB8), Colors.white, t)!;
          return SizedBox(
            height: 78 * s,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 44 * s,
                  height: 26 * s,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Opacity(
                        opacity: t,
                        child: Container(
                          width: 30 * s,
                          height: 30 * s,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF9C8BFF,
                                ).withValues(alpha: 0.35),
                                blurRadius: 18 * s,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Glyph(glyph, size: 24 * s, color: color, stroke: 1.6 * s),
                      if (badge != null)
                        Positioned(right: 0, top: -5 * s, child: badge!),
                    ],
                  ),
                ),
                SizedBox(height: 5 * s),
                Text(
                  label,
                  style: Typo.ui(11.5 * s, color: color, weight: 400 + 200 * t),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MixBadge extends StatelessWidget {
  const _MixBadge();

  @override
  Widget build(BuildContext context) {
    final count = MixerScope.of(context).sounds.length;
    final s = MediaQuery.of(context).size.width / 393;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
      child: count == 0
          ? const SizedBox.shrink(key: ValueKey(0))
          : Container(
              key: ValueKey(count),
              width: 15 * s,
              height: 15 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFD2C7FF), Color(0xFFA995F7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C8BFF).withValues(alpha: 0.6),
                    blurRadius: 8 * s,
                  ),
                ],
              ),
              child: Text(
                '$count',
                style: Typo.ui(
                  9.5 * s,
                  weight: 600,
                  color: Night.ink,
                  height: 1,
                ),
              ),
            ),
    );
  }
}
