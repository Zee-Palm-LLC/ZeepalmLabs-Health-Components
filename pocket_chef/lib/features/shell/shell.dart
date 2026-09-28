import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/palette.dart';
import '../../core/type.dart';
import '../../widgets/nav_bar.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import 'collection_screen.dart';

class Shell extends StatefulWidget {
  const Shell({super.key, this.initial = 0});

  final int initial;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> with TickerProviderStateMixin {
  late int _index = widget.initial;
  late final List<AnimationController> _entrances;
  late final AnimationController _swap;
  late final AnimationController _fab;
  late final AnimationController _bar;

  @override
  void initState() {
    super.initState();
    _entrances = [for (var i = 0; i < 4; i++) AnimationController(vsync: this, duration: const Duration(milliseconds: 2300))];
    _entrances[_index].forward();
    _swap = AnimationController(vsync: this, duration: const Duration(milliseconds: 460), value: 1);
    _fab = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _bar = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  }

  @override
  void dispose() {
    for (final c in _entrances) {
      c.dispose();
    }
    _swap.dispose();
    _fab.dispose();
    _bar.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (i == _index) return;
    if (_fab.value > 0) _fab.reverse();
    setState(() => _index = i);
    _swap.forward(from: 0);
    if (_entrances[i].isDismissed) _entrances[i].forward();
  }

  void _toggleFab() {
    HapticFeedback.mediumImpact();
    _fab.isCompleted || _fab.status == AnimationStatus.forward ? _fab.reverse() : _fab.forward();
  }

  void _pick(int i) {
    _fab.reverse();
    final label = FabMenu.actions[i].$2;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 120),
        backgroundColor: Palette.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text('$label is cooking up soon', style: inter(14, 500, color: Colors.white)),
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeScreen(entrance: _entrances[0], onProfile: () => _select(3)),
      CollectionScreen(entrance: _entrances[1], favorites: false),
      CollectionScreen(entrance: _entrances[2], favorites: true),
      ProfileScreen(entrance: _entrances[3]),
    ];
    return PopScope(
      canPop: _index == 0 && _fab.value == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_fab.value > 0) {
          _fab.reverse();
        } else {
          _select(0);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF7F0),
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _swap,
                builder: (context, child) {
                  final t = Curves.easeOutCubic.transform(_swap.value);
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 14 * (1 - t)),
                      child: Transform.scale(scale: 0.985 + 0.015 * t, child: child),
                    ),
                  );
                },
                child: IndexedStack(
                  index: _index,
                  children: [for (final (i, tab) in tabs.indexed) TickerMode(enabled: i == _index, child: tab)],
                ),
              ),
            ),
            Positioned.fill(
              child: NavBar(index: _index, onSelect: _select, entrance: _bar),
            ),
            Positioned.fill(
              child: FabMenu(open: _fab, onClose: _fab.reverse, onPick: _pick),
            ),
            Positioned.fill(
              child: NavFab(open: _fab, onTap: _toggleFab, entrance: _bar),
            ),
          ],
        ),
      ),
    );
  }
}
