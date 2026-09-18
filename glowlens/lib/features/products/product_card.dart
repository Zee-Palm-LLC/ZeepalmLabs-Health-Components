import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/catalog.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product, required this.clock, required this.onOpen, required this.onAdd});

  final Product product;
  final ValueNotifier<double> clock;
  final VoidCallback onOpen;
  final void Function(Rect imageRect) onAdd;

  static const height = 317.0;
  static const imageHeight = 166.0;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with TickerProviderStateMixin {
  late final AnimationController _tiltBack;
  late final AnimationController _added;
  Offset _tilt = Offset.zero;
  final GlobalKey _imageKey = GlobalKey();

  static const _spring = SpringDescription(mass: 1, stiffness: 300, damping: 16);

  @override
  void initState() {
    super.initState();
    _tiltBack = AnimationController.unbounded(vsync: this)..addListener(() => setState(() {}));
    _added = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _tiltBack.dispose();
    _added.dispose();
    super.dispose();
  }

  void _aim(Offset local, Size size) {
    _tiltBack.stop();
    _tiltBack.value = 1;
    setState(() {
      _tilt = Offset(
        (local.dx / size.width * 2 - 1).clamp(-1.0, 1.0),
        (local.dy / size.height * 2 - 1).clamp(-1.0, 1.0),
      );
    });
  }

  void _release() {
    _tiltBack.animateWith(SpringSimulation(_spring, _tiltBack.value, 0, 0));
  }

  void _add() {
    HapticFeedback.lightImpact();
    _added.forward(from: 0);
    final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final origin = box.localToGlobal(Offset.zero);
    widget.onAdd(origin & box.size);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final amount = _tiltBack.value;
    final tilt = _tilt * amount;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, ProductCard.height);
        return Listener(
          onPointerDown: (e) => _aim(e.localPosition, size),
          onPointerMove: (e) => _aim(e.localPosition, size),
          onPointerUp: (_) => _release(),
          onPointerCancel: (_) => _release(),
          child: GestureDetector(
            onTap: widget.onOpen,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(-tilt.dy * 0.12)
                ..rotateY(tilt.dx * 0.14)
                ..scaleByDouble(1 - amount * 0.025, 1 - amount * 0.025, 1, 1),
              child: Container(
                height: ProductCard.height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x127A4FA0),
                      blurRadius: 18 + amount * 10,
                      offset: Offset(tilt.dx * -6, 8 + tilt.dy * -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: ProductCard.imageHeight,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Hero(
                              tag: 'product-${p.id}',
                              child: ClipRRect(
                                key: _imageKey,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                child: Transform.translate(
                                  offset: Offset(-tilt.dx * 5, -tilt.dy * 4),
                                  child: Transform.scale(
                                    scale: 1.06,
                                    child: Image.asset(p.image, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: RoutineBadge(routine: p.routine, clock: widget.clock),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.brand,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: inter(11.5, 500, color: Palette.inkSoft, spacing: 0),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: 42,
                              child: Text(
                                p.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: inter(15, 700, height: 1.38, spacing: -0.3),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                p.target,
                                maxLines: 1,
                                style: inter(11.5, 400, color: Palette.muted, spacing: 0),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Text('\$${p.price}', style: inter(17, 700, spacing: -0.4)),
                                const Spacer(),
                                _AddButton(progress: _added, onTap: _add),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.progress, required this.onTap});

  final Animation<double> progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.8,
      haptic: false,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          final t = progress.value;
          final on = t > 0 && t < 1;
          final morph = on ? Curves.easeOutBack.transform(window(t, 0, 0.25)) * (1 - window(t, 0.8, 1)) : 0.0;
          return Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: Color.lerp(Palette.button, Palette.good, morph),
              shape: BoxShape.circle,
              gradient: morph > 0.01 ? Palette.brand : null,
            ),
            child: Transform.rotate(
              angle: morph * math.pi,
              child: Center(
                child: morph > 0.5
                    ? GlyphIcon(Glyph.check, size: 16, color: Colors.white, stroke: 2.2, progress: window(t, 0.1, 0.35))
                    : const GlyphIcon(Glyph.plus, size: 15, color: Colors.white, stroke: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RoutineBadge extends StatelessWidget {
  const RoutineBadge({super.key, required this.routine, required this.clock, this.size = 28});

  final Routine routine;
  final ValueNotifier<double> clock;
  final double size;

  @override
  Widget build(BuildContext context) {
    final morning = routine == Routine.morning;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Center(
        child: ValueListenableBuilder<double>(
          valueListenable: clock,
          builder: (context, s, child) {
            final angle = morning ? s * 0.6 : math.sin(s * 1.4) * 0.22;
            return Transform.rotate(angle: angle, child: child);
          },
          child: morning
              ? GlyphIcon(Glyph.sun, size: size * 0.58, stroke: 1.5, gradient: Palette.brand)
              : GlyphIcon(Glyph.moon, size: size * 0.55, stroke: 1.6),
        ),
      ),
    );
  }
}
