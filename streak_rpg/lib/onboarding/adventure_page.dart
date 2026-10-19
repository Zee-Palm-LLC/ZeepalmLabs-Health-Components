import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/fx.dart';
import '../widgets/parts.dart';
import '../widgets/place.dart';

/// Onboarding 2: "Your Fitness Adventure Awaits".
///
/// The hex badge spins in and levels up from Lv. 1 to Lv. 5 with a burst on
/// every level, the three power-up orbs are flung out of it, and the hero does
/// real push-ups whose every rep sends a shockwave across the platform.
class AdventurePage extends StatefulWidget {
  const AdventurePage({super.key, required this.onNext, required this.onSkip});

  final void Function(Offset origin) onNext;
  final VoidCallback onSkip;

  @override
  State<AdventurePage> createState() => _AdventurePageState();
}

/// The s2 screen is 788.7 pt tall; bottom-pinned art shifts by this to the 784 frame.
const _s2 = -4.67;

class _AdventurePageState extends State<AdventurePage> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _rep;
  late final AnimationController _hexPulse;
  int _level = 1;
  int _reps = 0;

  static const _hex = Offset(209.5, 275);
  static const _orbs = [(Offset(88, 302), 37.5, Art.iconDumbbell, 0.0), (Offset(315, 285), 32.5, Art.iconArrow, 0.33), (Offset(348.5, 367), 33.5, Art.iconStar, 0.66)];

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
      ..addListener(_levelUp)
      ..forward();
    _hexPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _rep = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _rep.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) _rep.forward(from: 0);
    });
    _rep.addListener(_repCue);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _rep.forward();
    });
  }

  double _lastRep = 0;

  void _repCue() {
    // The bottom of each rep (t = 0.5) thumps the platform.
    if (_lastRep < 0.5 && _rep.value >= 0.5) {
      final f = Frame.read(context);
      final fx = FxLayer.of(context);
      final c = Offset(201, f.b(574 + _s2));
      fx.ring(c, color: const Color(0xFFFFC94A), radius: 210, life: 0.9, squash: 0.17);
      fx.ring(c, color: const Color(0xFF5FD9FF), radius: 160, life: 0.7, squash: 0.17);
      _reps++;
      fx.float(Offset(300, f.b(470 + _s2)), '+${_reps * 5} XP', style: Typo.toast.copyWith(fontSize: 14));
    }
    _lastRep = _rep.value;
  }

  void _levelUp() {
    // Levels tick 1 → 5 between 0.3 and 0.62 of the intro.
    final target = 1 + (span(_intro.value, 0.3, 0.62, Curves.easeIn) * 4).floor();
    if (target > _level) {
      setState(() => _level = target);
      _hexPulse.forward(from: 0);
      final f = Frame.read(context);
      final c = Offset(_hex.dx, f.b(_hex.dy + _s2));
      final fx = FxLayer.of(context);
      final last = _level == 5;
      HapticFeedback.selectionClick();
      fx.ring(c, color: last ? const Color(0xFFFFE07A) : const Color(0xFFFFC94A), radius: last ? 120 : 70, life: last ? 0.9 : 0.5);
      fx.burst(c, count: last ? 34 : 10, power: last ? 220 : 110, colors: const [Color(0xFFFFE07A), Color(0xFFFFB02E), Colors.white]);
      if (last) HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _rep.dispose();
    _hexPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = Frame.of(context);
    final a = _intro;
    return AnimatedBuilder(
      animation: a,
      builder: (context, _) => Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.scale(
            scale: 1 + 0.05 * (1 - span(a.value, 0, 0.6)),
            child: const Plate(asset: Art.bgOnboard, size: Size(402, 788.67), offsetY: _s2, sky: Color(0xFF040822), ground: Color(0xFF030826)),
          ),
          const Positioned.fill(child: Fog(colors: [Color(0x287A4CFF), Color(0x1A3C8BFF), Color(0x22B44CFF)], blobs: 5, seed: 4, speed: 0.8)),
          _platformArcs(f),
          const Positioned.fill(
            child: Motes(count: 30, colors: [Color(0xFFB98CFF), Color(0xFFFFD86B), Color(0xFF7FDBFF)], speed: 12, seed: 8, size: (0.8, 2.4)),
          ),
          _rays(f, a),
          _hero(f, a),
          for (var i = 0; i < _orbs.length; i++) _orb(f, a, i),
          _hexBadge(f, a),
          _titles(f, a),
          Positioned(
            left: 0,
            right: 0,
            top: f.b(658.5 + _s2),
            child: Staged(
              animation: a,
              begin: 0.55,
              end: 0.8,
              offset: const Offset(0, 8),
              child: const Center(child: Dots(index: 1)),
            ),
          ),
          Positioned(
            left: 113,
            top: f.b(688 + _s2),
            child: Staged(
              animation: a,
              begin: 0.6,
              end: 0.88,
              offset: const Offset(0, 50),
              scale: 0.75,
              curve: pop,
              child: VioletButton(
                width: 177,
                height: 49,
                onTap: () => widget.onNext(Offset(201.5, f.b(712.5 + _s2))),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Line('Next', style: tight(Typo.buttonLight)),
                      const SizedBox(width: 8),
                      Tick(
                        builder: (context, s, _) => Transform.translate(offset: Offset(math.max(0, wave(s, 1.2)) * 3, 0), child: const PhIcon(Ph.arrowRight, size: 18)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 151,
            width: 100,
            top: f.b(749 + _s2),
            height: 30,
            child: Staged(
              animation: a,
              begin: 0.7,
              end: 0.95,
              offset: const Offset(0, 12),
              child: Pressable(
                onTap: widget.onSkip,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Line('Skip', style: tight(Typo.skip)),
                      Transform.translate(
                        offset: const Offset(0, -5),
                        child: Container(width: 33, height: 1.4, color: const Color(0xD9FFFFFF)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titles(Frame f, Animation<double> a) {
    final title = Typo.title.copyWith(fontSize: 31, letterSpacing: 0.7);
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: f.y(98.3 - ascent * 31),
          child: Staged(
            animation: a,
            begin: 0.0,
            end: 0.3,
            offset: const Offset(0, -26),
            rotateX: 1.2,
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: const Offset(-0.2, 0),
              child: Center(child: Line('Your Fitness', style: tight(title))),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: f.y(134.6 - ascent * 31),
          child: Staged(
            animation: a,
            begin: 0.08,
            end: 0.38,
            offset: const Offset(0, 24),
            rotateX: -1.2,
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: const Offset(-2, 0),
              child: Center(
                child: Sheen(
                  period: 3.8,
                  delay: 1,
                  strength: 0.7,
                  width: 0.14,
                  child: GradientText('Adventure Awaits', style: tight(title), colors: const [Color(0xFFFFF09A), Color(0xFFFFD43B), Color(0xFFF2A11F)], stops: const [0, 0.5, 1]),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: f.y(172.5 - ascent * 15.3),
          child: Staged(
            animation: a,
            begin: 0.2,
            end: 0.45,
            offset: const Offset(0, 12),
            blur: 5,
            child: Transform.translate(
              offset: const Offset(0.5, 0),
              child: Column(
                children: [
                  Line('Work out, earn XP,', style: tight(Typo.lede.copyWith(fontSize: 15.3))),
                  Transform.translate(
                    offset: const Offset(0, 2.2),
                    child: Line('and unlock new worlds.', style: tight(Typo.lede.copyWith(fontSize: 15.3))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rays(Frame f, Animation<double> a) {
    final c = Offset(_hex.dx, f.b(_hex.dy + _s2));
    final on = span(a.value, 0.25, 0.7);
    return Positioned(
      left: c.dx - 150,
      top: c.dy - 150,
      width: 300,
      height: 300,
      child: Opacity(
        opacity: on,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Glow(color: Color(0xFFFFA62E), opacity: 0.55),
            Transform.scale(
              scale: 0.4 + on * 0.6,
              child: const GodRays(color: Color(0xFFFFC85A), rays: 16, opacity: 0.38, speed: 0.04, spread: 0.32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hexBadge(Frame f, Animation<double> a) {
    final enter = span(a.value, 0.1, 0.36, pop);
    final spin = (1 - span(a.value, 0.1, 0.34, swift)) * math.pi * 2.2;
    return Positioned(
      left: _hex.dx - 55,
      top: f.b(_hex.dy + _s2) - 55,
      width: 110,
      height: 110,
      child: Opacity(
        opacity: span(a.value, 0.1, 0.18, Curves.linear),
        child: Bob(
          amplitude: 3,
          period: 3.4,
          child: AnimatedBuilder(
            animation: _hexPulse,
            builder: (context, _) {
              final p = _hexPulse.value;
              final kick = 1 + math.sin(p * math.pi) * 0.14 * (1 - p * 0.4);
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateY(spin)
                  ..scaleByDouble(enter * kick, enter * kick, 1, 1),
                child: Tick(
                  builder: (context, s, _) => CustomPaint(
                    painter: _HexPainter(s, p),
                    child: Center(child: _levelText()),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _levelText() {
    return Transform.translate(
      offset: const Offset(0, 1),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: Tween(begin: 1.6, end: 1.0).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Line(
          'Lv. $_level',
          key: ValueKey(_level),
          style: poppins(
            25.5,
            FontWeight.w700,
            tracking: -0.4,
            shadows: const [Shadow(color: Color(0xCC7A3B00), blurRadius: 6, offset: Offset(0, 1.5))],
          ),
        ),
      ),
    );
  }

  Widget _orb(Frame f, Animation<double> a, int i) {
    final (center, r, art, phase) = _orbs[i];
    final from = Offset(_hex.dx, _hex.dy);
    final t = span(a.value, 0.42 + i * 0.06, 0.72 + i * 0.06, Curves.linear);
    final k = spring(t, bounce: 0.25, freq: 2.2);
    // Fly out along an arc that bulges away from the hex.
    final mid = Offset.lerp(from, center, 0.5)! + const Offset(0, -60);
    final q = 1 - k.clamp(0.0, 1.2);
    final pos = Offset(q * q * from.dx + 2 * q * k * mid.dx + k * k * center.dx, q * q * from.dy + 2 * q * k * mid.dy + k * k * center.dy);
    final size = r * 2;
    return Positioned(
      left: pos.dx - r,
      top: f.b(pos.dy + _s2) - r,
      width: size,
      height: size,
      child: Opacity(
        opacity: span(t, 0, 0.15, Curves.linear),
        child: Transform.scale(
          scale: lerp(0.2, 1, span(t, 0, 0.6, pop)),
          child: Bob(
            amplitude: 5,
            period: 3.2 + i * 0.5,
            phase: phase,
            tilt: 0.06,
            child: Pressable(
              onTap: () {
                final fx = FxLayer.of(context);
                fx.burst(Offset(center.dx, f.b(center.dy + _s2)), count: 16, power: 120, colors: const [Color(0xFFD7C4FF), Tone.goldHi, Colors.white]);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: CustomPaint(painter: _OrbPainter())),
                  Positioned(
                    left: art.x - (center.dx - r),
                    top: art.y - (center.dy - r),
                    width: art.w,
                    height: art.h,
                    child: Tick(
                      builder: (context, s, _) => Transform.rotate(angle: wave(s, 4, phase) * 0.08, child: art.image()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(Frame f, Animation<double> a) {
    const art = Art.heroPushup;
    final enter = span(a.value, 0.0, 0.45, swift);
    return Positioned(
      left: art.x,
      top: f.b(art.y + _s2) + (1 - enter) * 40,
      width: art.w,
      height: art.h,
      child: Opacity(
        opacity: span(a.value, 0.0, 0.12, Curves.linear),
        child: AnimatedBuilder(
          animation: _rep,
          builder: (context, child) {
            // Down 0 → 0.5, hold, then press up. Hands stay planted on the platform.
            final t = _rep.value;
            final down = t < 0.5 ? Curves.easeInOutSine.transform(t / 0.5) : 1 - Curves.easeOutBack.transform(((t - 0.5) / 0.5).clamp(0, 1));
            return Transform(
              alignment: const Alignment(0, 0.92),
              transform: Matrix4.identity()
                ..scaleByDouble(1 + down * 0.012, 1 - down * 0.075, 1, 1)
                ..translateByDouble(0, down * 2, 0, 1),
              child: child,
            );
          },
          child: art.image(),
        ),
      ),
    );
  }

  Widget _platformArcs(Frame f) {
    return Positioned(
      left: 0,
      right: 0,
      top: f.b(520 + _s2),
      height: 110,
      child: Tick(builder: (context, s, _) => CustomPaint(painter: _ArcsPainter(s))),
    );
  }
}

class _HexPainter extends CustomPainter {
  _HexPainter(this.s, this.pulse);

  final double s;
  final double pulse;

  Path _hex(Offset c, double w, double h, double r) {
    final pts = [
      Offset(c.dx, c.dy - h / 2),
      Offset(c.dx + w / 2, c.dy - h / 4),
      Offset(c.dx + w / 2, c.dy + h / 4),
      Offset(c.dx, c.dy + h / 2),
      Offset(c.dx - w / 2, c.dy + h / 4),
      Offset(c.dx - w / 2, c.dy - h / 4),
    ];
    final p = Path();
    for (var i = 0; i < 6; i++) {
      final prev = pts[(i + 5) % 6];
      final cur = pts[i];
      final next = pts[(i + 1) % 6];
      final a = cur + (prev - cur) / (prev - cur).distance * r;
      final b = cur + (next - cur) / (next - cur).distance * r;
      i == 0 ? p.moveTo(a.dx, a.dy) : p.lineTo(a.dx, a.dy);
      p.quadraticBezierTo(cur.dx, cur.dy, b.dx, b.dy);
    }
    return p..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const w = 100.0;
    const h = 104.0;
    final outer = _hex(c, w, h, 9);
    final glow = 0.6 + 0.4 * math.sin(s * 2.4) + pulse * 0.8;
    canvas.drawPath(
      outer,
      Paint()
        ..color = const Color(0xFFFFB02E).withValues(alpha: (0.55 * glow).clamp(0, 1))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawPath(
      outer,
      Paint()
        ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF8A4A2C), Color(0xFF5C2A36), Color(0xFF3A1A3E)]).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.2
        ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFF0A0), Color(0xFFFFC22E), Color(0xFFF08A10)]).createShader(Offset.zero & size),
    );
    // A spark that runs around the rim.
    final metric = outer.computeMetrics().first;
    final d = (s * 0.45 % 1) * metric.length;
    for (var k = 0; k < 6; k++) {
      final pos = metric.getTangentForOffset((d - k * 3) % metric.length)!.position;
      canvas.drawCircle(
        pos,
        3.2 - k * 0.45,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9 - k * 0.14)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
    final inner = _hex(c, w - 12, h - 12, 7);
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x66FFE7A0),
    );
  }

  @override
  bool shouldRepaint(_HexPainter old) => old.s != s || old.pulse != pulse;
}

class _OrbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(
      c,
      r + 3,
      Paint()
        ..color = const Color(0x557A4CFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()..shader = const RadialGradient(center: Alignment(-0.3, -0.4), colors: [Color(0xCC3B2C72), Color(0xD9201640), Color(0xE6150F30)]).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r - 0.8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = const SweepGradient(colors: [Color(0xCC9B7CFF), Color(0x55563AB0), Color(0xCCB59BFF), Color(0x55563AB0), Color(0xCC9B7CFF)]).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    final hl = Rect.fromCircle(center: c + Offset(-r * 0.28, -r * 0.42), radius: r * 0.5);
    canvas.drawOval(
      Rect.fromCenter(center: hl.center, width: hl.width, height: hl.height * 0.45),
      Paint()
        ..color = const Color(0x22FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) => false;
}

/// Energy arcs spinning around the hero's platform.
class _ArcsPainter extends CustomPainter {
  _ArcsPainter(this.s);

  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, 54);
    for (var ring = 0; ring < 2; ring++) {
      final rect = Rect.fromCenter(center: c, width: ring == 0 ? 330 : 250, height: ring == 0 ? 58 : 42);
      final dir = ring == 0 ? 1 : -1;
      for (var k = 0; k < 3; k++) {
        final start = dir * s * (0.6 + ring * 0.3) + k * math.pi * 2 / 3;
        canvas.drawArc(
          rect,
          start,
          0.55,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 2.2
            ..color = (ring == 0 ? const Color(0xFFFFD45A) : const Color(0xFF6BE3FF)).withValues(alpha: 0.55)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ArcsPainter old) => old.s != s;
}
