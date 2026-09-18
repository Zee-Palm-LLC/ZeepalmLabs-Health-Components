import 'package:flutter/material.dart';

import 'dart:math' as math;

import '../../core/motion.dart';
import '../../core/routes.dart';
import '../../core/widgets.dart';
import '../analytic/analytic_screen.dart';
import '../home/home_screen.dart';
import '../products/products_screen.dart';
import '../profile/profile_screen.dart';
import '../scan/scan_screen.dart';
import 'nav_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  late int _tab = widget.initialTab;
  late final Set<int> _visited = {widget.initialTab};
  late final AnimationController _navEnter;

  @override
  void initState() {
    super.initState();
    _navEnter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _navEnter.forward();
    });
  }

  @override
  void dispose() {
    _navEnter.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _tab) return;
    setState(() {
      _tab = index;
      _visited.add(index);
    });
  }

  Future<void> _openScan() async {
    final media = MediaQuery.of(context);
    final origin = Offset(media.size.width / 2, media.size.height - math.max(87.0, 67 + media.padding.bottom) + 5);
    final result = await Navigator.of(
      context,
    ).push<String>(RevealRoute(origin: origin, builder: (_) => const ScanScreen()));
    if (result == 'analytic' && mounted) _select(1);
  }

  Widget _page(int index) {
    return switch (index) {
      0 => HomeScreen(onScan: _openScan, onOpenAnalytic: () => _select(1)),
      1 => AnalyticScreen(active: _tab == 1, onBack: () => _select(0), onUpload: _openScan),
      3 => const ProductsScreen(),
      _ => const ProfileScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: Backdrop()),
          for (final index in const [0, 1, 3, 4])
            if (_visited.contains(index)) _TabStage(active: _tab == index, child: _page(index)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _navEnter,
              builder: (context, child) {
                final t = const Cubic(0.2, 0.9, 0.25, 1.05).transform(_navEnter.value);
                return Transform.translate(offset: Offset(0, (1 - t) * 130), child: child);
              },
              child: GlowNavBar(index: _tab, onSelect: _select, onSparkle: _openScan),
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
      duration: const Duration(milliseconds: 480),
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
                opacity: window(t, 0.3, 1),
                child: Transform.scale(scale: lerp(0.97, 1, t), child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}
