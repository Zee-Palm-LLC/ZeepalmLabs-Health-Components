import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../meals/meal_schedule_screen.dart';
import '../stats/stats_screen_view.dart';
import '../timer/timer_screen_view.dart';
import 'components/floating_bottom_nav.dart';

class LandingPageView extends StatefulWidget {
  const LandingPageView({super.key});

  @override
  State<LandingPageView> createState() => _LandingPageViewState();
}

class _LandingPageViewState extends State<LandingPageView> {
  int _index = 1;
  int _direction = 1;

  void _onNav(int i) {
    if (i == _index) return;
    setState(() {
      _direction = i > _index ? 1 : -1;
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F13),
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 480),
        reverseDuration: const Duration(milliseconds: 380),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ...previousChildren,
              ?currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          final isIncoming =
              (child.key as ValueKey<int>?)?.value == _index;
          final slideBegin = Offset(
            (isIncoming ? 0.055 : -0.045) * _direction,
            0,
          );

          final fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.12, 1, curve: Curves.easeOut),
            reverseCurve: const Interval(0, 0.78, curve: Curves.easeIn),
          );
          final move = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final scale = Tween<double>(begin: 0.985, end: 1).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ),
          );

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: slideBegin,
                end: Offset.zero,
              ).animate(move),
              child: ScaleTransition(
                scale: scale,
                alignment: Alignment.center,
                child: child,
              ),
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: _TabBody(index: _index),
        ),
      ),
      bottomNavigationBar: Material(
        type: MaterialType.transparency,
        child: FloatingBottomNav(
          currentIndex: _index,
          onChanged: _onNav,
        ),
      ),
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    if (index == 1) return const MealScheduleScreen();
    if (index == 2) return const TimerScreenView();
    if (index == 3) return const StatsScreenView();

    final dest = FloatingBottomNav.items[index];
    Widget glyph = Icon(
      dest.icon,
      size: 38,
      color: const Color(0xFFE6E6E6),
    );
    if (dest.tilt != 0) {
      glyph = Transform.rotate(angle: dest.tilt, child: glyph);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          glyph,
          const SizedBox(height: 12),
          Text(
            dest.label,
            style: GoogleFonts.poppins(
              color: const Color(0xFFE6E6E6),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
