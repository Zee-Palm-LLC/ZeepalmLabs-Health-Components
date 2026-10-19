import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/fx.dart';
import '../widgets/parts.dart';

/// One stop on a tutorial: the widgets to spotlight and what the coach says.
class ShowStep {
  const ShowStep({required this.targets, required this.title, required this.body, this.radius = 18, this.pad = 6, this.tap = false, this.hint = 'Tap the highlight'});

  /// Spotlit area is the union of these widgets' boxes.
  final List<GlobalKey> targets;
  final String title;
  final String body;
  final double radius;
  final double pad;

  /// The player must tap the highlighted widget to continue. Taps inside the
  /// spotlight reach the real widget, so it reacts exactly as it normally would.
  final bool tap;
  final String hint;
}

/// A tutorial chapter: a banner, its steps and the reward for finishing.
class Chapter {
  const Chapter({required this.id, required this.name, required this.steps, this.reward = 100, this.onDone});

  final String id;
  final String name;
  final List<ShowStep> steps;
  final int reward;
  final VoidCallback? onDone;
}

enum _Phase { idle, banner, steps, outro }

/// Hosts game-style guided tours over the whole app.
///
/// A spotlight cut out of a dark veil glides between targets with a spring,
/// framed by marching gold dashes and targeting brackets. A coach dialog with
/// a portrait types each line; tap-to-try steps pulse ripples and a bouncing
/// arrow until the player taps the real widget underneath.
class ShowcaseHost extends StatefulWidget {
  const ShowcaseHost({super.key, required this.child, this.onReward});

  final Widget child;
  final void Function(int xp)? onReward;

  static ShowcaseHostState of(BuildContext context) => context.findAncestorStateOfType<ShowcaseHostState>()!;

  @override
  State<ShowcaseHost> createState() => ShowcaseHostState();
}

class ShowcaseHostState extends State<ShowcaseHost> with TickerProviderStateMixin {
  final _key = GlobalKey();
  late final AnimationController _veil;
  late final AnimationController _move;
  late final AnimationController _type;
  late final AnimationController _banner;
  late final AnimationController _nudge;
  _Phase _phase = _Phase.idle;
  Chapter? _chapter;
  int _index = 0;
  Rect? _from;
  Rect _last = Rect.zero;
  Offset? _down;
  int _pending = -1;

  bool get active => _phase != _Phase.idle;

  @override
  void initState() {
    super.initState();
    _veil = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _move = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _type = AnimationController(vsync: this);
    _banner = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));
    _nudge = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  }

  @override
  void dispose() {
    _veil.dispose();
    _move.dispose();
    _type.dispose();
    _banner.dispose();
    _nudge.dispose();
    super.dispose();
  }

  /// Plays [chapter] as soon as no other chapter is on screen.
  void queue(Chapter chapter, {int tries = 20}) {
    if (!mounted || tries <= 0) return;
    if (active) {
      Future.delayed(const Duration(milliseconds: 400), () => queue(chapter, tries: tries - 1));
    } else {
      start(chapter);
    }
  }

  /// Plays [chapter] unless one is already running.
  Future<void> start(Chapter chapter) async {
    if (active) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _chapter = chapter;
      _index = 0;
      _from = null;
      _phase = _Phase.banner;
    });
    _veil.forward(from: 0);
    await _banner.forward(from: 0);
    if (!mounted || _chapter != chapter) return;
    setState(() => _phase = _Phase.steps);
    _enterStep();
  }

  void _enterStep() {
    final step = _chapter!.steps[_index];
    _move.forward(from: 0);
    _type.duration = Duration(milliseconds: 420 + step.body.length * 24);
    _type.forward(from: 0);
  }

  void _next() {
    final steps = _chapter!.steps;
    HapticFeedback.selectionClick();
    if (_index + 1 >= steps.length) {
      _finish();
      return;
    }
    setState(() {
      _from = _last;
      _index++;
    });
    _enterStep();
  }

  void _finish({bool skipped = false}) {
    final chapter = _chapter;
    if (chapter == null) return;
    if (skipped) {
      _veil.reverse().then((_) => _close(chapter, reward: false));
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() => _phase = _Phase.outro);
    final box = _key.currentContext!.findRenderObject() as RenderBox;
    final c = box.size.center(Offset.zero);
    final fx = FxLayer.of(context);
    fx.burst(c, count: 50, power: 260, colors: const [Tone.goldHi, Color(0xFFB98CFF), Color(0xFF6BE3FF), Colors.white]);
    fx.ring(c, color: Tone.goldHi, radius: 160, life: 1);
    _banner.forward(from: 0).then((_) => _veil.reverse()).then((_) => _close(chapter, reward: true));
  }

  void _close(Chapter chapter, {required bool reward}) {
    if (!mounted) return;
    setState(() {
      _phase = _Phase.idle;
      _chapter = null;
    });
    if (reward) widget.onReward?.call(chapter.reward);
    chapter.onDone?.call();
  }

  Rect? _target(ShowStep step) {
    final host = _key.currentContext?.findRenderObject() as RenderBox?;
    if (host == null) return null;
    Rect? out;
    for (final k in step.targets) {
      final box = k.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached || !box.hasSize) continue;
      final r = MatrixUtils.transformRect(box.getTransformTo(host), Offset.zero & box.size);
      out = out == null ? r : out.expandToInclude(r);
    }
    return out?.inflate(step.pad);
  }

  void _tap(TapUpDetails d) {
    if (_phase != _Phase.steps) return;
    if (_type.isAnimating) {
      _type.value = 1;
      return;
    }
    final step = _chapter!.steps[_index];
    if (step.tap) {
      HapticFeedback.lightImpact();
      _nudge.forward(from: 0);
      return;
    }
    _next();
  }

  /// A tap that landed inside the spotlight (and went through to the widget).
  void _holeTap() {
    if (_phase != _Phase.steps || _pending == _index) return;
    _type.value = 1;
    final at = _index;
    _pending = at;
    // Let the real widget's press play before the spotlight moves on.
    Future.delayed(const Duration(milliseconds: 260), () {
      if (!mounted || _phase != _Phase.steps || _index != at) return;
      _pending = -1;
      _next();
    });
  }

  bool get _holeOpen => _phase == _Phase.steps && !_last.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) => _down = e.localPosition,
      onPointerUp: (e) {
        final down = _down;
        _down = null;
        if (!_holeOpen || down == null) return;
        if (_last.contains(e.localPosition) && _last.contains(down) && (e.localPosition - down).distance < 24) _holeTap();
      },
      child: Stack(
        key: _key,
        fit: StackFit.expand,
        children: [
          widget.child,
          if (active)
            Positioned.fill(
              child: _PassThrough(
                hole: () => _holeOpen ? _last : null,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: _tap,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Tick(builder: (context, s, _) => _overlay(context, s)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _overlay(BuildContext context, double s) {
    final size = MediaQuery.sizeOf(context);
    final chapter = _chapter!;
    final steps = _phase == _Phase.steps;
    final step = chapter.steps[_index];
    final live = steps ? _target(step) : null;
    final t = settle.transform(_move.value);
    final hole = live == null ? null : (_from == null ? live : Rect.lerp(_from, live, t)!);
    if (hole != null) _last = hole;
    final veil = Curves.easeOut.transform(_veil.value);
    final below = hole == null || hole.center.dy < size.height * 0.52;
    final radius = hole == null ? step.radius : math.min(step.radius, hole.shortestSide / 2);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Light up whatever sits in the spotlight so it reads as live, not greyed out.
        if (hole != null)
          Positioned.fromRect(
            rect: hole,
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: BackdropFilter(filter: ColorFilter.matrix(_lift(1.1 + 0.07 * math.sin(s * 3.2) * veil)), child: const SizedBox.expand()),
              ),
            ),
          ),
        Positioned.fill(child: CustomPaint(painter: _VeilPainter(hole, radius, veil, s, step.tap && steps, t))),
        if (hole != null && step.tap) _arrow(hole, below, s),
        if (steps && hole != null) _dialog(context, chapter, step, hole, below, size),
        if (_phase == _Phase.banner) _bannerView(chapter.name, 'TUTORIAL', size),
        if (_phase == _Phase.outro) _bannerView('Chapter complete', '+${chapter.reward} XP', size, done: true),
      ],
    );
  }

  /// Brightens and slightly saturates.
  static List<double> _lift(double b) {
    const sat = 1.12;
    const lr = 0.2126 * (1 - sat);
    const lg = 0.7152 * (1 - sat);
    const lb = 0.0722 * (1 - sat);
    return [
      (lr + sat) * b, lg * b, lb * b, 0, 6, //
      lr * b, (lg + sat) * b, lb * b, 0, 6,
      lr * b, lg * b, (lb + sat) * b, 0, 6,
      0, 0, 0, 1, 0,
    ];
  }

  Widget _arrow(Rect hole, bool below, double s) {
    final bounce = (math.sin(s * 7) + 1) / 2 * 8;
    final x = hole.center.dx - 13;
    final y = below ? hole.bottom + 6 + bounce : hole.top - 32 - bounce;
    return Positioned(
      left: x,
      top: y,
      width: 26,
      height: 26,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: below ? 0 : math.pi,
          child: const CustomPaint(painter: _ArrowPainter()),
        ),
      ),
    );
  }

  Widget _dialog(BuildContext context, Chapter chapter, ShowStep step, Rect hole, bool below, Size size) {
    const h = 150.0;
    final top = below ? math.min(hole.bottom + (step.tap ? 40 : 18), size.height - h - 24) : math.max(hole.top - h - (step.tap ? 40 : 18), 40.0);
    final enter = span(_move.value, 0, 0.6, pop);
    return Positioned(
      left: 12,
      right: 12,
      top: top,
      height: h,
      child: AnimatedBuilder(
        animation: Listenable.merge([_type, _nudge]),
        builder: (context, _) {
          final nudge = shake(_nudge.value, freq: 4, decay: 3) * 10;
          return Transform.translate(
            offset: Offset(nudge, (1 - enter) * (below ? -14 : 14)),
            child: Opacity(
              opacity: enter.clamp(0, 1),
              child: _DialogBox(chapter: chapter, step: step, index: _index, typed: _type.value, onSkip: () => _finish(skipped: true), onNext: step.tap ? null : _next, hinting: _nudge.isAnimating),
            ),
          );
        },
      ),
    );
  }

  Widget _bannerView(String title, String kicker, Size size, {bool done = false}) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _banner,
          builder: (context, _) {
            final v = _banner.value;
            final inT = span(v, 0, 0.3, swift);
            final out = span(v, 0.78, 1, Curves.easeIn);
            final y = size.height * 0.42;
            return Opacity(
              opacity: (1 - out).clamp(0, 1),
              child: Stack(
                children: [
                  // Speed streaks.
                  for (var i = 0; i < 14; i++)
                    Positioned(
                      left: lerp(-200, size.width + 40, cycle(v * 1.6 + hash(i, 4), 1)),
                      top: y - 60 + hash(i, 5) * 150,
                      width: 60 + hash(i, 6) * 120,
                      height: 1.5 + hash(i, 7) * 2,
                      child: ColoredBox(color: (i.isEven ? Tone.goldHi : const Color(0xFFB98CFF)).withValues(alpha: 0.6 * inT)),
                    ),
                  Positioned(
                    left: lerp(-size.width, 0, inT) - out * 60,
                    right: lerp(size.width, 0, inT) + out * 60,
                    top: y - 46,
                    height: 92,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.skewY(-0.06),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              (done ? const Color(0xFF3A2A08) : const Color(0xFF1E1250)).withValues(alpha: 0.95),
                              (done ? const Color(0xFF3A2A08) : const Color(0xFF1E1250)).withValues(alpha: 0.95),
                              Colors.transparent,
                            ],
                            stops: const [0, 0.18, 0.82, 1],
                          ),
                          border: const Border.symmetric(horizontal: BorderSide(color: Color(0xAAFFD45A), width: 1.4)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Line(kicker, style: poppins(11.5, FontWeight.w700, color: done ? Tone.butter : const Color(0xFFC9B6FF), tracking: 5)),
                            const SizedBox(height: 2),
                            Transform.scale(
                              scale: lerp(1.6, 1, span(v, 0.05, 0.32, pop)),
                              child: Sheen(
                                period: 1.6,
                                strength: 0.7,
                                child: GradientText(title.toUpperCase(), style: poppins(27, FontWeight.w700, tracking: 1.5), colors: goldText, stops: goldStops),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Lets pointer events inside the spotlight fall through to the app below.
class _PassThrough extends SingleChildRenderObjectWidget {
  const _PassThrough({required this.hole, super.child});

  final Rect? Function() hole;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderPassThrough(hole);

  @override
  void updateRenderObject(BuildContext context, _RenderPassThrough renderObject) => renderObject.hole = hole;
}

class _RenderPassThrough extends RenderProxyBox {
  _RenderPassThrough(this.hole);

  Rect? Function() hole;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final h = hole();
    if (h != null && h.contains(position)) return false;
    return super.hitTest(result, position: position);
  }
}

class _DialogBox extends StatelessWidget {
  const _DialogBox({required this.chapter, required this.step, required this.index, required this.typed, required this.onSkip, required this.onNext, required this.hinting});

  final Chapter chapter;
  final ShowStep step;
  final int index;
  final double typed;
  final VoidCallback onSkip;
  final VoidCallback? onNext;
  final bool hinting;

  @override
  Widget build(BuildContext context) {
    final shown = step.body.substring(0, (step.body.length * typed).round());
    final count = chapter.steps.length;
    return CustomPaint(
      painter: const _FramePainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Portrait(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Line('STEP ${index + 1}/$count', style: poppins(9.5, FontWeight.w700, color: const Color(0xFFB59CFF), tracking: 1.6)),
                            const Spacer(),
                            Pressable(
                              onTap: onSkip,
                              child: Line('Skip tutorial', style: poppins(11, FontWeight.w500, color: const Color(0xFF9B97C2))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        GradientText(step.title, style: poppins(16, FontWeight.w700), colors: goldText, stops: goldStops),
                        const SizedBox(height: 3),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: shown),
                              if (typed >= 1)
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Tick(
                                    builder: (context, s, _) => Opacity(
                                      opacity: (math.sin(s * 8) + 1) / 2,
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 4),
                                        child: PhIcon(Ph.caretRight, size: 10, color: Tone.butter),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          style: poppins(12.6, FontWeight.w400, color: const Color(0xFFE4E1F7), height: 1.42),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < count; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(right: 5),
                    width: i == index ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i < index ? const Color(0xFFB59CFF) : (i == index ? Tone.butter : const Color(0x40FFFFFF)),
                      boxShadow: i == index ? const [BoxShadow(color: Color(0x88FFD45A), blurRadius: 6)] : null,
                    ),
                  ),
                const Spacer(),
                if (onNext == null)
                  Tick(
                    builder: (context, s, _) => Opacity(
                      opacity: 0.55 + 0.45 * (math.sin(s * 5) + 1) / 2,
                      child: Row(
                        children: [
                          const PhIcon(Ph.sparkle, size: 12, color: Tone.butter),
                          const SizedBox(width: 5),
                          Line(hinting ? 'Tap the glowing target!' : step.hint, style: poppins(11.5, FontWeight.w600, color: hinting ? const Color(0xFFFF9B6A) : Tone.butter)),
                        ],
                      ),
                    ),
                  )
                else
                  VioletButton(
                    width: index + 1 == count ? 98 : 84,
                    height: 30,
                    onTap: onNext,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Line(index + 1 == count ? 'Finish' : 'Next', style: poppins(12.5, FontWeight.w600)),
                          const SizedBox(width: 4),
                          const PhIcon(Ph.caretRight, size: 11),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The coach portrait: the hero avatar in a rotating gold rune frame with a name plate.
class _Portrait extends StatelessWidget {
  const _Portrait();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 2,
            top: 2,
            width: 64,
            height: 64,
            child: Tick(
              builder: (context, s, _) => CustomPaint(
                painter: _RuneRing(s),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: ClipOval(
                    child: Transform.translate(
                      offset: Offset(0, wave(s, 2.4) * 0.8),
                      child: Art.avatar.image(fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -2,
            right: -2,
            top: 66,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(colors: [Color(0xFFFFD45A), Color(0xFFF2A11F)]),
                boxShadow: const [BoxShadow(color: Color(0x66FFB02E), blurRadius: 8)],
              ),
              child: Center(
                child: Line('COACH KAI', style: poppins(8.6, FontWeight.w700, color: Tone.buttonInk, tracking: 0.8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuneRing extends CustomPainter {
  _RuneRing(this.s);

  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(
      c,
      r + 2,
      Paint()
        ..color = const Color(0x66FFB02E)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(c, r - 1, Paint()..color = const Color(0xFF241A4A));
    canvas.drawCircle(
      c,
      r - 1.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..shader = const SweepGradient(colors: [Color(0xFFFFF0A0), Color(0xFFF08A10), Color(0xFFFFD45A), Color(0xFFF08A10), Color(0xFFFFF0A0)]).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    for (var i = 0; i < 12; i++) {
      final a = s * 0.8 + i * math.pi / 6;
      final p = c + Offset(math.cos(a), math.sin(a)) * (r + 4);
      canvas.drawCircle(p, i.isEven ? 1.6 : 1, Paint()..color = const Color(0xCCFFE07A));
    }
  }

  @override
  bool shouldRepaint(_RuneRing old) => old.s != s;
}

/// Ornate dialog frame: dark glass, a double gold border and corner gems.
class _FramePainter extends CustomPainter {
  const _FramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18));
    canvas.drawRRect(
      r.shift(const Offset(0, 6)),
      Paint()
        ..color = const Color(0x99050318)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawRRect(
      r,
      Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xF2251C55), Color(0xF5140F33)]).createShader(Offset.zero & size),
    );
    canvas.drawRRect(
      r.deflate(0.8),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = const LinearGradient(colors: [Color(0xFFFFE07A), Color(0xFFB0721E), Color(0xFFFFE07A)]).createShader(Offset.zero & size),
    );
    canvas.drawRRect(
      r.deflate(4.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = const Color(0x44FFE07A),
    );
    for (final p in [const Offset(0, 0), Offset(size.width, 0), Offset(0, size.height), Offset(size.width, size.height)]) {
      final q = Offset(p.dx == 0 ? 9 : p.dx - 9, p.dy == 0 ? 9 : p.dy - 9);
      final gem = Path()
        ..moveTo(q.dx, q.dy - 5)
        ..lineTo(q.dx + 5, q.dy)
        ..lineTo(q.dx, q.dy + 5)
        ..lineTo(q.dx - 5, q.dy)
        ..close();
      canvas.drawPath(gem, Paint()..color = const Color(0xFFFFD45A));
      canvas.drawPath(
        gem,
        Paint()
          ..color = const Color(0xFFFFF4C2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(_FramePainter old) => false;
}

class _VeilPainter extends CustomPainter {
  _VeilPainter(this.hole, this.radius, this.veil, this.s, this.tap, this.arrive);

  final Rect? hole;
  final double radius;
  final double veil;
  final double s;
  final bool tap;
  final double arrive;

  @override
  void paint(Canvas canvas, Size size) {
    final dim = Paint()..color = const Color(0xFF040516).withValues(alpha: 0.8 * veil);
    if (hole == null) {
      canvas.drawRect(Offset.zero & size, dim);
      return;
    }
    final rr = RRect.fromRectAndRadius(hole!, Radius.circular(radius));
    // Even-odd fill cuts the hole on every renderer (path booleans are not reliable on web).
    final veilPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect((Offset.zero & size).inflate(2))
      ..addRRect(rr);
    canvas.drawPath(veilPath, dim);
    // Inner rim light.
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = const Color(0x55FFC94A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Marching dashes.
    final metric = (Path()..addRRect(rr.inflate(3))).computeMetrics().first;
    const dash = 9.0;
    const gap = 6.0;
    final shift = (s * 30) % (dash + gap);
    final dashes = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFFE07A);
    for (var d = -shift; d < metric.length; d += dash + gap) {
      final a = math.max(0.0, d);
      final b = math.min(metric.length, d + dash);
      if (b > a) canvas.drawPath(metric.extractPath(a, b), dashes);
    }
    // Targeting brackets that snap in and breathe.
    final out = 10 + 6 * (1 - arrive) + 2 * math.sin(s * 4);
    final box = hole!.inflate(out);
    const arm = 14.0;
    final bracket = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.9);
    for (final corner in [box.topLeft, box.topRight, box.bottomLeft, box.bottomRight]) {
      final sx = corner.dx == box.left ? 1.0 : -1.0;
      final sy = corner.dy == box.top ? 1.0 : -1.0;
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx, corner.dy + sy * arm)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx + sx * arm, corner.dy),
        bracket,
      );
    }
    if (tap) {
      for (var k = 0; k < 2; k++) {
        final p = cycle(s, 1.4, k * 0.5);
        canvas.drawRRect(
          rr.inflate(4 + p * 22),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4 * (1 - p)
            ..color = const Color(0xFFFFD45A).withValues(alpha: (1 - p) * 0.8),
        );
      }
    }
    // Light sweep across the spotlight.
    final sweep = cycle(s, 2.8);
    if (sweep < 0.45) {
      final x = lerp(hole!.left - 40, hole!.right + 40, sweep / 0.45);
      canvas.save();
      canvas.clipRRect(rr);
      canvas.drawRect(
        Rect.fromLTWH(x - 20, hole!.top, 40, hole!.height),
        Paint()..shader = ui.Gradient.linear(Offset(x - 20, 0), Offset(x + 20, 0), const [Color(0x00FFFFFF), Color(0x33FFFFFF), Color(0x00FFFFFF)], const [0, 0.5, 1]),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_VeilPainter old) => true;
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, w * 0.55)
      ..lineTo(w * 0.66, w * 0.55)
      ..lineTo(w * 0.66, w)
      ..lineTo(w * 0.34, w)
      ..lineTo(w * 0.34, w * 0.55)
      ..lineTo(0, w * 0.55)
      ..close();
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xAAFFB02E)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      p,
      Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFF0A0), Color(0xFFF2A11F)]).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF7A3B00),
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => false;
}
