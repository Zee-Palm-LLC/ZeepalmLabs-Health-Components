import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';

class Composer extends StatefulWidget {
  const Composer({
    super.key,
    required this.controller,
    required this.focus,
    required this.busy,
    required this.onCamera,
    required this.onCalendar,
    required this.onSend,
    required this.onStop,
    this.cameraKey,
  });

  static const size = Size(371.6, 109.5);
  static const radius = 26.0;

  final TextEditingController controller;
  final FocusNode focus;
  final bool busy;
  final VoidCallback onCamera;
  final VoidCallback onCalendar;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final GlobalKey? cameraKey;

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> with TickerProviderStateMixin {
  late final AnimationController _busy;
  late final AnimationController _ready;
  late final AnimationController _focus;

  @override
  void initState() {
    super.initState();
    _busy = AnimationController(vsync: this, duration: const Duration(milliseconds: 700), value: widget.busy ? 1 : 0);
    _ready = AnimationController(vsync: this, duration: const Duration(milliseconds: 420), value: widget.controller.text.trim().isEmpty ? 0 : 1);
    _focus = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    widget.controller.addListener(_text);
    widget.focus.addListener(_focused);
  }

  @override
  void didUpdateWidget(Composer old) {
    super.didUpdateWidget(old);
    if (old.busy != widget.busy) {
      widget.busy ? _busy.animateTo(1, curve: gentle) : _busy.animateBack(0, duration: const Duration(milliseconds: 900), curve: gentle);
    }
  }

  void _text() {
    final ready = widget.controller.text.trim().isNotEmpty;
    if (ready && _ready.value < 1 && _ready.status != AnimationStatus.forward) {
      _ready.animateTo(1, curve: settle);
    } else if (!ready && _ready.value > 0 && _ready.status != AnimationStatus.reverse) {
      _ready.animateBack(0, duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    }
  }

  void _focused() {
    widget.focus.hasFocus ? _focus.animateTo(1, curve: gentle) : _focus.animateBack(0, curve: gentle);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_text);
    widget.focus.removeListener(_focused);
    _busy.dispose();
    _ready.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Composer.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Tick(
              builder: (context, t, _) => AnimatedBuilder(
                animation: Listenable.merge([_busy, _focus]),
                builder: (context, _) => CustomPaint(painter: _AuroraPainter(t: t, busy: _busy.value, focus: _focus.value)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 60,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.focus.requestFocus(),
            ),
          ),
          Positioned(
            left: 17,
            right: 64,
            top: 38.3 - 16.7 * interAscent,
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focus,
              style: Typo.input,
              cursorColor: Shade.coral,
              cursorWidth: 2,
              cursorRadius: const Radius.circular(2),
              cursorHeight: 20,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => widget.onSend(),
              maxLines: 1,
              decoration: InputDecoration(
                isDense: true,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: 'Ask about your day',
                hintStyle: Typo.hint,
              ),
            ),
          ),
          Positioned(
            left: 28.2 - 20,
            top: 80.6 - 20,
            child: Pressable(
              key: widget.cameraKey,
              onTap: widget.onCamera,
              scale: 0.86,
              child: const SizedBox.square(dimension: 40, child: Center(child: PhIcon(Ph.camera, size: 24, color: Color(0xFF6D6A63)))),
            ),
          ),
          Positioned(
            left: 52,
            top: 80.6 - 18,
            child: Pressable(
              onTap: widget.onCalendar,
              scale: 0.92,
              child: SizedBox(
                width: 76,
                height: 36,
                child: Stack(
                  children: [
                    const Positioned(left: 13.5 - 9, top: 18.1 - 9, child: PhIcon(Ph.calendar, size: 18, color: Color(0xFF8F8A82))),
                    Positioned(left: 27.1, top: 22 - 13.6 * interAscent, child: BaseText('Today', style: Typo.chip)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 344.3 - 17,
            top: 80.4 - 17,
            child: _SendButton(ready: _ready, busy: _busy, onSend: widget.onSend, onStop: widget.onStop),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.ready, required this.busy, required this.onSend, required this.onStop});

  final Animation<double> ready;
  final Animation<double> busy;
  final VoidCallback onSend;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      scale: 0.86,
      onTap: () {
        if (busy.value > 0.5) {
          onStop();
        } else if (ready.value > 0.5) {
          HapticFeedback.mediumImpact();
          onSend();
        }
      },
      child: Tick(
        builder: (context, t, _) => AnimatedBuilder(
          animation: Listenable.merge([ready, busy]),
          builder: (context, _) {
            final dark = math.max(ready.value.clamp(0.0, 1.0), busy.value);
            final pop = 1 + 0.08 * math.sin(ready.value.clamp(0.0, 1.0) * math.pi) * (1 - busy.value);
            final fill = Color.lerp(Shade.sendIdle, Shade.cocoa, dark)!;
            return Transform.scale(
              scale: pop,
              child: SizedBox.square(
                dimension: 34,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: fill,
                        boxShadow: [BoxShadow(color: Shade.cocoa.withValues(alpha: 0.22 * dark), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: const SizedBox.expand(),
                    ),
                    if (busy.value > 0.01)
                      Opacity(
                        opacity: busy.value,
                        child: CustomPaint(size: const Size.square(34), painter: _OrbitPainter(t)),
                      ),
                    Opacity(
                      opacity: 1 - busy.value,
                      child: Transform.translate(
                        offset: Offset(0, 3 * (1 - ready.value.clamp(0.0, 1.0)) * 0),
                        child: const PhIcon(Ph.arrowUp, size: 17, color: Colors.white),
                      ),
                    ),
                    Opacity(
                      opacity: busy.value,
                      child: Transform.scale(
                        scale: 0.6 + 0.4 * busy.value,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2.2)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: c, radius: size.width / 2 - 2.2);
    final a = t * math.pi * 2 * 0.9;
    canvas.drawArc(
      rect,
      a,
      math.pi * 0.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 2,
          transform: GradientRotation(a),
          colors: [Shade.peach.withValues(alpha: 0), Shade.apricot, Shade.peach.withValues(alpha: 0)],
          stops: const [0, 0.2, 0.35],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.t != t;
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({required this.t, required this.busy, required this.focus});

  final double t;
  final double busy;
  final double focus;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(Composer.radius));
    canvas.drawRRect(
      rrect.shift(const Offset(0, 6)),
      Paint()
        ..color = const Color(0x0E3A2A1A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [const Color(0xFFFAFAF5), const Color(0xFFFBF9F3)], [0, 1]),
    );
    canvas.save();
    canvas.clipRRect(rrect);
    final idle = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.52, size.height * 0.92),
        size.width * 0.42,
        [const Color(0xFFFFEEE0).withValues(alpha: 0.7), const Color(0x00FFEEE0)],
        [0, 1],
        TileMode.clamp,
        Matrix4.diagonal3Values(1, 0.42, 1).storage,
      );
    canvas.drawRect(rect, idle);
    if (busy > 0.001) {
      final blobs = [
        (Shade.apricot, 0.22, 0.0, 1.1),
        (Shade.peach, 0.5, 2.1, 0.8),
        (Shade.blush, 0.78, 4.2, 0.95),
        (Shade.lilac, 0.62, 1.2, 0.7),
      ];
      for (final (color, x, phase, speed) in blobs) {
        final cx = size.width * (x + 0.16 * math.sin(t * speed * 1.7 + phase));
        final cy = size.height * (0.72 + 0.22 * math.cos(t * speed * 1.3 + phase));
        final r = size.width * (0.26 + 0.05 * math.sin(t * 2 + phase));
        canvas.drawCircle(
          Offset(cx, cy),
          r,
          Paint()
            ..shader = ui.Gradient.radial(
              Offset(cx, cy),
              r,
              [color.withValues(alpha: 0.42 * busy), color.withValues(alpha: 0)],
              [0, 1],
            ),
        );
      }
    }
    canvas.restore();
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = Color.lerp(const Color(0x14000000), const Color(0x2EF7795C), focus * 0.7)!;
    canvas.drawRRect(rrect.deflate(0.45), border);
    if (busy > 0.001) {
      final sweep = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = SweepGradient(
          center: Alignment.center,
          transform: GradientRotation(t * math.pi * 1.4),
          colors: [
            Shade.peach.withValues(alpha: 0),
            Shade.peach.withValues(alpha: 0.85 * busy),
            Shade.blush.withValues(alpha: 0.7 * busy),
            Shade.lilac.withValues(alpha: 0),
            Shade.peach.withValues(alpha: 0),
          ],
          stops: const [0, 0.12, 0.24, 0.4, 1],
        ).createShader(rect);
      canvas.drawRRect(rrect.deflate(0.8), sweep);
    }
    canvas.drawRRect(
      rrect.deflate(1.6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = ui.Gradient.linear(rect.topCenter, Offset(0, size.height * 0.4), [Colors.white.withValues(alpha: 0.9), Colors.white.withValues(alpha: 0)], [0, 1]),
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t || old.busy != busy || old.focus != focus;
}
