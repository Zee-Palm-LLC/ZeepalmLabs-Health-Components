import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glyphs.dart';
import 'palette.dart';
import 'type.dart';

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.94,
    this.haptic = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 320),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _c.forward(),
      onTapCancel: () => _c.reverse(),
      onTapUp: (_) => _c.reverse(),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            },
      onLongPress: widget.onLongPress == null
          ? null
          : () {
              HapticFeedback.mediumImpact();
              _c.reverse();
              widget.onLongPress!();
            },
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final v = Curves.easeOut.transform(_c.value);
          return Transform.scale(
            scale: 1 - (1 - widget.scale) * v,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class GlassCircle extends StatelessWidget {
  const GlassCircle({
    super.key,
    required this.size,
    required this.child,
    this.fill = Night.glass,
    this.border = Night.hairline,
    this.glow,
  });

  final double size;
  final Widget child;
  final Color fill;
  final Color border;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(fill, Colors.white, 0.03)!, fill],
        ),
        border: Border.all(color: border, width: 1),
        boxShadow: glow == null
            ? null
            : [BoxShadow(color: glow!, blurRadius: 18, spreadRadius: -2)],
      ),
      child: child,
    );
  }
}

class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.child,
    this.height = 34,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final double height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: Night.glass,
        border: Border.all(color: Night.hairline),
      ),
      child: child,
    );
  }
}

class Blurred extends StatelessWidget {
  const Blurred({
    super.key,
    required this.child,
    required this.radius,
    this.sigma = 18,
  });

  final Widget child;
  final BorderRadius radius;
  final double sigma;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: child,
      ),
    );
  }
}

class NightSlider extends StatefulWidget {
  const NightSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.colors = const [Color(0xFF3F63E8), Color(0xFF8FA6FF)],
  });

  final double value;
  final ValueChanged<double> onChanged;
  final List<Color> colors;

  @override
  State<NightSlider> createState() => _NightSliderState();
}

class _NightSliderState extends State<NightSlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _grab;

  @override
  void initState() {
    super.initState();
    _grab = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _grab.dispose();
    super.dispose();
  }

  void _set(Offset local, double width) {
    final v = ((local.dx - 8) / (width - 16)).clamp(0.0, 1.0);
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) {
            _grab.forward();
            _set(d.localPosition, w);
          },
          onHorizontalDragUpdate: (d) => _set(d.localPosition, w),
          onHorizontalDragEnd: (_) => _grab.reverse(),
          onTapDown: (d) {
            _grab.forward();
            _set(d.localPosition, w);
          },
          onTapUp: (_) => _grab.reverse(),
          child: SizedBox(
            height: 36,
            child: AnimatedBuilder(
              animation: _grab,
              builder: (context, _) => CustomPaint(
                size: Size(w, 36),
                painter: _SliderPainter(
                  widget.value,
                  _grab.value,
                  widget.colors,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliderPainter extends CustomPainter {
  _SliderPainter(this.value, this.grab, this.colors);

  final double value;
  final double grab;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final x0 = 8.0;
    final x1 = size.width - 8;
    final x = x0 + (x1 - x0) * value;
    final track = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..color = const Color(0x24FFFFFF);
    canvas.drawLine(Offset(x0, y), Offset(x1, y), track);
    if (x > x0 + 1) {
      final active = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4
        ..shader = ui.Gradient.linear(Offset(x0, y), Offset(x, y), [
          colors[0],
          colors[1],
        ]);
      canvas.drawLine(Offset(x0, y), Offset(x, y), active);
      canvas.drawLine(
        Offset(x0, y),
        Offset(x, y),
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 8
          ..color = colors[0].withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    final r = 7.0 + grab * 2;
    canvas.drawCircle(
      Offset(x, y),
      r + 6,
      Paint()
        ..color = colors[1].withValues(alpha: 0.35 + grab * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(
      Offset(x, y),
      r,
      Paint()..color = const Color(0xFFF7F6FF),
    );
  }

  @override
  bool shouldRepaint(_SliderPainter old) =>
      old.value != value || old.grab != grab || old.colors != colors;
}

class DeviceChrome extends StatelessWidget {
  const DeviceChrome({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        padding: const EdgeInsets.only(top: 54, bottom: 34),
        viewPadding: const EdgeInsets.only(top: 54, bottom: 34),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: child),
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 54,
            child: IgnorePointer(
              child: Material(
                type: MaterialType.transparency,
                child: _StatusBar(),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          width: 140,
          top: 0,
          bottom: 0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, left: 6),
              child: Text(
                '9:41',
                style: Typo.ui(17, weight: 600, spacing: -0.2),
              ),
            ),
          ),
        ),
        Positioned(
          top: 11,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 124,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        const Positioned(right: 26, top: 22, child: _StatusIcons()),
      ],
    );
  }
}

class _StatusIcons extends StatelessWidget {
  const _StatusIcons();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(78, 13), painter: _StatusPainter());
  }
}

class _StatusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white;
    for (var i = 0; i < 4; i++) {
      final h = 4.0 + i * 2.6;
      canvas.drawRRect(
        RRect.fromLTRBR(
          i * 4.6,
          12 - h,
          i * 4.6 + 3,
          12,
          const Radius.circular(1),
        ),
        white,
      );
    }
    final c = const Offset(31, 12.4);
    for (var i = 0; i < 3; i++) {
      final r = 3.4 + i * 3.6;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -2.36,
        1.57,
        false,
        Paint()
          ..color = Colors.white
          ..style = i == 0 ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 2.1
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx - 3.4, c.dy - 3.4)
        ..arcToPoint(
          Offset(c.dx + 3.4, c.dy - 3.4),
          radius: const Radius.circular(4.8),
        )
        ..close(),
      white,
    );
    final body = RRect.fromLTRBR(48, 0.5, 72, 12.5, const Radius.circular(3.6));
    canvas.drawRRect(
      body,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(50, 2.5, 70, 10.5, const Radius.circular(2)),
      white,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(73.4, 4.4, 75, 8.6, const Radius.circular(1)),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(_StatusPainter oldDelegate) => false;
}

class IconLabel extends StatelessWidget {
  const IconLabel({
    super.key,
    required this.glyph,
    required this.label,
    this.onTap,
    this.color = Night.text,
    this.active = false,
  });

  final G glyph;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: SizedBox(
        width: 84,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, a) => ScaleTransition(
                scale: Tween(begin: 0.6, end: 1.0).animate(a),
                child: FadeTransition(opacity: a, child: child),
              ),
              child: Glyph(
                glyph,
                key: ValueKey(glyph),
                size: 26,
                color: active ? Night.lavenderSoft : color,
                stroke: 1.7,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: Typo.ui(12.5, color: Night.textSoft, weight: 450),
            ),
          ],
        ),
      ),
    );
  }
}

class Toast {
  static OverlayEntry? _entry;

  static void dismiss() {
    _entry?.remove();
    _entry = null;
  }

  static void show(
    BuildContext context,
    String text, {
    G glyph = G.check,
    String? action,
    VoidCallback? onAction,
  }) {
    dismiss();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    void close() {
      if (_entry == entry) dismiss();
    }

    entry = OverlayEntry(
      builder: (_) => Material(
        type: MaterialType.transparency,
        child: _ToastView(
          text: text,
          glyph: glyph,
          action: action,
          onAction: onAction == null
              ? null
              : () {
                  close();
                  onAction();
                },
          onDone: close,
        ),
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.text,
    required this.glyph,
    required this.onDone,
    this.action,
    this.onAction,
  });

  final String text;
  final G glyph;
  final VoidCallback onDone;
  final String? action;
  final VoidCallback? onAction;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.action == null ? 2200 : 3400),
    )..forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 10;
    final hasAction = widget.action != null;
    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final v = _c.value;
          final span = _c.duration!.inMilliseconds;
          final inT = Curves.easeOutCubic.transform(
            (v * span / 360).clamp(0.0, 1.0),
          );
          final outT = Curves.easeInCubic.transform(
            ((v * span - (span - 380)) / 380).clamp(0.0, 1.0),
          );
          return IgnorePointer(
            ignoring: !hasAction || outT > 0,
            child: Opacity(
              opacity: inT * (1 - outT),
              child: Transform.translate(
                offset: Offset(0, -16 * (1 - inT) - 10 * outT),
                child: Transform.scale(scale: 0.96 + 0.04 * inT, child: child),
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.only(top: top),
          child: Blurred(
            radius: BorderRadius.circular(22),
            child: Container(
              height: 44,
              padding: EdgeInsets.only(left: 16, right: hasAction ? 5 : 18),
              decoration: BoxDecoration(
                color: const Color(0xD91C1A36),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Night.hairlineStrong),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Glyph(
                    widget.glyph,
                    size: 17,
                    color: Night.lavenderSoft,
                    stroke: 1.8,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.text,
                    style: Typo.ui(13.5, weight: 500, color: Night.text),
                  ),
                  if (hasAction) ...[
                    const SizedBox(width: 12),
                    Pressable(
                      onTap: widget.onAction,
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC6B8FF), Color(0xFFAE9CF6)],
                          ),
                        ),
                        child: Text(
                          widget.action!,
                          style: Typo.ui(12.5, weight: 600, color: Night.ink),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
