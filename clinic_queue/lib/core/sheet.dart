import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'glyphs.dart';
import 'theme.dart';
import 'widgets.dart';

class SheetLayer extends StatefulWidget {
  const SheetLayer({super.key, required this.sheet, required this.onDismiss});

  final Widget? sheet;
  final VoidCallback onDismiss;

  @override
  State<SheetLayer> createState() => _SheetLayerState();
}

class _SheetLayerState extends State<SheetLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  Widget? _shown;
  double _drag = 0;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _sync();
  }

  @override
  void didUpdateWidget(SheetLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.sheet != null) {
      _shown = widget.sheet;
      _drag = 0;
      _c.forward();
    } else if (_shown != null) {
      _c.reverse().whenComplete(() {
        if (mounted && widget.sheet == null) setState(() => _shown = null);
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = _shown;
    if (shown == null) return const SizedBox.shrink();
    final scope = CanvasScope.of(context);
    return Positioned.fill(
      left: -scope.bleed,
      right: -scope.bleed,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = _c.value;
          final slide = _c.status == AnimationStatus.reverse
              ? Curves.easeInCubic.transform(t)
              : Curves.easeOutCubic.transform(t);
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onDismiss,
                  child: ColoredBox(color: Color.fromRGBO(8, 30, 29, 0.42 * t)),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FractionalTranslation(
                  translation: Offset(0, 1 - slide),
                  child: Transform.translate(offset: Offset(0, _drag), child: child),
                ),
              ),
            ],
          );
        },
        child: GestureDetector(
          onVerticalDragUpdate: (d) => setState(() => _drag = math.max(0, _drag + d.delta.dy)),
          onVerticalDragEnd: (d) {
            if (_drag > 90 || d.velocity.pixelsPerSecond.dy > 500) {
              widget.onDismiss();
            } else {
              setState(() => _drag = 0);
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFBFDFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Color(0x260F3B3A), blurRadius: 30, offset: Offset(0, -8))],
            ),
            padding: EdgeInsets.only(bottom: math.max(scope.bottomInset, 12) + 8),
            child: Center(
              heightFactor: 1,
              child: SizedBox(
                width: DesignCanvas.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(color: const Color(0xFFD5E3DF), borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(height: 14),
                    shown,
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

class SheetTitle extends StatelessWidget {
  const SheetTitle({super.key, required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: jakarta(21, 800, spacing: -0.6, height: 1.2)),
          const SizedBox(height: 4),
          Text(caption, style: jakarta(13, 500, color: Hue.gray, height: 1.35)),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.glyph, required this.label, required this.value, this.tone = Hue.teal});

  final Glyph glyph;
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: tone.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(11)),
            alignment: Alignment.center,
            child: GlyphIcon(glyph, size: 16, color: tone, stroke: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: jakarta(13, 600, color: Hue.gray)),
          ),
          Text(value, style: jakarta(13.5, 800)),
        ],
      ),
    );
  }
}

class ToastLayer extends StatelessWidget {
  const ToastLayer({super.key, required this.message, required this.serial});

  final String? message;
  final int serial;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 54,
      child: IgnorePointer(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 380),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, -0.6), end: Offset.zero).animate(animation),
              child: child,
            ),
          ),
          child: message == null
              ? const SizedBox(key: ValueKey('none'))
              : Center(
                  key: ValueKey(serial),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 9, 16, 9),
                    decoration: BoxDecoration(
                      color: Hue.ink,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [BoxShadow(color: Color(0x400F3B3A), blurRadius: 18, offset: Offset(0, 8))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: Hue.live, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const GlyphIcon(Glyph.check, size: 12, color: Colors.white, stroke: 2.6),
                        ),
                        const SizedBox(width: 9),
                        Text(message!, style: jakarta(12.5, 700, color: Colors.white, spacing: -0.1)),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
