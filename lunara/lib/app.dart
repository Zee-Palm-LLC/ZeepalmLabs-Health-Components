import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/aurora.dart';
import 'core/canvas.dart';
import 'core/motion.dart';
import 'core/theme.dart';
import 'data/cycle.dart';
import 'features/home_screen.dart';
import 'features/insights_screen.dart';
import 'features/log_screen.dart';
import 'features/welcome_screen.dart';
import 'features/you_screen.dart';
import 'widgets/liquid_nav.dart';
import 'widgets/screen_swap.dart';

class LunaraFlow extends StatefulWidget {
  const LunaraFlow({super.key, this.initial = 0});

  final int initial;

  @override
  State<LunaraFlow> createState() => FlowState();
}

class FlowState extends State<LunaraFlow> with TickerProviderStateMixin {
  static const moonStart = Offset(286, 214);
  static const moonRadius = 96.0;
  static const ringCentre = Offset(196.5, 300);
  static const revealFrom = Offset(196.5, 706);

  late final AnimationController enter;
  late final AnimationController pulse;
  late final AnimationController morph;
  final cycle = Cycle();

  int tab = 0;
  String? focus;

  @override
  void initState() {
    super.initState();
    enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900));
    pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat();
    morph = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    morph.addListener(_onMorph);
    if (widget.initial == 0) {
      enter.forward();
    } else {
      morph.value = 1;
      tab = widget.initial - 1;
      enter.forward();
    }
  }

  void _onMorph() {
    if (morph.value >= 0.22 && enter.value == 0 && enter.status != AnimationStatus.forward) {
      enter.forward();
    }
  }

  @override
  void dispose() {
    morph.removeListener(_onMorph);
    enter.dispose();
    pulse.dispose();
    morph.dispose();
    cycle.dispose();
    super.dispose();
  }

  void begin() {
    if (morph.value > 0) return;
    enter.value = 0;
    morph.forward(from: 0);
  }

  void openTab(int index, {String? focusOn}) {
    if (tab == index && focusOn == focus) return;
    setState(() {
      tab = index;
      focus = focusOn;
    });
    enter.forward(from: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Hue.canvas,
        body: DesignCanvas(
          backdrop: AnimatedBuilder(
            animation: morph,
            builder: (context, _) => Aurora(
              night: 1 - span(morph.value, 0.2, 0.9) * 0.45,
              floor: span(morph.value, 0.1, 0.7),
              horizon: tab == 0 ? 1 : 0.35,
            ),
          ),
          child: AnimatedBuilder(
            animation: morph,
            builder: (context, _) {
              final m = morph.value;
              final leaving = span(m, 0, 0.36, gentle);
              final travel = span(m, 0.02, 0.8, easeInOutSoft);
              final moonFade = 1 - span(m, 0.5, 0.92);
              final centre = Offset.lerp(moonStart, ringCentre, travel)!;
              final radius = lerp(moonRadius, 112, travel);
              final reveal = span(m, 0.05, 0.75, easeInOutSoft);
              return Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  if (m < 0.999)
                    IgnorePointer(
                      ignoring: m > 0,
                      child: Transform.scale(
                        scale: 1 - 0.05 * leaving,
                        child: ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(
                            sigmaX: 8 * leaving,
                            sigmaY: 8 * leaving,
                            tileMode: TileMode.decal,
                          ),
                          child: WelcomeScreen(
                            enter: enter,
                            pulse: pulse,
                            onBegin: begin,
                            fade: (1 - leaving).clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                    ),
                  if (moonFade > 0.01)
                    Positioned.fill(
                      child: MoonOverlay(
                        centre: centre,
                        radius: radius,
                        fade: moonFade.clamp(0.0, 1.0),
                        spin: travel * 0.5,
                      ),
                    ),
                  if (m > 0.02)
                    ClipPath(
                      clipper: _Reveal(centre: revealFrom, progress: reveal),
                      child: _main(context),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _main(BuildContext context) {
    final scope = CanvasScope.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ScreenSwap(
          index: tab,
          builder: (context, index) {
            switch (index) {
              case 1:
                return LogScreen(
                  cycle: cycle,
                  enter: enter,
                  pulse: pulse,
                  focus: focus,
                  onBack: () => openTab(0),
                  onSave: () => openTab(0),
                );
              case 2:
                return InsightsScreen(cycle: cycle, enter: enter, pulse: pulse, onAsk: () => openTab(3));
              case 3:
                return YouScreen(cycle: cycle, enter: enter, pulse: pulse, onLog: () => openTab(1));
              default:
                return HomeScreen(
                  cycle: cycle,
                  enter: enter,
                  pulse: pulse,
                  onDay: cycle.select,
                  onLog: (which) => openTab(1, focusOn: which),
                  onInsights: () => openTab(2),
                );
            }
          },
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 620),
          curve: gentle,
          left: (DesignCanvas.width - LiquidNav.width) / 2,
          top: tab == 1 ? scope.height + 20 : scope.navTop,
          child: Staged(
            animation: enter,
            begin: 0.5,
            end: 1.0,
            offset: const Offset(0, 46),
            child: LiquidNav(index: tab, onSelect: openTab),
          ),
        ),
      ],
    );
  }
}

class _Reveal extends CustomClipper<Path> {
  const _Reveal({required this.centre, required this.progress});

  final Offset centre;
  final double progress;

  @override
  Path getClip(Size size) {
    if (progress >= 0.999) return Path()..addRect(Offset.zero & size);
    final corners = [Offset.zero, Offset(size.width, 0), Offset(0, size.height), Offset(size.width, size.height)];
    final reach = corners.map((c) => (c - centre).distance).reduce(math.max);
    return Path()..addOval(Rect.fromCircle(center: centre, radius: reach * progress));
  }

  @override
  bool shouldReclip(_Reveal oldClipper) => oldClipper.progress != progress || oldClipper.centre != centre;
}
