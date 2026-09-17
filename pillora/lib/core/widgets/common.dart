import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../icons/glyphs.dart';
import '../motion/motion.dart';
import '../theme/palette.dart';
import '../theme/text_styles.dart';

class CircleButton extends StatelessWidget {
  const CircleButton({
    super.key,
    required this.glyph,
    this.onTap,
    this.size = 52,
    this.iconSize = 22,
    this.background = Palette.surface,
    this.foreground = Palette.ink,
    this.badge = false,
    this.swingTrigger,
  });

  final Glyph glyph;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color background;
  final Color foreground;
  final bool badge;
  final int? swingTrigger;

  @override
  Widget build(BuildContext context) {
    Widget icon = GlyphIcon(glyph, size: iconSize, color: foreground);
    if (swingTrigger != null) {
      icon = Swing(trigger: swingTrigger!, child: icon);
    }
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: background == Palette.surface
              ? const [BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 6))]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            icon,
            if (badge)
              Positioned(
                top: size * 0.27,
                right: size * 0.3,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Palette.alert,
                    shape: BoxShape.circle,
                    border: Border.all(color: background, width: 1.4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FakeStatusBar extends StatelessWidget {
  const FakeStatusBar({super.key, this.color = Colors.white});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: Padding(
        padding: const EdgeInsets.only(left: 34, right: 26, top: 6),
        child: Row(
          children: [
            Text(
              '9:41',
              style: TextStyle(
                fontFamily: TextStyles.family,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: -0.2,
                decoration: TextDecoration.none,
              ),
            ),
            const Spacer(),
            SizedBox(width: 68, height: 13, child: CustomPaint(painter: _StatusIcons(color))),
          ],
        ),
      ),
    );
  }
}

class _StatusIcons extends CustomPainter {
  _StatusIcons(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color;
    for (var i = 0; i < 4; i++) {
      final h = 4.0 + i * 2.6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(i * 4.6, size.height - h - 0.5, 3, h), const Radius.circular(1)),
        fill,
      );
    }
    final wifi = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    const centre = Offset(28.5, 12);
    for (var i = 0; i < 3; i++) {
      final r = 3.2 + i * 3.4;
      if (i == 0) {
        canvas.drawCircle(centre.translate(0, -1.6), 1.6, fill);
        continue;
      }
      canvas.drawArc(Rect.fromCircle(center: centre, radius: r), -math.pi * 0.77, math.pi * 0.54, false, wifi);
    }
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(40, 0.5, 24, 12), const Radius.circular(3.6));
    canvas.drawRRect(
      body,
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(42, 2.5, 20, 8), const Radius.circular(2)), fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(65, 4.5, 1.6, 4), const Radius.circular(1)),
      Paint()..color = color.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(_StatusIcons oldDelegate) => oldDelegate.color != color;
}

class Toast {
  static void show(BuildContext context, String message, {Glyph glyph = Glyph.check}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastView(message: message, glyph: glyph, onDone: () => entry.remove()),
    );
    overlay.insert(entry);
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({required this.message, required this.glyph, required this.onDone});

  final String message;
  final Glyph glyph;
  final VoidCallback onDone;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 8;
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value * 2600;
              final enter = Curves.elasticOut.transform((t / 700).clamp(0.0, 1.0));
              final leave = Curves.easeInCubic.transform(((t - 2200) / 400).clamp(0.0, 1.0));
              return Opacity(
                opacity: (1 - leave).clamp(0.0, 1.0) * (t / 160).clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, lerp(-40, 0, enter) - leave * 30),
                  child: Transform.scale(scale: lerp(0.7, 1, enter), child: child),
                ),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 18, 8),
                decoration: BoxDecoration(
                  color: Palette.deep,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(color: Color(0xFFCFEDE7), shape: BoxShape.circle),
                      child: Center(child: GlyphIcon(widget.glyph, size: 16, color: Palette.deep, stroke: 2)),
                    ),
                    const SizedBox(width: 10),
                    Text(widget.message, style: TextStyles.label.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
