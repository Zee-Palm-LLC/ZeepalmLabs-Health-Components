import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _heart;
  final ScrollController _scroll = ScrollController();
  bool _liked = false;
  bool _added = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
    _heart = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    _intro.dispose();
    _heart.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _like() {
    HapticFeedback.lightImpact();
    setState(() => _liked = !_liked);
    if (_liked) _heart.forward(from: 0);
  }

  void _add() {
    if (_added) return;
    HapticFeedback.mediumImpact();
    Bag.instance.add(widget.product.id);
    setState(() => _added = true);
    Toast.show(context, '${widget.product.name} added to bag', glyph: Glyph.bag);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final media = MediaQuery.of(context);
    final imageHeight = media.size.width * 1.02;
    return Scaffold(
      backgroundColor: Palette.canvas,
      body: Stack(
        children: [
          const Positioned.fill(child: Backdrop()),
          AnimatedBuilder(
            animation: _scroll,
            builder: (context, child) {
              final offset = _scroll.hasClients ? _scroll.offset : 0.0;
              final stretch = offset < 0 ? 1 + (-offset / imageHeight) : 1.0;
              return Positioned(
                top: offset > 0 ? -offset * 0.5 : 0,
                left: 0,
                right: 0,
                height: imageHeight,
                child: Transform.scale(scale: stretch, alignment: Alignment.topCenter, child: child),
              );
            },
            child: Hero(
              tag: 'product-${p.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
                child: Image.asset(p.image, fit: BoxFit.cover),
              ),
            ),
          ),
          ListView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(22, imageHeight + 20, 22, 130),
            children: [
              _stagger(0, Text(p.brand, style: inter(12, 600, color: Palette.orchid, spacing: 0.6))),
              const SizedBox(height: 6),
              _stagger(1, Text(p.name, style: inter(25, 700, spacing: -0.6, height: 1.2))),
              const SizedBox(height: 10),
              _stagger(2, _rating(p)),
              const SizedBox(height: 16),
              _stagger(
                3,
                Wrap(
                  spacing: 8,
                  children: [
                    _Tag(glyph: Glyph.check, label: p.target),
                    _Tag(
                      glyph: p.routine == Routine.morning ? Glyph.sun : Glyph.moon,
                      label: p.routine == Routine.morning ? 'Morning' : 'Evening',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _stagger(4, Text('About', style: inter(16, 700))),
              const SizedBox(height: 6),
              _stagger(5, Text(p.about, style: inter(13.5, 400, color: Palette.muted, height: 1.6))),
              const SizedBox(height: 20),
              _stagger(6, Text('Key ingredients', style: inter(16, 700))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (i, ing) in p.ingredients.indexed)
                    Entrance(
                      animation: stage(_intro, 0.5 + i * 0.07, 0.85 + i * 0.04, curve: Curves.easeOutBack),
                      offset: const Offset(0, 16),
                      scale: 0.6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Palette.hairline),
                        ),
                        child: Text(ing, style: inter(12.5, 500)),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: media.padding.top + 11,
            left: 21,
            right: 21,
            child: Row(
              children: [
                RoundButton(glyph: Glyph.back, onTap: () => Navigator.of(context).maybePop()),
                const Spacer(),
                AnimatedBuilder(
                  animation: _heart,
                  builder: (context, _) {
                    final t = _heart.value;
                    final pop = 1.0 + (t > 0 && t < 1 ? Curves.elasticOut.transform(t) * 0.25 - 0.25 * t : 0.0);
                    return Transform.scale(
                      scale: pop,
                      child: RoundButton(
                        glyph: Glyph.heart,
                        onTap: _like,
                        child: GlyphIcon(
                          _liked ? Glyph.heartFilled : Glyph.heart,
                          size: 20,
                          color: _liked ? Palette.rose : Palette.ink,
                          gradient: _liked ? Palette.brand : null,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: media.padding.bottom + 16,
            child: Entrance(
              animation: stage(_intro, 0.4, 0.9, curve: const Cubic(0.2, 0.9, 0.25, 1.1)),
              offset: const Offset(0, 80),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: const [BoxShadow(color: Color(0x1A7A4FA0), blurRadius: 26, offset: Offset(0, 10))],
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price', style: inter(11, 500, color: Palette.faint)),
                        Text('\$${p.price}', style: inter(22, 700, spacing: -0.6)),
                      ],
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: GradientPill(
                        label: _added ? 'Added to bag' : 'Add to bag',
                        glyph: _added ? Glyph.check : Glyph.bag,
                        onTap: _add,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stagger(int i, Widget child) {
    return Entrance(
      animation: stage(_intro, 0.2 + i * 0.06, 0.6 + i * 0.06),
      offset: const Offset(0, 24),
      blur: 4,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  Widget _rating(Product p) {
    return AnimatedBuilder(
      animation: _intro,
      builder: (context, _) {
        return Row(
          children: [
            for (var i = 0; i < 5; i++)
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Transform.scale(
                  scale: Curves.elasticOut.transform(window(_intro.value, 0.35 + i * 0.05, 0.75 + i * 0.05)),
                  child: GlyphIcon(
                    Glyph.star,
                    size: 16,
                    color: i < p.rating.floor() ? const Color(0xFFF5B83D) : Palette.hairline,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Text('${p.rating}', style: inter(13, 700)),
            Text('  (${p.reviews} reviews)', style: inter(12.5, 400, color: Palette.faint)),
          ],
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.glyph, required this.label});

  final Glyph glyph;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlyphIcon(glyph, size: 14, stroke: 1.8, gradient: Palette.brand),
          const SizedBox(width: 6),
          Text(label, style: inter(12, 500)),
        ],
      ),
    );
  }
}
