import 'package:flutter/widgets.dart';

import '../core/design.dart';
import '../core/motion/pressable.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../data/symptoms.dart';

/// A "popular search" chip: a white disc with the 3D emoji, then the label.
class SymptomChip extends StatelessWidget {
  const SymptomChip({
    super.key,
    required this.symptom,
    this.onTap,
    this.chipKey,
    this.selected = false,
  });

  final Symptom symptom;
  final VoidCallback? onTap;
  final GlobalKey? chipKey;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.93,
      child: ChipBody(key: chipKey, symptom: symptom, selected: selected),
    );
  }
}

/// The chip's look, separated so a flying copy can be drawn in an overlay
/// without the gesture layer.
class ChipBody extends StatelessWidget {
  const ChipBody({super.key, required this.symptom, this.selected = false});

  final Symptom symptom;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: D.chipHeight,
      padding: const EdgeInsets.only(left: 6, right: 16),
      decoration: BoxDecoration(
        color: selected ? Leaf.soft : Paper.chip,
        borderRadius: BorderRadius.circular(D.chipHeight / 2),
        border: Border.all(
          color: selected ? Leaf.border : Paper.edge,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: D.chipIcon,
            height: D.chipIcon,
            decoration: BoxDecoration(
              color: Paper.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF1F272C).withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: symptom.emoji == null
                  ? const SizedBox.shrink()
                  : Image.asset(
                      symptom.emojiAsset,
                      width: D.chipEmoji,
                      height: D.chipEmoji,
                      filterQuality: FilterQuality.medium,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Text(symptom.name, style: T.chip),
        ],
      ),
    );
  }
}
