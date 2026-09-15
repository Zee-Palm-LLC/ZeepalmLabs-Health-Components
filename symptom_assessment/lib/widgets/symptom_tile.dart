import 'package:flutter/widgets.dart';

import '../core/design.dart';
import '../core/motion/pressable.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../data/symptoms.dart';
import 'icons/glyphs.dart';

/// One search result. Title, optional grey hint, and a green "?" badge that
/// opens a short explanation without leaving the list.
class SymptomTile extends StatelessWidget {
  const SymptomTile({
    super.key,
    required this.symptom,
    this.onTap,
    this.onInfo,
    this.tileKey,
  });

  final Symptom symptom;
  final VoidCallback? onTap;
  final VoidCallback? onInfo;
  final GlobalKey? tileKey;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.97,
      child: TileBody(key: tileKey, symptom: symptom, onInfo: onInfo),
    );
  }
}

class TileBody extends StatelessWidget {
  const TileBody({super.key, required this.symptom, this.onInfo});

  final Symptom symptom;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    final hint = symptom.hint;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          D.tilePadding, 16, D.tilePadding - 2, 16),
      decoration: BoxDecoration(
        color: Paper.white,
        borderRadius: BorderRadius.circular(D.tileRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF1F272C).withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(symptom.name, style: T.tileTitle),
                if (hint != null) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(hint, style: T.tileSub),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Pressable(
            onTap: onInfo,
            pressedScale: 0.8,
            hitTestBehavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Container(
                width: D.badge,
                height: D.badge,
                decoration: const BoxDecoration(
                  color: Leaf.base,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon2(Glyph.question, size: 13, color: Paper.white,
                      strokeWidth: 1.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
