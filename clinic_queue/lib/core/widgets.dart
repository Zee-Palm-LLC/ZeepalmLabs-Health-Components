import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'glyphs.dart';
import 'motion.dart';
import 'theme.dart';

class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.background, required this.child});

  static const width = 393.0;
  static const height = 852.0;
  static const statusAllowance = 50.0;
  static const breathing = 12.0;
  static const barHeight = 64.0;
  static const minBarInset = 10.0;
  static const contentFloor = 766.5;

  final Widget background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        final insets = EdgeInsets.only(
          top: math.max(media.viewPadding.top, media.padding.top),
          bottom: math.max(media.viewPadding.bottom, media.padding.bottom),
        );
        var scale = math.min(w / width, h / height);
        for (var i = 0; i < 3; i++) {
          final top = math.max(0.0, insets.top / scale - statusAllowance);
          final bar = barHeight + math.max(insets.bottom / scale, minBarInset);
          final lift = math.max(0.0, contentFloor + breathing + bar - height);
          scale = math.min(w / width, h / (height + top + lift));
        }
        final shiftTop = math.max(0.0, insets.top / scale - statusAllowance);
        final canvasHeight = h / scale - shiftTop;
        final scope = CanvasScope(
          height: canvasHeight,
          bottomInset: insets.bottom / scale,
          bleed: (w / scale - width) / 2,
          child: MediaQuery(
            data: media.copyWith(
              padding: EdgeInsets.zero,
              viewPadding: EdgeInsets.zero,
              textScaler: TextScaler.noScaling,
            ),
            child: child,
          ),
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            background,
            FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: w / scale,
                height: h / scale,
                child: Padding(
                  padding: EdgeInsets.only(top: shiftTop),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(width: width, height: canvasHeight, child: scope),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CanvasScope extends InheritedWidget {
  const CanvasScope({
    super.key,
    required this.height,
    required this.bottomInset,
    required this.bleed,
    required super.child,
  });

  final double height;
  final double bottomInset;
  final double bleed;

  double get barInset => math.max(bottomInset, DesignCanvas.minBarInset);
  double get barTop => height - DesignCanvas.barHeight - barInset;

  static CanvasScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CanvasScope>()!;

  double pin(double designGap) {
    final gap = math.max(designGap, bottomInset + DesignCanvas.breathing);
    return (height - DesignCanvas.height) - (gap - designGap);
  }

  @override
  bool updateShouldNotify(CanvasScope oldWidget) {
    return oldWidget.height != height || oldWidget.bottomInset != bottomInset || oldWidget.bleed != bleed;
  }
}

class Label extends StatelessWidget {
  const Label(
    this.text, {
    super.key,
    required this.left,
    required this.top,
    required this.style,
    this.width,
    this.align,
  });

  final String text;
  final double left;
  final double top;
  final TextStyle style;
  final double? width;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      child: Text(text, style: style, textAlign: align, softWrap: width != null),
    );
  }
}

TextStyle caps(double size, {Color color = Hue.gray, double tracking = 0.16, double weight = 800, double? height}) {
  return jakarta(size, weight, color: color, spacing: size * tracking, height: height);
}

class TealButton extends StatelessWidget {
  const TealButton({
    super.key,
    required this.label,
    this.onTap,
    this.trailing,
    this.leading,
    this.height = 60,
    this.halo = true,
  });

  final String label;
  final VoidCallback? onTap;
  final Glyph? trailing;
  final Glyph? leading;
  final double height;
  final bool halo;

  @override
  Widget build(BuildContext context) {
    final r = height / 2;
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r + 7),
          boxShadow: halo
              ? [
                  const BoxShadow(color: Color(0x5914B8A6), blurRadius: 26, offset: Offset(0, 14)),
                  const BoxShadow(color: Color(0xB3D2F1EC), spreadRadius: 6, blurRadius: 6),
                ]
              : [const BoxShadow(color: Color(0x4014B8A6), blurRadius: 22, offset: Offset(0, 12))],
        ),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF0F766E), Color(0xFF0C645D), Color(0xFF0B5550)],
              stops: [0, 0.55, 1],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(r),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withValues(alpha: 0.10), Colors.white.withValues(alpha: 0)],
                      stops: const [0, 0.5],
                    ),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading != null) ...[
                      GlyphIcon(leading!, size: 16, color: Colors.white, stroke: 2.4),
                      const SizedBox(width: 10),
                    ],
                    Text(label, style: jakarta(16, 800, color: Colors.white, spacing: -0.32)),
                    if (trailing != null) ...[
                      const SizedBox(width: 10),
                      GlyphIcon(trailing!, size: 17, color: Colors.white, stroke: 2.2),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotchClipper extends CustomClipper<Path> {
  const NotchClipper({required this.radius, required this.notch, this.vertical = true, required this.at});

  final double radius;
  final double notch;
  final bool vertical;
  final double at;

  @override
  Path getClip(Size size) {
    final card = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    final holes = Path();
    if (vertical) {
      holes.addOval(Rect.fromCircle(center: Offset(at, 0), radius: notch));
      holes.addOval(Rect.fromCircle(center: Offset(at, size.height), radius: notch));
    } else {
      holes.addOval(Rect.fromCircle(center: Offset(0, at), radius: notch));
      holes.addOval(Rect.fromCircle(center: Offset(size.width, at), radius: notch));
    }
    return Path.combine(PathOperation.difference, card, holes);
  }

  @override
  bool shouldReclip(NotchClipper oldClipper) {
    return oldClipper.radius != radius ||
        oldClipper.notch != notch ||
        oldClipper.at != at ||
        oldClipper.vertical != vertical;
  }
}

class ShadowPath extends CustomPainter {
  const ShadowPath(
    this.clipper, {
    this.color = const Color(0x140F3B3A),
    this.blur = 22,
    this.offset = const Offset(0, 10),
  });

  final CustomClipper<Path> clipper;
  final Color color;
  final double blur;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    final path = clipper.getClip(size).shift(offset);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur / 2),
    );
  }

  @override
  bool shouldRepaint(ShadowPath oldDelegate) => false;
}

class DashedLine extends StatelessWidget {
  const DashedLine({
    super.key,
    this.vertical = false,
    this.color = Hue.line,
    this.dash = 4,
    this.gap = 4,
    this.thickness = 1,
  });

  final bool vertical;
  final Color color;
  final double dash;
  final double gap;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DashPainter(vertical, color, dash, gap, thickness));
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.vertical, this.color, this.dash, this.gap, this.thickness);

  final bool vertical;
  final Color color;
  final double dash;
  final double gap;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    final length = vertical ? size.height : size.width;
    for (var d = 0.0; d < length; d += dash + gap) {
      final e = math.min(d + dash, length);
      if (vertical) {
        canvas.drawLine(Offset(size.width / 2, d), Offset(size.width / 2, e), paint);
      } else {
        canvas.drawLine(Offset(d, size.height / 2), Offset(e, size.height / 2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => false;
}

class Glow extends StatelessWidget {
  const Glow({super.key, required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(size: Size.square(radius * 2), painter: _GlowPainter(color)),
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      size.width / 2,
      Paint()..shader = ui.Gradient.radial(c, size.width / 2, [color, color.withValues(alpha: 0)]),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) => oldDelegate.color != color;
}
