import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';

Future<void> showAreaSheet(BuildContext context, Area area) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: area.name,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 800),
    pageBuilder: (context, animation, _) => _AreaSheet(area: area, animation: animation),
  );
}

class _AreaSheet extends StatefulWidget {
  const _AreaSheet({required this.area, required this.animation});

  final Area area;
  final Animation<double> animation;

  @override
  State<_AreaSheet> createState() => _AreaSheetState();
}

class _AreaSheetState extends State<_AreaSheet> with SingleTickerProviderStateMixin, ClockMixin {
  @override
  void initState() {
    super.initState();
    startClock();
  }

  @override
  void dispose() {
    disposeClock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = widget.animation;
    final area = widget.area;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final product = Catalog.byId(area.productId);
    final level = switch (area.severity) {
      Severity.mild => 1,
      Severity.moderate => 2,
      Severity.deep => 3,
    };
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final rise = animation.status == AnimationStatus.reverse
            ? Curves.easeInCubic.transform(t)
            : const Cubic(0.16, 1, 0.3, 1).transform(t);
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10 * t, sigmaY: 10 * t),
                  child: ColoredBox(color: const Color(0xFF2A1640).withValues(alpha: 0.2 * t)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FractionalTranslation(translation: Offset(0, 1 - rise), child: child),
            ),
          ],
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 22 + bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Palette.hairline, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Entrance(
              animation: stage(animation, 0.2, 0.7),
              offset: const Offset(0, 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: _ZoomedArea(area: area, clock: clock, reveal: stage(animation, 0.3, 1)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Entrance(
              animation: stage(animation, 0.3, 0.8),
              offset: const Offset(0, 24),
              child: Row(
                children: [
                  Expanded(child: Text(area.name, style: inter(19, 700, spacing: -0.4))),
                  GradientText('${area.score}', style: inter(24, 700, spacing: -0.8)),
                  Text(' /100', style: inter(12, 500, color: Palette.faint)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Entrance(
              animation: stage(animation, 0.35, 0.85),
              offset: const Offset(0, 24),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    Expanded(
                      child: AnimatedBuilder(
                        animation: animation,
                        builder: (context, _) {
                          final fill = i < level ? window(animation.value, 0.45 + i * 0.12, 0.7 + i * 0.12) : 0.0;
                          return Container(
                            height: 6,
                            decoration: BoxDecoration(color: Palette.hairline, borderRadius: BorderRadius.circular(3)),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: fill,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: Palette.brand,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (i < 2) const SizedBox(width: 6),
                  ],
                  const SizedBox(width: 12),
                  Text(area.severityLabel, style: inter(12.5, 600, color: Palette.orchid)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Entrance(
              animation: stage(animation, 0.4, 0.9),
              offset: const Offset(0, 24),
              child: Text(area.tip, style: inter(13, 400, color: Palette.muted, height: 1.55)),
            ),
            const SizedBox(height: 16),
            Entrance(
              animation: stage(animation, 0.5, 1, curve: Curves.easeOutBack),
              offset: const Offset(0, 30),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Palette.canvas, borderRadius: BorderRadius.circular(18)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(product.image, width: 52, height: 52, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recommended', style: inter(11, 500, color: Palette.faint)),
                          Text(product.name, style: inter(13.5, 600)),
                          Text('\$${product.price}', style: inter(12.5, 700, color: Palette.orchid)),
                        ],
                      ),
                    ),
                    Pressable(
                      onTap: () {
                        Bag.instance.add(product.id);
                        Navigator.of(context).pop();
                        Toast.show(context, '${product.name} added', glyph: Glyph.bag);
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(color: Palette.button, shape: BoxShape.circle),
                        child: const Center(child: GlyphIcon(Glyph.plus, size: 18, color: Colors.white, stroke: 2)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomedArea extends StatelessWidget {
  const _ZoomedArea({required this.area, required this.clock, required this.reveal});

  final Area area;
  final ValueNotifier<double> clock;
  final Animation<double> reveal;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final imageWidth = w * 2.1;
        final imageHeight = imageWidth * 1.401;
        final left = w / 2 - area.focus.dx * imageWidth;
        final top = 85 - area.focus.dy * imageHeight;
        return Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Color(0xFFF1E8FA))),
            AnimatedBuilder(
              animation: reveal,
              builder: (context, child) {
                final zoom = lerp(1.25, 1, Curves.easeOutCubic.transform(reveal.value));
                return Positioned(
                  left: left,
                  top: top,
                  width: imageWidth,
                  height: imageHeight,
                  child: Transform.scale(
                    scale: zoom,
                    alignment: Alignment(area.focus.dx * 2 - 1, area.focus.dy * 2 - 1),
                    child: child,
                  ),
                );
              },
              child: Image.asset('assets/images/face.webp', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _FocusPainter(clock: clock, reveal: reveal, radius: area.radius * imageWidth),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FocusPainter extends CustomPainter {
  _FocusPainter({required this.clock, required this.reveal, required this.radius})
    : super(repaint: Listenable.merge([clock, reveal]));

  final ValueNotifier<double> clock;
  final Animation<double> reveal;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOutBack.transform(reveal.value.clamp(0.0, 1.0));
    final s = clock.value;
    final c = Offset(size.width / 2, 85);
    final r = math.min(radius, size.width * 0.34) * t;
    if (r <= 0) return;
    canvas.drawCircle(
      c,
      r * 1.2,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          r * 1.2,
          [const Color(0x66E77FC5), const Color(0x22C274EB), const Color(0x00C274EB)],
          const [0, 0.6, 1],
        ),
    );
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Colors.white;
    for (var k = 0; k < 24; k++) {
      final a = k * math.pi * 2 / 24 + s * 0.5;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), a, math.pi / 24, false, ring);
    }
    final scanY = c.dy - r + (s * 0.6 % 1) * r * 2;
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    canvas.drawLine(
      Offset(c.dx - r, scanY),
      Offset(c.dx + r, scanY),
      Paint()
        ..color = const Color(0xCCF7A8C4)
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FocusPainter oldDelegate) => false;
}
