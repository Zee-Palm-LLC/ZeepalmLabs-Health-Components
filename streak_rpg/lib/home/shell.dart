import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/canvas.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../quests/quests_screen.dart';
import '../widgets/fx.dart';
import '../widgets/nav_bar.dart';
import '../widgets/place.dart';
import '../widgets/transitions.dart';
import '../workout/workout_screen.dart';
import 'home_screen.dart';

/// Home / Quests / Friends / Profile behind the shared nav bar. Tabs swap with a
/// depth slide in the direction of travel; the nav pill squashes across.
class Shell extends StatefulWidget {
  const Shell({super.key, this.initial = 0});

  final int initial;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> with SingleTickerProviderStateMixin {
  late int _index = widget.initial;
  int _from = 0;
  late final AnimationController _nav;
  final _navKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _nav = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) _nav.forward();
    });
  }

  @override
  void dispose() {
    _nav.dispose();
    super.dispose();
  }

  void _go(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _from = _index;
      _index = i;
    });
  }

  void _startWorkout(Offset origin) {
    HapticFeedback.heavyImpact();
    Navigator.of(context).push(WarpRoute(builder: (_) => const WorkoutScreen(), origin: origin, color: const Color(0xFFFFC94A)));
  }

  Widget _page(int i) {
    switch (i) {
      case 0:
        return HomeScreen(key: const ValueKey(0), onStart: _startWorkout, navKey: _navKey);
      case 1:
        return QuestsScreen(key: const ValueKey(1), onStart: _startWorkout);
      default:
        return _Soon(key: ValueKey(i), index: i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = Frame.of(context);
    final dir = _index > _from ? 1.0 : -1.0;
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(0);
      },
      child: Scaffold(
        backgroundColor: Tone.night,
        body: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              switchInCurve: gentle,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
              transitionBuilder: (child, anim) {
                final incoming = child.key == ValueKey(_index);
                return AnimatedBuilder(
                  animation: anim,
                  child: child,
                  builder: (context, child) {
                    final t = anim.value;
                    final m = Matrix4.identity()..setEntry(3, 2, 0.0012);
                    if (incoming) {
                      m.translateByDouble(dir * 90 * (1 - t), 0, 0, 1);
                      m.rotateY(-dir * 0.35 * (1 - t));
                    } else {
                      m.translateByDouble(-dir * 60 * (1 - t), 0, 0, 1);
                      m.scaleByDouble(0.9 + 0.1 * t, 0.9 + 0.1 * t, 1, 1);
                    }
                    return Opacity(
                      opacity: t.clamp(0, 1),
                      child: Transform(alignment: Alignment.center, transform: m, child: child),
                    );
                  },
                );
              },
              child: _page(_index),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: f.b(664),
              height: 120,
              child: AnimatedBuilder(
                animation: _nav,
                builder: (context, child) => Transform.translate(offset: Offset(0, (1 - span(_nav.value, 0, 1, settle)) * 120), child: child),
                child: KeyedSubtree(
                  key: _navKey,
                  child: NavBar(index: _index, onTap: _go),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Friends and Profile are not in the mockup; they show a teaser.
class _Soon extends StatelessWidget {
  const _Soon({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final f = Frame.of(context);
    final title = index == 2 ? 'Your party is gathering' : 'Your legend is being written';
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(center: Alignment(0, -0.3), radius: 1.1, colors: [Color(0xFF2A1F6B), Color(0xFF0B0C2B)]),
          ),
        ),
        const Positioned.fill(child: Motes(count: 40, colors: [Color(0xFFB98CFF), Color(0xFFFFD86B)], seed: 50)),
        Positioned(
          left: 0,
          right: 0,
          top: f.y(300),
          child: Entrance(
            duration: const Duration(milliseconds: 900),
            builder: (context, a) => Staged(
              animation: a,
              begin: 0,
              end: 1,
              offset: const Offset(0, 30),
              child: Column(
                children: [
                  Line(title, style: tight(Typo.section)),
                  const SizedBox(height: 6),
                  Line('Coming in the next update', style: tight(Typo.caption)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
