import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../icons.dart';
import '../theme.dart';

// ---------------------------------------------------------------------------
// Motion helpers
// ---------------------------------------------------------------------------

const springOut = Cubic(0.16, 1.18, 0.3, 1); // gentle overshoot
const smoothOut = Cubic(0.22, 1, 0.36, 1);

/// Runs a 0..1 animation once after [delay]. Children read it to choreograph
/// entrances; a new [key] on the screen replays everything.
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.delay = 0,
    this.duration = 900,
    this.dy = 24,
    this.dx = 0,
    this.scale = 1,
    this.blur = 0,
    this.rotate = 0,
    this.curve = smoothOut,
  });

  final Widget child;
  final int delay, duration;
  final double dy, dx, scale, blur, rotate;
  final Curve curve;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.duration),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = widget.curve.transform(_c.value);
        final o = Curves.easeOut.transform((_c.value * 1.6).clamp(0.0, 1.0));
        Widget w = Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translateByDouble(widget.dx * (1 - t), widget.dy * (1 - t), 0, 1)
            ..rotateZ(widget.rotate * (1 - t))
            ..scaleByDouble(ui.lerpDouble(widget.scale, 1, t)!, ui.lerpDouble(widget.scale, 1, t)!, 1, 1),
          child: child,
        );
        // Keep the filter in the tree even when idle: inserting/removing it
        // would change the tree shape and remount (replay) everything inside.
        final b = widget.blur * (1 - t);
        w = ImageFiltered(
          enabled: b > 0.05,
          imageFilter: ui.ImageFilter.blur(sigmaX: b, sigmaY: b),
          child: w,
        );
        return Opacity(opacity: o, child: w);
      },
    );
  }
}

/// Text that materialises word by word: each word rises, unblurs and fades in
/// on a stagger, so headlines feel written in real time.
class BlurText extends StatefulWidget {
  const BlurText(this.text, {super.key, required this.style, this.delay = 0, this.stagger = 55, this.align = TextAlign.center});

  final String text;
  final TextStyle style;
  final int delay, stagger;
  final TextAlign align;

  @override
  State<BlurText> createState() => _BlurTextState();
}

class _BlurTextState extends State<BlurText> with SingleTickerProviderStateMixin {
  // Words plus explicit line breaks ('\n' tokens) so copy can match the design's breaks.
  late final List<String> _words = widget.text.replaceAll('\n', ' \n ').split(' ').where((w) => w.isNotEmpty).toList();
  late final int _total = widget.delay + _words.length * widget.stagger + 700;
  late final _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _total),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final ms = _c.value * _total;
        if (_c.isCompleted) return Text(widget.text, style: widget.style, textAlign: widget.align);
        final spans = <InlineSpan>[];
        for (var i = 0; i < _words.length; i++) {
          if (_words[i] == '\n') {
            spans.add(const TextSpan(text: '\n'));
            continue;
          }
          final lt = ((ms - widget.delay - i * widget.stagger) / 700).clamp(0.0, 1.0);
          final t = smoothOut.transform(lt);
          final b = 6 * (1 - t);
          Widget w = Text(_words[i], style: widget.style);
          if (b > 0.05) {
            w = ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: b, sigmaY: b),
              child: w,
            );
          }
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Opacity(
                opacity: Curves.easeOut.transform((lt * 1.5).clamp(0.0, 1.0)),
                child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: w),
              ),
            ),
          );
          if (i < _words.length - 1 && _words[i + 1] != '\n') {
            spans.add(TextSpan(text: ' ', style: widget.style));
          }
        }
        return Text.rich(TextSpan(children: spans), textAlign: widget.align);
      },
    );
  }
}

/// Squishes on press with a spring release and a light haptic.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.96});

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> with SingleTickerProviderStateMixin {
  late final _c = AnimationController.unbounded(vsync: this, value: 1);

  void _to(double v, {double vel = 0}) =>
      _c.animateWith(SpringSimulation(const SpringDescription(mass: 1, stiffness: 520, damping: 18), _c.value, v, vel));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _to(widget.scale),
      onTapCancel: () => _to(1),
      onTapUp: (_) {
        _to(1, vel: 2);
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) => Transform.scale(scale: _c.value, child: child),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Primitives
// ---------------------------------------------------------------------------

/// Dark full-width CTA with a slow specular sweep.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton(this.label, {super.key, this.onTap, this.color = C.button, this.height = 56, this.enabled = true});

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double height;
  final bool enabled;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with SingleTickerProviderStateMixin {
  late final _sheen = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat();

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: widget.enabled ? 1 : 0.45,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: widget.color.withValues(alpha: 0.28), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _sheen,
                  builder: (context, _) {
                    final x = -1.6 + _sheen.value * 4.2;
                    return Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(x - 0.5, -1),
                            end: Alignment(x + 0.5, 1),
                            colors: const [Color(0x00FFFFFF), Color(0x1FFFFFFF), Color(0x00FFFFFF)],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Text(
                  widget.label,
                  style: sans(15, color: Colors.white, w: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BackLink extends StatelessWidget {
  const BackLink({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(PhB.caretLeft, size: 11, color: C.ink2),
            const SizedBox(width: 4),
            Text(
              'Back',
              style: sans(14, color: C.ink2, w: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small outlined compass used inside tag pills and the stepper.
class CompassGlyph extends StatelessWidget {
  const CompassGlyph({super.key, this.size = 14, this.color = C.red});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _GlyphPainter(color));
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(
      c,
      r * 0.86,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.16
        ..color = color,
    );
    final d = Offset(math.cos(-math.pi / 4), math.sin(-math.pi / 4));
    final n = Offset(-d.dy, d.dx);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx + d.dx * r * 0.62, c.dy + d.dy * r * 0.62)
        ..lineTo(c.dx + n.dx * r * 0.2, c.dy + n.dy * r * 0.2)
        ..lineTo(c.dx - d.dx * r * 0.62, c.dy - d.dy * r * 0.62)
        ..lineTo(c.dx - n.dx * r * 0.2, c.dy - n.dy * r * 0.2)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.color != color;
}

class TagPill extends StatelessWidget {
  const TagPill(this.label, {super.key, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      decoration: BoxDecoration(
        color: C.tagBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Color(0x0FE24A3B), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon == null) const CompassGlyph(size: 13) else Icon(icon, size: 13, color: C.red),
          const SizedBox(width: 6),
          Text(label, style: serif(13, color: C.ink2)),
        ],
      ),
    );
  }
}

/// iOS-style status bar.
class StatusBar extends StatelessWidget {
  const StatusBar({super.key, this.color = C.ink});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(42, 16, 30, 0),
        child: Row(
          children: [
            Text(
              '9:41',
              style: sans(15.5, color: color, w: FontWeight.w600, height: 1),
            ),
            const Spacer(),
            Icon(Ph.signal, size: 16, color: color),
            const SizedBox(width: 5),
            Icon(Ph.wifi, size: 16, color: color),
            const SizedBox(width: 5),
            Icon(Ph.battery, size: 22, color: color),
          ],
        ),
      ),
    );
  }
}

/// A rounded square icon chip (blue/green/purple tiles on the preview cards).
class IconChip extends StatelessWidget {
  const IconChip(this.icon, this.color, {super.key, this.size = 34, this.radius = 10});
  final IconData icon;
  final Color color;
  final double size, radius;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [hsl.withLightness((hsl.lightness + 0.08).clamp(0, 1)).toColor(), color],
        ),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Icon(icon, size: size * 0.5, color: Colors.white),
    );
  }
}

// ---------------------------------------------------------------------------
// Selection
// ---------------------------------------------------------------------------

/// Animated rounded checkbox: the box fills with a radial ink splash and the
/// tick is stroked on with a slight overshoot.
class CheckBox3 extends StatelessWidget {
  const CheckBox3({super.key, required this.checked, this.size = 22, this.round = false});
  final bool checked;
  final double size;
  final bool round;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: checked ? 1 : 0),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => CustomPaint(size: Size.square(size), painter: _CheckPainter(t, round)),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.t, this.round);
  final double t;
  final bool round;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(round ? size.width / 2 : size.width * 0.3));
    canvas.drawRRect(r, Paint()..color = const Color(0xFFF7F4F3));
    canvas.drawRRect(
      r.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Color.lerp(C.line, C.red, t)!,
    );
    if (t <= 0) return;
    canvas.save();
    canvas.clipRRect(r);
    canvas.drawCircle(
      size.center(Offset.zero),
      size.width * 0.75 * Curves.easeOutBack.transform(math.min(1, t * 1.4)),
      Paint()..color = C.red,
    );
    canvas.restore();
    final p = Path()
      ..moveTo(size.width * 0.27, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.68)
      ..lineTo(size.width * 0.74, size.height * 0.35);
    final m = p.computeMetrics().first;
    final tk = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
    canvas.drawPath(
      m.extractPath(0, m.length * tk),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.11
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.t != t;
}

/// Answer card: 3D emoji, serif label, checkbox. On selection the emoji does a
/// spring-loaded 3D flip, the card lifts and its border ignites.
class OptionCard extends StatefulWidget {
  const OptionCard({
    super.key,
    required this.image,
    required this.label,
    required this.selected,
    this.dimmed = false,
    this.onTap,
  });

  final String image, label;
  final bool selected, dimmed;
  final VoidCallback? onTap;

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard> with SingleTickerProviderStateMixin {
  late final _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didUpdateWidget(OptionCard old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) _flip.forward(from: 0);
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return Pressable(
      scale: 0.97,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: sel ? 1.025 : (widget.dimmed ? 0.985 : 1),
        duration: const Duration(milliseconds: 500),
        curve: springOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: widget.dimmed ? 0.78 : 0.94),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: sel ? C.red : Colors.white, width: sel ? 1.6 : 1),
            boxShadow: [
              BoxShadow(
                color: sel ? const Color(0x33F0473A) : const Color(0x12B4442F),
                blurRadius: sel ? 26 : 16,
                offset: Offset(0, sel ? 12 : 6),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _flip,
                builder: (context, child) {
                  final v = _flip.value;
                  final spin = Curves.easeOutBack.transform(v) * math.pi * 2;
                  final pop = 1 + math.sin(v * math.pi) * 0.28;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateY(spin)
                      ..scaleByDouble(pop, pop, 1, 1),
                    child: child,
                  );
                },
                child: Image.asset(widget.image, width: 40, height: 40, filterQuality: FilterQuality.medium),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(widget.label, style: serif(15, color: C.ink, height: 1.25)),
              ),
              const SizedBox(width: 12),
              CheckBox3(checked: sel),
            ],
          ),
        ),
      ),
    );
  }
}

/// Text field card (label above value) with an igniting focus ring.
class FieldCard extends StatefulWidget {
  const FieldCard({super.key, required this.label, required this.initial, this.onFocus, this.onChanged});
  final String label, initial;
  final ValueChanged<bool>? onFocus;
  final ValueChanged<String>? onChanged;

  @override
  State<FieldCard> createState() => _FieldCardState();
}

class _FieldCardState extends State<FieldCard> {
  late final _ctl = TextEditingController(text: widget.initial);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() {});
      widget.onFocus?.call(_focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = _focus.hasFocus;
    return GestureDetector(
      onTap: _focus.requestFocus,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        height: 64,
        padding: const EdgeInsets.fromLTRB(16, 11, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: f ? C.red.withValues(alpha: 0.75) : Colors.white, width: f ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: f ? const Color(0x2EF0473A) : const Color(0x10B4442F),
              blurRadius: f ? 22 : 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: sans(11, color: f ? C.red : C.muted, w: FontWeight.w500),
              child: Text(widget.label),
            ),
            const SizedBox(height: 3),
            Expanded(
              child: TextField(
                controller: _ctl,
                focusNode: _focus,
                onChanged: widget.onChanged,
                cursorColor: C.red,
                cursorWidth: 1.6,
                style: sans(16, color: C.ink, w: FontWeight.w500, height: 1.2),
                decoration: const InputDecoration.collapsed(hintText: ''),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stepper
// ---------------------------------------------------------------------------

/// Six-node progress rail. The active ring travels between nodes as a gooey
/// blob: it stretches along the rail with its speed and snaps back round,
/// while the red fill races ahead of it.
class AppStepper extends StatelessWidget {
  const AppStepper({super.key, required this.index, this.from});
  final int index;
  final int? from;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: (from ?? index).toDouble(), end: index.toDouble()),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeInOutCubic,
      builder: (context, p, _) => CustomPaint(size: const Size(330, 34), painter: _StepperPainter(p, index.toDouble())),
    );
  }
}

class _StepperPainter extends CustomPainter {
  _StepperPainter(this.p, this.target);
  final double p, target;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 6;
    final y = size.height / 2;
    double x(double i) => 18 + (size.width - 36) * i / (n - 1);
    final vel = (target - p).abs(); // remaining distance ~ speed proxy

    // Rail.
    canvas.drawLine(
      Offset(x(0), y),
      Offset(x(5), y),
      Paint()
        ..color = const Color(0xFFF6D9D3)
        ..strokeWidth = 1.6,
    );
    canvas.drawLine(
      Offset(x(0), y),
      Offset(x(p), y),
      Paint()
        ..color = C.red
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    // Start node: compass glyph disc.
    canvas.drawCircle(Offset(x(0), y), 13, Paint()..color = const Color(0xFFFBD9D2));
    // End node: big pale disc.
    canvas.drawCircle(Offset(x(5), y), 16, Paint()..color = const Color(0xFFFBDCD5));
    canvas.drawCircle(
      Offset(x(5), y),
      16,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFFF7C4BA),
    );

    for (var i = 1; i < 5; i++) {
      final done = i < p - 0.05;
      canvas.drawCircle(Offset(x(i.toDouble()), y), done ? 3.6 : 3.0, Paint()..color = done ? C.red : const Color(0xFFF6D9D3));
    }

    // Gooey active ring: a stroked stadium stretched by speed.
    final cx = x(p);
    final stretch = math.min(26.0, vel * 30);
    final rad = p > 4.5 ? ui.lerpDouble(10, 14, (p - 4.5) * 2)! : 10.0;
    final rect = Rect.fromCenter(
      center: Offset(cx - stretch * 0.35, y),
      width: rad * 2 + stretch,
      height: rad * 2 - stretch * 0.18,
    );
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));
    canvas.drawRRect(
      rr.inflate(4),
      Paint()
        ..color = C.red.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(rr, Paint()..color = Colors.white);
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = C.red,
    );
  }

  @override
  bool shouldRepaint(_StepperPainter old) => old.p != p;
}

/// Stepper start node glyph overlay helper (placed by the scaffold).
class StepperBar extends StatelessWidget {
  const StepperBar({super.key, required this.index, this.from});
  final int index;
  final int? from;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      height: 34,
      child: Stack(
        children: [
          AppStepper(index: index, from: from),
          const Positioned(left: 11, top: 10, child: CompassGlyph(size: 14, color: Color(0xFFF07A6E))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scalloped card
// ---------------------------------------------------------------------------

/// White card whose top edge is a row of scallops (a torn-off receipt). It
/// unrolls downward on entry, the leading edge carrying a soft curl shadow.
class ScallopCard extends StatefulWidget {
  const ScallopCard({super.key, required this.children, this.delay = 250});
  final List<Widget> children;
  final int delay;

  @override
  State<ScallopCard> createState() => _ScallopCardState();
}

class _ScallopCardState extends State<ScallopCard> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeOutQuart.transform(_c.value);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRect(
              child: Align(alignment: Alignment.topCenter, heightFactor: math.max(0.02, t), child: child),
            ),
            if (t < 0.999)
              Positioned(
                left: 6,
                right: 6,
                bottom: -10,
                child: Opacity(
                  opacity: (1 - t).clamp(0.0, 1.0) * 0.9,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: const [BoxShadow(color: Color(0x30B4442F), blurRadius: 12, offset: Offset(0, 6))],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: PhysicalShape(
        clipper: const _ScallopClipper(),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        elevation: 10,
        shadowColor: const Color(0x55B4321F),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 34, 18, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: widget.children),
        ),
      ),
    );
  }
}

class _ScallopClipper extends CustomClipper<Path> {
  const _ScallopClipper();

  @override
  Path getClip(Size size) {
    const r = 9.0, top = 10.0;
    final n = (size.width / (r * 3.1)).floor();
    final gap = size.width / n;
    final p = Path()..moveTo(0, top + r);
    for (var i = 0; i < n; i++) {
      final cx = gap * (i + 0.5);
      p.lineTo(cx - r, top + r);
      p.arcToPoint(Offset(cx + r, top + r), radius: const Radius.circular(r));
    }
    p
      ..lineTo(size.width, top + r)
      ..lineTo(size.width, size.height - 18)
      ..quadraticBezierTo(size.width, size.height, size.width - 18, size.height)
      ..lineTo(18, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - 18)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(_ScallopClipper old) => false;
}

/// Wraps a ticker-driven repaint for painters that animate forever.
mixin TickerRepaint<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  late final Ticker ticker = createTicker((d) => time.value = d.inMicroseconds / 1e6);
  final time = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    ticker.start();
  }

  @override
  void dispose() {
    ticker.dispose();
    time.dispose();
    super.dispose();
  }
}
