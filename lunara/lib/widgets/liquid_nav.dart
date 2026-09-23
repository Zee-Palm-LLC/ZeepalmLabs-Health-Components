import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/theme.dart';

class LiquidNav extends StatefulWidget {
  const LiquidNav({super.key, required this.index, required this.onSelect});

  static const width = 268.0;
  static const height = 64.0;
  static const item = 54.0;
  static const inset = 5.0;

  static const glyphs = [Glyph.moon, Glyph.plus, Glyph.chart, Glyph.user];

  final int index;
  final ValueChanged<int> onSelect;

  @override
  State<LiquidNav> createState() => _LiquidNavState();
}

class _LiquidNavState extends State<LiquidNav> with SingleTickerProviderStateMixin {
  late final AnimationController _move;
  late int _from = widget.index;
  late int _to = widget.index;

  @override
  void initState() {
    super.initState();
    _move = AnimationController(vsync: this, duration: const Duration(milliseconds: 720), value: 1);
  }

  @override
  void didUpdateWidget(LiquidNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _from = oldWidget.index;
      _to = widget.index;
      _move.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  static double _left(int i) {
    const gap = (LiquidNav.width - LiquidNav.inset * 2 - LiquidNav.item * 4) / 3;
    return LiquidNav.inset + i * (LiquidNav.item + gap);
  }

  RRect _blob(double t) {
    final fromLeft = _left(_from);
    final toLeft = _left(_to);
    final forward = _to >= _from;
    const lead = Cubic(0.25, 0.9, 0.3, 1);
    const trail = Cubic(0.7, 0, 0.35, 1);
    final leftEdge = lerp(fromLeft, toLeft, (forward ? trail : lead).transform(t));
    final rightEdge = lerp(fromLeft + LiquidNav.item, toLeft + LiquidNav.item, (forward ? lead : trail).transform(t));
    final stretch = ((rightEdge - leftEdge) - LiquidNav.item) / LiquidNav.item;
    final squash = LiquidNav.item * (1 - 0.16 * stretch.clamp(0.0, 1.0));
    final top = LiquidNav.inset + (LiquidNav.item - squash) / 2;
    return RRect.fromLTRBR(leftEdge, top, rightEdge, top + squash, Radius.circular(squash / 2));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: LiquidNav.width,
      height: LiquidNav.height,
      child: AnimatedBuilder(
        animation: _move,
        builder: (context, _) {
          final blob = _blob(Curves.linear.transform(_move.value));
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Hue.deep,
                    borderRadius: BorderRadius.circular(LiquidNav.height / 2),
                    boxShadow: [
                      BoxShadow(color: Hue.night.withValues(alpha: 0.34), blurRadius: 26, offset: const Offset(0, 12)),
                    ],
                  ),
                ),
              ),
              Positioned.fill(child: CustomPaint(painter: _BlobPainter(blob))),
              Positioned.fill(child: _icons(Colors.white.withValues(alpha: 0.5), null)),
              Positioned.fill(child: _icons(Hue.deep, blob)),
              for (var i = 0; i < 4; i++)
                Positioned(
                  left: _left(i),
                  top: LiquidNav.inset,
                  width: LiquidNav.item,
                  height: LiquidNav.item,
                  child: Pressable(onTap: () => widget.onSelect(i), scale: 0.88, child: const SizedBox.expand()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _icons(Color tone, RRect? clip) {
    final row = IgnorePointer(
      child: Stack(
        children: [
          for (var i = 0; i < 4; i++)
            Positioned(
              left: _left(i),
              top: LiquidNav.inset,
              width: LiquidNav.item,
              height: LiquidNav.item,
              child: Center(child: GlyphIcon(LiquidNav.glyphs[i], size: 22, color: tone, stroke: 2)),
            ),
        ],
      ),
    );
    if (clip == null) return row;
    return ClipPath(clipper: _BlobClipper(clip), child: row);
  }
}

class _BlobPainter extends CustomPainter {
  const _BlobPainter(this.blob);

  final RRect blob;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      blob.shift(const Offset(0, 3)),
      Paint()
        ..color = Hue.rose.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawRRect(blob, Paint()..shader = warmGradient.createShader(blob.outerRect));
    canvas.drawRRect(
      blob.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.3),
    );
  }

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) => oldDelegate.blob != blob;
}

class _BlobClipper extends CustomClipper<Path> {
  const _BlobClipper(this.blob);

  final RRect blob;

  @override
  Path getClip(Size size) => Path()..addRRect(blob);

  @override
  bool shouldReclip(_BlobClipper oldClipper) => oldClipper.blob != blob;
}
