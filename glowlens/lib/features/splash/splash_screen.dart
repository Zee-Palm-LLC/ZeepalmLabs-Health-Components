import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../shell/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin, ClockMixin {
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    startClock();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
    _intro.forward().whenComplete(_enter);
  }

  void _enter() {
    if (!mounted) return;
    final size = MediaQuery.sizeOf(context);
    Navigator.of(context).pushReplacement(
      RevealRoute(origin: Offset(size.width / 2, size.height * 0.44), builder: (_) => const AppShell()),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    disposeClock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const word = 'GlowLens';
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: Backdrop()),
          Positioned.fill(
            child: CustomPaint(
              painter: _AuraPainter(clock: clock, intro: _intro),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([_intro, clock]),
                  builder: (context, _) {
                    final t = _intro.value;
                    final pop = Curves.elasticOut.transform(window(t, 0.05, 0.45));
                    final ring = Curves.easeInOutCubic.transform(window(t, 0.1, 0.55));
                    return SizedBox.square(
                      dimension: 132,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(size: const Size.square(132), painter: _RingPainter(ring, clock.value)),
                          Transform.rotate(
                            angle: (1 - pop) * -math.pi,
                            child: Transform.scale(
                              scale: pop,
                              child: Container(
                                width: 92,
                                height: 92,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Color(0x33E583C0), blurRadius: 30, offset: Offset(0, 12)),
                                  ],
                                ),
                                child: Center(child: SparkleMark(size: 46, twinkle: (clock.value / 1.6) % 1)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < word.length; i++)
                      Entrance(
                        animation: stage(_intro, 0.32 + i * 0.035, 0.6 + i * 0.035, curve: Curves.easeOutBack),
                        offset: const Offset(0, 22),
                        blur: 8,
                        child: i < 4
                            ? Text(word[i], style: inter(34, 700, spacing: -1))
                            : GradientText(word[i], style: inter(34, 700, spacing: -1)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Entrance(
                  animation: stage(_intro, 0.6, 0.85),
                  offset: const Offset(0, 12),
                  child: Text('Your skin, decoded.', style: inter(14, 500, color: Palette.muted)),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.paddingOf(context).bottom + 40,
            child: Entrance(
              animation: stage(_intro, 0.65, 0.95),
              offset: const Offset(0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GlyphIcon(Glyph.shield, size: 15, color: Palette.faint, stroke: 1.6),
                  const SizedBox(width: 6),
                  Text('Photos never leave your phone', style: inter(12, 500, color: Palette.faint)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.seconds);

  final double progress;
  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final c = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: c, radius: size.width / 2 - 3);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-math.pi / 2 + seconds * 0.8);
    canvas.translate(-c.dx, -c.dy);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.sweep(
          c,
          const [Color(0x00C274EB), Palette.violet, Palette.rose, Palette.coral],
          const [0, 0.35, 0.75, 1],
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.seconds != seconds;
}

class _AuraPainter extends CustomPainter {
  _AuraPainter({required this.clock, required this.intro}) : super(repaint: Listenable.merge([clock, intro]));

  final ValueNotifier<double> clock;
  final Animation<double> intro;

  @override
  void paint(Canvas canvas, Size size) {
    final s = clock.value;
    final show = Curves.easeOut.transform(window(intro.value, 0, 0.5));
    final c = Offset(size.width / 2, size.height * 0.44);
    for (final (dx, dy, r, color, period) in const [
      (-0.25, -0.12, 0.62, Color(0x66D9B8F6), 7.0),
      (0.28, 0.05, 0.55, Color(0x55FBC6D4), 9.0),
      (0.0, 0.2, 0.5, Color(0x44C7DAF6), 11.0),
    ]) {
      final centre = c + Offset(dx * size.width + 14 * math.sin(s / period * 6.28), dy * size.width);
      final radius = r * size.width * show;
      if (radius <= 0) continue;
      canvas.drawCircle(
        centre,
        radius,
        Paint()..shader = ui.Gradient.radial(centre, radius, [color, color.withValues(alpha: 0)]),
      );
    }
  }

  @override
  bool shouldRepaint(_AuraPainter oldDelegate) => false;
}
