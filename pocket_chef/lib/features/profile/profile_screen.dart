import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/type.dart';
import '../../widgets/chef_hat.dart';
import '../../widgets/pop_text.dart';
import 'premium_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.entrance});

  static const reference = 900.2;

  final Animation<double> entrance;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _gear;

  @override
  void initState() {
    super.initState();
    _gear = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  }

  @override
  void dispose() {
    _gear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final e = widget.entrance;
    final navTop = frame.height - frame.drop - ProfileScreen.reference + 804.5;
    final content = math.max(frame.height, 790 + lift + 14 + (frame.height - navTop));
    final name = inter(31.8, 700, color: const Color(0xFF0C0A1B));
    final sub = inter(16.2, 400, color: const Color(0xFF605D63));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: Frame.width,
        height: content,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: math.min(0.0, lift),
              width: Frame.width,
              height: Art.profPlate.height + lift.abs(),
              child: Image.asset(Art.profPlate.asset, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
            ),
            Positioned(
              left: 0,
              top: lift,
              width: Frame.width,
              height: 330,
              child: _Decor(entrance: e),
            ),
            Positioned(
              left: 364.5 - 16,
              top: 83.5 - 16 + lift,
              child: Staged(
                animation: e,
                begin: 0.1,
                end: 0.4,
                scale: 0.3,
                rotateZ: -2,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _gear.forward(from: 0);
                  },
                  child: AnimatedBuilder(
                    animation: _gear,
                    builder: (context, child) => Transform.rotate(angle: Curves.easeOutBack.transform(_gear.value) * math.pi, child: child),
                    child: const PhIcon(Ph.gear, size: 32, color: Color(0xFF0D0C12)),
                  ),
                ),
              ),
            ),
            Positioned(
              left: Art.profAvatar.left,
              top: Art.profAvatar.top + lift,
              width: Art.profAvatar.width,
              height: Art.profAvatar.height,
              child: _Avatar(entrance: e),
            ),
            Positioned(
              left: 251.25 - 20,
              top: 207.39 - 20 + lift,
              child: AnimatedBuilder(
                animation: e,
                builder: (context, child) {
                  final raw = ((e.value - 0.34) / 0.3).clamp(0.0, 1.0);
                  final s = spring(raw, bounce: 0.6, freq: 2.6);
                  return Transform.scale(scale: s, child: child);
                },
                child: Pressable(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFAF9FA),
                      boxShadow: [BoxShadow(color: Color(0x2A5A2030), blurRadius: 12, offset: Offset(0, 4))],
                    ),
                    child: const Center(child: PhIcon(Ph.camera, size: 25, color: Color(0xFF111015))),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              width: Frame.width,
              top: 272 - 100 + lift,
              child: Baseline(
                baseline: 100,
                baselineType: TextBaseline.alphabetic,
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(-1.6, 0),
                    child: PopText(text: 'John Doe', style: name, animation: e, begin: 0.2, end: 0.5, rise: 16, spin: 0.14),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: lift,
              width: Frame.width,
              height: 320,
              child: Staged(
                animation: e,
                begin: 0.3,
                end: 0.58,
                offset: const Offset(0, 10),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Pin(x: 90.67, base: 299.67, text: 'Food Lover', style: sub),
                    Positioned(
                      left: 187.4 - 2,
                      top: 294.0 - 2,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF6A676D)),
                      ),
                    ),
                    Pin(x: 202.33, base: 299.67, text: 'Home Chef', style: sub),
                    const Positioned(
                      left: 302.0 - 10,
                      top: 293.4 - 10,
                      child: ChefHat(size: 20, color: Color(0xFF2B2930), stroke: 1.6),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18.8,
              top: 326.6 + lift,
              child: _Stats(entrance: e),
            ),
            Positioned(
              left: 17.8,
              top: 412.7 + lift,
              child: PremiumCard(entrance: e),
            ),
            for (final (i, (icon, label, top, height, base)) in [
              (Ph.chefHat, 'My Recipes', 518.3, 49.2, 550.33),
              (Ph.heart, 'Favorites', 572.5, 48.8, 603.0),
              (Ph.bag, 'Shopping List', 626.5, 51.0, 658.33),
              (Ph.gear, 'Settings', 682.5, 51.0, 715.33),
              (Ph.question, 'Help & Support', 738.0, 51.5, 771.33),
            ].indexed)
              Positioned(
                left: 18.5,
                top: top + lift,
                child: Staged(
                  animation: e,
                  begin: 0.55 + i * 0.04,
                  end: 0.84 + i * 0.04,
                  offset: const Offset(0, 36),
                  child: _MenuRow(icon: icon, label: label, height: height, base: base - top),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    const disc = Offset(197.34, 151.41);
    final pivot = disc - Offset(Art.profAvatar.left, Art.profAvatar.top);
    return AnimatedBuilder(
      animation: entrance,
      builder: (context, child) {
        final raw = ((entrance.value - 0.04) / 0.42).clamp(0.0, 1.0);
        final s = spring(raw, bounce: 0.5, freq: 2.3);
        return Opacity(
          opacity: (raw * 5).clamp(0.0, 1.0),
          child: Transform(
            origin: pivot,
            transform: Matrix4.identity()
              ..scaleByDouble(s, s, 1, 1)
              ..rotateZ(-0.5 * (1 - s)),
            child: child,
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: pivot.dx - 84,
            top: pivot.dy - 84,
            width: 168,
            height: 168,
            child: Tick(builder: (context, s, _) => CustomPaint(painter: _HaloPainter(s))),
          ),
          Positioned.fill(
            child: Tick(
              builder: (context, s, child) {
                final b = wave(s, 3.4);
                return Transform(
                  origin: Offset(pivot.dx, pivot.dy + 76),
                  transform: Matrix4.diagonal3Values(1 + 0.01 * b, 1 - 0.01 * b, 1),
                  child: child,
                );
              },
              child: Art.profAvatar.image(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HaloPainter extends CustomPainter {
  _HaloPainter(this.seconds);

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: c, radius: 79.5);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..shader = SweepGradient(
          colors: const [Color(0x00FF8A9A), Color(0x55FF8A9A), Color(0x00FF8A9A), Color(0x00FF8A9A)],
          stops: const [0.0, 0.12, 0.26, 1.0],
          transform: GradientRotation(seconds * 0.9),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_HaloPainter old) => old.seconds != seconds;
}

class _Decor extends StatelessWidget {
  const _Decor({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Art.profBlobA, const Offset(60, 0), 0.0, 5.0, 7.0),
      (Art.profBlobB, const Offset(60, 20), 0.0, 4.0, 8.0),
      (Art.profTomato, const Offset(-60, -10), 0.6, 4.5, 5.2),
      (Art.profPepper, const Offset(-70, 10), -0.8, 5.5, 6.1),
      (Art.profBasilA, const Offset(-30, -60), 1.8, 4.0, 4.4),
      (Art.profBasilB, const Offset(40, 40), -1.6, 3.6, 4.9),
    ];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final (i, (sprite, from, spin, amp, period)) in items.indexed)
          Positioned(
            left: sprite.left,
            top: sprite.top,
            width: sprite.width,
            height: sprite.height,
            child: AnimatedBuilder(
              animation: entrance,
              builder: (context, child) {
                final begin = 0.08 + i * 0.05;
                final t = span(entrance.value, begin, begin + 0.4, gentle);
                return Opacity(
                  opacity: span(entrance.value, begin, begin + 0.15, Curves.linear),
                  child: Transform.translate(
                    offset: from * (1 - t),
                    child: Transform.rotate(angle: spin * (1 - t), child: child),
                  ),
                );
              },
              child: Tick(
                builder: (context, s, child) => Transform.translate(
                  offset: Offset(amp * 0.4 * wave(s, period * 1.3, i * 0.2), amp * wave(s, period, i * 0.17)),
                  child: Transform.rotate(angle: 0.06 * wave(s, period * 1.1, i * 0.3), child: child),
                ),
                child: sprite.image(),
              ),
            ),
          ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: entrance,
            builder: (context, _) {
              final grow = span(entrance.value, 0.38, 0.6, Curves.easeOutBack);
              return Tick(builder: (context, s, _) => CustomPaint(painter: _StrokePainter(grow, s)));
            },
          ),
        ),
      ],
    );
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.grow, this.seconds);

  final double grow;
  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    if (grow <= 0) return;
    final paint = Paint()
      ..color = const Color(0xFFE9233C)
      ..strokeWidth = 3.3
      ..strokeCap = StrokeCap.round;
    final beat = math.pow(math.max(0.0, math.sin(seconds / 3.2 * math.pi * 2)), 8).toDouble();
    const center = Offset(197.34, 151.41);
    void line(Offset a, Offset b) {
      final mid = (a + b) / 2;
      final away = mid - center;
      final push = away / away.distance * (3.4 * beat);
      final half = (b - a) * (grow * (1 + 0.16 * beat)) / 2;
      canvas.drawLine(mid - half + push, mid + half + push, paint);
    }

    line(const Offset(69.4, 146.2), const Offset(89.0, 160.2));
    line(const Offset(64.0, 174.0), const Offset(85.0, 176.0));
    line(const Offset(291.4, 130.6), const Offset(299.6, 115.4));
    line(const Offset(299.8, 145.6), const Offset(317.8, 137.2));
  }

  @override
  bool shouldRepaint(_StrokePainter old) => old.grow != grow || old.seconds != seconds;
}

class _Stats extends StatelessWidget {
  const _Stats({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final number = inter(20.5, 700, color: const Color(0xFF0B0912));
    final label = inter(13.5, 400, color: const Color(0xFF7D7A7D));
    const left = 18.8;
    const top = 326.6;
    return AnimatedBuilder(
      animation: entrance,
      builder: (context, child) {
        final t = span(entrance.value, 0.34, 0.66, gentle);
        return Opacity(
          opacity: span(entrance.value, 0.34, 0.46, Curves.linear),
          child: Transform.translate(
            offset: Offset(0, 34 * (1 - t)),
            child: Transform.scale(scale: lerp(0.94, 1, t), child: child),
          ),
        );
      },
      child: Container(
        width: 357.4,
        height: 69.9,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F1EB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1EBE5), width: 0.9),
          boxShadow: const [BoxShadow(color: Color(0x0C6E4B30), blurRadius: 14, offset: Offset(0, 6))],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final x in [136.7, 260.4])
              Positioned(
                left: x - left,
                top: 339 - top,
                width: 1,
                height: 46,
                child: const ColoredBox(color: Color(0xFFECE6E0)),
              ),
            for (final (i, (n, word, cx)) in [(12, 'Recipes', 76.5), (3, 'Collections', 198.0), (28, 'Followers', 319.4)].indexed) ...[
              Positioned(
                left: cx - left - 60,
                width: 120,
                top: 359.8 - top - 100,
                child: Baseline(
                  baseline: 100,
                  baselineType: TextBaseline.alphabetic,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: entrance,
                      builder: (context, _) {
                        final t = span(entrance.value, 0.44 + i * 0.05, 0.86 + i * 0.05, Curves.easeOutCubic);
                        return Text('${(n * t).round()}', style: number);
                      },
                    ),
                  ),
                ),
              ),
              Pin(x: cx - left - 0.8, base: 378.5 - top, text: word, style: label, align: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF111016);
    if (icon != Ph.bag) return PhIcon(icon, size: 32, color: ink);
    return SizedBox.square(
      dimension: 32,
      child: CustomPaint(
        foregroundPainter: _SmilePainter(),
        child: const PhIcon(Ph.bag, size: 32, color: ink),
      ),
    );
  }
}

class _SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 32;
    final path = Path()
      ..moveTo(11.6 * k, 17.4 * k)
      ..quadraticBezierTo(16 * k, 23.2 * k, 20.4 * k, 17.4 * k);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * k
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF111016),
    );
  }

  @override
  bool shouldRepaint(_SmilePainter old) => false;
}

class _MenuRow extends StatefulWidget {
  const _MenuRow({required this.icon, required this.label, required this.height, required this.base});

  final IconData icon;
  final String label;
  final double height;
  final double base;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> with SingleTickerProviderStateMixin {
  late final AnimationController _wiggle;

  @override
  void initState() {
    super.initState();
    _wiggle = AnimationController(vsync: this, duration: const Duration(milliseconds: 700), value: 1);
  }

  @override
  void dispose() {
    _wiggle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = inter(15.3, 500, color: const Color(0xFF2B2831));
    final h = widget.height;
    return Pressable(
      scale: 0.975,
      onTap: () => _wiggle.forward(from: 0),
      child: Container(
        width: 357.5,
        height: h,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F2EE),
          borderRadius: BorderRadius.circular(h / 2),
          border: Border.all(color: const Color(0xFFF2ECE8), width: 0.8),
        ),
        child: AnimatedBuilder(
          animation: _wiggle,
          builder: (context, _) {
            final t = _wiggle.value;
            final wig = math.sin(t * math.pi * 4) * 0.22 * (1 - t);
            final nudge = math.sin(t * math.pi) * 6;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 53.5 - 18.5 - 16,
                  top: widget.base - 6 - 16,
                  child: Transform.rotate(angle: wig, child: _Glyph(widget.icon)),
                ),
                Pin(x: 86.9 - 18.5, base: widget.base - 0.7, text: widget.label, style: label),
                Positioned(
                  left: 354.3 - 18.5 - 11 + nudge,
                  top: widget.base - 5.6 - 11,
                  child: const PhIcon(Ph.caretRight, size: 22, color: Color(0xFF4A474F)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
