import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import 'fx.dart';

/// Reveals [child] through an expanding portal centred on [origin], with a
/// burning rim and sparks streaming inward. [t] runs 0 → 1.
class Portal extends StatelessWidget {
  const Portal({super.key, required this.t, required this.origin, required this.child, this.color = const Color(0xFFFFC94A), this.inner = const Color(0xFFB48CFF)});

  final double t;
  final Offset origin;
  final Widget child;
  final Color color;
  final Color inner;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final far = [Offset.zero, Offset(box.maxWidth, 0), Offset(0, box.maxHeight), Offset(box.maxWidth, box.maxHeight)].map((c) => (c - origin).distance).reduce(math.max);
        final r = Curves.easeInOutCubic.transform(t) * (far + 40);
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(clipper: _Circle(origin, r), child: child),
            IgnorePointer(child: CustomPaint(painter: _RimPainter(origin, r, t, color, inner))),
          ],
        );
      },
    );
  }
}

class _Circle extends CustomClipper<Path> {
  _Circle(this.c, this.r);

  final Offset c;
  final double r;

  @override
  Path getClip(Size size) => Path()..addOval(Rect.fromCircle(center: c, radius: math.max(r, 0.01)));

  @override
  bool shouldReclip(_Circle old) => old.r != r || old.c != c;
}

class _RimPainter extends CustomPainter {
  _RimPainter(this.c, this.r, this.t, this.color, this.inner);

  final Offset c;
  final double r;
  final double t;
  final Color color;
  final Color inner;

  @override
  void paint(Canvas canvas, Size size) {
    final fade = t < 0.85 ? 1.0 : (1 - t) / 0.15;
    if (fade <= 0 || r <= 0) return;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..color = inner.withValues(alpha: 0.35 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = color.withValues(alpha: 0.95 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.9 * fade),
    );
    // Runes / sparks orbiting on the rim.
    for (var i = 0; i < 28; i++) {
      final a = i / 28 * math.pi * 2 + t * 5 * (i.isEven ? 1 : -1);
      final rr = r + (hash(i, 3) - 0.5) * 18;
      final p = c + Offset(math.cos(a), math.sin(a)) * rr;
      star(canvas, p, 2 + hash(i, 5) * 3, Colors.white.withValues(alpha: fade * (0.4 + 0.6 * hash(i, 6))), rotation: a);
    }
  }

  @override
  bool shouldRepaint(_RimPainter old) => old.r != r || old.t != t;
}

/// Route that warps into the next screen: the old screen zooms past the
/// camera while the new one rushes in behind a flash of light and speed lines.
class WarpRoute<T> extends PageRouteBuilder<T> {
  WarpRoute({required WidgetBuilder builder, this.origin, this.color = const Color(0xFFFFD86B), Duration duration = const Duration(milliseconds: 1100)})
    : super(transitionDuration: duration, reverseTransitionDuration: const Duration(milliseconds: 700), opaque: true, pageBuilder: (context, a, b) => builder(context));

  final Offset? origin;
  final Color color;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value;
        final come = span(t, 0.25, 1, swift);
        final flash = math.sin(span(t, 0.1, 0.55, Curves.linear) * math.pi);
        return LayoutBuilder(
          builder: (context, box) {
            final o = origin ?? Offset(box.maxWidth / 2, box.maxHeight / 2);
            final align = Alignment((o.dx / box.maxWidth) * 2 - 1, (o.dy / box.maxHeight) * 2 - 1);
            return Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: span(t, 0.2, 0.5, Curves.linear),
                  child: Transform.scale(scale: lerp(1.35, 1, come), alignment: align, child: child),
                ),
                IgnorePointer(child: CustomPaint(painter: _WarpPainter(o, t, color))),
                IgnorePointer(child: ColoredBox(color: Color.lerp(Colors.transparent, color.withValues(alpha: 0.62), flash)!)),
              ],
            );
          },
        );
      },
    );
  }
}

class _WarpPainter extends CustomPainter {
  _WarpPainter(this.o, this.t, this.color);

  final Offset o;
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final a = math.sin(span(t, 0, 0.8, Curves.linear) * math.pi);
    if (a <= 0) return;
    final far = size.longestSide;
    for (var i = 0; i < 60; i++) {
      final ang = hash(i, 11) * math.pi * 2;
      final speed = 0.4 + hash(i, 12);
      final head = ((t * 1.6 * speed + hash(i, 13)) % 1) * far;
      final tail = head - 60 - 140 * speed;
      final dir = Offset(math.cos(ang), math.sin(ang));
      canvas.drawLine(
        o + dir * math.max(tail, 0),
        o + dir * head,
        Paint()
          ..strokeWidth = 1 + hash(i, 14) * 2
          ..strokeCap = StrokeCap.round
          ..color = Color.lerp(color, Colors.white, hash(i, 15))!.withValues(alpha: a * 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(_WarpPainter old) => old.t != t;
}

/// Reverse-friendly fade-through used for back navigation and tab swaps.
class FadeThroughRoute<T> extends PageRouteBuilder<T> {
  FadeThroughRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, a, b) => builder(context),
        transitionsBuilder: (context, a, b, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.0).animate(CurvedAnimation(parent: a, curve: gentle)),
            child: child,
          ),
        ),
      );
}
