import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';
import 'cart_sheet.dart';
import 'product_card.dart';
import 'product_detail.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> with TickerProviderStateMixin, ClockMixin {
  late final AnimationController _intro;
  late final AnimationController _bump;
  Filter _filter = Filter.all;
  final GlobalKey _cartKey = GlobalKey();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))..forward();
    _bump = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    startClock();
  }

  @override
  void dispose() {
    _intro.dispose();
    _bump.dispose();
    _scroll.dispose();
    disposeClock();
    super.dispose();
  }

  void _fly(Product product, Rect from) {
    final cart = _cartKey.currentContext?.findRenderObject() as RenderBox?;
    if (cart == null) {
      Bag.instance.add(product.id);
      return;
    }
    final to = cart.localToGlobal(cart.size.center(Offset.zero));
    final overlay = Overlay.of(context);
    final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 820));
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final t = Curves.easeInOutCubic.transform(controller.value);
          final start = from.center;
          final control = Offset((start.dx + to.dx) / 2, math.min(start.dy, to.dy) - 140);
          final p = Offset(
            (1 - t) * (1 - t) * start.dx + 2 * (1 - t) * t * control.dx + t * t * to.dx,
            (1 - t) * (1 - t) * start.dy + 2 * (1 - t) * t * control.dy + t * t * to.dy,
          );
          final size = lerp(from.width * 0.7, 18, Curves.easeInCubic.transform(controller.value));
          return Positioned(
            left: p.dx - size / 2,
            top: p.dy - size / 2,
            width: size,
            height: size,
            child: IgnorePointer(
              child: Opacity(
                opacity: 1 - window(controller.value, 0.85, 1),
                child: Transform.rotate(angle: t * math.pi * 0.9, child: child),
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x40C274EB), blurRadius: 20, offset: Offset(0, 8))],
            image: DecorationImage(image: AssetImage(product.image), fit: BoxFit.cover),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    controller.forward().whenComplete(() {
      entry.remove();
      controller.dispose();
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Bag.instance.add(product.id);
      _bump.forward(from: 0);
    });
  }

  void _open(Product product) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, _) => ProductDetail(product: product),
        transitionsBuilder: (context, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: const Interval(0, 0.5)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final width = MediaQuery.sizeOf(context).width;
    return Stack(
      children: [
        ListView(
          controller: _scroll,
          padding: EdgeInsets.fromLTRB(0, top + 66, 0, 120),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Entrance(
                    animation: stage(_intro, 0.05, 0.4),
                    offset: const Offset(0, 20),
                    blur: 8,
                    child: Text('Essentials', style: inter(24, 700, spacing: -0.5)),
                  ),
                  const SizedBox(height: 7),
                  Entrance(
                    animation: stage(_intro, 0.1, 0.45),
                    offset: const Offset(0, 14),
                    child: Text(
                      'Curated treatments for your targeted lines.',
                      style: inter(12.5, 400, color: Palette.muted),
                    ),
                  ),
                  const SizedBox(height: 19),
                  _FilterBar(value: _filter, intro: _intro, onChanged: (f) => setState(() => _filter = f)),
                  const SizedBox(height: 11),
                ],
              ),
            ),
            _grid(width),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: GlassHeader(
            scroll: _scroll,
            child: Padding(padding: const EdgeInsets.only(left: 4), child: _header()),
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return Entrance(
      animation: stage(_intro, 0, 0.35),
      offset: const Offset(0, -14),
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            Text('Products', style: inter(20, 600, spacing: -0.4)),
            const Spacer(),
            AnimatedBuilder(
              animation: Listenable.merge([_bump, Bag.instance]),
              builder: (context, child) {
                final t = _bump.value;
                final scale = 1 + math.sin(t * math.pi * 3) * (1 - t) * 0.22;
                return Transform.scale(
                  scale: scale,
                  child: RoundButton(
                    key: _cartKey,
                    glyph: Glyph.cart,
                    badge: Bag.instance.count,
                    onTap: () => showCartSheet(context),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid(double width) {
    const gap = 13.0;
    const rowGap = 15.0;
    final cardWidth = (width - 21 - 22 - gap) / 2;
    final visible = [
      for (final p in Catalog.products)
        if (p.matches(_filter)) p,
    ];
    final rows = (visible.length / 2).ceil();
    final height = rows * (ProductCard.height + rowGap);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [for (final (i, p) in Catalog.products.indexed) _slot(p, i, visible, cardWidth, gap, rowGap)],
      ),
    );
  }

  Widget _slot(Product p, int catalogIndex, List<Product> visible, double cardWidth, double gap, double rowGap) {
    final index = visible.indexOf(p);
    final shown = index >= 0;
    final place = shown ? index : catalogIndex;
    final left = 21 + (place % 2) * (cardWidth + gap);
    final top = (place ~/ 2) * (ProductCard.height + rowGap);
    return AnimatedPositioned(
      key: ValueKey(p.id),
      duration: Duration(milliseconds: 560 + place * 70),
      curve: const Cubic(0.2, 0.9, 0.25, 1.08),
      left: left,
      top: top,
      width: cardWidth,
      height: ProductCard.height,
      child: IgnorePointer(
        ignoring: !shown,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: shown ? 1 : 0),
          duration: Duration(milliseconds: shown ? 520 + place * 60 : 320),
          curve: shown ? Curves.easeOutBack : Curves.easeInCubic,
          builder: (context, v, child) => Opacity(
            opacity: v.clamp(0.0, 1.0),
            child: Transform.scale(scale: lerp(0.7, 1, v), child: child),
          ),
          child: Entrance(
            animation: stage(
              _intro,
              0.22 + catalogIndex * 0.07,
              0.72 + catalogIndex * 0.05,
              curve: const Cubic(0.2, 0.9, 0.25, 1.06),
            ),
            offset: const Offset(0, 60),
            scale: 0.92,
            child: ProductCard(product: p, clock: clock, onOpen: () => _open(p), onAdd: (rect) => _fly(p, rect)),
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatefulWidget {
  const _FilterBar({required this.value, required this.intro, required this.onChanged});

  final Filter value;
  final Animation<double> intro;
  final ValueChanged<Filter> onChanged;

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> with SingleTickerProviderStateMixin {
  late final AnimationController _move;
  late Filter _from;

  static const _widths = [58.0, 116.0, 114.0];
  static const _gap = 13.0;
  static const _height = 37.0;

  @override
  void initState() {
    super.initState();
    _from = widget.value;
    _move = AnimationController(vsync: this, duration: const Duration(milliseconds: 650), value: 1);
  }

  @override
  void didUpdateWidget(_FilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _from = oldWidget.value;
      _move.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  double _left(int i) {
    var x = 0.0;
    for (var k = 0; k < i; k++) {
      x += _widths[k] + _gap;
    }
    return x;
  }

  RRect _blob(double t) {
    final from = _from.index;
    final to = widget.value.index;
    final forward = to >= from;
    const lead = Cubic(0.2, 0.95, 0.3, 1);
    const trail = Cubic(0.75, 0, 0.3, 1);
    final l = lerp(_left(from), _left(to), (forward ? trail : lead).transform(t));
    final r = lerp(_left(from) + _widths[from], _left(to) + _widths[to], (forward ? lead : trail).transform(t));
    final stretch = ((r - l) - lerp(_widths[from], _widths[to], t)) / 60;
    final h = _height * (1 - 0.1 * stretch.clamp(0.0, 1.0));
    final y = (_height - h) / 2;
    return RRect.fromLTRBR(l, y, r, y + h, Radius.circular(h / 2));
  }

  @override
  Widget build(BuildContext context) {
    const labels = [('All', null), ('Morning', Glyph.sun), ('Evening', Glyph.moon)];
    return SizedBox(
      height: _height,
      child: AnimatedBuilder(
        animation: Listenable.merge([_move, widget.intro]),
        builder: (context, _) {
          final blob = _blob(_move.value);
          Widget chipRow(bool active) => Stack(
            children: [
              for (var i = 0; i < 3; i++)
                Positioned(
                  left: _left(i),
                  top: 0,
                  width: _widths[i],
                  height: _height,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (labels[i].$2 != null) ...[
                          GlyphIcon(labels[i].$2!, size: 17, color: active ? Colors.white : Palette.ink, stroke: 1.5),
                          const SizedBox(width: 7),
                        ],
                        Text(labels[i].$1, style: inter(13.5, 500, color: active ? Colors.white : Palette.ink)),
                      ],
                    ),
                  ),
                ),
            ],
          );
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < 3; i++)
                Positioned(
                  left: _left(i),
                  top: 0,
                  width: _widths[i],
                  height: _height,
                  child: Opacity(
                    opacity: window(widget.intro.value, 0.14 + i * 0.06, 0.45 + i * 0.06),
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        16 *
                            (1 -
                                Curves.easeOutBack.transform(
                                  window(widget.intro.value, 0.14 + i * 0.06, 0.5 + i * 0.06),
                                )),
                      ),
                      child: Pressable(
                        onTap: () => widget.onChanged(Filter.values[i]),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(_height / 2),
                            boxShadow: const [
                              BoxShadow(color: Color(0x0D7A4FA0), blurRadius: 12, offset: Offset(0, 4)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: window(widget.intro.value, 0.2, 0.5),
                    child: CustomPaint(painter: _BlobPainter(blob)),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(opacity: window(widget.intro.value, 0.2, 0.5), child: chipRow(false)),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipPath(
                    clipper: _RRectClipper(blob),
                    child: Opacity(opacity: window(widget.intro.value, 0.2, 0.5), child: chipRow(true)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter(this.blob);

  final RRect blob;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      blob.shift(const Offset(0, 5)),
      Paint()
        ..color = const Color(0x40E583C0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRRect(blob, Paint()..shader = Palette.brand.createShader(blob.outerRect));
  }

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) => oldDelegate.blob != blob;
}

class _RRectClipper extends CustomClipper<Path> {
  _RRectClipper(this.rrect);

  final RRect rrect;

  @override
  Path getClip(Size size) => Path()..addRRect(rrect);

  @override
  bool shouldReclip(_RRectClipper oldClipper) => oldClipper.rrect != rrect;
}
