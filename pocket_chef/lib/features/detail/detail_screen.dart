import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/glyphs.dart';
import '../../core/kitchen.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../widgets/chef_hat.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/pop_text.dart';
import 'cook_sheet.dart';
import 'detail_parts.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  static const reference = 890.05;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _in;
  final _scroll = ScrollController();
  final _done = <int>{};

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..forward();
  }

  @override
  void dispose() {
    _in.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _cook() {
    HapticFeedback.mediumImpact();
    showCookSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final e = _in;
    double low(double y) => frame.height - frame.drop - (DetailScreen.reference - y);
    final ctaTop = low(794.2);
    final content = math.max(frame.height, 780.0 + lift + (frame.height - ctaTop) + 16);

    final chip = inter(13.2, 500, color: const Color(0xFFDA2E40));
    final title = inter(27.03, 700, color: const Color(0xFF0B0A1C));
    final meta = inter(14.5, 400, color: const Color(0xFF78787E));
    final desc = inter(14.5, 400, color: const Color(0xFF77767B));
    final value = inter(13.8, 600, color: const Color(0xFF2E2C31));
    final unit = inter(13.4, 400, color: const Color(0xFF858288));
    final heading = inter(17.75, 700, color: const Color(0xFF0D0B12));
    final link = inter(12.2, 500, color: const Color(0xFFE0243C));
    final name = inter(14.0, 400, color: const Color(0xFF28262C));
    final amount = inter(12.9, 400, color: const Color(0xFF979596));

    final sheet = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 21.5,
          top: 287.3,
          child: Staged(
            animation: e,
            begin: 0.3,
            end: 0.6,
            scale: 0.5,
            child: Container(
              width: 70,
              height: 27.7,
              decoration: BoxDecoration(color: const Color(0xFFFDE3E4), borderRadius: BorderRadius.circular(13.85)),
              child: Stack(
                children: [Pin(x: 39.33 - 21.5, base: 305.67 - 287.3, text: 'Italian', style: chip)],
              ),
            ),
          ),
        ),
        Positioned(
          left: Art.detailBasil.left,
          top: Art.detailBasil.top,
          child: Staged(
            animation: e,
            begin: 0.42,
            end: 0.8,
            scale: 0.2,
            rotateZ: 1.6,
            child: Tick(
              builder: (context, s, child) => Transform.translate(
                offset: Offset(0, 2.2 * wave(s, 3.8)),
                child: Transform.rotate(angle: 0.12 * wave(s, 4.6), child: child),
              ),
              child: Art.detailBasil.image(),
            ),
          ),
        ),
        Positioned(
          left: 23.67 - bearing('C', title),
          top: 352.33 - 100,
          child: Baseline(
            baseline: 100,
            baselineType: TextBaseline.alphabetic,
            child: PopText(text: 'Creamy Pasta', style: title, animation: e, begin: 0.32, end: 0.64, rise: 18, spin: 0.14),
          ),
        ),
        Positioned.fill(
          child: Staged(
            animation: e,
            begin: 0.42,
            end: 0.72,
            offset: const Offset(0, 12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  left: 31.3 - 11.5,
                  top: 381.0 - 11.5,
                  child: PhIcon(Ph.clock, size: 23, color: Color(0xFF26252B)),
                ),
                Pin(x: 51.67, base: 386.33, text: '20 min', style: meta),
                const Positioned(
                  left: 146.6 - 11,
                  top: 381.0 - 11,
                  child: ChefHat(size: 22, color: Color(0xFF26252B), stroke: 1.8),
                ),
                Pin(x: 165.67, base: 386.33, text: 'Easy', style: meta),
                const Positioned(
                  left: 244.2 - 11.5,
                  top: 380.9 - 11.5,
                  child: PhIcon(Ph.usersBold, size: 23, color: Color(0xFF26252B)),
                ),
                Pin(x: 263.33, base: 386.33, text: '2 servings', style: meta),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: _Wipe(
            animation: e,
            begin: 0.5,
            end: 0.82,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Pin(x: 23.0, base: 420.67, text: 'A creamy, cheesy pasta dish made with', style: desc),
                Pin(x: 23.2, base: 441.33, text: 'simple ingredients. Perfect for a quick', style: desc),
                Pin(x: 23.0, base: 461.0, text: 'and delicious meal!', style: desc),
              ],
            ),
          ),
        ),
        for (final (i, (x0, x1, icon, n, suffix, label, vx)) in [
          (17.5, 131.0, Art.nutFlame, 480, '', 'kcal', 72.9),
          (140.8, 259.0, Art.nutProtein, 18, ' g', 'protein', 198.1),
          (269.6, 375.6, Art.nutCarbs, 62, ' g', 'carbs', 325.5),
        ].indexed)
          Positioned(
            left: x0,
            top: 480.3,
            child: AnimatedBuilder(
              animation: e,
              builder: (context, child) {
                final raw = ((e.value - 0.5 - i * 0.06) / 0.32).clamp(0.0, 1.0);
                final s = spring(raw, bounce: 0.45, freq: 2.4);
                return Opacity(
                  opacity: (raw * 4).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - s)),
                    child: Transform.scale(scale: lerp(0.7, 1, s), child: child),
                  ),
                );
              },
              child: Container(
                width: x1 - x0,
                height: 61.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F2EE),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFF1ECE7), width: 0.8),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: icon.left - x0,
                      top: icon.top - 480.3,
                      width: icon.width,
                      height: icon.height,
                      child: _Throb(index: i, child: icon.image()),
                    ),
                    Positioned(
                      left: vx - x0 - bearing(n.toString(), value),
                      top: 506.2 - 480.3 - 100,
                      child: Baseline(
                        baseline: 100,
                        baselineType: TextBaseline.alphabetic,
                        child: CountUp(animation: e, value: n, suffix: suffix, style: value, begin: 0.52 + i * 0.05),
                      ),
                    ),
                    Pin(x: vx - x0, base: 525.0 - 480.3, text: label, style: unit),
                  ],
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: Staged(
            animation: e,
            begin: 0.58,
            end: 0.86,
            offset: const Offset(0, 10),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Pin(x: 24.0, base: 580.0, text: 'Ingredients', style: heading),
                Pin(x: 370.33, base: 583.67, text: 'View all', style: link, align: TextAlign.right),
              ],
            ),
          ),
        ),
        for (final (i, (thumb, label, qty, base, left, right)) in [
          (Art.ingPasta, 'Pasta', '200 g', 616.0, 76.67, 369.6),
          (Art.ingCream, 'Fresh Cream', '1/2 cup', 652.3, 76.67, 369.6),
          (Art.ingParmesan, 'Parmesan Cheese', '1/4 cup', 689.4, 76.33, 369.3),
          (Art.ingGarlic, 'Garlic', '2 cloves', 727.5, 75.67, 368.3),
          (Art.ingOil, 'Olive Oil', '1 tbsp', 764.2, 75.0, 368.6),
        ].indexed)
          _IngredientRow(
            entrance: e,
            index: i,
            thumb: thumb,
            label: label,
            qty: qty,
            base: base,
            left: left,
            right: right,
            name: name,
            amount: amount,
            done: _done.contains(i),
            last: i == 4,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _done.contains(i) ? _done.remove(i) : _done.add(i));
            },
          ),
      ],
    );

    return Scaffold(
      backgroundColor: Palette.paper,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: Frame.width,
                height: content,
                child: AnimatedBuilder(
                  animation: _scroll,
                  builder: (context, child) {
                    final pull = _scroll.hasClients ? math.max(0.0, -_scroll.offset) : 0.0;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 0,
                          top: -pull,
                          width: Frame.width,
                          height: 330 + lift + pull,
                          child: _Hero(entrance: e, lift: lift, pull: pull),
                        ),
                        child!,
                      ],
                    );
                  },
                  child: Positioned.fill(
                    child: AnimatedBuilder(
                      animation: e,
                      builder: (context, child) {
                        final raw = ((e.value - 0.05) / 0.55).clamp(0.0, 1.0);
                        final s = spring(raw, bounce: 0.4, freq: 2.2);
                        final wobble = 26 * math.sin(raw * math.pi * 2.4) * (1 - raw);
                        return Transform.translate(
                          offset: Offset(0, 180 * (1 - s)),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 0,
                                top: lift,
                                width: Frame.width,
                                height: content - lift,
                                child: ClipPath(
                                  clipper: SheetClipper(wobble),
                                  child: const DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Color(0xFFFCFAF6), Color(0xFFFCF9F5), Color(0xFFFDF4EE)],
                                        stops: [0.0, 0.8, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: Art.detailBowl.left,
                                top: Art.detailBowl.top + lift - 180 * (1 - s),
                                width: Art.detailBowl.width,
                                height: Art.detailBowl.height,
                                child: Opacity(opacity: s.clamp(0.0, 1.0), child: Art.detailBowl.image()),
                              ),
                              Positioned(left: 0, top: lift, width: Frame.width, height: 800, child: child!),
                            ],
                          ),
                        );
                      },
                      child: sheet,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 40.64 - 22,
            top: 87 - 22 + lift,
            child: Staged(
              animation: e,
              begin: 0.2,
              end: 0.5,
              scale: 0.3,
              child: _RoundButton(icon: Ph.arrowLeftBold, size: 23, onTap: () => Navigator.of(context).maybePop()),
            ),
          ),
          Positioned(
            left: 354.46 - 22,
            top: 87.08 - 22 + lift,
            child: Staged(animation: e, begin: 0.26, end: 0.56, scale: 0.3, child: const _LikeButton()),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: ctaTop - 22,
            bottom: 0,
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00FCFAF6), Color(0xFFFCF9F5)],
                    stops: [0.0, 0.42],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 23.8,
            top: ctaTop,
            child: Staged(
              animation: e,
              begin: 0.66,
              end: 1,
              offset: const Offset(0, 70),
              child: GlowButton(
                width: 346.8,
                height: 58.5,
                arrowX: 305.2 - 23.8,
                onTap: _cook,
                labelShift: 17,
                leadingX: 125.2 - 23.8,
                leading: const ChefHat(size: 24.5, color: Colors.white, stripe: Color(0xFFFD2A45)),
                label: Text('Start Cooking', style: inter(17.6, 700, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.entrance, required this.lift, required this.pull});

  final Animation<double> entrance;
  final double lift;
  final double pull;

  @override
  Widget build(BuildContext context) {
    final h = 330 + lift;
    return AnimatedBuilder(
      animation: entrance,
      builder: (context, child) {
        final t = span(entrance.value, 0, 0.7, Curves.easeOutCubic);
        final zoom = lerp(1.14, 1, t) * (1 + pull / h);
        return ClipRect(
          child: Transform.scale(scale: zoom, alignment: Alignment.topCenter, child: child),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 0, top: lift, width: Frame.width, height: 330, child: Art.detailHero.image()),
          if (lift > 0)
            Positioned(
              left: 0,
              top: 0,
              width: Frame.width,
              height: lift + 0.5,
              child: ClipRect(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(1, -1, 1),
                  child: Image.asset(Art.detailHero.asset, fit: BoxFit.fitWidth, alignment: Alignment.topCenter),
                ),
              ),
            ),
          Positioned(
            left: 0,
            top: 312 + lift,
            width: Frame.width,
            height: 19,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00FCFAF6), Color(0xFFFCFAF6)],
                ),
              ),
            ),
          ),
          Positioned(left: 128, top: 150 + lift, width: 70, height: 70, child: const GrinderDust()),
          Positioned(left: 40, top: 150 + lift, width: 240, height: 80, child: const BowlSteam()),
        ],
      ),
    );
  }
}

class _Throb extends StatelessWidget {
  const _Throb({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, s, child) {
        final u = ((s + index * 0.8) % 4.2) / 4.2;
        final k = u < 0.16 ? math.sin(u / 0.16 * math.pi) : 0.0;
        return Transform(alignment: Alignment.bottomCenter, transform: Matrix4.diagonal3Values(1 + 0.1 * k, 1 + 0.14 * k, 1), child: child);
      },
      child: child,
    );
  }
}

class _Wipe extends StatelessWidget {
  const _Wipe({required this.animation, required this.begin, required this.end, required this.child});

  final Animation<double> animation;
  final double begin;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = span(animation.value, begin, end, Curves.easeOutCubic);
        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Colors.white, Colors.white, Color(0x00FFFFFF)],
            stops: [0, math.max(0.0, t * 1.1 - 0.1), t * 1.1],
          ).createShader(Rect.fromLTRB(0, 400, rect.width, 470)),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.entrance,
    required this.index,
    required this.thumb,
    required this.label,
    required this.qty,
    required this.base,
    required this.left,
    required this.right,
    required this.name,
    required this.amount,
    required this.done,
    required this.last,
    required this.onTap,
  });

  final Animation<double> entrance;
  final int index;
  final Sprite thumb;
  final String label;
  final String qty;
  final double base;
  final double left;
  final double right;
  final TextStyle name;
  final TextStyle amount;
  final bool done;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final top = thumb.top;
    final nameWidth = (TextPainter(
      text: TextSpan(text: label, style: name),
      textDirection: TextDirection.ltr,
    )..layout()).width;
    return Positioned(
      left: 0,
      top: top,
      width: Frame.width,
      height: thumb.height,
      child: Staged(
        animation: entrance,
        begin: 0.6 + index * 0.04,
        end: 0.84 + index * 0.04,
        offset: const Offset(60, 0),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (!last)
                Positioned(
                  left: 76,
                  right: 23,
                  top: base + 18.4 - top,
                  height: 0.8,
                  child: const ColoredBox(color: Color(0xFFF0EBE6)),
                ),
              Positioned(
                left: thumb.left,
                top: 0,
                width: thumb.width,
                height: thumb.height,
                child: AnimatedScale(
                  scale: done ? 0.86 : 1,
                  duration: const Duration(milliseconds: 420),
                  curve: settle,
                  child: AnimatedOpacity(opacity: done ? 0.55 : 1, duration: const Duration(milliseconds: 300), child: thumb.image()),
                ),
              ),
              Positioned(
                left: 53,
                top: 30,
                child: AnimatedScale(
                  scale: done ? 1 : 0,
                  duration: const Duration(milliseconds: 460),
                  curve: settle,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Palette.tomato),
                    child: const Center(child: PhIcon(Ph.check, size: 11, color: Colors.white)),
                  ),
                ),
              ),
              Pin(x: left, base: base - top, text: label, style: name),
              Positioned(
                left: left,
                top: base - top - 4.6,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: done ? 1 : 0),
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) => Container(width: nameWidth * t, height: 1.4, color: const Color(0xFF333136)),
                ),
              ),
              Pin(x: right, base: base + 0.4 - top, text: qty, style: amount, align: TextAlign.right),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.size, required this.onTap});

  final IconData icon;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.88,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFBFDFE),
          boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 3))],
        ),
        child: Center(
          child: PhIcon(icon, size: size, color: const Color(0xFF141318)),
        ),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton();

  @override
  Widget build(BuildContext context) {
    final kitchen = KitchenScope.of(context);
    final liked = kitchen.liked('pasta');
    return TweenAnimationBuilder<double>(
      key: ValueKey(liked),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 620),
      builder: (context, t, child) {
        final pop = 1 + math.sin(t * math.pi) * 0.3 * (1 - t);
        return Transform.scale(scale: pop, child: child);
      },
      child: _RoundButton(icon: liked ? Ph.heartFill : Ph.heart, size: 26, onTap: () => kitchen.toggle('pasta')),
    );
  }
}
