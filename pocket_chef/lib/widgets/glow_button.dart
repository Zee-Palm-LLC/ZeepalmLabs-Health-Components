import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';

class GlowButton extends StatelessWidget {
  const GlowButton({
    super.key,
    required this.width,
    required this.height,
    required this.label,
    required this.onTap,
    this.arrowX,
    this.leading,
    this.leadingX,
    this.labelShift = 0,
  });

  final double width;
  final double height;
  final Widget label;
  final VoidCallback onTap;
  final double? arrowX;
  final Widget? leading;
  final double? leadingX;
  final double labelShift;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(height / 2);
    return Pressable(
      onTap: onTap,
      scale: 0.965,
      child: Tick(
        builder: (context, seconds, child) {
          final breath = (wave(seconds, 2.8) + 1) / 2;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: r,
              boxShadow: [
                BoxShadow(
                  color: Palette.tomato.withValues(alpha: 0.26 + 0.1 * breath),
                  blurRadius: 20 + 6 * breath,
                  spreadRadius: -2,
                  offset: const Offset(0, 11),
                ),
                BoxShadow(color: Palette.tomatoLo.withValues(alpha: 0.18), blurRadius: 5, offset: const Offset(0, 3)),
              ],
            ),
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: r,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFD2F4C), Color(0xFFFD2442), Color(0xFFF7162F)],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: height * 0.4,
                  right: height * 0.4,
                  top: 1.2,
                  height: height * 0.42,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white.withValues(alpha: 0.06), Colors.white.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Tick(builder: (context, s, _) => CustomPaint(painter: _Sheen(s))),
                ),
                Positioned.fill(
                  child: Center(
                    child: Transform.translate(offset: Offset(labelShift, 0), child: label),
                  ),
                ),
                if (leading != null && leadingX != null)
                  Positioned(
                    left: leadingX! - 20,
                    top: height / 2 - 20,
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Tick(
                        builder: (context, s, child) {
                          final u = (s % 3.4) / 3.4;
                          final k = u < 0.18 ? math.sin(u / 0.18 * math.pi * 2) * (1 - u / 0.18) : 0.0;
                          return Transform.rotate(angle: 0.22 * k, alignment: Alignment.bottomCenter, child: child);
                        },
                        child: leading,
                      ),
                    ),
                  ),
                if (arrowX != null)
                  Positioned(
                    left: arrowX! - 13,
                    top: height / 2 - 13,
                    child: Tick(
                      builder: (context, s, child) {
                        final k = math.pow((math.sin(s * math.pi * 2 / 1.6) + 1) / 2, 3).toDouble();
                        return Transform.translate(offset: Offset(3.2 * k, 0), child: child);
                      },
                      child: const PhIcon(Ph.arrowRight, size: 26, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Sheen extends CustomPainter {
  _Sheen(this.seconds);

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    const period = 3.8;
    final t = (seconds % period) / 1.1;
    if (t > 1) return;
    final x = lerp(-size.height * 1.6, size.width + size.height * 0.6, Curves.easeInOutCubic.transform(t));
    final band = Rect.fromLTWH(x, -size.height, size.height * 1.1, size.height * 3);
    canvas.save();
    canvas.translate(band.center.dx, size.height / 2);
    canvas.rotate(0.42);
    canvas.translate(-band.center.dx, -size.height / 2);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0)],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(band),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Sheen old) => old.seconds != seconds;
}
