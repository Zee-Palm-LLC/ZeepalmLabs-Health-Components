import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/glyphs.dart';
import '../../core/kitchen.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe, required this.onOpen, this.imageKey});

  static const size = Size(171.3, 173.5);
  static const imageHeight = 104.1;

  final Recipe recipe;
  final VoidCallback onOpen;
  final GlobalKey? imageKey;

  @override
  Widget build(BuildContext context) {
    final kitchen = KitchenScope.of(context);
    final liked = kitchen.liked(recipe.id);
    final title = inter(14.55, 600, color: const Color(0xFF14131A));
    final rating = inter(12.7, 500, color: const Color(0xFF333235));
    final count = inter(12.4, 400, color: const Color(0xFF8E8C8F));
    final chip = inter(11.6, 600, color: const Color(0xFF28282E));
    return Pressable(
      onTap: onOpen,
      scale: 0.97,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: const Color(0xFFFEFBF7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x14704A30), blurRadius: 18, offset: Offset(0, 8)),
            BoxShadow(color: Color(0x08704A30), blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              width: size.width,
              height: imageHeight,
              child: ClipRRect(
                key: imageKey,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(9),
                  bottomRight: Radius.circular(9),
                ),
                child: Tick(
                  builder: (context, s, child) => Transform.scale(scale: 1.02 + 0.02 * wave(s, 9, recipe.minutes / 20), child: child),
                  child: recipe.photo.image(fit: BoxFit.cover),
                ),
              ),
            ),
            Positioned(
              left: 150.94 - 13.3,
              top: 20.41 - 13.3,
              child: _Heart(liked: liked, onTap: () => kitchen.toggle(recipe.id)),
            ),
            Positioned(
              left: 9.0,
              top: 90.5,
              child: Container(
                width: 68.5,
                height: 21.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFCFB),
                  borderRadius: BorderRadius.circular(10.75),
                  boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned(
                      left: 12.2 - 7.5,
                      top: 11.3 - 7.5,
                      child: PhIcon(Ph.clockBold, size: 15, color: Color(0xFF28282E)),
                    ),
                    Pin(x: 25.2, base: 15.3, text: '${recipe.minutes} min', style: chip),
                  ],
                ),
              ),
            ),
            Pin(x: 12.5, base: 134.2, text: recipe.title, style: title),
            const Positioned(
              left: 20.3 - 8,
              top: 152.3 - 8,
              child: PhIcon(Ph.star, size: 16, color: Palette.star),
            ),
            Pin(x: 32.8, base: 157.5, text: recipe.rating, style: rating),
            Pin(x: 56.8, base: 157.8, text: recipe.reviews, style: count),
          ],
        ),
      ),
    );
  }
}

class _Heart extends StatefulWidget {
  const _Heart({required this.liked, required this.onTap});

  final bool liked;
  final VoidCallback onTap;

  @override
  State<_Heart> createState() => _HeartState();
}

class _HeartState extends State<_Heart> with SingleTickerProviderStateMixin {
  late final AnimationController _burst;

  @override
  void initState() {
    super.initState();
    _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 820), value: 1);
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_Heart old) {
    super.didUpdateWidget(old);
    if (widget.liked && !old.liked) _burst.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: SizedBox.square(
        dimension: 26.6,
        child: AnimatedBuilder(
          animation: _burst,
          builder: (context, _) {
            final t = _burst.value;
            final pop = t < 1 ? 1 + math.sin(t * math.pi) * 0.35 * (1 - t) : 1.0;
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 26.6,
                  height: 26.6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xF2FFFFFF),
                    boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 2))],
                  ),
                ),
                if (t < 1) CustomPaint(size: const Size.square(26.6), painter: _BurstPainter(t)),
                Transform.scale(
                  scale: pop,
                  child: PhIcon(widget.liked ? Ph.heartFill : Ph.heartBold, size: 18, color: const Color(0xFF1B1A24)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final ring = Curves.easeOut.transform(t);
    canvas.drawCircle(
      c,
      8 + 14 * ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - ring)
        ..color = Palette.tomato.withValues(alpha: 1 - ring),
    );
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + 0.3;
      final d = 10 + 16 * ring;
      final p = c + Offset(math.cos(a), math.sin(a)) * d;
      canvas.drawCircle(
        p,
        2.4 * (1 - ring),
        Paint()..color = (i.isEven ? Palette.tomato : const Color(0xFFFFB020)).withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}
