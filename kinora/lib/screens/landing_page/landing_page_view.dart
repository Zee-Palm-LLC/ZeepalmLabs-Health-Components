import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/kinora_colors.dart';
import '../home/home_screen_view.dart';
import '../meals/meals_screen_view.dart';
import '../workout/workout_detail_view.dart';
import 'components/floating_bottom_nav.dart';
import 'components/math_motion.dart';

class LandingPageView extends StatefulWidget {
  const LandingPageView({super.key});

  @override
  State<LandingPageView> createState() => _LandingPageViewState();
}

class _LandingPageViewState extends State<LandingPageView> {
  int _index = 0;
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
      backgroundColor: KinoraColors.bg,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 480),
        reverseDuration: const Duration(milliseconds: 380),
        switchInCurve: MathCurves.smoother,
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
            curve: const Interval(0.12, 1, curve: MathCurves.spiral),
            reverseCurve: const Interval(0, 0.78, curve: Curves.easeIn),
          );
          final move = CurvedAnimation(
            parent: animation,
            curve: MathCurves.anticipate,
            reverseCurve: Curves.easeInCubic,
          );
          final scale = Tween<double>(begin: 0.985, end: 1).animate(
            CurvedAnimation(
              parent: animation,
              curve: MathCurves.settle,
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
          child: _TabBody(
            index: _index,
            onBackHome: () => _onNav(0),
          ),
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
  const _TabBody({
    required this.index,
    required this.onBackHome,
  });

  final int index;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    if (index == 0) return const HomeScreenView();
    if (index == 1) {
      return WorkoutDetailView(onBack: onBackHome);
    }
    if (index == 3) return const MealsScreenView();

    final dest = FloatingBottomNav.items[index];
    Widget glyph = Icon(
      dest.icon,
      size: 40,
      color: KinoraColors.lime,
    );
    if (dest.tilt != 0) {
      glyph = Transform.rotate(angle: dest.tilt, child: glyph);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          glyph,
          const SizedBox(height: 14),
          Text(
            dest.label,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: KinoraColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
