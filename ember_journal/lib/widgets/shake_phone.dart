import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../data/prompts.dart';

class ShakePhone extends StatefulWidget {
  const ShakePhone({
    super.key,
    required this.seconds,
    required this.roll,
    required this.onShake,
    this.width = 150,
    this.height = 300,
  });

  final double seconds;
  final double roll;
  final VoidCallback onShake;
  final double width;
  final double height;

  @override
  State<ShakePhone> createState() => _ShakePhoneState();
}

class _ShakePhoneState extends State<ShakePhone> with SingleTickerProviderStateMixin {
  late final AnimationController _jolt;
  double _grab = 0;
  double _lastDx = 0;
  int _flips = 0;
  DateTime _flipAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _jolt = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _jolt.dispose();
    super.dispose();
  }

  void _drag(DragUpdateDetails d) {
    setState(() => _grab = (_grab + d.delta.dx * 0.004).clamp(-0.34, 0.34));
    if (d.delta.dx.abs() < 1.4) return;
    if (_lastDx != 0 && d.delta.dx.sign != _lastDx.sign) {
      final now = DateTime.now();
      if (now.difference(_flipAt).inMilliseconds > 620) _flips = 0;
      _flipAt = now;
      _flips++;
      if (_flips >= 3) {
        _flips = 0;
        shake();
        widget.onShake();
      }
    }
    _lastDx = d.delta.dx;
  }

  void shake() {
    _jolt.forward(from: 0);
  }

  void _release() {
    _lastDx = 0;
    final from = _grab;
    _jolt.stop();
    final release = AnimationController(vsync: this, duration: const Duration(milliseconds: 620));
    release.addListener(() {
      if (!mounted) return;
      setState(() => _grab = from * (1 - spring(release.value)));
    });
    release.addStatusListener((s) {
      if (s == AnimationStatus.completed) release.dispose();
    });
    release.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: _drag,
      onPanEnd: (_) => _release(),
      onPanCancel: _release,
      onTap: () {
        shake();
        widget.onShake();
      },
      child: AnimatedBuilder(
        animation: _jolt,
        builder: (context, _) {
          final j = _jolt.value;
          final decay = math.exp(-5.0 * j);
          final wobble = j > 0 && j < 1 ? math.sin(j * math.pi * 2 * 7) * decay : 0.0;
          final idle = math.sin(widget.seconds * 0.8) * 0.018;
          final tiltZ = 0.315 + _grab * 1.2 + wobble * 0.30 + idle;
          final tiltY = 0.17 - _grab * 0.9 + wobble * 0.12;
          final tiltX = -0.20 + math.sin(widget.seconds * 0.55 + 1.2) * 0.022;
          return SizedBox(
            width: widget.width * 1.9,
            height: widget.height * 1.12,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ArcPainter(
                      seconds: widget.seconds,
                      energy: (0.58 + 0.42 * (wobble.abs() * 2.4).clamp(0.0, 1.0)).toDouble(),
                    ),
                  ),
                ),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0013)
                    ..rotateX(tiltX)
                    ..rotateY(tiltY)
                    ..rotateZ(tiltZ),
                  child: SizedBox(
                    width: widget.width,
                    height: widget.height,
                    child: CustomPaint(
                      painter: _PhonePainter(seconds: widget.seconds, jolt: j, roll: widget.roll),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PhonePainter extends CustomPainter {
  _PhonePainter({required this.seconds, required this.jolt, required this.roll});

  final double seconds;
  final double jolt;
  final double roll;

  static final _painters = <TextPainter>[];

  void _ensure() {
    if (_painters.isNotEmpty) return;
    for (final text in teaserCards) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: font(7.6, 400, height: 1.42, color: const Color(0xFFE9CDA9)),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
      )..layout(maxWidth: 68);
      _painters.add(tp);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _ensure();
    final body = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(30));

    canvas.drawRRect(
      body.shift(const Offset(-10, 26)),
      Paint()
        ..color = const Color(0x7A2A0C00)
        ..maskFilter = const ui.MaskFilter.blur(BlurStyle.normal, 26),
    );

    canvas.drawRRect(
      body,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, size.height),
          const [Color(0xFFFFD25C), Color(0xFFFBB02C), Color(0xFFE88A14), Color(0xFFC96A0D)],
          const [0.0, 0.34, 0.72, 1.0],
        ),
    );
    canvas.drawRRect(
      body.deflate(1.2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = ui.Gradient.linear(Offset.zero, Offset(size.width, 0), const [
          Color(0x99FFF0C0),
          Color(0x1AFFF0C0),
        ]),
    );

    final screen = RRect.fromRectAndRadius(
      Rect.fromLTWH(7.5, 8.5, size.width - 15, size.height - 30),
      const Radius.circular(24),
    );
    canvas.drawRRect(
      screen,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, screen.top), Offset(0, screen.bottom), const [
          Color(0xFF2A1A12),
          Color(0xFF17100C),
        ]),
    );

    canvas.save();
    canvas.clipRRect(screen);

    final drift = roll * 240;
    for (var i = 0; i < _painters.length; i++) {
      final tp = _painters[i];
      final rightAlign = i.isOdd;
      final wobble = math.sin(seconds * 1.4 + i * 1.1) * 1.6 * (1 + jolt * 4);
      var y = 26.0 + i * 52.0 + wobble - drift;
      final span = _painters.length * 52.0;
      while (y < -40) {
        y += span;
      }
      final x = rightAlign ? size.width - tp.width - 26 : 20.0;
      final cardRect = Rect.fromLTWH(x - 7, y - 6, tp.width + 14, tp.height + 12);
      if (cardRect.bottom < 0 || cardRect.top > size.height) continue;
      final fade = (1 - (roll * 3 - i * 0.2).clamp(0.0, 1.0)).clamp(0.22, 1.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(cardRect, const Radius.circular(9)),
        Paint()..color = const Color(0xFF3B2A1F).withValues(alpha: 0.86 * fade),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(cardRect, const Radius.circular(9)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = const Color(0x2EFFE2C4).withValues(alpha: 0.18 * fade),
      );
      canvas.saveLayer(cardRect, Paint()..color = Colors.white.withValues(alpha: fade));
      tp.paint(canvas, Offset(x, y));
      canvas.restore();
    }

    canvas.drawRect(
      Rect.fromLTWH(screen.left, screen.top, screen.width, screen.height),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(screen.left, screen.top),
          Offset(screen.right, screen.bottom),
          const [Color(0x24FFFFFF), Color(0x00FFFFFF), Color(0x14FFFFFF)],
          const [0.0, 0.45, 1.0],
        ),
    );
    canvas.restore();

    final notch = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.width / 2, 15), width: 74, height: 15),
      const Radius.circular(8),
    );
    canvas.drawRRect(notch, Paint()..color = const Color(0xFFF7B733));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width / 2 - 6, 15), width: 34, height: 3.6),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF7A4708),
    );
    canvas.drawCircle(Offset(size.width / 2 + 20, 15), 2.6, Paint()..color = const Color(0xFF6B3D06));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width / 2, size.height - 12), width: 34, height: 6.5),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF8A4E09),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.18 + i * 7, size.height - 12),
        1.5,
        Paint()..color = const Color(0xFF8A4E09),
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 2.6, size.height * 0.30, 3.4, 40),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFE39412),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-0.8, size.height * 0.24, 3.4, 26), const Radius.circular(2)),
      Paint()..color = const Color(0xFFE39412),
    );
  }

  @override
  bool shouldRepaint(_PhonePainter old) => old.seconds != seconds || old.jolt != jolt || old.roll != roll;
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.seconds, required this.energy});

  final double seconds;
  final double energy;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    for (final (anchor, from, sweep) in [
      (Offset(-0.30, -0.24), math.pi * 0.84, 0.64),
      (Offset(0.30, 0.12), -0.32, 0.64),
    ]) {
      final hub = centre + Offset(anchor.dx * size.width, anchor.dy * size.height);
      for (var i = 0; i < 3; i++) {
        final phase = (seconds * 1.15 + i * 0.2) % 1.0;
        final pulse = math.sin(phase * math.pi);
        final alpha = (0.14 + 0.70 * pulse * pulse) * energy;
        if (alpha < 0.02) continue;
        final r = size.width * (0.070 + i * 0.040) + pulse * 2.5;
        canvas.drawArc(
          Rect.fromCircle(center: hub, radius: r),
          from,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6 - i * 0.45
            ..strokeCap = StrokeCap.round
            ..color = Ember.gold.withValues(alpha: alpha.clamp(0.0, 1.0)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.seconds != seconds || old.energy != energy;
}
