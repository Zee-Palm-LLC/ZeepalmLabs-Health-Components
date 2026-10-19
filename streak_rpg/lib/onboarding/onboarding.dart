import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/glyphs.dart';
import '../home/shell.dart';
import '../widgets/transitions.dart';
import 'adventure_page.dart';
import 'splash_page.dart';

/// Two-page onboarding. "Get Started" opens a burning portal from the button
/// into the second page; "Next" (or Skip) warps into the app.
class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> with SingleTickerProviderStateMixin {
  late final AnimationController _portal;
  Offset _origin = Offset.zero;
  bool _second = false;
  bool _warmed = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _portal = AnimationController(vsync: this, duration: const Duration(milliseconds: 1250))..addStatusListener((_) => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_warmed) {
      _warmed = true;
      Art.warm(context).whenComplete(() {
        if (mounted) setState(() => _ready = true);
      });
    }
  }

  @override
  void dispose() {
    _portal.dispose();
    super.dispose();
  }

  void _open(Offset origin) {
    if (_second) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _origin = origin;
      _second = true;
    });
    _portal.forward(from: 0);
  }

  void _enter(Offset? origin) {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pushReplacement(WarpRoute(builder: (_) => const Shell(), origin: origin));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_second,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _second) {
          _portal.reverse().then((_) {
            if (mounted) setState(() => _second = false);
          });
        }
      },
      child: Scaffold(
        body: !_ready
            ? const SizedBox.expand()
            : Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedBuilder(
                    animation: _portal,
                    builder: (context, child) => Transform.scale(scale: 1 + _portal.value * 0.18, alignment: Alignment(_origin.dx / 201 - 1, 0.6), child: child),
                    child: TickerMode(
                      enabled: !_second || _portal.value < 1,
                      child: SplashPage(onNext: _open),
                    ),
                  ),
                  if (_second)
                    AnimatedBuilder(
                      animation: _portal,
                      builder: (context, child) => Portal(t: _portal.value, origin: _origin, child: child!),
                      child: AdventurePage(onNext: _enter, onSkip: () => _enter(null)),
                    ),
                ],
              ),
      ),
    );
  }
}
