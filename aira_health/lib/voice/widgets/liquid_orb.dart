import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated iridescent liquid orb for the voice assistant screen.
class LiquidOrb extends StatefulWidget {
  const LiquidOrb({
    super.key,
    required this.size,
    this.listening = false,
    this.onTap,
  });

  final double size;
  final bool listening;
  final VoidCallback? onTap;

  @override
  State<LiquidOrb> createState() => _LiquidOrbState();
}

class _LiquidOrbState extends State<LiquidOrb> with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _pulseController;
  late final AnimationController _driftController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = AnimatedBuilder(
      animation: Listenable.merge([
        _spinController,
        _pulseController,
        _driftController,
      ]),
      builder: (context, _) {
        final pulse = widget.listening
            ? 1.04 + (_pulseController.value * 0.08)
            : 1 + (_pulseController.value * 0.05);

        return Transform.scale(
          scale: pulse,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _LiquidOrbPainter(
              spin: _spinController.value,
              drift: _driftController.value,
              listening: widget.listening,
            ),
          ),
        );
      },
    );

    if (widget.onTap == null) return child;

    return GestureDetector(
      onTap: widget.onTap,
      child: child,
    );
  }
}

class _LiquidOrbPainter extends CustomPainter {
  _LiquidOrbPainter({
    required this.spin,
    required this.drift,
    required this.listening,
  });

  final double spin;
  final double drift;
  final bool listening;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    _drawGlow(canvas, center, radius * 1.18, const Color(0x33C9B8FF));
    _drawGlow(canvas, center, radius * 1.05, const Color(0x44FFD6EC));

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    final basePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.25),
        radius: 1.1,
        colors: const [
          Color(0xFFF8F2FF),
          Color(0xFFE7DBFF),
          Color(0xFFD7E8FF),
          Color(0xFFFFE3F1),
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    final angle = spin * math.pi * 2;
    final blobs = [
      _Blob(
        color: const Color(0xFFB8A4FF),
        alignment: Alignment(
          math.cos(angle) * 0.35,
          math.sin(angle) * 0.28,
        ),
        radiusFactor: 0.52,
      ),
      _Blob(
        color: const Color(0xFFFFB8D9),
        alignment: Alignment(
          math.cos(angle + 2.1) * 0.3,
          math.sin(angle + 2.1) * 0.34,
        ),
        radiusFactor: 0.45,
      ),
      _Blob(
        color: const Color(0xFF9ED8FF),
        alignment: Alignment(
          math.cos(angle + 4.2) * 0.26,
          math.sin(angle + 4.2) * 0.22,
        ),
        radiusFactor: 0.4,
      ),
      _Blob(
        color: const Color(0xFFFFE9A8),
        alignment: Alignment(
          -0.15 + drift * 0.12,
          0.2 - drift * 0.1,
        ),
        radiusFactor: 0.28,
      ),
    ];

    for (final blob in blobs) {
      final blobCenter = Offset(
        center.dx + blob.alignment.x * radius * 0.55,
        center.dy + blob.alignment.y * radius * 0.55,
      );
      final blobPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            blob.color.withValues(alpha: listening ? 0.9 : 0.72),
            blob.color.withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: blobCenter,
            radius: radius * blob.radiusFactor,
          ),
        )
        ..blendMode = BlendMode.plus;
      canvas.drawCircle(
        blobCenter,
        radius * blob.radiusFactor,
        blobPaint,
      );
    }

    final highlight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.45, -0.5),
        radius: 0.55,
        colors: [
          Colors.white.withValues(alpha: 0.82),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, highlight);

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.03
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.75),
          Colors.white.withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.97, rim);

    canvas.restore();

    final shadowPaint = Paint()
      ..color = const Color(0xFF9B8AAE).withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(
      Offset(center.dx, center.dy + radius * 0.08),
      radius * 0.88,
      shadowPaint,
    );
  }

  void _drawGlow(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidOrbPainter oldDelegate) {
    return oldDelegate.spin != spin ||
        oldDelegate.drift != drift ||
        oldDelegate.listening != listening;
  }
}

class _Blob {
  const _Blob({
    required this.color,
    required this.alignment,
    required this.radiusFactor,
  });

  final Color color;
  final Alignment alignment;
  final double radiusFactor;
}
