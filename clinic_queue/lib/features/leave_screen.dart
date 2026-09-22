import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({
    super.key,
    required this.onBack,
    required this.onArrive,
    required this.onSwap,
    required this.onInfo,
    required this.onLeave,
  });

  final VoidCallback onBack;
  final VoidCallback onArrive;
  final VoidCallback onSwap;
  final VoidCallback onInfo;
  final VoidCallback onLeave;

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _drive;
  late final AnimationController _trip;
  final _left = ValueNotifier<int>(total);
  final _onWay = ValueNotifier<bool>(false);
  Timer? _timer;

  static const total = 12 * 60;
  static const drive = 11 * 60;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..forward();
    _drive = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat();
    _trip = AnimationController(vsync: this, duration: const Duration(milliseconds: 5600))
      ..addListener(() => _left.value = ((1 - _trip.value) * drive).round());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_onWay.value && _left.value > 0) _left.value -= 1;
    });
  }

  Future<void> _go() async {
    if (_onWay.value) return;
    widget.onLeave();
    _timer?.cancel();
    _onWay.value = true;
    _drive
      ..stop()
      ..duration = const Duration(milliseconds: 5600);
    _drive.forward(from: 0);
    await _trip.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 450));
    if (mounted) widget.onArrive();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _enter.dispose();
    _drive.dispose();
    _trip.dispose();
    _left.dispose();
    _onWay.dispose();
    super.dispose();
  }

  Widget _stage(double begin, Widget child, {Offset offset = const Offset(0, 16), double scale = 1}) {
    return Staged(animation: _enter, begin: begin, end: begin + 0.5, offset: offset, scale: scale, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final spare = CanvasScope.of(context).pin(73).clamp(0.0, 110.0);
    final mid = spare * 0.45;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(left: 21, top: 57, child: _stage(0, _square(Glyph.back, widget.onBack))),
        Positioned(left: 328, top: 57, child: _stage(0, _square(Glyph.info, widget.onInfo))),
        Positioned(
          left: 96.5,
          top: 62,
          width: 200,
          child: _stage(
            0,
            Column(
              children: [
                Text('Your visit', style: jakarta(15, 800, spacing: -0.3, height: 1.25)),
                const SizedBox(height: 1.5),
                Text('Token A–27 · CityCare', style: jakarta(11.25, 500, color: const Color(0xFF6B7F7C), height: 1.25)),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 120.5 + mid * 0.5,
          width: 353,
          height: 251.5,
          child: _stage(0.08, _MapCard(drive: _drive)),
        ),
        Positioned(
          left: 56.5,
          top: 245 + mid,
          width: 280,
          height: 280,
          child: _stage(
            0.2,
            _Countdown(left: _left, enter: _enter, onWay: _onWay),
            scale: 0.85,
            offset: Offset.zero,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 522.5 + mid,
          height: 33.5,
          child: _stage(
            0.4,
            Center(
              child: Container(
                padding: const EdgeInsets.only(left: 16.5, right: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFDFC),
                  borderRadius: BorderRadius.circular(16.75),
                  boxShadow: const [BoxShadow(color: Color(0x0D0F3B3A), blurRadius: 10, offset: Offset(0, 3))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const GlyphIcon(Glyph.bell, size: 11.5, color: Color(0xFFD9541E), stroke: 2.2),
                    const SizedBox(width: 10.5),
                    Text(
                      'Traffic: 11 min drive right now',
                      style: jakarta(12.25, 700, color: const Color(0xFF1F3E3C), spacing: -0.2, height: 1.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 583.5 + spare,
          width: 353,
          height: 59,
          child: _stage(
            0.48,
            ValueListenableBuilder<bool>(
              valueListenable: _onWay,
              builder: (context, onWay, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 360),
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(animation), child: child),
                ),
                child: onWay
                    ? _Trip(key: const ValueKey('trip'), progress: _trip)
                    : TealButton(
                        key: const ValueKey('go'),
                        label: "I'm on my way",
                        trailing: Glyph.arrow,
                        onTap: _go,
                        height: 59,
                      ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 667 + spare,
          child: _stage(
            0.55,
            Center(
              child: Pressable(
                onTap: widget.onSwap,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 1),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Hue.teal, width: 1.3)),
                  ),
                  child: Text(
                    'Need more time? Swap spot',
                    style: jakarta(13.75, 700, color: Hue.teal, spacing: -0.14, height: 1.25),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 21,
          top: 717 + spare,
          width: 352,
          height: 62,
          child: _stage(
            0.6,
            Container(
              decoration: BoxDecoration(color: const Color(0xFFE8F4F0), borderRadius: BorderRadius.circular(18)),
              child: Stack(
                children: [
                  Positioned(
                    left: 14.5,
                    top: 13.5,
                    width: 35,
                    height: 35,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
                      alignment: Alignment.center,
                      child: const GlyphIcon(Glyph.shield, size: 16, color: Hue.teal, stroke: 1.8),
                    ),
                  ),
                  Positioned(
                    left: 62.5,
                    top: 12.5,
                    width: 285,
                    child: Text(
                      "We'll hold your spot for 10 minutes after your turn — no need to rush.",
                      style: jakarta(12.25, 600, color: const Color(0xFF1F5A55), spacing: -0.15, height: 18 / 12.25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _square(Glyph glyph, VoidCallback onTap) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFFBFDFC),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x0F0F3B3A), blurRadius: 10, offset: Offset(0, 3))],
        ),
        alignment: Alignment.center,
        child: GlyphIcon(glyph, size: glyph == Glyph.back ? 17 : 15, color: Hue.ink, stroke: 2),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.drive});

  final Animation<double> drive;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(child: CustomPaint(painter: _MapPainter(drive))),
          ),
          Positioned(
            left: 15.5,
            top: 14,
            height: 32.5,
            child: Container(
              padding: const EdgeInsets.only(left: 13.5, right: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFDFC),
                borderRadius: BorderRadius.circular(16.25),
                boxShadow: const [BoxShadow(color: Color(0x140F3B3A), blurRadius: 8, offset: Offset(0, 3))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GlyphIcon(Glyph.pin, size: 12.5, color: Hue.teal, stroke: 2),
                  const SizedBox(width: 7.5),
                  Text(
                    'Home → CityCare · 3.2 km',
                    style: jakarta(12.25, 700, color: const Color(0xFF1F3E3C), spacing: -0.2, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.drive) : super(repaint: drive);

  final Animation<double> drive;

  static const home = Offset(58.5, 179.5);
  static const dest = Offset(283, 52);

  static Path route() {
    return Path()
      ..moveTo(home.dx + 8, home.dy - 9)
      ..cubicTo(95, 150, 128, 120, 165, 108)
      ..cubicTo(205, 95, 240, 78, dest.dx - 4, dest.dy + 16);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFFD4EBE2));
    final block = Paint()..color = const Color(0xFFC6E4D9);
    canvas.drawRRect(RRect.fromLTRBR(18, 17, 118, 84.5, const Radius.circular(12)), block);
    canvas.drawRRect(RRect.fromLTRBR(146, 17, 226, 79, const Radius.circular(12)), block);
    canvas.drawRRect(RRect.fromLTRBR(254, 29.5, 336, 83.5, const Radius.circular(12)), block);
    canvas.drawRRect(RRect.fromLTRBR(26.5, 124.5, 117, 196.5, const Radius.circular(12)), block);
    canvas.drawRRect(RRect.fromLTRBR(146, 122.5, 226, 158, const Radius.circular(12)), block);
    canvas.drawRRect(RRect.fromLTRBR(256, 123, 336, 196, const Radius.circular(12)), block);

    final road = Paint()..color = const Color(0xFFF4FAF8);
    canvas.drawRect(Rect.fromLTWH(0, 97.5, size.width, 11.5), road);
    canvas.drawRect(Rect.fromLTWH(0, 200.5, size.width, 11.5), road);
    canvas.drawRect(Rect.fromLTWH(125, 0, 11, size.height), road);
    canvas.drawRect(Rect.fromLTWH(235, 0, 11, size.height), road);

    final dot = Paint()..color = const Color(0xFFA7D7C6);
    canvas.drawCircle(const Offset(63, 59), 9, dot);
    canvas.drawCircle(const Offset(296.5, 164), 11, dot);

    final path = route();
    final dash = Paint()..color = Hue.orange;
    for (final metric in path.computeMetrics()) {
      final carAt = drive.value * metric.length;
      for (var d = 0.0; d < metric.length; d += 8.3) {
        final p = metric.getTangentForOffset(d)!.position;
        final fade = d < 35 ? 0.35 + 0.65 * d / 35 : 1.0;
        final ahead = d > carAt ? 1.0 : 0.55;
        canvas.drawCircle(p, 2.15, dash..color = Hue.orange.withValues(alpha: fade * ahead));
      }
      final car = metric.getTangentForOffset(carAt)!;
      canvas.save();
      canvas.translate(car.position.dx, car.position.dy - 7);
      canvas.rotate(-car.angle * 0.9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 26, height: 8), const Radius.circular(4)),
        Paint()..color = Hue.teal,
      );
      canvas.drawCircle(const Offset(-6, 7), 3.5, Paint()..color = const Color(0xFF0F3B3A));
      canvas.drawCircle(const Offset(6, 7), 3.5, Paint()..color = const Color(0xFF0F3B3A));
      canvas.restore();
    }

    canvas.drawCircle(
      home + const Offset(-2, 10),
      10,
      Paint()
        ..color = const Color(0x260F3B3A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(home, 15.5, Paint()..color = const Color(0xFF0E3A38));
    canvas.drawCircle(
      home,
      15.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x33FFFFFF),
    );
    final house = Path()
      ..moveTo(home.dx, home.dy - 6)
      ..lineTo(home.dx + 6.5, home.dy - 0.5)
      ..lineTo(home.dx + 6.5, home.dy + 6)
      ..lineTo(home.dx - 6.5, home.dy + 6)
      ..lineTo(home.dx - 6.5, home.dy - 0.5)
      ..close();
    canvas.drawPath(house, Paint()..color = Colors.white);

    canvas.drawOval(
      Rect.fromCenter(center: dest + const Offset(0, 22), width: 26, height: 7),
      Paint()..color = const Color(0x2E0F3B3A),
    );
    canvas.drawCircle(
      dest + const Offset(0, 2),
      18,
      Paint()
        ..color = const Color(0x40FF8A3D)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(dest, 16, Paint()..color = Hue.orange);
    final plus = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(dest - const Offset(7, 0), dest + const Offset(7, 0), plus);
    canvas.drawLine(dest - const Offset(0, 7), dest + const Offset(0, 7), plus);
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => false;
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.left, required this.enter, required this.onWay});

  final ValueListenable<bool> onWay;

  final ValueListenable<int> left;
  final Animation<double> enter;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: RepaintBoundary(child: CustomPaint(painter: _RingPainter(left, enter))),
        ),
        Positioned(
          top: 90,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Hue.live, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              ValueListenableBuilder<bool>(
                valueListenable: onWay,
                builder: (context, way, _) => Text(
                  way ? 'ON THE WAY' : 'LEAVE NOW',
                  style: caps(10.5, color: const Color(0xFF1E7F5E), tracking: 0.16, height: 1.2),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 104,
          child: ValueListenableBuilder<int>(
            valueListenable: left,
            builder: (context, left, _) {
              final m = (left ~/ 60).toString().padLeft(2, '0');
              final s = (left % 60).toString().padLeft(2, '0');
              return Text(
                '$m:$s',
                style: jakarta(
                  54,
                  800,
                  spacing: -2.7,
                  height: 1.2,
                ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              );
            },
          ),
        ),
        Positioned(
          top: 164,
          child: ValueListenableBuilder<bool>(
            valueListenable: onWay,
            builder: (context, way, _) => Text(
              way ? 'until you arrive at CityCare' : 'minutes until you should go',
              style: jakarta(13.25, 600, color: const Color(0xFF3F5553), spacing: -0.2, height: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.left, this.enter) : super(repaint: Listenable.merge([left, enter]));

  final ValueListenable<int> left;
  final Animation<double> enter;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      133,
      Paint()
        ..color = const Color(0x1A0F3B3A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawCircle(c, 135, Paint()..color = const Color(0xFFF1F8F5));
    canvas.drawCircle(c, 129, Paint()..color = Colors.white);
    canvas.drawCircle(c, 94, Paint()..color = const Color(0xFFF3FAF8));
    canvas.drawCircle(
      c,
      94,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFE6F0ED),
    );

    const radius = 112.5;
    final rect = Rect.fromCircle(center: c, radius: radius);
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..color = const Color(0xFFEFF5F3),
    );

    const start = -math.pi / 2 + 0.05;
    const full = math.pi * 2 * 0.63;
    final grow = Curves.easeOutCubic.transform(span(enter.value, 0.25, 0.95));
    final sweep = full * grow * (left.value / _LeaveScreenState.total);
    if (sweep <= 0.001) return;
    final shader = const SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      transform: GradientRotation(start),
      colors: [Color(0xFF12948A), Color(0xFF14A99A), Color(0xFF1CC39A), Color(0xFF3FD386), Color(0xFF3FD386)],
      stops: [0, 0.3, 0.5, 0.64, 1],
    ).createShader(rect);
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => false;
}

class _Trip extends StatelessWidget {
  const _Trip({super.key, required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 59,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(29.5),
        boxShadow: cardShadow(1.1),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          final t = progress.value;
          final minutes = ((1 - t) * 11).ceil();
          return Stack(
            children: [
              FractionallySizedBox(
                widthFactor: math.max(0.14, t),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFD7F2EA), Color(0xFFBFE9DC)]),
                    borderRadius: BorderRadius.circular(29.5),
                  ),
                ),
              ),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Container(
                    width: 39,
                    height: 39,
                    decoration: const BoxDecoration(color: Hue.teal, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const GlyphIcon(Glyph.car, size: 19, color: Colors.white, stroke: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t >= 1 ? 'You have arrived' : 'On the way to CityCare',
                          style: jakarta(14.5, 800, spacing: -0.3),
                        ),
                        Text(
                          t >= 1 ? 'Checking you in…' : 'Arriving in $minutes min · clinic notified',
                          style: jakarta(11.5, 600, color: Hue.gray),
                        ),
                      ],
                    ),
                  ),
                  Text('${(t * 100).round()}%', style: jakarta(13, 800, color: Hue.teal)),
                  const SizedBox(width: 20),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
