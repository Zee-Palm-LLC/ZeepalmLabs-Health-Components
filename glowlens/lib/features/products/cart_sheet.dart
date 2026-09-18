import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';

Future<void> showCartSheet(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Bag',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 750),
    pageBuilder: (context, animation, _) => _CartSheet(animation: animation),
  );
}

class _CartSheet extends StatefulWidget {
  const _CartSheet({required this.animation});

  final Animation<double> animation;

  @override
  State<_CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<_CartSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _success;
  int _paid = 0;

  @override
  void initState() {
    super.initState();
    _success = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
  }

  @override
  void dispose() {
    _success.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    if (Bag.instance.count == 0) return;
    HapticFeedback.heavyImpact();
    setState(() => _paid = Bag.instance.total);
    await _success.forward(from: 0);
    Bag.instance.clear();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final animation = widget.animation;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final rise = animation.status == AnimationStatus.reverse
            ? Curves.easeInCubic.transform(t)
            : const Cubic(0.16, 1, 0.3, 1).transform(t);
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10 * t, sigmaY: 10 * t),
                  child: ColoredBox(color: const Color(0xFF2A1640).withValues(alpha: 0.2 * t)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FractionalTranslation(translation: Offset(0, 1 - rise), child: child),
            ),
          ],
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 22 + bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([Bag.instance, _success]),
          builder: (context, _) {
            if (_success.value > 0) return _SuccessView(progress: _success, paid: _paid);
            final items = Bag.instance.items.entries.toList();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Palette.hairline, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text('Your Bag', style: inter(19, 700, spacing: -0.4)),
                    const Spacer(),
                    Text('${Bag.instance.count} items', style: inter(12.5, 500, color: Palette.faint)),
                  ],
                ),
                const SizedBox(height: 14),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Column(
                        children: [
                          const GlyphIcon(Glyph.bag, size: 40, gradient: Palette.brand, stroke: 1.4),
                          const SizedBox(height: 10),
                          Text('Your bag is empty', style: inter(14, 600)),
                          const SizedBox(height: 4),
                          Text('Tap + on a product to add it.', style: inter(12.5, 400, color: Palette.muted)),
                        ],
                      ),
                    ),
                  ),
                for (final (i, entry) in items.indexed)
                  Entrance(
                    animation: stage(animation, 0.25 + i * 0.08, 0.75 + i * 0.06, curve: Curves.easeOutBack),
                    offset: const Offset(0, 30),
                    child: _Line(product: Catalog.byId(entry.key), quantity: entry.value),
                  ),
                if (items.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Subtotal', style: inter(14, 500, color: Palette.muted)),
                      const Spacer(),
                      TweenAnimationBuilder<double>(
                        tween: Tween(end: Bag.instance.total.toDouble()),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => Text('\$${v.round()}', style: inter(22, 700, spacing: -0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GradientPill(label: 'Checkout', glyph: Glyph.shield, onTap: _checkout),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Palette.canvas, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(product.image, width: 54, height: 54, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.brand, style: inter(10.5, 500, color: Palette.faint, spacing: 0)),
                  Text(product.name, style: inter(13.5, 600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('\$${product.price}', style: inter(13, 700, color: Palette.orchid)),
                ],
              ),
            ),
            _Stepper(id: product.id, quantity: quantity),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.id, required this.quantity});

  final String id;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    Widget button(Glyph glyph, VoidCallback onTap) => Pressable(
      onTap: onTap,
      scale: 0.8,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Center(child: GlyphIcon(glyph, size: 14, stroke: 2)),
      ),
    );
    return Row(
      children: [
        button(Glyph.minus, () => Bag.instance.remove(id)),
        SizedBox(
          width: 28,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Text('$quantity', key: ValueKey(quantity), style: inter(14, 700)),
            ),
          ),
        ),
        button(Glyph.plus, () => Bag.instance.add(id)),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.progress, required this.paid});

  final Animation<double> progress;
  final int paid;

  @override
  Widget build(BuildContext context) {
    final t = progress.value;
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _Confetti(t))),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: Curves.elasticOut.transform(window(t, 0, 0.45)),
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: const BoxDecoration(gradient: Palette.brand, shape: BoxShape.circle),
                  child: Center(
                    child: GlyphIcon(
                      Glyph.check,
                      size: 40,
                      color: Colors.white,
                      stroke: 2.6,
                      progress: window(t, 0.15, 0.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Opacity(
                opacity: window(t, 0.25, 0.45),
                child: Text('Order placed', style: inter(19, 700)),
              ),
              const SizedBox(height: 4),
              Opacity(
                opacity: window(t, 0.3, 0.5),
                child: Text('\$$paid · arriving in 2 days', style: inter(13, 400, color: Palette.muted)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Confetti extends CustomPainter {
  _Confetti(this.t);

  final double t;

  static const _colors = [Palette.violet, Palette.rose, Palette.coral, Color(0xFF9DB0F2), Color(0xFFFFD98E)];

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final origin = Offset(size.width / 2, size.height * 0.36);
    for (var i = 0; i < 40; i++) {
      final seed = math.sin(i * 12.9898) * 43758.5453;
      final r = seed - seed.floorToDouble();
      final angle = -math.pi / 2 + (r - 0.5) * math.pi * 1.8;
      final speed = 120 + r * 170;
      final time = Curves.easeOutCubic.transform(t);
      final p = origin + Offset(math.cos(angle) * speed * time, math.sin(angle) * speed * time + 220 * t * t);
      final fade = (1 - window(t, 0.6, 1)).clamp(0.0, 1.0);
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(t * (8 + r * 10) * (i.isEven ? 1 : -1));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 8, height: 4), const Radius.circular(1.5)),
        Paint()..color = _colors[i % _colors.length].withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_Confetti oldDelegate) => oldDelegate.t != t;
}
