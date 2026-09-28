import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/canvas.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../widgets/nav_bar.dart';
import '../home/home_screen.dart';
import '../library/library_screen.dart';
import '../profile/profile_screen.dart';
import '../progress/progress_screen.dart';

class Shell extends StatefulWidget {
  const Shell({super.key, this.initial = 0});

  final int initial;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> with TickerProviderStateMixin {
  late int _index = widget.initial;
  late int _from = widget.initial;
  late final AnimationController _swap;
  late final AnimationController _bar;
  final _built = <int>{};

  @override
  void initState() {
    super.initState();
    _built.add(_index);
    _swap = AnimationController(vsync: this, duration: const Duration(milliseconds: 560), value: 1);
    _bar = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _bar.forward();
    });
  }

  @override
  void dispose() {
    _swap.dispose();
    _bar.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (i == _index) return;
    setState(() {
      _from = _index;
      _index = i;
      _built.add(i);
    });
    _swap.forward(from: 0);
  }

  Widget _page(int i) {
    switch (i) {
      case 0:
        return const HomeScreen();
      case 1:
        return const LibraryScreen();
      case 2:
        return const ProgressScreen();
      default:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        backgroundColor: Palette.cream,
        body: Stack(
          children: [
            for (final i in _built)
              AnimatedBuilder(
                animation: _swap,
                builder: (context, child) {
                  final active = i == _index;
                  final leaving = i == _from && !active && _swap.value < 1;
                  final visible = active || leaving;
                  final dir = (_index - _from).sign.toDouble();
                  final t = gentle.transform(_swap.value);
                  final x = active ? 36 * dir * (1 - t) : -24 * dir * t;
                  final o = active ? span(_swap.value, 0.1, 0.6, Curves.linear) : 1 - span(_swap.value, 0, 0.35, Curves.linear);
                  final s = active ? lerp(0.985, 1, t) : 1 - 0.015 * t;
                  return Offstage(
                    offstage: !visible,
                    child: TickerMode(
                      enabled: visible,
                      child: IgnorePointer(
                        ignoring: !active,
                        child: Opacity(
                          opacity: math.max(0.0, math.min(1.0, o)),
                          child: Transform.translate(
                            offset: Offset(x, 0),
                            child: Transform.scale(scale: s, child: child),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: KeyedSubtree(key: ValueKey(i), child: _page(i)),
              ),
            Positioned(
              left: 0,
              bottom: 0,
              width: Frame.width,
              height: NavBar.height(frame),
              child: NavBar(index: _index, onSelect: _select, entrance: _bar),
            ),
          ],
        ),
      ),
    );
  }
}
