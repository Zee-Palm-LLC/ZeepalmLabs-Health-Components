import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/art.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/type.dart';
import '../../widgets/rolling_number.dart';

class StreakCard extends StatefulWidget {
  const StreakCard({super.key, required this.entrance});

  static const origin = Offset(11.2, 112.0);

  final Animation<double> entrance;

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> with SingleTickerProviderStateMixin {
  final _tilt = ValueNotifier(Offset.zero);
  late final AnimationController _back;
  Offset _from = Offset.zero;

  @override
  void initState() {
    super.initState();
    _back = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..addListener(() => _tilt.value = Offset.lerp(_from, Offset.zero, settle.transform(_back.value))!);
  }

  @override
  void dispose() {
    _back.dispose();
    _tilt.dispose();
    super.dispose();
  }

  void _press(Offset local) {
    _back.stop();
    final size = Art.streakPlate.rect.size;
    final p = Offset((local.dx / size.width - 0.5) * 2, (local.dy / size.height - 0.5) * 2);
    _tilt.value = Offset(p.dx.clamp(-1.0, 1.0), p.dy.clamp(-1.0, 1.0));
  }

  void _release() {
    _from = _tilt.value;
    _back.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    const plate = Art.streakPlate;
    final o = StreakCard.origin;
    final e = widget.entrance;
    final cs = inter(13.4, 500, color: const Color(0xFFB4B1F6));
    final days = inter(30.2, 700, color: const Color(0xFFEDECFB), optical: 28);
    final risk = inter(13, 500, color: const Color(0xFFA8A4E6));
    final money = inter(22.9, 700, color: const Color(0xFFE6E6F6));

    return GestureDetector(
      onPanDown: (d) => _press(d.localPosition),
      onPanUpdate: (d) => _press(d.localPosition),
      onPanEnd: (_) => _release(),
      onPanCancel: _release,
      child: AnimatedBuilder(
        animation: Listenable.merge([_tilt, e]),
        builder: (context, child) {
          final t = span(e.value, 0.08, 0.55, gentle);
          final p = _tilt.value;
          final m = Matrix4.identity()
            ..setEntry(3, 2, 0.0011)
            ..translateByDouble(0, 46 * (1 - t), 0, 1)
            ..rotateX(0.32 * (1 - t) - p.dy * 0.09)
            ..rotateY(p.dx * 0.12)
            ..scaleByDouble(lerp(0.92, 1, t), lerp(0.92, 1, t), 1, 1);
          return Opacity(
            opacity: span(e.value, 0.08, 0.3, Curves.linear),
            child: Transform(alignment: Alignment.center, transform: m, child: child),
          );
        },
        child: SizedBox(
          width: plate.width,
          height: plate.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [BoxShadow(color: Color(0x553A2DB8), blurRadius: 26, offset: Offset(0, 10))],
                  ),
                  child: plate.image(),
                ),
              ),
              Positioned.fill(child: IgnorePointer(child: _Streaks(tilt: _tilt))),
              Positioned(
                left: Art.streakRunner.left - o.dx,
                top: Art.streakRunner.top - o.dy,
                width: Art.streakRunner.width,
                height: Art.streakRunner.height,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_tilt, e]),
                  builder: (context, child) {
                    final t = span(e.value, 0.22, 0.72, gentle);
                    final p = _tilt.value;
                    return Opacity(
                      opacity: span(e.value, 0.22, 0.4, Curves.linear),
                      child: Transform.translate(offset: Offset(40 * (1 - t) - p.dx * 3.2, -p.dy * 2.4), child: child),
                    );
                  },
                  child: Tick(
                    builder: (context, s, child) {
                      final stride = (wave(s, 0.9) - wave(0, 0.9)) * 0.9;
                      return Transform.translate(offset: Offset(0, stride), child: child);
                    },
                    child: Art.streakRunner.image(),
                  ),
                ),
              ),
              Positioned(
                left: 42 - o.dx - 12,
                top: 157.5 - o.dy - 12,
                child: Staged(
                  animation: e,
                  begin: 0.25,
                  end: 0.6,
                  scale: 0.2,
                  curve: settle,
                  alignment: Alignment.bottomCenter,
                  child: const Flicker(size: 24),
                ),
              ),
              Positioned(
                left: 61.33 - o.dx - bearing('C', cs),
                top: 151.9 - o.dy - capInset(cs),
                child: Staged(animation: e, begin: 0.26, end: 0.6, offset: const Offset(-10, 0), child: Text('Current Streak', style: cs)),
              ),
              Positioned(
                left: 32.67 - o.dx - bearing('1', days),
                top: 179 - o.dy - capInset(days),
                child: AnimatedBuilder(
                  animation: e,
                  builder: (context, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RollingNumber(text: '12', style: days, progress: span(e.value, 0.3, 0.9, Curves.linear)),
                      Opacity(opacity: span(e.value, 0.3, 0.5, Curves.linear), child: Text(' Days', style: days)),
                    ],
                  ),
                ),
              ),
              for (var i = 0; i < 6; i++)
                Positioned(
                  left: 31.2 + i * 28.26 - o.dx,
                  top: 215.5 - o.dy,
                  child: _Bar(index: i, entrance: e),
                ),
              Positioned(
                left: 31.33 - o.dx - bearing('T', risk),
                top: 247.0 - o.dy - capInset(risk),
                child: Staged(animation: e, begin: 0.4, end: 0.75, offset: const Offset(0, 8), child: Text('Today’s Risk', style: risk)),
              ),
              Positioned(
                left: 32.33 - o.dx - bearing(r'$', money),
                top: 270.3 - o.dy - capInset(money),
                child: AnimatedBuilder(
                  animation: e,
                  builder: (context, _) => RollingNumber(text: r'$18', style: money, progress: span(e.value, 0.45, 0.95, Curves.linear)),
                ),
              ),
              Positioned(
                left: 89.2 - o.dx - 10.5,
                top: 278.5 - o.dy - 10.5,
                child: Staged(
                  animation: e,
                  begin: 0.55,
                  end: 0.9,
                  scale: 0.3,
                  curve: settle,
                  child: Pressable(
                    onTap: () {},
                    child: Tick(
                      builder: (context, s, child) {
                        final nudge = math.max(0.0, wave(s, 1.8)) * 1.6;
                        return Container(
                          width: 21,
                          height: 21,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF5F52D6), Color(0xFF533CCA), Color(0xFF4A33BE)],
                            ),
                          ),
                          child: Transform.translate(offset: Offset(nudge, 0), child: child),
                        );
                      },
                      child: const Center(child: PhIcon(Ph.caretRightBold, size: 11.5, color: Color(0xFFF4ECFF))),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.index, required this.entrance});

  final int index;
  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    final lit = index < 5;
    final begin = 0.38 + index * 0.055;
    return AnimatedBuilder(
      animation: entrance,
      builder: (context, _) {
        final t = span(entrance.value, begin, begin + 0.22, settle);
        return SizedBox(
          width: 23.7,
          height: 11,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.5),
                    color: const Color(0x663F2AA6),
                  ),
                ),
              ),
              if (lit)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 23.7 * t.clamp(0.0, 1.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.5),
                      gradient: index == 4
                          ? const LinearGradient(colors: [Color(0xFFF9A441), Color(0xFFDC8BBF), Color(0xFFC593E1)])
                          : const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFC77E), Color(0xFFFFA645), Color(0xFFF79D3C)],
                              stops: [0.0, 0.45, 1.0],
                            ),
                      boxShadow: [BoxShadow(color: const Color(0x66FFA645).withValues(alpha: 0.4 * t.clamp(0.0, 1.0)), blurRadius: 6)],
                    ),
                  ),
                ),
              if (!lit)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.5),
                      gradient: const LinearGradient(colors: [Color(0xFF5A40B5), Color(0xFF6A4BBE)]),
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

class Flicker extends StatelessWidget {
  const Flicker({super.key, required this.size, this.asset = Art.fire});

  final double size;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, s, child) {
        final a = wave(s, 0.37) * 0.5 + wave(s, 0.23, 0.3) * 0.5 - (wave(0, 0.37) * 0.5 + wave(0, 0.23, 0.3) * 0.5);
        return Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..scaleByDouble(1 - a * 0.03, 1 + a * 0.06, 1, 1)
            ..rotateZ(a * 0.035),
          child: child,
        );
      },
      child: Image.asset(asset, width: size, height: size, filterQuality: FilterQuality.medium),
    );
  }
}

class _Streaks extends StatelessWidget {
  const _Streaks({required this.tilt});

  final ValueNotifier<Offset> tilt;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Tick(builder: (context, s, _) => CustomPaint(painter: _Wind(seconds: s))),
    );
  }
}

class _Wind extends CustomPainter {
  _Wind({required this.seconds});

  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    if (seconds == 0) return;
    final p = Paint()
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.plus;
    for (var i = 0; i < 9; i++) {
      final speed = 150 + (i * 37) % 90;
      final y = 40.0 + (i * 53) % 150;
      final len = 26.0 + (i * 17) % 30;
      final x = size.width + 40 - ((seconds * speed + i * 97) % (size.width * 0.72 + 80));
      if (x < size.width * 0.42) continue;
      final fade = ((x - size.width * 0.42) / 60).clamp(0.0, 1.0);
      p
        ..strokeWidth = 1.2
        ..shader = LinearGradient(
          colors: [Color.fromRGBO(255, 235, 255, 0.34 * fade), const Color(0x00FFFFFF)],
        ).createShader(Rect.fromLTWH(x, y, len, 1));
      canvas.drawLine(Offset(x, y), Offset(x + len, y), p);
    }
  }

  @override
  bool shouldRepaint(_Wind old) => old.seconds != seconds;
}
