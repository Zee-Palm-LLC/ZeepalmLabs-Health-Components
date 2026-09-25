import 'package:flutter/material.dart';

import '../core/motion.dart';

const ctaBase = [
  Color(0xFF4523FC),
  Color(0xFF4D25FC),
  Color(0xFF5E27FC),
  Color(0xFF7127FE),
  Color(0xFF9525F7),
  Color(0xFFC630DA),
  Color(0xFFED3DAC),
  Color(0xFFFA4880),
  Color(0xFFFF5070),
];
const ctaBaseStops = [0.0, 0.137, 0.279, 0.421, 0.563, 0.705, 0.819, 0.933, 1.0];
const ctaLight = [
  Color(0xFF9A93FF),
  Color(0xFFB198FF),
  Color(0xFFB489FF),
  Color(0xFFBE6DFF),
  Color(0xFFFB79D7),
  Color(0xFFFFAFA0),
  Color(0xFFFFE987),
  Color(0xFFFFE987),
];
const ctaLightStops = [0.0, 0.28, 0.42, 0.56, 0.7, 0.82, 0.93, 1.0];

class GlowButton extends StatelessWidget {
  const GlowButton({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.onTap,
    this.glow = 1,
  });

  final double width;
  final double height;
  final Widget child;
  final VoidCallback? onTap;
  final double glow;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.965,
      child: Tick(
        builder: (context, s, inner) {
          final flow = wave(s, 5.2) * 0.05;
          final pulse = 0.5 + 0.5 * wave(s, 2.8);
          final cycle = (s % 3.8) / 1.25;
          return CustomPaint(
            painter: _Pill(flow: flow, pulse: pulse, sheen: cycle, glow: glow),
            child: SizedBox(width: width, height: height, child: inner),
          );
        },
        child: child,
      ),
    );
  }
}

class _Pill extends CustomPainter {
  _Pill({required this.flow, required this.pulse, required this.sheen, required this.glow});

  final double flow;
  final double pulse;
  final double sheen;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2;
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(r));

    if (glow > 0) {
      final halo = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF5B3BFF).withValues(alpha: (0.34 + 0.12 * pulse) * glow),
            const Color(0xFFFF4F8E).withValues(alpha: (0.30 + 0.12 * pulse) * glow),
          ],
        ).createShader(rect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 + 4 * pulse);
      canvas.drawRRect(rr.shift(const Offset(0, 7)).deflate(10), halo);
    }

    final shift = flow;
    final base = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1 - shift, 0),
        end: Alignment(1 - shift, 0),
        colors: ctaBase,
        stops: ctaBaseStops,
      ).createShader(rect);
    canvas.drawRRect(rr, base);

    canvas.save();
    canvas.clipRRect(rr);
    final light = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1 - shift, 0),
        end: Alignment(1 - shift, 0),
        colors: ctaLight,
        stops: ctaLightStops,
      ).createShader(rect);
    final fade = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xC7FFFFFF), Color(0x99FFFFFF), Color(0x4DFFFFFF), Color(0x12FFFFFF), Color(0x00FFFFFF)],
        stops: [0.0, 0.1, 0.32, 0.53, 0.68],
      ).createShader(rect)
      ..blendMode = BlendMode.dstIn;
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(rect, light);
    canvas.drawRect(rect, fade);
    canvas.restore();

    if (sheen < 1.4) {
      final x = lerp(-0.4, 1.4, sheen / 1.4) * size.width;
      final band = Paint()
        ..shader = LinearGradient(
          colors: const [Color(0x00FFFFFF), Color(0x40FFFFFF), Color(0x00FFFFFF)],
          stops: const [0.0, 0.5, 1.0],
          transform: const GradientRotation(-0.35),
        ).createShader(Rect.fromLTWH(x - 60, 0, 120, size.height));
      canvas.drawRect(rect, band);
    }
    canvas.restore();

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x80FFFFFF), Color(0x14FFFFFF), Color(0x00FFFFFF), Color(0x26FFFFFF)],
        stops: [0.0, 0.16, 0.8, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rr.deflate(0.55), rim);
  }

  @override
  bool shouldRepaint(_Pill old) =>
      old.flow != flow || old.pulse != pulse || old.sheen != sheen || old.glow != glow;
}

class PulseRing extends StatelessWidget {
  const PulseRing({super.key, required this.size, required this.child, this.color = Colors.white, this.period = 2.4});

  final double size;
  final Widget child;
  final Color color;
  final double period;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, s, inner) {
        final t = (s % period) / period;
        final e = Curves.easeOut.transform(t);
        return CustomPaint(
          painter: _Ring(progress: e, color: color),
          child: inner,
        );
      },
      child: SizedBox.square(dimension: size, child: child),
    );
  }
}

class _Ring extends CustomPainter {
  _Ring({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 * (1 + 0.55 * progress);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * (1 - progress) + 0.2
      ..color = color.withValues(alpha: 0.45 * (1 - progress));
    canvas.drawCircle(c, r, p);
  }

  @override
  bool shouldRepaint(_Ring old) => old.progress != progress;
}
