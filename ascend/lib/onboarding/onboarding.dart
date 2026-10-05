import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/parts.dart';
import 'crew_page.dart';
import 'level_page.dart';
import 'streak_page.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key, this.script});

  final OnboardingScript? script;

  @override
  State<Onboarding> createState() => OnboardingState();
}

class OnboardingScript {
  OnboardingState? state;
}

class OnboardingState extends State<Onboarding> with TickerProviderStateMixin {
  static const durations = [Duration(milliseconds: 2300), Duration(milliseconds: 2000), Duration(milliseconds: 1800)];
  static const textTops = [570.0, 570.0, 505.0];

  late final List<AnimationController> _enter;
  late final AnimationController _slide;
  late final AnimationController _toast;
  int _page = 0;
  int _from = 0;
  String _toastText = '';

  @override
  void initState() {
    super.initState();
    widget.script?.state = this;
    _enter = [for (final d in durations) AnimationController(vsync: this, duration: d)];
    _slide = AnimationController(vsync: this, duration: const Duration(milliseconds: 620), value: 1);
    _toast = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _enter[0].forward(from: 0);
    });
  }

  @override
  void dispose() {
    for (final c in _enter) {
      c.dispose();
    }
    _slide.dispose();
    _toast.dispose();
    super.dispose();
  }

  void go(int page) {
    if (page < 0 || page > 2 || page == _page) return;
    HapticFeedback.selectionClick();
    setState(() {
      _from = _page;
      _page = page;
    });
    _slide.forward(from: 0);
    _enter[page].forward(from: 0);
  }

  void next() => go(_page + 1);

  void back() => go(_page - 1);

  void signIn(String provider) {
    HapticFeedback.mediumImpact();
    setState(() => _toastText = 'Signed in with $provider');
    _toast.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final f = Frame.of(context);
    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: Scaffold(
        backgroundColor: Tone.night,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v < -300 && _page < 2) next();
            if (v > 300) back();
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([..._enter, _slide, _toast]),
            builder: (context, _) {
              final moving = _slide.value < 1;
              final dir = (_page - _from).sign.toDouble();
              final out = Curves.easeInCubic.transform(span(_slide.value, 0, 0.5, Curves.linear));
              final into = Curves.easeOutCubic.transform(_slide.value);
              final backT = _page > 0 ? (moving && _from == 0 ? into : 1.0) : (moving && _from > 0 ? 1 - into : 0.0);
              return Stack(
                children: [
                  if (moving && _from != _page)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Transform.translate(
                          offset: Offset(-dir * 402 * out, 0),
                          child: Opacity(opacity: 1 - span(_slide.value, 0.25, 0.5, Curves.linear), child: _pageView(_from, 1, f)),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(moving ? dir * 90 * (1 - into) : 0, 0),
                      child: _pageView(_page, _enter[_page].value, f),
                    ),
                  ),
                  Positioned(left: 0, right: 0, top: 0, child: Header(top: f.top, back: backT, onBack: back)),
                  if (_toast.value > 0 && _toast.value < 1) _toastView(f),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _pageView(int page, double t, Frame f) {
    final textTop = textTops[page];
    final mockRoom = textTop - 120;
    final room = (textTop - f.drop) - (120 + f.lift);
    final squeeze = math.min(1.0, room / mockRoom);
    final hero = switch (page) {
      0 => LevelHero(t: t),
      1 => StreakHero(t: t),
      _ => CrewHero(t: t),
    };
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: f.lift,
          width: 402,
          height: 874,
          child: Transform.scale(
            scale: squeeze,
            alignment: const Alignment(0, -0.725),
            child: hero,
          ),
        ),
        Positioned(left: 0, top: -f.drop, width: 402, height: 874, child: _copy(page, t)),
      ],
    );
  }

  Widget _copy(int page, double t) {
    final lines = switch (page) {
      0 => ('Tiny wins,', 'big momentum', 'Every habit you complete earns XP.', 'Keep showing up and level up.'),
      1 => ('Day one of', 'your best streak', 'Keep the chain going and every', 'milestone earns its own badge.'),
      _ => ('Rise with', 'your crew', 'Weekly leaderboards with friends.', 'Start your climb today.'),
    };
    if (page == 2) {
      return Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 544 - 40 * interAscent,
            child: Reveal(t: span(t, 0.52, 0.7, Curves.linear), child: Center(child: Line(lines.$1, style: Typo.headlineBig))),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 588 - 40 * interAscent,
            child: Reveal(t: span(t, 0.56, 0.74, Curves.linear), child: Center(child: Line(lines.$2, style: Typo.headlineBig))),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 619.3 - 14.2 * interAscent,
            child: Reveal(t: span(t, 0.6, 0.78, Curves.linear), blur: 4, rise: 8, child: Center(child: Line(lines.$3, style: Typo.bodySmall))),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 638 - 14.2 * interAscent,
            child: Reveal(t: span(t, 0.62, 0.8, Curves.linear), blur: 4, rise: 8, child: Center(child: Line(lines.$4, style: Typo.bodySmall))),
          ),
          Positioned(
            left: 0,
            top: 671.3,
            child: Socials(
              apple: span(t, 0.66, 0.88, Curves.linear),
              google: span(t, 0.72, 0.92, Curves.linear),
              login: span(t, 0.8, 0.96, Curves.linear),
              onApple: () => signIn('Apple'),
              onGoogle: () => signIn('Google'),
              onLogin: () => signIn('your account'),
            ),
          ),
        ],
      );
    }
    final base = page == 0 ? 0.48 : 0.6;
    return Stack(
      children: [
        Positioned(left: 181, top: 570, child: PageDots(index: page, t: span(t, base, base + 0.12, Curves.linear))),
        Positioned(
          left: 0,
          right: 0,
          top: 639.5 - 36 * interAscent,
          child: Reveal(t: span(t, base + 0.02, base + 0.18, Curves.linear), child: Center(child: Line(lines.$1, style: Typo.headline))),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 685.7 - 36 * interAscent,
          child: Reveal(t: span(t, base + 0.05, base + 0.21, Curves.linear), child: Center(child: Line(lines.$2, style: Typo.headline))),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 718.3 - 15.4 * interAscent,
          child: Reveal(t: span(t, base + 0.08, base + 0.24, Curves.linear), blur: 4, rise: 8, child: Center(child: Line(lines.$3, style: Typo.body))),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 736.8 - 15.4 * interAscent,
          child: Reveal(t: span(t, base + 0.1, base + 0.26, Curves.linear), blur: 4, rise: 8, child: Center(child: Line(lines.$4, style: Typo.body))),
        ),
        Positioned(left: 64.3, top: 771.3, child: SolidButton(label: 'Continue', t: span(t, base + 0.1, base + 0.34, Curves.linear), onTap: next)),
      ],
    );
  }

  Widget _toastView(Frame f) {
    final t = _toast.value;
    final inT = spring(span(t, 0, 0.25, Curves.linear), bounce: 0.35, freq: 2);
    final outT = span(t, 0.8, 1, Curves.easeIn);
    return Positioned(
      left: 0,
      right: 0,
      top: f.top + 66,
      child: IgnorePointer(
        child: Opacity(
          opacity: (1 - outT) * span(t, 0, 0.1, Curves.linear),
          child: Transform.translate(
            offset: Offset(0, -40 * (1 - inT) - 20 * outT),
            child: Center(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xF2202027),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0x1FFFFFFF)),
                  boxShadow: [BoxShadow(color: Tone.violet.withValues(alpha: 0.3), blurRadius: 24)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Tone.mint),
                      alignment: Alignment.center,
                      child: const PhIcon(Ph.check, size: 13, color: Color(0xFF07291C)),
                    ),
                    const SizedBox(width: 10),
                    Line(_toastText, style: inter(15, 600, tracking: -0.2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
