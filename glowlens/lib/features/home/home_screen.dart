import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';
import '../analytic/area_sheet.dart';
import '../products/product_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onScan, required this.onOpenAnalytic});

  final VoidCallback onScan;
  final VoidCallback onOpenAnalytic;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, ClockMixin {
  late final AnimationController _intro;
  final ScrollController _scroll = ScrollController();
  final Set<int> _done = {0};

  static const _routine = [('Cleanse', 'barrier'), ('Treat', 'inkey'), ('Protect', 'spf')];

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900))..forward();
    startClock();
  }

  @override
  void dispose() {
    _intro.dispose();
    _scroll.dispose();
    disposeClock();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _toggle(int i) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_done.remove(i)) _done.add(i);
    });
    if (_done.length == _routine.length) Toast.show(context, 'Routine complete, glow on!', glyph: Glyph.star);
  }

  void _open(Product product) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, _) => ProductDetail(product: product),
        transitionsBuilder: (context, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: const Interval(0, 0.5)),
          child: child,
        ),
      ),
    );
  }

  Widget _reveal(double begin, Widget child, {Offset offset = const Offset(0, 40)}) {
    return Entrance(
      animation: stage(
        _intro,
        math.min(begin, 0.7),
        math.min(begin + 0.42, 1.0),
        curve: const Cubic(0.2, 0.9, 0.25, 1.05),
      ),
      offset: offset,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        ListView(
          controller: _scroll,
          padding: EdgeInsets.fromLTRB(0, top + 72, 0, 130),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Entrance(
                    animation: stage(_intro, 0.06, 0.42),
                    offset: const Offset(0, 20),
                    blur: 8,
                    child: Text('Your Glow Today', style: inter(24, 700, spacing: -0.5)),
                  ),
                  const SizedBox(height: 6),
                  Entrance(
                    animation: stage(_intro, 0.1, 0.46),
                    offset: const Offset(0, 14),
                    child: Text("Here's how your skin is doing.", style: inter(12.5, 400, color: Palette.muted)),
                  ),
                  const SizedBox(height: 18),
                  _reveal(0.12, _scanCard()),
                  const SizedBox(height: 24),
                  _reveal(
                    0.24,
                    _sectionTitle('Detected Areas', 'See all', widget.onOpenAnalytic),
                    offset: const Offset(-20, 0),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 21),
                clipBehavior: Clip.none,
                itemCount: Analysis.areas.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) =>
                    _reveal(0.28 + i * 0.06, _areaChip(Analysis.areas[i]), offset: const Offset(50, 0)),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _reveal(0.36, _routineCard()),
                  const SizedBox(height: 24),
                  _reveal(0.46, _sectionTitle('Recommended for you', null, null), offset: const Offset(-20, 0)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            SizedBox(
              height: 196,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 21),
                clipBehavior: Clip.none,
                itemCount: Catalog.products.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) =>
                    _reveal(0.5 + i * 0.05, _miniProduct(Catalog.products[i]), offset: const Offset(60, 0)),
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

  Widget _header() {
    return Entrance(
      animation: stage(_intro, 0, 0.4),
      offset: const Offset(0, -16),
      blur: 6,
      child: Row(
        children: [
          ScaleTransition(
            scale: stage(_intro, 0.05, 0.5, curve: Curves.elasticOut),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                image: const DecorationImage(image: AssetImage('assets/images/avatar.webp'), fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(), style: inter(12, 400, color: Palette.muted, height: 1.3)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text('Hello, Wilson', style: inter(16.5, 600, height: 1.25)),
                  const SizedBox(width: 5),
                  WavingHand(clock: clock),
                ],
              ),
            ],
          ),
          const Spacer(),
          RoundButton(
            glyph: Glyph.bell,
            onTap: () => Toast.show(context, 'No new reminders', glyph: Glyph.bell),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String? action, VoidCallback? onAction) {
    return Row(
      children: [
        Expanded(child: Text(title, style: inter(17, 700, spacing: -0.4))),
        if (action != null)
          Pressable(
            onTap: onAction,
            child: Row(
              children: [
                GradientText(action, style: inter(13, 600)),
                const SizedBox(width: 2),
                const GlyphIcon(Glyph.chevronRight, size: 16, gradient: Palette.brand, stroke: 2),
              ],
            ),
          ),
      ],
    );
  }

  Widget _scanCard() {
    return Pressable(
      onTap: widget.onScan,
      scale: 0.98,
      child: HoloSurface(
        tone: HoloTone.score,
        radius: 24,
        dots: 1,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Skin Health Score', style: inter(13, 500, color: Palette.muted)),
                    const SizedBox(height: 4),
                    AnimatedBuilder(
                      animation: _intro,
                      builder: (context, _) {
                        final t = Curves.easeOutCubic.transform(window(_intro.value, 0.2, 0.8));
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${(Analysis.score * t).round()}', style: inter(40, 700, spacing: -1.4, height: 1)),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text('/ Good', style: inter(13, 600, color: Palette.good)),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const GlyphIcon(Glyph.clock, size: 14, color: Palette.faint, stroke: 1.6),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Last scan · Today, 9:41',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: inter(11.5, 500, color: Palette.faint),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GradientPill(
                      label: 'Start Face Scan',
                      glyph: Glyph.camera,
                      height: 44,
                      fontSize: 13.5,
                      onTap: widget.onScan,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              _FaceThumb(clock: clock, size: math.min(118, MediaQuery.sizeOf(context).width * 0.3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _areaChip(Area area) {
    final mild = area.severity == Severity.mild;
    return Pressable(
      onTap: () => showAreaSheet(context, area),
      child: Container(
        width: 148,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x0D7A4FA0), blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: mild
                        ? const LinearGradient(colors: [Color(0xFF9DB0F2), Palette.periwinkle])
                        : Palette.brand,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(area.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: inter(12.5, 600)),
                ),
              ],
            ),
            Row(
              children: [
                Text(area.severityLabel, style: inter(11.5, 600, color: mild ? Palette.periwinkle : Palette.orchid)),
                const Spacer(),
                Text('${area.score}', style: inter(15, 700, spacing: -0.4)),
              ],
            ),
            AnimatedBuilder(
              animation: _intro,
              builder: (context, _) {
                final fill = window(_intro.value, 0.4, 0.9, Curves.easeOutCubic) * area.score / 100;
                return Container(
                  height: 5,
                  decoration: BoxDecoration(color: Palette.hairline, borderRadius: BorderRadius.circular(3)),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: fill,
                    child: Container(
                      decoration: BoxDecoration(gradient: Palette.brand, borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _routineCard() {
    final progress = _done.length / _routine.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x0F7A4FA0), blurRadius: 24, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ValueListenableBuilder<double>(
                valueListenable: clock,
                builder: (context, s, child) => Transform.rotate(angle: s * 0.5, child: child),
                child: const GlyphIcon(Glyph.sun, size: 20, gradient: Palette.brand, stroke: 1.7),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text("Today's Routine", style: inter(15, 700, spacing: -0.3))),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Text(
                  '${_done.length}/${_routine.length}',
                  key: ValueKey(_done.length),
                  style: inter(13, 700, color: Palette.orchid),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Container(
              height: 6,
              decoration: BoxDecoration(color: Palette.hairline, borderRadius: BorderRadius.circular(3)),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: v.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(gradient: Palette.brand, borderRadius: BorderRadius.circular(3)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          for (final (i, (step, id)) in _routine.indexed) _routineRow(i, step, Catalog.byId(id)),
        ],
      ),
    );
  }

  Widget _routineRow(int i, String step, Product product) {
    final done = _done.contains(i);
    return Pressable(
      onTap: () => _toggle(i),
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(product.image, width: 44, height: 44, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.toUpperCase(), style: inter(10.5, 600, color: Palette.faint, spacing: 0.6)),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: inter(13.5, 600, color: done ? Palette.faint : Palette.ink).copyWith(
                      decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
                      decorationColor: Palette.faint,
                    ),
                    child: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            TweenAnimationBuilder<double>(
              tween: Tween(end: done ? 1 : 0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, t, _) {
                final v = t.clamp(0.0, 1.0);
                return Transform.scale(
                  scale: 1 + math.sin(v * math.pi) * 0.2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: v > 0.05 ? Palette.brand : null,
                      border: v > 0.05 ? null : Border.all(color: Palette.hairline, width: 2),
                    ),
                    child: v > 0.05
                        ? GlyphIcon(Glyph.check, size: 28, color: Colors.white, stroke: 1.5, progress: v)
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniProduct(Product p) {
    return Pressable(
      onTap: () => _open(p),
      child: Container(
        width: 138,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x0D7A4FA0), blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Image.asset(p.image, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: inter(12.5, 600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('\$${p.price}', style: inter(13.5, 700)),
                      const Spacer(),
                      const GlyphIcon(Glyph.star, size: 12, color: Color(0xFFF5B83D)),
                      const SizedBox(width: 2),
                      Text('${p.rating}', style: inter(11, 600, color: Palette.muted)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceThumb extends StatelessWidget {
  const _FaceThumb({required this.clock, required this.size});

  final ValueNotifier<double> clock;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imageWidth = size * 1.75;
    final imageHeight = imageWidth * 1.401;
    final left = size / 2 - meshCentre.dx * imageWidth;
    final top = size / 2 - meshCentre.dy * imageHeight;
    return ValueListenableBuilder<double>(
      valueListenable: clock,
      builder: (context, s, child) {
        return Container(
          width: size + 8,
          height: size + 8,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: const [Color(0xFFE9C9F4), Palette.violet, Palette.rose, Palette.coral, Color(0xFFE9C9F4)],
              transform: GradientRotation(s * 0.9),
            ),
            boxShadow: [BoxShadow(color: Palette.rose.withValues(alpha: 0.25 + 0.1 * math.sin(s * 2)), blurRadius: 18)],
          ),
          child: child,
        );
      },
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF1E8FA)),
        child: ClipOval(
          child: Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                width: imageWidth,
                height: imageHeight,
                child: Image.asset('assets/images/face.webp', fit: BoxFit.cover),
              ),
              Positioned(
                left: left,
                top: top,
                width: imageWidth,
                height: imageHeight,
                child: CustomPaint(painter: _ThumbMeshPainter(clock)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbMeshPainter extends CustomPainter {
  _ThumbMeshPainter(this.clock) : super(repaint: clock);

  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    final s = clock.value;
    Offset at(int i) => Offset(meshPoints[i].dx * size.width, meshPoints[i].dy * size.height);
    final phase = (s / 2.6) % 1;
    final sweep = phase < 0.5 ? phase * 2 : 2 - phase * 2;
    final beam = lerp(faceBounds.top, faceBounds.bottom, Curves.easeInOutSine.transform(sweep)) * size.height;
    for (final (a, b) in meshEdges) {
      final pa = at(a);
      final pb = at(b);
      final near = math.exp(-math.pow(((pa.dy + pb.dy) / 2 - beam) / 18, 2));
      canvas.drawLine(
        pa,
        pb,
        Paint()
          ..strokeWidth = 0.7
          ..color = Color.lerp(const Color(0x99FFFFFF), const Color(0xFFF7A8C4), near)!,
      );
    }
    for (var i = 0; i < meshPoints.length; i++) {
      final p = at(i);
      final near = math.exp(-math.pow((p.dy - beam) / 14, 2));
      canvas.drawCircle(p, 1.2 + near * 1.4, Paint()..color = Colors.white);
    }
    final left = faceBounds.left * size.width - 10;
    final right = faceBounds.right * size.width + 10;
    canvas.drawLine(
      Offset(left, beam),
      Offset(right, beam),
      Paint()
        ..strokeWidth = 2
        ..shader = ui.Gradient.linear(
          Offset(left, beam),
          Offset(right, beam),
          const [Color(0x00F7A8C4), Color(0xFFF7A8C4), Color(0x00F7A8C4)],
          const [0, 0.5, 1],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
  }

  @override
  bool shouldRepaint(_ThumbMeshPainter oldDelegate) => false;
}
