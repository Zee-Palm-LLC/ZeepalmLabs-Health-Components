import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';
import 'area_sheet.dart';
import 'score_ring.dart';
import 'trend_card.dart';

class AnalyticScreen extends StatefulWidget {
  const AnalyticScreen({super.key, required this.active, required this.onBack, required this.onUpload});

  final bool active;
  final VoidCallback onBack;
  final VoidCallback onUpload;

  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> with TickerProviderStateMixin, ClockMixin {
  late final AnimationController _intro;
  late final AnimationController _score;
  late final AnimationController _total;
  int _seen = ScanResults.instance.generation;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _score = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));
    _total = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));
    startClock();
    _play();
  }

  @override
  void didUpdateWidget(AnalyticScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final fresh = ScanResults.instance.generation != _seen;
    if (widget.active && !oldWidget.active && fresh) {
      _seen = ScanResults.instance.generation;
      _play();
    }
  }

  void _play() {
    _intro.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) _score.forward(from: 0);
    });
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) _total.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _score.dispose();
    _total.dispose();
    _scroll.dispose();
    disposeClock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        ListView(
          controller: _scroll,
          padding: EdgeInsets.fromLTRB(0, top + 78, 0, 130),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Entrance(
                animation: stage(_intro, 0.02, 0.4, curve: const Cubic(0.2, 0.9, 0.25, 1.05)),
                offset: const Offset(0, 40),
                scale: 0.94,
                child: _uploadCard(),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Entrance(
                animation: stage(_intro, 0.15, 0.45),
                offset: const Offset(-20, 0),
                child: Text('Detected Areas', style: inter(17, 700, spacing: -0.4)),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                clipBehavior: Clip.none,
                itemCount: Analysis.areas.length,
                separatorBuilder: (_, _) => const SizedBox(width: 11),
                itemBuilder: (context, i) => _areaCard(i),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Entrance(
                animation: stage(_intro, 0.35, 0.75, curve: const Cubic(0.2, 0.9, 0.25, 1.05)),
                offset: const Offset(0, 50),
                child: _scoreCard(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Entrance(
                animation: stage(_intro, 0.45, 0.85, curve: const Cubic(0.2, 0.9, 0.25, 1.05)),
                offset: const Offset(0, 50),
                child: _totalCard(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Entrance(
                animation: stage(_intro, 0.55, 0.95, curve: const Cubic(0.2, 0.9, 0.25, 1.05)),
                offset: const Offset(0, 50),
                child: TrendCard(progress: _total, clock: clock),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: GlassHeader(scroll: _scroll, child: _header()),
        ),
      ],
    );
  }

  double _ringSize(BuildContext context) => math.min(114, MediaQuery.sizeOf(context).width * 0.29);

  Widget _header() {
    return Entrance(
      animation: stage(_intro, 0, 0.35),
      offset: const Offset(0, -14),
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            RoundButton(glyph: Glyph.back, onTap: widget.onBack),
            Expanded(
              child: Center(child: Text('Analytic', style: inter(20, 600, spacing: -0.4))),
            ),
            RoundButton(
              glyph: Glyph.more,
              onTap: () => Toast.show(context, 'Report saved to Profile', glyph: Glyph.share),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadCard() {
    return SizedBox(
      height: 200,
      child: HoloSurface(
        tone: HoloTone.upload,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _GlintPainter(clock))),
            Positioned.fill(
              child: Column(
                children: [
                  const SizedBox(height: 22),
                  _CameraBadge(clock: clock),
                  const SizedBox(height: 14),
                  Text('Upload a clear photo', style: inter(14, 600)),
                  const SizedBox(height: 4),
                  Text('for best results', style: inter(12, 400, color: Palette.muted)),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 138,
                    child: GradientPill(label: 'Upload Photo', height: 38, fontSize: 13.5, onTap: widget.onUpload),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _areaCard(int i) {
    final area = Analysis.areas[i];
    final mild = area.severity == Severity.mild;
    return AnimatedBuilder(
      animation: _intro,
      builder: (context, child) {
        final t = window(_intro.value, 0.2 + i * 0.08, 0.62 + i * 0.08);
        final flip = Curves.easeOutBack.transform(t);
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0016)
              ..rotateY((1 - flip) * -1.3)
              ..translateByDouble(0, (1 - flip) * 20, 0, 1),
            child: child,
          ),
        );
      },
      child: Pressable(
        onTap: () => showAreaSheet(context, area),
        child: SizedBox(
          width: 108,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                bottom: 3,
                child: HoloSurface(
                  tone: HoloTone(Palette.mint, Palette.surface, Palette.petal, seed: 0.2 + i * 0.23),
                  radius: 18,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(area.name, style: inter(12, 500, color: Palette.inkSoft)),
                      const SizedBox(height: 3),
                      GradientText(
                        area.severityLabel,
                        style: inter(12, 700),
                        gradient: mild
                            ? const LinearGradient(colors: [Color(0xFF8FA4F0), Palette.periwinkle])
                            : const LinearGradient(colors: [Palette.orchid, Color(0xFFE38BD8)]),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0x1A7A4FA0), blurRadius: 12, offset: Offset(0, 4))],
                    ),
                    child: const Center(child: GlyphIcon(Glyph.camera, size: 21, stroke: 1.6)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreCard() {
    return Pressable(
      onTap: () => _score.forward(from: 0),
      scale: 0.98,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 164),
        child: HoloSurface(
          tone: HoloTone.score,
          radius: 20,
          dots: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(19, 22, 16, 18),
            child: AnimatedBuilder(
              animation: Listenable.merge([_score, clock]),
              builder: (context, _) {
                final t = Curves.easeOutCubic.transform(_score.value);
                final glint = (clock.value / 2.8) % 1;
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Skin Health Score', style: inter(15, 600, spacing: -0.3)),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('${(Analysis.score * t).round()}', style: inter(38, 700, spacing: -1.2, height: 1)),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('/100', style: inter(13, 400, color: Palette.faint)),
                                  Opacity(
                                    opacity: window(_score.value, 0.6, 1),
                                    child: Text('/ Good', style: inter(13, 600, color: Palette.good)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Keep going! Your skin is on the right track.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: inter(12.5, 400, color: Palette.muted, height: 1.55),
                          ),
                        ],
                      ),
                    ),
                    ScoreRing(value: Analysis.score, sweep: t, glint: glint, size: _ringSize(context)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _totalCard() {
    const metrics = [('Hydration', 72), ('Elasticity', 81), ('Texture', 64)];
    return Pressable(
      onTap: () => _total.forward(from: 0),
      scale: 0.98,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 164),
        child: HoloSurface(
          tone: HoloTone.total,
          radius: 20,
          dots: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(19, 22, 16, 18),
            child: AnimatedBuilder(
              animation: Listenable.merge([_total, clock]),
              builder: (context, _) {
                final t = Curves.easeOutCubic.transform(_total.value);
                final glint = (clock.value / 3.1 + 0.4) % 1;
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Skin Health', style: inter(15, 600, spacing: -0.3)),
                          const SizedBox(height: 14),
                          for (final (i, (label, value)) in metrics.indexed) ...[
                            MetricBar(
                              label: label,
                              value: value,
                              fill: window(_total.value, i * 0.12, 0.7 + i * 0.12, Curves.easeOutCubic),
                            ),
                            if (i < metrics.length - 1) const SizedBox(height: 9),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    ScoreRing(value: 82, sweep: t, glint: glint, size: _ringSize(context)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraBadge extends StatelessWidget {
  const _CameraBadge({required this.clock});

  final ValueNotifier<double> clock;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: clock,
      builder: (context, s, _) {
        return SizedBox.square(
          dimension: 52,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              for (var k = 0; k < 2; k++)
                Builder(
                  builder: (context) {
                    final phase = (s / 2.4 + k * 0.5) % 1;
                    return Container(
                      width: 52 + phase * 34,
                      height: 52 + phase * 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Palette.rose.withValues(alpha: (1 - phase) * 0.45), width: 1.2),
                      ),
                    );
                  },
                ),
              Transform.translate(
                offset: Offset(0, math.sin(s * 1.8) * 2),
                child: Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(1.6),
                  decoration: const BoxDecoration(shape: BoxShape.circle, gradient: Palette.brandSoft),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Center(child: GlyphIcon(Glyph.camera, size: 24, stroke: 1.6, gradient: Palette.brand)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlintPainter extends CustomPainter {
  _GlintPainter(this.clock) : super(repaint: clock);

  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    final s = clock.value;
    const spots = [(0.9, 0.12, 0.0), (0.88, 0.58, 0.4), (0.12, 0.2, 0.7), (0.72, 0.3, 0.2)];
    for (final (x, y, phase) in spots) {
      final pulse = math.pow(math.max(0, math.sin((s / 2.2 + phase) * math.pi * 2)), 3).toDouble();
      if (pulse <= 0.01) continue;
      final c = Offset(x * size.width, y * size.height);
      final r = 3 + pulse * 7;
      final paint = Paint()..color = Colors.white.withValues(alpha: 0.9 * pulse);
      canvas.drawCircle(
        c,
        r * 1.4,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      final star = Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
        ..close();
      canvas.drawPath(star, paint);
    }
  }

  @override
  bool shouldRepaint(_GlintPainter oldDelegate) => false;
}
