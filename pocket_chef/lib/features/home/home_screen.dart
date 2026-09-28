import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/canvas.dart';
import '../../core/kitchen.dart';
import '../../core/motion.dart';
import '../../core/routes.dart';
import '../../core/type.dart';
import '../detail/detail_screen.dart';
import 'categories.dart';
import 'home_header.dart';
import 'pick_card.dart';
import 'recipe_card.dart';
import 'search_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.entrance, required this.onProfile});

  static const reference = 892.9;

  final Animation<double> entrance;
  final VoidCallback onProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pick = GlobalKey();
  final _cards = [GlobalKey(), GlobalKey()];

  void _open(GlobalKey key, double radius) {
    Navigator.of(context).push(MorphRoute(from: rectOf(context, key), radius: radius, builder: (_) => const DetailScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final e = widget.entrance;
    final navRoom = frame.height - frame.drop - HomeScreen.reference + 796;
    final content = math.max(frame.height, 780 + lift + 30 + (frame.height - navRoom));
    final popular = inter(21.73, 700, color: const Color(0xFF0A0815));
    final seeAll = inter(13.4, 500, color: const Color(0xFFE0243C));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: Frame.width,
        height: content,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: lift,
              width: Frame.width,
              height: 170,
              child: HomeHeader(entrance: e, onAvatar: widget.onProfile),
            ),
            Positioned.fromRect(
              rect: SearchField.rect.shift(Offset(0, lift)),
              child: SearchField(entrance: e),
            ),
            Positioned.fromRect(
              rect: PickCard.rect.shift(Offset(0, lift)),
              child: KeyedSubtree(
                key: _pick,
                child: PickCard(entrance: e, onOpen: () => _open(_pick, PickCard.radius)),
              ),
            ),
            Positioned(
              left: 150,
              top: 425 + lift,
              width: 93,
              height: 14,
              child: _Dots(entrance: e),
            ),
            Positioned(
              left: 0,
              top: lift,
              width: Frame.width,
              height: 560,
              child: CategoryRow(entrance: e),
            ),
            Positioned(
              left: 0,
              top: lift,
              width: Frame.width,
              height: 600,
              child: Staged(
                animation: e,
                begin: 0.56,
                end: 0.86,
                offset: const Offset(0, 14),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Pin(x: 23.67, base: 588, text: 'Popular Recipes', style: popular),
                    Pin(x: 372, base: 591, text: 'See all', style: seeAll, align: TextAlign.right),
                  ],
                ),
              ),
            ),
            for (final (i, recipe) in recipes.indexed)
              Positioned(
                left: 20.5 + i * 184.7,
                top: 606.5 + lift,
                child: Staged(
                  animation: e,
                  begin: 0.62 + i * 0.07,
                  end: 0.95 + i * 0.05,
                  offset: const Offset(0, 60),
                  rotateX: 0.4,
                  child: KeyedSubtree(
                    key: _cards[i],
                    child: RecipeCard(recipe: recipe, onOpen: () => _open(_cards[i], 16)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return Staged(
      animation: entrance,
      begin: 0.62,
      end: 0.85,
      scale: 0.4,
      child: Tick(
        builder: (context, s, _) {
          final u = s / 3.2 + 1;
          final whole = u.floor();
          final f = Curves.easeInOutCubic.transform(((u - whole - 0.78) / 0.22).clamp(0.0, 1.0));
          final pos = (whole % 3) + f;
          return CustomPaint(painter: _DotsPainter(pos));
        },
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter(this.pos);

  final double pos;

  @override
  void paint(Canvas canvas, Size size) {
    const xs = [31.5, 48.25, 64.5];
    const cy = 7.0;
    final p = pos % 3;
    for (var i = 0; i < 3; i++) {
      final d = math.min((p - i).abs(), 3 - (p - i).abs());
      final k = (1 - d).clamp(0.0, 1.0);
      final w = 5.2 + 12.3 * k;
      final x = xs[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, cy), width: w, height: 5.2), const Radius.circular(2.6)),
        Paint()..color = Color.lerp(const Color(0xFFDDD8D3), const Color(0xFFCBC5C0), k)!,
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.pos != pos;
}
