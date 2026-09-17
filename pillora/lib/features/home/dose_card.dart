import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/icons/glyphs.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/text_styles.dart';
import '../../data/medications.dart';

class DoseCard extends StatefulWidget {
  const DoseCard({
    super.key,
    required this.dayIndex,
    required this.medication,
    required this.taken,
    required this.dayLabel,
    required this.onToggle,
  });

  final int dayIndex;
  final Medication medication;
  final bool taken;
  final String dayLabel;
  final VoidCallback onToggle;

  @override
  State<DoseCard> createState() => _DoseCardState();
}

class _DoseCardState extends State<DoseCard> with SingleTickerProviderStateMixin {
  late final AnimationController _swap;
  Widget? _outgoing;
  int _direction = 1;

  @override
  void initState() {
    super.initState();
    _swap = AnimationController(vsync: this, duration: const Duration(milliseconds: 620), value: 1);
  }

  @override
  void didUpdateWidget(DoseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dayIndex != widget.dayIndex) {
      _direction = widget.dayIndex > oldWidget.dayIndex ? 1 : -1;
      _outgoing = _content(oldWidget, interactive: false);
      _swap.forward(from: 0).whenComplete(() {
        if (mounted) setState(() => _outgoing = null);
      });
    }
  }

  @override
  void dispose() {
    _swap.dispose();
    super.dispose();
  }

  Widget _content(DoseCard source, {required bool interactive}) {
    return _DoseFace(
      key: ValueKey(source.dayIndex),
      medication: source.medication,
      dayLabel: source.dayLabel,
      taken: source.taken,
      onToggle: interactive ? source.onToggle : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.deepCard,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x29154044), blurRadius: 22, offset: Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.hardEdge,
        child: AnimatedBuilder(
          animation: _swap,
          builder: (context, _) {
            final t = _outgoing == null ? 1.0 : Curves.easeInOutCubic.transform(_swap.value);
            return Stack(
              children: [
                if (_outgoing != null)
                  KeyedSubtree(
                    key: const ValueKey('outgoing'),
                    child: Opacity(
                      opacity: (1 - t * 1.6).clamp(0.0, 1.0),
                      child: Transform(
                        alignment: _direction > 0 ? Alignment.centerLeft : Alignment.centerRight,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0014)
                          ..translateByDouble(-_direction * 60 * t, 0, 0, 1)
                          ..rotateY(_direction * 0.55 * t),
                        child: _outgoing,
                      ),
                    ),
                  ),
                KeyedSubtree(
                  key: const ValueKey('incoming'),
                  child: Opacity(
                    opacity: ((t - 0.2) * 1.6).clamp(0.0, 1.0),
                    child: Transform(
                      alignment: _direction > 0 ? Alignment.centerRight : Alignment.centerLeft,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0014)
                        ..translateByDouble(_direction * 80 * (1 - t), 0, 0, 1)
                        ..rotateY(-_direction * 0.5 * (1 - t)),
                      child: _content(widget, interactive: true),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DoseFace extends StatefulWidget {
  const _DoseFace({super.key, required this.medication, required this.dayLabel, required this.taken, this.onToggle});

  final Medication medication;
  final String dayLabel;
  final bool taken;
  final VoidCallback? onToggle;

  @override
  State<_DoseFace> createState() => _DoseFaceState();
}

class _DoseFaceState extends State<_DoseFace> with TickerProviderStateMixin {
  late final AnimationController _fill;
  late final AnimationController _hop;
  late final AnimationController _burst;

  @override
  void initState() {
    super.initState();
    _fill = AnimationController(vsync: this, duration: const Duration(milliseconds: 900), value: widget.taken ? 1 : 0);
    _hop = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  }

  @override
  void didUpdateWidget(_DoseFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taken != widget.taken) {
      if (widget.taken) {
        _fill.forward();
        _hop.forward(from: 0);
        _burst.forward(from: 0);
      } else {
        _fill.reverse();
      }
    }
  }

  @override
  void dispose() {
    _fill.dispose();
    _hop.dispose();
    _burst.dispose();
    super.dispose();
  }

  void _toggle() {
    if (widget.onToggle == null) return;
    HapticFeedback.mediumImpact();
    widget.onToggle!();
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.medication;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Chip(child: Text(widget.dayLabel, style: _chipText)),
              const Spacer(),
              AnimatedBuilder(
                animation: _fill,
                builder: (context, _) {
                  final done = _fill.value > 0.5;
                  return _Chip(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(animation),
                          child: child,
                        ),
                      ),
                      child: Row(
                        key: ValueKey(done),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GlyphIcon(
                            done ? Glyph.check : Glyph.bell,
                            size: 15,
                            color: const Color(0xE6FFFFFF),
                            stroke: 1.5,
                          ),
                          const SizedBox(width: 6),
                          Text(done ? 'Done' : med.time, style: _chipText),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: Palette.tealChip, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _hop,
                      builder: (context, child) {
                        final t = _hop.value;
                        final jump = math.sin(math.min(t / 0.55, 1) * math.pi) * -12;
                        final spin = Curves.easeOutBack.transform(math.min(t / 0.6, 1)) * math.pi * 2;
                        return Transform.translate(
                          offset: Offset(0, jump),
                          child: Transform.rotate(angle: spin, child: child),
                        );
                      },
                      child: med.shape == PillShape.capsule ? const CapsuleArt(size: 24) : const TabletArt(size: 24),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      med.count,
                      style: const TextStyle(
                        fontFamily: TextStyles.family,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xE6FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.title.copyWith(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const GlyphIcon(Glyph.bowl, size: 15, color: Color(0x99FFFFFF), stroke: 1.3),
                        const SizedBox(width: 6),
                        Text(
                          med.timing,
                          style: TextStyles.caption.copyWith(color: const Color(0x99FFFFFF), fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _TakenButton(fill: _fill, burst: _burst, onTap: widget.onToggle == null ? null : _toggle),
        ],
      ),
    );
  }
}

const _chipText = TextStyle(
  fontFamily: TextStyles.family,
  fontSize: 13,
  fontWeight: FontWeight.w500,
  color: Color(0xE6FFFFFF),
  height: 1.2,
);

class _Chip extends StatelessWidget {
  const _Chip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 31,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Palette.tealChip, borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }
}

class _TakenButton extends StatelessWidget {
  const _TakenButton({required this.fill, required this.burst, this.onTap});

  final Animation<double> fill;
  final Animation<double> burst;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      haptic: false,
      child: SizedBox(
        height: 42,
        child: AnimatedBuilder(
          animation: Listenable.merge([fill, burst]),
          builder: (context, _) {
            final f = Curves.easeInOutCubic.transform(fill.value);
            final check = window(fill.value, 0.45, 0.95, Curves.easeOutCubic);
            final done = fill.value > 0.5;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: CustomPaint(painter: _LiquidFillPainter(f))),
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: done ? lerp(0.6, 1, Curves.elasticOut.transform(check)) : 1,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Color.lerp(Colors.white, Palette.deep, f),
                            shape: BoxShape.circle,
                          ),
                          child: GlyphIcon(
                            Glyph.check,
                            size: 18,
                            color: Color.lerp(Palette.deep, Colors.white, f)!,
                            stroke: 2.1,
                            progress: done ? check : 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ClipRect(
                        child: SizedBox(
                          height: 22,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.translate(
                                offset: Offset(0, -22 * f),
                                child: Opacity(
                                  opacity: (1 - f).clamp(0.0, 1.0),
                                  child: Text(
                                    'Taken',
                                    style: TextStyles.label.copyWith(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0, 22 * (1 - f)),
                                child: Opacity(
                                  opacity: f.clamp(0.0, 1.0),
                                  child: Text(
                                    'Dose taken at 9:41',
                                    style: TextStyles.label.copyWith(color: Palette.deep, fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (burst.value > 0 && burst.value < 1)
                  Positioned.fill(
                    child: IgnorePointer(child: CustomPaint(painter: _BurstPainter(burst.value))),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LiquidFillPainter extends CustomPainter {
  _LiquidFillPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final shape = RRect.fromRectAndRadius(Offset.zero & size, radius);
    canvas.drawRRect(shape, Paint()..color = Palette.teal);

    if (progress > 0) {
      canvas.save();
      canvas.clipRRect(shape);
      final front = size.width * 1.2 * progress - size.width * 0.1;
      final wobble = math.sin(progress * math.pi) * 10;
      final wave = Path()..moveTo(0, 0);
      wave.lineTo(front - wobble, 0);
      wave.cubicTo(
        front + wobble * 1.6,
        size.height * 0.33,
        front - wobble * 1.6,
        size.height * 0.66,
        front + wobble,
        size.height,
      );
      wave.lineTo(0, size.height);
      wave.close();
      canvas.drawPath(
        wave,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFBFE6DE), Color(0xFFD9F2EC)],
          ).createShader(Offset.zero & size),
      );
      canvas.restore();
    }

    final rim = RRect.fromRectAndRadius(Rect.fromLTWH(0.5, -2.5, size.width - 1, size.height + 2), radius);
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5 + 2));
    canvas.drawRRect(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..shader = LinearGradient(
          colors: [
            const Color(0x00FFFFFF),
            Colors.white.withValues(alpha: 0.9 - progress * 0.5),
            Colors.white.withValues(alpha: 0.9 - progress * 0.5),
            const Color(0x00FFFFFF),
          ],
          stops: const [0, 0.16, 0.84, 1],
        ).createShader(Offset.zero & size),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LiquidFillPainter oldDelegate) => oldDelegate.progress != progress;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t);

  final double t;

  static const _colors = [
    Color(0xFFEF4F58),
    Color(0xFFA9D3F0),
    Color(0xFFCFEDE7),
    Color(0xFFF8D8BC),
    Color(0xFFFFFFFF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 22; i++) {
      final seed = math.sin(i * 12.9898) * 43758.5453;
      final r = seed - seed.floorToDouble();
      final angle = -math.pi / 2 + (r - 0.5) * math.pi * 1.5 + (i.isEven ? 0.2 : -0.2);
      final speed = 70 + r * 110;
      final time = Curves.easeOutCubic.transform(t);
      final gravity = 90 * t * t;
      final p = origin + Offset(math.cos(angle) * speed * time * 1.4, math.sin(angle) * speed * time + gravity);
      final fade = (1 - t).clamp(0.0, 1.0);
      final paint = Paint()..color = _colors[i % _colors.length].withValues(alpha: fade);
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(t * (6 + r * 8) * (i.isEven ? 1 : -1));
      if (i % 3 == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 9, height: 4), const Radius.circular(2)),
          paint,
        );
      } else if (i % 3 == 1) {
        canvas.drawCircle(Offset.zero, 2.2, paint);
      } else {
        final star = Path();
        for (var k = 0; k < 4; k++) {
          final a = k * math.pi / 2;
          star.moveTo(0, 0);
          star.lineTo(math.cos(a) * 4.5, math.sin(a) * 4.5);
        }
        canvas.drawPath(
          star,
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..strokeCap = StrokeCap.round,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => oldDelegate.t != t;
}
