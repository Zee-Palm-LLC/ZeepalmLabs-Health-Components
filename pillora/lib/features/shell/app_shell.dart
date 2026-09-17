import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/motion/motion.dart';
import '../../core/motion/routes.dart';
import '../../core/theme/palette.dart';
import '../assistant/assistant_screen.dart';
import '../home/home_screen.dart';
import '../plan/plan_screen.dart';
import '../profile/profile_screen.dart';
import 'liquid_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int _tab = 0;
  int _navIndex = 0;
  final Set<int> _visited = {0};
  late final AnimationController _navEnter;
  late final AnimationController _navHide;

  @override
  void initState() {
    super.initState();
    _navEnter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _navHide = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) _navEnter.forward();
    });
  }

  @override
  void dispose() {
    _navEnter.dispose();
    _navHide.dispose();
    super.dispose();
  }

  Future<void> _select(int index) async {
    if (index == 2) {
      setState(() => _navIndex = 2);
      await _openAssistant();
      return;
    }
    if (index == _tab) return;
    setState(() {
      _tab = index;
      _navIndex = index;
      _visited.add(index);
    });
    _navHide.reverse();
  }

  Future<void> _openAssistant() async {
    _navHide.forward();
    await Navigator.of(context).push(StageRoute(builder: (_) => const AssistantScreen()));
    if (!mounted) return;
    setState(() => _navIndex = _tab);
    _navHide.reverse();
  }

  void _onScroll(ScrollDirection direction) {
    if (direction == ScrollDirection.reverse) _navHide.forward();
    if (direction == ScrollDirection.forward) _navHide.reverse();
  }

  Widget _page(int index) {
    return switch (index) {
      0 => HomeScreen(
        onOpenAssistant: () => _select(2),
        onOpenSchedule: () => _select(1),
        onScrollDirection: _onScroll,
      ),
      1 => PlanScreen(onScrollDirection: _onScroll),
      _ => ProfileScreen(onScrollDirection: _onScroll),
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottom = math.max(MediaQuery.paddingOf(context).bottom, 19.0);
    return Scaffold(
      backgroundColor: Palette.canvas,
      body: Stack(
        children: [
          for (final index in const [0, 1, 3])
            if (_visited.contains(index)) _TabStage(active: _tab == index, child: _page(index)),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottom,
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_navEnter, _navHide]),
                builder: (context, child) {
                  final enter = const ElasticOutCurve(0.75).transform(_navEnter.value);
                  final hide = Curves.easeInOutCubic.transform(_navHide.value);
                  final drop = (1 - enter) * 140 + hide * (LiquidNav.height + bottom + 20);
                  return Transform.translate(
                    offset: Offset(0, drop),
                    child: Transform.scale(
                      scale: lerp(0.7, 1, window(_navEnter.value, 0, 0.5, Curves.easeOut)),
                      child: child,
                    ),
                  );
                },
                child: LiquidNav(index: _navIndex, onSelect: _select),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabStage extends StatelessWidget {
  const _TabStage({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: active ? 1 : 0),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
      child: child,
      builder: (context, t, child) {
        final hidden = t <= 0.001;
        return Offstage(
          offstage: hidden && !active,
          child: TickerMode(
            enabled: !hidden,
            child: IgnorePointer(
              ignoring: !active,
              child: Opacity(
                opacity: window(t, 0.35, 1),
                child: Transform.scale(scale: lerp(0.96, 1, t), child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}
