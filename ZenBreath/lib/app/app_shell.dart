import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/meditation_library_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/progress_screen.dart';
import '../theme/app_decoration.dart';
import '../theme/app_motion.dart';
import '../widgets/app_bottom_nav.dart';

/// Hosts the four primary destinations, paints the shared page gradient behind
/// them and keeps the bottom bar persistent across tab changes.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;
  late int _previousIndex = widget.initialIndex;

  static const _pages = [
    HomeScreen(),
    MeditationLibraryScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  void _select(int value) {
    if (value == _index) return;
    setState(() {
      _previousIndex = _index;
      _index = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Moving right along the bar sends the new page in from the right, and vice
    // versa, so the tabs feel spatially connected.
    final forward = _index >= _previousIndex;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppDecoration.pageGradient),
        child: AnimatedSwitcher(
          duration: AppMotion.tab,
          switchInCurve: AppMotion.enterCurve,
          switchOutCurve: AppMotion.exitCurve,
          layoutBuilder: (current, previous) =>
              Stack(fit: StackFit.expand, children: [...previous, ?current]),
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: Offset(forward ? 0.06 : -0.06, 0),
              end: Offset.zero,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slide,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.985, end: 1).animate(animation),
                  child: child,
                ),
              ),
            );
          },
          child: KeyedSubtree(key: ValueKey(_index), child: _pages[_index]),
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _index, onChanged: _select),
    );
  }
}
