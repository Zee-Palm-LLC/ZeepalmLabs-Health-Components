import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/art.dart';
import '../core/canvas.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/surfaces.dart';

class CameraLayer extends StatefulWidget {
  const CameraLayer({
    super.key,
    required this.review,
    required this.photoHidden,
    required this.onClose,
    required this.onShutter,
    required this.onRetake,
    required this.onUse,
  });

  final bool review;
  final bool photoHidden;
  final VoidCallback onClose;
  final VoidCallback onShutter;
  final VoidCallback onRetake;
  final VoidCallback onUse;

  static Rect viewfinder(double top) => Rect.fromLTWH(14, top + 70.3, 374, 498.5);

  static double controls(Frame frame) => frame.height - frame.bottom - 82;

  @override
  State<CameraLayer> createState() => _CameraLayerState();
}

class _CameraLayerState extends State<CameraLayer> with TickerProviderStateMixin {
  late final AnimationController _flash;
  late final AnimationController _mode;
  late final AnimationController _focus;
  Offset _focusAt = const Offset(0.5, 0.5);

  @override
  void initState() {
    super.initState();
    _flash = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _mode = AnimationController(vsync: this, duration: const Duration(milliseconds: 520), value: widget.review ? 1 : 0);
    _focus = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  }

  @override
  void didUpdateWidget(CameraLayer old) {
    super.didUpdateWidget(old);
    if (old.review != widget.review) {
      if (widget.review) {
        _flash.forward(from: 0);
        _mode.animateTo(1, curve: gentle);
      } else {
        _mode.animateBack(0, curve: gentle);
        _focusAt = const Offset(0.5, 0.5);
        _focus.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _flash.dispose();
    _mode.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _tapFinder(TapUpDetails d, Size size) {
    if (widget.review) return;
    HapticFeedback.selectionClick();
    setState(() => _focusAt = Offset(d.localPosition.dx / size.width, d.localPosition.dy / size.height));
    _focus.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final top = frame.top;
    final finder = CameraLayer.viewfinder(top);
    final controlsY = CameraLayer.controls(frame);
    return ColoredBox(
      color: Shade.ground,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flash, _mode, _focus]),
        builder: (context, _) {
          final m = _mode.value;
          return Stack(
            children: [
              Positioned(
                left: 40 - 22.25,
                top: top + 28.8 - 22.25,
                child: GlassCircle(icon: Ph.x, iconSize: 22, onTap: widget.onClose),
              ),
              Positioned(
                left: 100,
                right: 100,
                top: top + 33.5 - 16.8 * interAscent,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Opacity(opacity: 1 - m, child: Transform.translate(offset: Offset(0, -6 * m), child: BaseText('Meal photo', style: Typo.sheet))),
                    Opacity(opacity: m, child: Transform.translate(offset: Offset(0, 6 * (1 - m)), child: BaseText('Your photo', style: Typo.sheet))),
                  ],
                ),
              ),
              Positioned.fromRect(
                rect: finder,
                child: Opacity(
                  opacity: widget.photoHidden ? 0 : 1,
                  child: GestureDetector(
                    onTapUp: (d) => _tapFinder(d, finder.size),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Tick(
                            builder: (context, t, child) {
                              final live = 1 - m;
                              final dx = (2.2 * math.sin(t * 0.9) + 1.1 * math.sin(t * 2.3)) * live;
                              final dy = (1.8 * math.cos(t * 0.7) + 0.9 * math.sin(t * 1.9)) * live;
                              final zoom = 1 + 0.035 * live + 0.006 * math.sin(t * 0.5) * live;
                              return Transform.translate(offset: Offset(dx, dy), child: Transform.scale(scale: zoom, child: child));
                            },
                            child: Image.asset(Art.spaghetti, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
                          ),
                          if (m < 1) Opacity(opacity: 1 - m, child: _Reticle(t: _focus.value, at: _focusAt)),
                          if (m < 1) Positioned(left: 0, right: 0, bottom: 18, child: Opacity(opacity: (1 - m) * span(_focus.value, 0.55, 0.9), child: const _Seen())),
                          IgnorePointer(
                            child: Opacity(
                              opacity: _flash.value == 0 ? 0 : (_flash.value < 0.18 ? _flash.value / 0.18 : 1 - span(_flash.value, 0.18, 1, Curves.easeOut)) * 0.92,
                              child: const ColoredBox(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: controlsY - 40,
                height: 80,
                child: Stack(
                  children: [
                    IgnorePointer(
                      ignoring: m > 0.5,
                      child: Opacity(
                        opacity: 1 - span(m, 0, 0.6),
                        child: Transform.scale(
                          scale: lerp(1, 0.86, span(m, 0, 0.6)),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 55.7 - 18,
                                top: 40.5 - 21.5,
                                child: Transform.rotate(
                                  angle: -0.03,
                                  child: const SizedBox(width: 36, height: 43, child: Photo(Art.toast, radius: 7, border: 1.5)),
                                ),
                              ),
                              Positioned(left: 201 - 38, top: 2, child: _Shutter(onTap: widget.onShutter)),
                              Positioned(
                                left: 346.3 - 22,
                                top: 40 - 22,
                                child: Pressable(
                                  onTap: () => HapticFeedback.selectionClick(),
                                  child: const SizedBox.square(dimension: 44, child: Center(child: PhIcon(Ph.cameraRotate, size: 25, color: Color(0xFF6D6A63)))),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      ignoring: m < 0.5,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 31.3,
                            top: 40.5 - 26,
                            child: _ReviewPill(
                              t: span(m, 0.2, 1, Curves.linear),
                              width: 89.4,
                              label: 'Retake',
                              filled: false,
                              onTap: widget.onRetake,
                            ),
                          ),
                          Positioned(
                            left: 229.5,
                            top: 40.5 - 26,
                            child: _ReviewPill(
                              t: span(m, 0.3, 1, Curves.linear),
                              width: 141.3,
                              label: 'Use photo',
                              filled: true,
                              onTap: widget.onUse,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Reticle extends StatelessWidget {
  const _Reticle({required this.t, required this.at});

  final double t;
  final Offset at;

  @override
  Widget build(BuildContext context) {
    final appear = span(t, 0, 0.3);
    final settle = spring(span(t, 0, 0.6, Curves.linear), bounce: 0.3, freq: 2);
    final blink = t > 0.4 && t < 0.62 ? (math.sin((t - 0.4) / 0.22 * math.pi * 2) * 0.5 + 0.5) : 1.0;
    final dim = lerp(1, 0.55, span(t, 0.7, 1));
    return LayoutBuilder(
      builder: (context, box) {
        final c = Offset(box.maxWidth * at.dx, box.maxHeight * at.dy);
        final side = lerp(96, 62, settle);
        return Stack(
          children: [
            Positioned(
              left: c.dx - side / 2,
              top: c.dy - side / 2,
              width: side,
              height: side,
              child: Opacity(
                opacity: (appear * blink * dim).clamp(0.0, 1.0),
                child: CustomPaint(painter: _BracketPainter()),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;
    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final l = size.width * 0.26;
    const r = 8.0;
    final path = Path();
    for (final (x, y, sx, sy) in [(0.0, 0.0, 1.0, 1.0), (size.width, 0.0, -1.0, 1.0), (0.0, size.height, 1.0, -1.0), (size.width, size.height, -1.0, -1.0)]) {
      path
        ..moveTo(x, y + sy * l)
        ..lineTo(x, y + sy * r)
        ..quadraticBezierTo(x, y, x + sx * r, y)
        ..lineTo(x + sx * l, y);
    }
    canvas.drawPath(path, shadow);
    canvas.drawPath(path, p);
    canvas.drawCircle(size.center(Offset.zero), 2.2, Paint()..color = Colors.white.withValues(alpha: 0.9));
  }

  @override
  bool shouldRepaint(_BracketPainter old) => false;
}

class _Seen extends StatelessWidget {
  const _Seen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xB31E1C19),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tick(
              builder: (context, t, _) => Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Shade.peach,
                  boxShadow: [BoxShadow(color: Shade.peach.withValues(alpha: 0.5 + 0.4 * wave(t, 1.2)), blurRadius: 8, spreadRadius: 1)],
                ),
              ),
            ),
            const SizedBox(width: 8),
            BaseText('Spaghetti bolognese', style: inter(12.5, 500, tracking: -0.05, color: const Color(0xFFF7F4EE))),
          ],
        ),
      ),
    );
  }
}

class _Shutter extends StatefulWidget {
  const _Shutter({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_Shutter> createState() => _ShutterState();
}

class _ShutterState extends State<_Shutter> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.animateTo(1, duration: const Duration(milliseconds: 110), curve: Curves.easeOut),
      onTapCancel: () => _c.animateBack(0, curve: settle),
      onTapUp: (_) => _c.animateBack(0, duration: const Duration(milliseconds: 520), curve: settle),
      onTap: () {
        HapticFeedback.heavyImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => SizedBox.square(
          dimension: 76,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF8C8B86), width: 2.6),
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              Transform.scale(
                scale: lerp(1, 0.86, _c.value),
                child: Container(
                  width: 62.5,
                  height: 62.5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(center: Alignment(-0.3, -0.4), colors: [Color(0xFF3A3834), Color(0xFF26241F)]),
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

class _ReviewPill extends StatelessWidget {
  const _ReviewPill({required this.t, required this.width, required this.label, required this.filled, required this.onTap});

  final double t;
  final double width;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = spring(t, bounce: 0.3, freq: 2);
    return Opacity(
      opacity: span(t, 0, 0.4),
      child: Transform.translate(
        offset: Offset(0, 14 * (1 - s)),
        child: Pressable(
          onTap: onTap,
          scale: 0.93,
          child: Container(
            width: width,
            height: 52,
            decoration: filled
                ? pillDecoration(radius: 26)
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: const Color(0x66FFFFFF),
                    border: Border.all(color: const Color(0x14000000), width: 0.8),
                  ),
            child: Stack(
              children: [
                if (filled) const Positioned(left: 28.1 - 9, top: 26 - 9, child: PhIcon(Ph.check, size: 18, color: Shade.ink)),
                Positioned(
                  left: filled ? 46.2 : 20.4,
                  top: 31.5 - 15.8 * interAscent,
                  child: BaseText(label, style: Typo.action.copyWith(color: filled ? Shade.ink : Shade.soft)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
