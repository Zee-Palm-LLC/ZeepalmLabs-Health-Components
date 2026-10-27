import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../icons.dart';
import 'package:flutter/services.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/gauges.dart';
import '../widgets/motion.dart';
import 'body_viewer.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> with SingleTickerProviderStateMixin {
  late final _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300), value: stillMode ? 1 : 0)..forward();
  int _level = 2;
  bool _saved = false;

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    HapticFeedback.mediumImpact();
    AppState.painChecked.value = true;
    AppState.pain.value = _level;
    setState(() => _saved = true);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      setState(() => _saved = false);
    }
  }

  Widget _r(int i, Widget c, {double dy = 22}) => Reveal(anim: _enter, index: i, dy: dy, child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: DesignCanvas(
        child: Builder(builder: (context) {
          final top = math.max(0.0, MediaQuery.of(context).padding.top - 47);
          return PageBackground(
            child: Stack(
              children: [
                Positioned(left: 0, right: 0, top: 55 + top, child: _r(0, const TopBar(title: 'Body Check-in', action: PhRegular.slidersHorizontal), dy: 10)),
                Positioned(
                  left: 22,
                  top: 112 + top,
                  child: _r(1, Text('How does your body feel?', style: inter(22, FontWeight.w500, C.ink, ls: -0.3))),
                ),
                Positioned(
                  left: 22,
                  top: 144 + top,
                  child: _r(2, Text('Tap on the area where you feel discomfort.', style: inter(11, FontWeight.w400, C.ink2))),
                ),
                Positioned(left: 0, top: 160 + top, child: const BodyViewer()),
                Positioned(
                  left: 22,
                  right: 21,
                  top: 584 + top,
                  child: _r(
                    5,
                    GlassCard(
                      radius: 18,
                      child: SizedBox(
                        height: 146,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 14,
                              top: 14,
                              child: Text('How painful is it?', style: inter(15, FontWeight.w600, C.ink)),
                            ),
                            Positioned(
                              left: 14,
                              top: 38,
                              child: Text('Choose the emoji that best describes your pain level.',
                                  style: inter(10.5, FontWeight.w400, C.ink2)),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 57,
                              child: EmojiScale(selected: _level, onChanged: (i) => setState(() => _level = i)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  right: 21,
                  top: 754 + top,
                  child: _r(
                    6,
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      switchInCurve: springy,
                      transitionBuilder: (c, a) => FadeTransition(
                        opacity: a,
                        child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(a), child: c),
                      ),
                      child: _saved
                          ? const DarkButton(key: ValueKey('saved'), label: 'Check-in saved', icon: PhBold.check)
                          : DarkButton(key: const ValueKey('save'), label: 'Save check-in', icon: PhRegular.floppyDisk, onTap: _save),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
