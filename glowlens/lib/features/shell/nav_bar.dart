import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';

class GlowNavBar extends StatefulWidget {
  const GlowNavBar({super.key, required this.index, required this.onSelect, required this.onSparkle});

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onSparkle;

  static const barHeight = 87.0;

  @override
  State<GlowNavBar> createState() => _GlowNavBarState();
}

class _GlowNavBarState extends State<GlowNavBar> with TickerProviderStateMixin, ClockMixin {
  late final AnimationController _pick;
  late final AnimationController _burst;
  late int _from = widget.index;

  static const _items = [
    (Glyph.home, Glyph.homeFilled, 'Home'),
    (Glyph.analytic, Glyph.analyticFilled, 'Analytic'),
    (Glyph.bag, Glyph.bag, ''),
    (Glyph.bag, Glyph.bagFilled, 'Products'),
    (Glyph.profile, Glyph.profileFilled, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _pick = AnimationController(vsync: this, duration: const Duration(milliseconds: 750), value: 1);
    _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    startClock();
  }

  @override
  void didUpdateWidget(GlowNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _from = oldWidget.index;
      _pick.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pick.dispose();
    _burst.dispose();
    disposeClock();
    super.dispose();
  }

  void _sparkle() {
    HapticFeedback.mediumImpact();
    _burst.forward(from: 0);
    widget.onSparkle();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final height = math.max(GlowNavBar.barHeight, 67 + bottom);
    return SizedBox(
      height: height + 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: height,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Color(0x147A4FA0), blurRadius: 30, offset: Offset(0, -6))],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.86),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.95), width: 1.2)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: height,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _pick,
                builder: (context, _) => CustomPaint(
                  painter: _IndicatorPainter(from: _from, to: widget.index, t: _pick.value),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: height,
            child: Row(
              children: [
                for (var i = 0; i < 5; i++)
                  Expanded(
                    child: i == 2
                        ? const SizedBox()
                        : GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onSelect(i);
                            },
                            child: _item(i),
                          ),
                  ),
              ],
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: Center(child: _fab())),
        ],
      ),
    );
  }

  Widget _item(int i) {
    final (outline, filled, label) = _items[i];
    final active = widget.index == i;
    return AnimatedBuilder(
      animation: _pick,
      builder: (context, _) {
        final t = _pick.value;
        final bounce = active ? Curves.elasticOut.transform(t) : 1.0;
        final squash = active ? math.sin(t * math.pi) * 0.18 * (1 - t) : 0.0;
        final glow = active ? math.sin(math.min(t * 1.4, 1) * math.pi) : 0.0;
        return Column(
          children: [
            const SizedBox(height: 11),
            SizedBox(
              width: 44,
              height: 24,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (glow > 0.01)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Palette.rose.withValues(alpha: 0.35 * glow),
                            Palette.rose.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  Transform.scale(
                    scaleX: lerp(0.7, 1, bounce) + squash,
                    scaleY: lerp(0.7, 1, bounce) - squash,
                    child: GlyphIcon(
                      active ? filled : outline,
                      size: 24,
                      color: active ? Palette.ink : const Color(0xFF8E8E93),
                      stroke: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: inter(11.5, active ? 600 : 500, color: active ? Palette.ink : const Color(0xFF9A9AA0), spacing: 0),
              child: Text(label),
            ),
          ],
        );
      },
    );
  }

  Widget _fab() {
    return Pressable(
      onTap: _sparkle,
      scale: 0.9,
      haptic: false,
      child: AnimatedBuilder(
        animation: Listenable.merge([clock, _burst]),
        builder: (context, _) {
          final s = clock.value;
          final b = _burst.value;
          return SizedBox.square(
            dimension: 58,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 58 + 8 * math.sin(s * 2),
                  height: 58 + 8 * math.sin(s * 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Palette.rose.withValues(alpha: 0.22 + 0.1 * math.sin(s * 2)),
                        blurRadius: 22,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(2.2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: const [
                        Color(0xFFE9C9F4),
                        Palette.violet,
                        Palette.rose,
                        Color(0xFFFFD2DB),
                        Color(0xFFE9C9F4),
                      ],
                      transform: GradientRotation(s * 1.3),
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Center(
                      child: Transform.rotate(
                        angle: Curves.easeOutBack.transform(b) * math.pi * 2 * (b > 0 && b < 1 ? 1 : 0),
                        child: SparkleMark(size: 27, twinkle: (s / 1.8) % 1),
                      ),
                    ),
                  ),
                ),
                if (b > 0 && b < 1) CustomPaint(size: const Size.square(58), painter: _BurstPainter(b)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final eased = Curves.easeOutCubic.transform(t);
    for (var i = 0; i < 10; i++) {
      final a = i * math.pi * 2 / 10 + 0.3;
      final d = 30 + eased * 34;
      final p = c + Offset(math.cos(a), math.sin(a)) * d;
      final r = (1 - t) * (i.isEven ? 4.5 : 3);
      final paint = Paint()..color = (i.isEven ? Palette.violet : Palette.coral).withValues(alpha: 1 - t);
      final star = Path()
        ..moveTo(p.dx, p.dy - r)
        ..quadraticBezierTo(p.dx, p.dy, p.dx + r, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + r)
        ..quadraticBezierTo(p.dx, p.dy, p.dx - r, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - r);
      canvas.drawPath(star, paint);
    }
    canvas.drawCircle(
      c,
      29 + eased * 26,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * (1 - t)
        ..color = Palette.rose.withValues(alpha: 0.6 * (1 - t)),
    );
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => oldDelegate.t != t;
}

class _IndicatorPainter extends CustomPainter {
  _IndicatorPainter({required this.from, required this.to, required this.t});

  final int from;
  final int to;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final slot = size.width / 5;
    double centre(int i) => slot * (i + 0.5);
    const lead = Cubic(0.2, 0.95, 0.3, 1);
    const trail = Cubic(0.75, 0, 0.3, 1);
    final forward = to >= from;
    const half = 9.0;
    final left = lerp(centre(from) - half, centre(to) - half, (forward ? trail : lead).transform(t));
    final right = lerp(centre(from) + half, centre(to) + half, (forward ? lead : trail).transform(t));
    final rect = RRect.fromLTRBR(left, 61, right, 64.5, const Radius.circular(2));
    canvas.drawRRect(
      rect.inflate(2),
      Paint()
        ..color = const Color(0x55E583C0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(rect, Paint()..shader = Palette.brand.createShader(rect.outerRect));
  }

  @override
  bool shouldRepaint(_IndicatorPainter oldDelegate) => oldDelegate.t != t || oldDelegate.to != to;
}
