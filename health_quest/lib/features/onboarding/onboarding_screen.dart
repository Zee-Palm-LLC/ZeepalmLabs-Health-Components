import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../core/design.dart';
import '../../core/motion/entrance.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/stats.dart';
import '../shell/app_shell.dart';
import 'widgets/headline.dart';
import 'widgets/hero_stage.dart';
import 'widgets/intro_video.dart';
import 'widgets/start_button.dart';
import 'widgets/stat_badge.dart';
import 'widgets/xp_card.dart';

/// Health Quest, screen one.
///
/// The supplied clip plays as the background: the character drops out of the
/// sky and lands on the rock. The interface is timed against the clip's own
/// position rather than against a timer of its own, so the headline strikes
/// while he is still falling and the controls arrive as he stands up.
///
/// As the clip ends it is transformed onto the still composition's
/// registration and faded out, leaving a live scene behind it - the same
/// character, cut out of the same frame, now breathing and parallaxing under
/// your thumb.
///
/// Three clocks run the rest. [_entrance] is the staggered arrival, driven by
/// the clip when there is one. [_clock] free-runs for breathing, glows and
/// the sheen. [_charge] plays when the call to action is pressed. Parallax is
/// not a clock at all: it is integrated per frame so a flick hands its
/// velocity to the spring instead of snapping back from a standstill.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.playIntro = true});

  /// Off in tests, and anywhere the clip would be noise rather than value.
  final bool playIntro;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: D.entrance,
  );

  late final AnimationController _charge = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  /// The blink at the moment of launch. Its own clock, because it has to
  /// outlive the charge and cover the change of screen.
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );

  late final Ticker _clock;
  double _idle = 0;
  Duration _last = Duration.zero;

  // The clip.
  bool _useVideo = false;
  double _videoPos = 0;
  Timer? _videoWatchdog;

  // Parallax, integrated by hand so a release keeps its velocity.
  Offset _parallax = Offset.zero;
  Offset _velocity = Offset.zero;
  bool _dragging = false;

  // The stat whose colour is currently washed over the character.
  Stat? _litStat;
  double _litStrength = 0;
  Timer? _litTimer;

  int _level = 1;
  double _xp = 0;
  bool _leaving = false;

  /// Read once per build. Gesture callbacks can outlive the element - a
  /// pointer released during teardown still arrives - and looking up
  /// MediaQuery from a deactivated element throws.
  Size _screen = const Size(393, 852);

  double get _flashFade =>
      1 - Curves.easeOutQuart.transform(_flash.value.clamp(0.0, 1.0));

  /// How far the clip has been folded onto the still composition, 0..1.
  double get _blend =>
      D.emphasized.transform(((_videoPos - 0.84) / 0.16).clamp(0.0, 1.0));

  @override
  void initState() {
    super.initState();
    _clock = createTicker(_tick)..start();
    _charge.addListener(_onCharge);

    if (widget.playIntro) {
      _useVideo = true;
      // If the clip has not reported a single frame by now it is not going
      // to, whatever the platform said when it was asked to load it.
      _videoWatchdog = Timer(const Duration(milliseconds: 2500), () {
        if (mounted && _videoPos <= 0) _fallBack();
      });
    } else {
      _entrance.forward();
    }
  }

  void _fallBack() {
    if (!_useVideo) return;
    _videoWatchdog?.cancel();
    setState(() => _useVideo = false);
    _entrance.forward(from: _entrance.value);
  }

  void _onVideoProgress(double p) {
    if (!_useVideo || !mounted) return;
    _videoWatchdog?.cancel();
    setState(() {
      _videoPos = p;
      // The interface arrives over the middle of the clip and is fully in by
      // the time he is on his feet, leaving the last beat clear.
      _entrance.value = ((p - 0.10) / 0.72).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _videoWatchdog?.cancel();
    _litTimer?.cancel();
    _clock.dispose();
    _charge
      ..removeListener(_onCharge)
      ..dispose();
    _flash.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 1 / 60
        : ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 20);
    _last = elapsed;
    _idle += dt;

    if (!_dragging) {
      // Critically-ish damped return to centre.
      const k = 46.0, c = 9.5;
      final acc = Offset(
        -k * _parallax.dx - c * _velocity.dx,
        -k * _parallax.dy - c * _velocity.dy,
      );
      _velocity += acc * dt;
      _parallax += _velocity * dt;
    }

    if (_litStrength > 0 && _litStat == null) {
      _litStrength = (_litStrength - dt * 1.4).clamp(0.0, 1.0);
    } else if (_litStat != null && _litStrength < 1) {
      _litStrength = (_litStrength + dt * 4).clamp(0.0, 1.0);
    }

    setState(() {});
  }

  void _onCharge() {
    setState(() => _xp = 100 * Curves.easeInOut.transform(_charge.value));
  }

  void _onPanStart(DragStartDetails _) => _dragging = true;

  void _onPanUpdate(DragUpdateDetails d) {
    final next = Offset(
      (_parallax.dx + d.delta.dx / (_screen.width * 0.5)).clamp(-1.0, 1.0),
      (_parallax.dy + d.delta.dy / (_screen.height * 0.5)).clamp(-1.0, 1.0),
    );
    _velocity = (next - _parallax) * 60;
    _parallax = next;
  }

  void _onPanEnd(DragEndDetails d) {
    _dragging = false;
    _velocity = Offset(
      d.velocity.pixelsPerSecond.dx / (_screen.width * 0.5),
      d.velocity.pixelsPerSecond.dy / (_screen.height * 0.5),
    );
  }

  /// Pointer movement on desktop and web tilts the diorama without a drag.
  void _onHover(PointerHoverEvent e) {
    if (_dragging) return;
    final target = Offset(
      (e.localPosition.dx / _screen.width - 0.5) * 2,
      (e.localPosition.dy / _screen.height - 0.5) * 2,
    );
    _parallax = Offset.lerp(_parallax, target * 0.45, 0.12)!;
    _velocity = Offset.zero;
  }

  void _tapStat(Stat stat) {
    _litTimer?.cancel();
    setState(() => _litStat = stat);
    _litTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _litStat = null);
    });
  }

  /// The launch: the meter charges, the level ticks, the screen blinks, and
  /// the app opens behind it.
  Future<void> _startJourney() async {
    if (_leaving || _charge.isAnimating || _charge.value > 0) return;
    _leaving = true;
    HapticFeedback.mediumImpact();
    await _charge.forward();
    if (!mounted) return;

    HapticFeedback.heavyImpact();
    setState(() => _level = 2);
    await Future<void>.delayed(const Duration(milliseconds: 360));
    if (!mounted) return;

    _flash.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 190));
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 620),
        pageBuilder: (BuildContext context, Animation<double> a1,
                Animation<double> a2) =>
            const AppShell(),
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondary,
          Widget child,
        ) {
          final a = CurvedAnimation(parent: animation, curve: D.emphasized);
          return FadeTransition(
            opacity: a,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.04, end: 1).animate(a),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _screen = size;
    final pad = MediaQuery.paddingOf(context);
    final scale = size.width / D.refWidth;
    final gutter = D.gutter * scale;

    return Scaffold(
      backgroundColor: Night.voidBlack,
      body: MouseRegion(
        onHover: _onHover,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: AnimatedBuilder(
            animation:
                Listenable.merge(<Listenable>[_entrance, _charge, _flash]),
            builder: (BuildContext context, Widget? _) {
              final t = _entrance.value;
              final surge = _charge.value;
              final blend = _blend;

              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  HeroStage(
                    // With the clip running, the still scene is already fully
                    // placed behind it and the clip dissolves onto it.
                    entrance: _useVideo ? 1.0 : t,
                    idle: _idle,
                    parallax: _parallax,
                    surge: surge,
                    tint: _litStat?.tone.core,
                    tintStrength: _litStrength,
                  ),

                  if (_useVideo)
                    IntroVideo(
                      onProgress: _onVideoProgress,
                      onFailed: _fallBack,
                      blend: blend,
                      opacity: 1 - blend,
                    ),

                  // The four abilities, placed around the character.
                  for (var i = 0; i < Stat.all.length; i++)
                    Positioned(
                      left: D.statCentreX[i] * scale - D.badgeSlot / 2,
                      top: size.height * D.statFractionY[i ~/ 2] -
                          (D.hexHeight + 34) / 2,
                      child: StatBadge(
                        stat: Stat.all[i],
                        idle: _idle,
                        phase: i * 1.7,
                        t: D.softPop.transform(
                          D.stagger(t, D.statsStart, i, D.statStagger,
                              D.statSpan),
                        ),
                        onTap: () => _tapStat(Stat.all[i]),
                      ),
                    ),

                  // Type and controls.
                  SafeArea(
                    bottom: false,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: D.headlineTop),
                        Headline(t: t, message: _litStat?.blurb),
                        const Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: gutter),
                          child: Rise(
                            t: D.cardIn.transform(t),
                            distance: 26,
                            scaleFrom: 0.96,
                            child: XpCard(
                              level: _level,
                              xp: _xp,
                              maxXp: 100,
                              idle: _idle,
                              charge: surge,
                            ),
                          ),
                        ),
                        const SizedBox(height: D.cardToButton),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: gutter),
                          child: Rise(
                            t: D.buttonIn.transform(t),
                            distance: 26,
                            scaleFrom: 0.94,
                            child: StartButton(
                              label: 'START JOURNEY',
                              idle: _idle,
                              charge: surge,
                              onTap: _startJourney,
                            ),
                          ),
                        ),
                        const SizedBox(height: D.buttonToFooter),
                        Rise(
                          t: D.footerIn.transform(t),
                          distance: 8,
                          child: Text(
                            'Your adventure to a better you starts now!',
                            textAlign: TextAlign.center,
                            style: T.footer,
                          ),
                        ),
                        SizedBox(height: D.footerBottom + pad.bottom),
                      ],
                    ),
                  ),

                  // The launch blink, over everything.
                  if (_flash.value > 0 && _flash.value < 1)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              radius: 0.95,
                              colors: <Color>[
                                const Color(0xFFFFFFFF)
                                    .withValues(alpha: 0.85 * _flashFade),
                                Spectrum.violet
                                    .withValues(alpha: 0.55 * _flashFade),
                                Spectrum.violetDeep
                                    .withValues(alpha: 0.18 * _flashFade),
                              ],
                              stops: const <double>[0, 0.45, 1],
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
