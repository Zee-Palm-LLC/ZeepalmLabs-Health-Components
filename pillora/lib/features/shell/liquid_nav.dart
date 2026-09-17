import 'package:flutter/material.dart';

import '../../core/icons/glyphs.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';

class LiquidNav extends StatefulWidget {
  const LiquidNav({super.key, required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const width = 252.0;
  static const height = 65.0;
  static const item = 55.0;
  static const inset = 5.0;

  @override
  State<LiquidNav> createState() => _LiquidNavState();
}

class _LiquidNavState extends State<LiquidNav> with SingleTickerProviderStateMixin {
  late final AnimationController _move;
  late int _from;
  late int _to;

  static const _glyphs = [Glyph.home, Glyph.calendar, Glyph.care, Glyph.settings];

  @override
  void initState() {
    super.initState();
    _from = widget.index;
    _to = widget.index;
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

  static double left(int i) {
    const gap = (LiquidNav.width - LiquidNav.inset * 2 - LiquidNav.item * 4) / 3;
    return LiquidNav.inset + i * (LiquidNav.item + gap);
  }

  RRect _blob(double t) {
    final fromLeft = left(_from);
    final toLeft = left(_to);
    final forward = _to >= _from;
    const lead = Cubic(0.25, 0.9, 0.3, 1);
    const trail = Cubic(0.7, 0, 0.35, 1);
    final leftEdge = lerp(fromLeft, toLeft, (forward ? trail : lead).transform(t));
    final rightEdge = lerp(fromLeft + LiquidNav.item, toLeft + LiquidNav.item, (forward ? lead : trail).transform(t));
    final stretch = ((rightEdge - leftEdge) - LiquidNav.item) / LiquidNav.item;
    final squash = LiquidNav.item * (1 - 0.14 * stretch.clamp(0.0, 1.0));
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
          final t = _move.value;
          final blob = _blob(t);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: CustomPaint(painter: _NavPainter(blob))),
              for (var i = 0; i < 4; i++)
                Positioned(
                  left: left(i),
                  top: LiquidNav.inset,
                  width: LiquidNav.item,
                  height: LiquidNav.item,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.onSelect(i),
                    child: _icon(i, false, t),
                  ),
                ),
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipPath(
                    clipper: _BlobClipper(blob),
                    child: Stack(
                      children: [
                        for (var i = 0; i < 4; i++)
                          Positioned(
                            left: left(i),
                            top: LiquidNav.inset,
                            width: LiquidNav.item,
                            height: LiquidNav.item,
                            child: _icon(i, true, t),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _icon(int i, bool active, double t) {
    final arriving = i == _to ? Curves.elasticOut.transform(window(t, 0.3, 1)) : 1.0;
    final glyph = active && i == 0 ? Glyph.homeFilled : _glyphs[i];
    return Center(
      child: Transform.scale(
        scale: lerp(0.6, 1, arriving),
        child: GlyphIcon(
          glyph,
          size: 23,
          color: active ? const Color(0xFF0E1213) : const Color(0xE6FFFFFF),
          stroke: 1.55,
        ),
      ),
    );
  }
}

class _NavPainter extends CustomPainter {
  _NavPainter(this.blob);

  final RRect blob;

  @override
  void paint(Canvas canvas, Size size) {
    final shape = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.height / 2));
    canvas.drawRRect(
      shape.shift(const Offset(0, 10)),
      Paint()
        ..color = const Color(0x40163E42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawRRect(shape, Paint()..color = Palette.navBar);
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(_LiquidNavState.left(i) + LiquidNav.item / 2, size.height / 2),
        LiquidNav.item / 2,
        Paint()..color = Palette.navItem,
      );
    }
    canvas.drawRRect(
      blob.shift(const Offset(0, 3)),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(blob, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_NavPainter oldDelegate) => oldDelegate.blob != blob;
}

class _BlobClipper extends CustomClipper<Path> {
  _BlobClipper(this.blob);

  final RRect blob;

  @override
  Path getClip(Size size) => Path()..addRRect(blob);

  @override
  bool shouldReclip(_BlobClipper oldClipper) => oldClipper.blob != blob;
}
