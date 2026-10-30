import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'bubbles.dart';
import 'glass.dart';
import 'theme.dart';

enum Phase { intro, entering, home, resetting }

const _domeC = Offset(195, 800);
const _domeR = 228.0;
const _orbC = Offset(191, 308);
const _orbR = 41.0;

double _c01(double v) => v.clamp(0.0, 1.0);
double _ease(double v) => Curves.easeInOutCubic.transform(_c01(v));
double _ramp(double t, double a, double b) => _c01((t - a) / (b - a));
Offset _lerp(Offset a, Offset b, double t) => Offset.lerp(a, b, t)!;

/// All animated state, advanced once per frame. Every value the scene and
/// lens read lives here, so the visible scene and the lens's own copy of it
/// always agree.
class WabiModel extends ChangeNotifier {
  Phase phase = Phase.intro;
  double pt = 0, time = 0;

  // Lens.
  Offset lensC = _domeC, lensV = Offset.zero;
  double lensR = _domeR, mag = 1.06, disp = 0.02, wrap = 0.25;
  Offset sample = _domeC;
  double neon = 0;
  double inflate = 0, _inflV = 0; // press-to-inflate amount, on a jelly spring

  // Gesture.
  bool pressing = false, dragging = false;
  Offset drag = Offset.zero;
  Offset _from = _domeC;
  double _fromR = _domeR;

  // Copy.
  double aIntro = 1, aLabel = 1, aMeet = 0, aSub = 0, aGoogle = 0, aApple = 0;
  double aEyebrow = 0, aDesc = 0, aTrust = 0, aFoot = 0;

  final bubbles = BubbleSim();

  void tick(double dt) {
    time += dt;
    pt += dt;
    switch (phase) {
      case Phase.intro:
        _intro(dt);
      case Phase.entering:
        _entering(dt);
      case Phase.home:
        _home(dt);
      case Phase.resetting:
        _resetting();
    }
    // The fountain always flows from the orb's home spot, even while the
    // orb itself is being dragged around as a lens.
    final home = phase == Phase.home;
    bubbles.update(dt, home ? _orbC : lensC, home ? _orbR : lensR);
    notifyListeners();
  }

  /// How far the bubble has been swiped toward the orb (0 = resting dome).
  double get _k => _c01((_domeC.dy - lensC.dy) / (_domeC.dy - _orbC.dy));

  void _intro(double dt) {
    // The bubble follows the finger up (on a soft spring) and shrinks as it
    // rises; a light press makes it swell slightly, like water under touch.
    if (!pressing) drag = Offset.zero; // let go early: it springs back down
    final target = _domeC + Offset(drag.dx * 0.5, math.min(drag.dy, 20.0));
    lensV += ((target - lensC) * 260 - lensV * 26) * dt;
    lensC += lensV * dt;
    final pressT = pressing ? 1.0 : 0.0;
    _inflV += ((pressT - inflate) * 160 - _inflV * 14) * dt;
    inflate += _inflV * dt;
    final k = _k;
    lensR = _domeR + (_orbR + 30 - _domeR) * Curves.easeOut.transform(k) + 8 * inflate * (1 - k);
    neon += ((pressing ? (1 - k * 3.5).clamp(0.0, 1.0) : 0.0) - neon) * (1 - math.exp(-dt * 8));
    sample = lensC;
    mag = 1.05 + 0.35 * k;
    wrap = 0.25 + 0.6 * k;
    disp = 0.02 + 0.04 * k;
    aIntro = 1 - Curves.easeOut.transform(_c01(k / 0.45));
    aLabel = 1 - _c01(k / 0.2 + neon);
  }

  void _entering(double dt) {
    // The same bubble carries on to the orb spot on an underdamped spring
    // (a little jelly overshoot), shrinking as it closes in.
    lensV += ((_orbC - lensC) * 120 - lensV * 15) * dt;
    lensC += lensV * dt;
    final d0 = math.max(1.0, (_from - _orbC).distance);
    final f = _c01((lensC - _orbC).distance / d0);
    lensR = _orbR + (_fromR - _orbR) * Curves.easeIn.transform(f);
    neon *= math.exp(-dt * 8);
    sample = lensC;
    mag = 1.4 - 0.08 * (1 - f);
    wrap = 0.85;
    disp = 0.05;
    aIntro = math.min(aIntro, 1 - _c01(pt / 0.25));
    aLabel = 0;
    // Welcome page builds top to bottom on a stagger.
    aEyebrow = _ramp(pt, 0.15, 0.55);
    aMeet = _ramp(pt, 0.25, 0.7);
    aSub = _ramp(pt, 0.45, 0.9);
    aDesc = _ramp(pt, 0.65, 1.1);
    aTrust = _ramp(pt, 0.8, 1.25);
    aGoogle = _ramp(pt, 0.9, 1.35);
    aApple = _ramp(pt, 1.0, 1.45);
    aFoot = _ramp(pt, 1.15, 1.6);
    if (pt > 1.2 && !bubbles.emitting && bubbles.bubbles.isEmpty) bubbles.start();
    if (pt > 1.8) {
      lensV = Offset.zero;
      _go(Phase.home);
    }
  }

  void _home(double dt) {
    final target = dragging ? _orbC + drag : _orbC + Offset(0, math.sin(time * 1.6) * 1.5);
    lensV += ((target - lensC) * 170 - lensV * 17) * dt;
    lensC += lensV * dt;
    final grow = _c01((lensC - _orbC).distance / 110);
    lensR = _orbR + Curves.easeOut.transform(grow) * 54;
    sample = lensC;
    mag = 1.32 + 0.35 * grow;
    wrap = 0.85;
    disp = 0.05 + 0.03 * grow;
  }

  void _resetting() {
    final s = _ease(pt / 0.85);
    lensC = _lerp(_from, _domeC, s);
    lensR = _fromR + (_domeR - _fromR) * s;
    sample = lensC;
    mag = 1.35 + (1.05 - 1.35) * s;
    wrap = 0.85 + (0.22 - 0.85) * s;
    disp = 0.05 + (0.02 - 0.05) * s;
    final out = 1 - _c01(pt / 0.35);
    aMeet = math.min(aMeet, out);
    aSub = math.min(aSub, out);
    aGoogle = math.min(aGoogle, out);
    aApple = math.min(aApple, out);
    aEyebrow = math.min(aEyebrow, out);
    aDesc = math.min(aDesc, out);
    aTrust = math.min(aTrust, out);
    aFoot = math.min(aFoot, out);
    aIntro = _ramp(pt, 0.3, 0.9);
    aLabel = _ramp(pt, 0.5, 1.0);
    if (pt > 1.0) {
      drag = Offset.zero;
      inflate = 0;
      lensV = Offset.zero;
      _inflV = 0;
      _go(Phase.intro);
    }
  }

  void _go(Phase p) {
    phase = p;
    pt = 0;
  }

  // ---- gestures (design coordinates) --------------------------------------
  void down(Offset p) {
    if (phase == Phase.intro && ((p - lensC).distance < lensR * 1.08 || p.dy > 560)) {
      pressing = true;
      drag = Offset.zero;
      HapticFeedback.lightImpact();
    } else if (phase == Phase.home && (p - lensC).distance < lensR + 28) {
      dragging = true;
      drag = lensC - _orbC;
      HapticFeedback.selectionClick();
    }
  }

  void move(Offset delta) {
    if (pressing || dragging) drag += delta;
  }

  void up(Offset velocity) {
    if (pressing) {
      pressing = false;
      // Swiped far enough (or flicked up): the bubble goes on to become the orb.
      if (_k > 0.22 || velocity.dy < -500) {
        lensV += Offset(0, math.min(0.0, velocity.dy) * 0.15);
        _from = lensC;
        _fromR = lensR;
        HapticFeedback.mediumImpact();
        _go(Phase.entering);
      }
    } else if (dragging) {
      dragging = false;
      // Judge by where the finger took it, not where the trailing lens is.
      if ((_orbC + drag).dy > 600 || velocity.dy > 1400) {
        _from = lensC;
        _fromR = lensR;
        bubbles.release();
        HapticFeedback.mediumImpact();
        _go(Phase.resetting);
      }
    }
  }

  double get _stretch => phase == Phase.home ? 0.0 : _c01(-lensV.dy / 2200) * 0.12 - _c01(lensV.dy / 2200) * 0.06;

  LensSpec get lens => LensSpec(
    center: lensC,
    // Squash and stretch along the direction of travel, like a water drop.
    radius: Size(lensR * (1 - _stretch), lensR * (1 + _stretch)),
    sample: sample,
    mag: mag,
    disp: disp,
    wrap: wrap,
    shadow: phase == Phase.intro ? 0.35 : 1,
  );
}

/// The onboarding screen on a 390 x 844 design canvas.
class WabiScreen extends StatefulWidget {
  const WabiScreen({super.key});

  @override
  State<WabiScreen> createState() => _WabiScreenState();
}

class _WabiScreenState extends State<WabiScreen> with SingleTickerProviderStateMixin {
  final m = WabiModel();
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  final _sceneKey = GlobalKey(), _lensKey = GlobalKey();
  ui.Image? _snap, _old;
  Offset _snapOrigin = Offset.zero;
  ui.FragmentProgram? _program;
  BubbleSprites? _sprites;
  static const _snapScale = 1.5; // lens snapshot resolution: sharp enough, cheap to grab

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((now) {
      final dt = ((now - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
      _last = now;
      m.tick(dt);
    })..start();
    ui.FragmentProgram.fromAsset('shaders/lens.frag').then((p) {
      if (mounted) setState(() => _program = p);
    });
    _loadAtlas();
    SchedulerBinding.instance.addPersistentFrameCallback(_afterFrame);
  }

  Future<void> _loadAtlas() async {
    final data = await DefaultAssetBundle.of(context).load('assets/images/bubbles.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final img = (await codec.getNextFrame()).image;
    if (mounted) setState(() => _sprites = BubbleSprites.build(img, bubbleCells()));
  }

  /// After every frame, capture just the patch of scene the lens can see
  /// (not the whole screen), so the next frame's lens can refract it.
  void _afterFrame(Duration _) {
    if (!mounted) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // The lens's own copy exists only while the title is being revealed.
      final ro = (_lensKey.currentContext ?? _sceneKey.currentContext)?.findRenderObject();
      if (ro is! _RenderSnap || !ro.hasSize) return;
      final s = m.lens;
      final ext = math.max(s.radius.width, s.radius.height) * 1.7 + 8;
      final r = Rect.fromCenter(center: s.sample, width: ext * 2, height: ext * 2).intersect(Offset.zero & ro.size);
      if (r.width < 2 || r.height < 2) return;
      final region = Rect.fromLTRB(
        r.left.floorToDouble(),
        r.top.floorToDouble(),
        r.right.ceilToDouble(),
        r.bottom.ceilToDouble(),
      );
      final next = ro.grab(region, _snapScale);
      if (next == null) return;
      _old?.dispose();
      _old = _snap;
      _snap = next;
      _snapOrigin = region.topLeft;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    m.dispose();
    _snap?.dispose();
    _old?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (d) => m.down(d.localPosition),
      onPanUpdate: (d) => m.move(d.delta),
      onPanEnd: (d) => m.up(d.velocity.pixelsPerSecond),
      onPanCancel: () => m.up(Offset.zero),
      child: SizedBox(
        width: 390,
        height: 844,
        child: Stack(
          children: [
            // The lens's copy of the scene, needed only while the title is
            // being revealed (it shows the title before the screen does).
            // Painted underneath the visible scene, so it is never seen.
            Positioned.fill(
              child: AnimatedBuilder(
                animation: m,
                builder: (context, _) => m.phase == Phase.entering
                    ? _SnapBoundary(
                        key: _lensKey,
                        child: _Scene(m: m, lensView: true, sprites: _sprites),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Positioned.fill(
              child: _SnapBoundary(
                key: _sceneKey,
                child: _Scene(m: m, lensView: false, sprites: _sprites),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: LensPainter(
                    spec: () => m.lens,
                    program: _program,
                    snapshot: () => _snap,
                    origin: () => _snapOrigin,
                    scale: _snapScale,
                    repaint: m,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: m,
                  builder: (context, _) => CustomPaint(
                    painter: NeonPainter(center: m.lensC, radius: m.lensR, amount: m.neon, t: m.time),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fades in while rising a few points, driven by a 0..1 progress value.
class _Rise extends StatelessWidget {
  const _Rise(this.a, this.child);
  final double a;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOutCubic.transform(a.clamp(0.0, 1.0));
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: W.googleLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Ph.sparkle, size: 11, color: W.accent),
          const SizedBox(width: 6),
          Text(
            'YOUR AI HEALTH COMPANION',
            style: sf(10, color: W.accent, w: FontWeight.w600, ls: 1.3, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow();

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: W.accent),
        const SizedBox(width: 5),
        Text(
          label,
          style: sf(11.5, color: W.body, w: FontWeight.w500, ls: -0.1),
        ),
      ],
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        item(Ph.lock, 'Private & secure'),
        const SizedBox(width: 14),
        item(Ph.heartbeat, 'Clinician-informed'),
        const SizedBox(width: 14),
        item(Ph.gift, 'Free to start'),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final base = sf(11.5, color: W.hint, height: 1.4);
    final link = base.copyWith(color: W.body, fontWeight: FontWeight.w500, decoration: TextDecoration.underline);
    return Column(
      children: [
        Text.rich(
          TextSpan(
            style: base,
            children: [
              const TextSpan(text: 'By continuing, you agree to our '),
              TextSpan(text: 'Terms', style: link),
              const TextSpan(text: ' and '),
              TextSpan(text: 'Privacy Policy', style: link),
              const TextSpan(text: '.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            style: sf(13, color: W.body),
            children: [
              const TextSpan(text: 'Already have an account?  '),
              TextSpan(
                text: 'Log in',
                style: sf(13, color: W.ink, w: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A repaint boundary that can capture any sub-rectangle of itself.
class _SnapBoundary extends RepaintBoundary {
  const _SnapBoundary({super.key, super.child});

  @override
  RenderRepaintBoundary createRenderObject(BuildContext context) => _RenderSnap();
}

class _RenderSnap extends RenderRepaintBoundary {
  ui.Image? grab(Rect region, double pixelRatio) {
    final l = layer;
    if (l is! OffsetLayer) return null;
    try {
      return l.toImageSync(region, pixelRatio: pixelRatio);
    } catch (_) {
      return null; // not painted yet this frame; keep the previous capture
    }
  }
}

/// Background, copy, buttons and bubbles. [lensView] is the lens's copy:
/// the incoming title is already fully drawn there, so the glass reveals it
/// before it fades in on screen.
class _Scene extends StatelessWidget {
  const _Scene({required this.m, required this.lensView, required this.sprites});

  final WabiModel m;
  final bool lensView;
  final BubbleSprites? sprites;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: W.bg,
      child: AnimatedBuilder(
        animation: m,
        builder: (context, _) {
          final meet = lensView && m.phase == Phase.entering ? 1.0 : m.aMeet;
          return Stack(
            children: [
              const Positioned(left: 0, right: 0, top: 0, child: _StatusBar()),
              // Intro copy.
              Positioned(
                left: 0,
                right: 0,
                top: 368,
                child: Opacity(
                  opacity: m.aIntro,
                  child: Text(
                    'A new era of\nhealth is here.',
                    textAlign: TextAlign.center,
                    style: sf(26, height: 1.385, ls: -0.4),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 734,
                child: Opacity(
                  opacity: m.aLabel,
                  child: Text(
                    'Swipe up to enter',
                    textAlign: TextAlign.center,
                    style: sf(12.5, color: W.hint, ls: -0.1),
                  ),
                ),
              ),
              // Welcome page.
              Positioned(left: 0, right: 0, top: 366, child: _Rise(m.aEyebrow, const Center(child: _Eyebrow()))),
              Positioned(
                left: 0,
                right: 0,
                top: 402,
                child: Column(
                  children: [
                    _Rise(meet, Text('Meet Vita.', style: sf(35, w: FontWeight.w600, height: 1.14, ls: -1.2))),
                    _Rise(
                      m.aSub,
                      Text(
                        'Your health, understood.',
                        style: sf(29, w: FontWeight.w500, height: 1.3, ls: -0.9, color: W.tagline),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 34,
                right: 34,
                top: 497,
                child: _Rise(
                  m.aDesc,
                  Text(
                    'Sleep, heart, meds and habits in one calm place, with insights that make sense.',
                    textAlign: TextAlign.center,
                    style: sf(15, color: W.body, height: 1.5, ls: -0.1),
                  ),
                ),
              ),
              Positioned(left: 0, right: 0, top: 578, child: _Rise(m.aTrust, const _TrustRow())),
              // Sign-in.
              Positioned(left: 28, right: 28, top: 632, child: _Rise(m.aApple, const _Button(google: false))),
              Positioned(left: 28, right: 28, top: 692, child: _Rise(m.aGoogle, const _Button(google: true))),
              Positioned(left: 0, right: 0, top: 758, child: _Rise(m.aFoot, const _Footer())),
              Positioned.fill(child: CustomPaint(painter: BubblePainter(m.bubbles, sprites, m))),
            ],
          );
        },
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(44, 18, 30, 0),
        child: Row(
          children: [
            Text(
              '9:41',
              style: sf(15.5, color: W.status, w: FontWeight.w500, height: 1),
            ),
            const Spacer(),
            const Icon(Ph.signal, size: 15, color: W.status),
            const SizedBox(width: 5),
            const Icon(Ph.wifi, size: 15, color: W.status),
            const SizedBox(width: 5),
            const Icon(Ph.battery, size: 21, color: W.status),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatefulWidget {
  const _Button({required this.google});
  final bool google;

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.google;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        HapticFeedback.lightImpact();
      },
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: g ? W.googleBtn.withValues(alpha: 0.9) : W.appleBtn,
            borderRadius: BorderRadius.circular(25),
            border: g ? Border.all(color: W.googleLine) : null,
            boxShadow: [
              BoxShadow(color: Color.fromRGBO(90, 40, 30, g ? 0.06 : 0.18), blurRadius: 14, offset: const Offset(0, 5)),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 20,
                child: g
                    ? const CustomPaint(size: Size(18, 18), painter: _GoogleG())
                    : const Icon(Ph.apple, size: 19, color: Colors.white),
              ),
              Text(
                g ? 'Continue with Google' : 'Continue with Apple',
                style: sf(13.5, color: g ? W.ink : Colors.white, w: g ? FontWeight.w500 : FontWeight.w600, ls: -0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The four-colour Google "G".
class _GoogleG extends CustomPainter {
  const _GoogleG();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    final r = s * 0.39;
    final w = s * 0.19;
    final rect = Rect.fromCircle(center: c, radius: r);
    Paint p(int color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..color = Color(color);
    const d = math.pi / 180;
    canvas.drawArc(rect, -40 * d, -95 * d, false, p(0xFFEA4335)); // red, top
    canvas.drawArc(rect, -135 * d, -90 * d, false, p(0xFFFBBC05)); // yellow, left
    canvas.drawArc(rect, 135 * d, -90 * d, false, p(0xFF34A853)); // green, bottom
    canvas.drawArc(rect, 45 * d, -45 * d, false, p(0xFF4285F4)); // blue, right
    canvas.drawRect(Rect.fromLTWH(c.dx, c.dy - w / 2, r + w / 2, w), Paint()..color = const Color(0xFF4285F4));
  }

  @override
  bool shouldRepaint(_GoogleG old) => false;
}
