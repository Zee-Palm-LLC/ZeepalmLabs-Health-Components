import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../icons.dart';

import '../theme.dart';
import 'motion.dart';

/// Lays a screen out on the 390-pt design canvas and scales it to the device
/// width, so every design measurement can be used verbatim.
class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 390;
      final mq = MediaQuery.of(context);
      return SizedBox(
        width: c.maxWidth,
        height: c.maxHeight,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 390,
            height: c.maxHeight / s,
            child: MediaQuery(
              data: mq.copyWith(
                size: Size(390, c.maxHeight / s),
                padding: mq.padding / s,
                viewPadding: mq.viewPadding / s,
              ),
              child: child,
            ),
          ),
        ),
      );
    });
  }
}

/// Warm off-white page with the lavender haze at the top, as in the mockup.
class PageBackground extends StatelessWidget {
  const PageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [C.bgTop, Color(0xFFF6EFF3), C.bg],
          stops: [0, 0.28, 0.5],
        ),
      ),
      child: child,
    );
  }
}

/// The dark pill CTA: press squash, a light sweep across the glass, and an
/// arrow that nudges forward.
class DarkButton extends StatefulWidget {
  const DarkButton({super.key, required this.label, required this.icon, this.onTap, this.heroTag});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Object? heroTag;

  @override
  State<DarkButton> createState() => _DarkButtonState();
}

class _DarkButtonState extends State<DarkButton> with SingleTickerProviderStateMixin {
  late final _sweep = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _sweep.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget pill = Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: C.button,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x331E2B33), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CustomPaint(
          foregroundPainter: _SweepPainter(_sweep),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 17, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(widget.label, style: inter(15, FontWeight.w500, Colors.white, ls: 0.1)),
                ],
              ),
              Positioned(
                right: 20,
                child: AnimatedBuilder(
                  animation: _sweep,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(math.sin(_sweep.value * math.pi) * 5, 0),
                    child: child,
                  ),
                  child: const Icon(PhBold.arrowRight, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (widget.heroTag != null) {
      pill = Hero(
        tag: widget.heroTag!,
        flightShuttleBuilder: (ctx, anim, dir, from, to) => Material(type: MaterialType.transparency, child: to.widget),
        child: Material(type: MaterialType.transparency, child: pill),
      );
    }
    return Pressable(
      onTap: () {
        _sweep.forward(from: 0);
        widget.onTap?.call();
      },
      child: pill,
    );
  }
}

class _SweepPainter extends CustomPainter {
  _SweepPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    final v = Curves.easeInOutCubic.transform(t.value);
    if (v <= 0 || v >= 1) return;
    final x = -80 + (size.width + 160) * v;
    final rect = Rect.fromLTWH(x - 60, 0, 120, size.height);
    canvas.save();
    canvas.translate(x, size.height / 2);
    canvas.skew(-0.5, 0);
    canvas.translate(-x, -size.height / 2);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(colors: [Color(0x00FFFFFF), Color(0x26FFFFFF), Color(0x00FFFFFF)])
            .createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SweepPainter old) => false;
}

/// Frosted white card used across the screens.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.radius = 18, this.padding, this.color = C.card});

  final Widget child;
  final double radius;
  final EdgeInsets? padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xB3FFFFFF)),
        boxShadow: cardShadow,
      ),
      child: child,
    );
  }
}

/// Top bar used by the inner screens: back chevron, centred title, action.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, required this.action, this.onBack, this.color = C.ink});

  final String title;
  final IconData action;
  final VoidCallback? onBack;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(title, style: inter(15, FontWeight.w500, color)),
          Positioned(
            left: 14,
            child: Pressable(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: SizedBox(width: 36, height: 36, child: Icon(PhBold.caretLeft, size: 22, color: color)),
            ),
          ),
          Positioned(
            right: 14,
            child: Pressable(
              onTap: () {},
              child: SizedBox(width: 36, height: 36, child: Icon(action, size: 22, color: color)),
            ),
          ),
        ],
      ),
    );
  }
}
