import 'package:flutter/material.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/kitchen.dart';
import '../../core/motion.dart';
import '../../core/routes.dart';
import '../../core/type.dart';
import '../../widgets/pop_text.dart';
import '../detail/detail_screen.dart';
import '../home/recipe_card.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key, required this.entrance, required this.favorites});

  final Animation<double> entrance;
  final bool favorites;

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final _keys = <String, GlobalKey>{};

  void _open(String id) {
    final key = _keys[id]!;
    Navigator.of(context).push(MorphRoute(from: rectOf(context, key), radius: 16, builder: (_) => const DetailScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final kitchen = KitchenScope.of(context);
    final e = widget.entrance;
    final list = widget.favorites ? kitchen.favorites : recipes;
    final title = inter(30, 700, color: const Color(0xFF0A0919));
    final sub = inter(15.5, 400, color: const Color(0xFF7C7B7E));
    final top = frame.top + 18;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.5, top, 16.5, 140 + frame.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Line(widget.favorites ? 'Your favorites' : 'All recipes', title),
          const SizedBox(height: 8),
          Staged(
            animation: e,
            begin: 0.1,
            end: 0.4,
            offset: const Offset(-14, 0),
            child: Line(widget.favorites ? 'Dishes you loved, all in one place.' : 'Fresh ideas for every craving.', sub),
          ),
          const SizedBox(height: 24),
          if (list.isEmpty)
            _Empty(entrance: e)
          else
            Wrap(
              spacing: 13.4,
              runSpacing: 16,
              children: [
                for (final (i, r) in list.indexed)
                  Staged(
                    animation: e,
                    begin: 0.2 + i * 0.08,
                    end: 0.6 + i * 0.08,
                    offset: const Offset(0, 50),
                    rotateX: 0.4,
                    child: KeyedSubtree(
                      key: _keys.putIfAbsent(r.id, GlobalKey.new),
                      child: RecipeCard(recipe: r, onOpen: () => _open(r.id)),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.entrance});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Staged(
              animation: entrance,
              begin: 0.2,
              end: 0.6,
              scale: 0.4,
              child: Tick(
                builder: (context, s, child) => Transform.translate(offset: Offset(0, 5 * wave(s, 2.6)), child: child),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipOval(child: Image.asset(Art.homeAvatar.asset, fit: BoxFit.cover)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            PopText(
              text: 'Nothing here yet',
              style: inter(19, 700, color: const Color(0xFF0A0919)),
              animation: entrance,
              begin: 0.3,
              end: 0.7,
            ),
            const SizedBox(height: 6),
            Text('Tap a heart to save a recipe.', style: inter(14.5, 400, color: const Color(0xFF7C7B7E))),
          ],
        ),
      ),
    );
  }
}
