import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/icons/glyphs.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/text_styles.dart';
import '../../data/medications.dart';

Future<void> showReminderSheet(BuildContext context, {required Set<String> taken}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Reminders',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 820),
    pageBuilder: (context, animation, secondary) => _ReminderSheet(animation: animation, taken: taken),
  );
}

class _ReminderSheet extends StatelessWidget {
  const _ReminderSheet({required this.animation, required this.taken});

  final Animation<double> animation;
  final Set<String> taken;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    const items = [Cabinet.omeprazole, Cabinet.metformin, Cabinet.amlodipine, Cabinet.amoxicillin, Cabinet.vitaminD];
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
                  filter: ui.ImageFilter.blur(sigmaX: 8 * t, sigmaY: 8 * t),
                  child: ColoredBox(color: const Color(0xFF0B2224).withValues(alpha: 0.35 * t)),
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
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
          decoration: const BoxDecoration(
            color: Palette.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Palette.mistDeep, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(child: Text("Today's reminders", style: TextStyles.section)),
                  Text('${items.length} doses', style: TextStyles.caption),
                ],
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < items.length; i++)
                Entrance(
                  animation: stage(animation, 0.25 + i * 0.08, 0.7 + i * 0.06, curve: Curves.easeOutCubic),
                  offset: const Offset(0, 30),
                  child: _ReminderRow(
                    medication: items[i],
                    done: i < 2 || taken.contains(items[i].name),
                    last: i == items.length - 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.medication, required this.done, required this.last});

  final Medication medication;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                const SizedBox(height: 14),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: done ? Palette.deep : Palette.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: done ? Palette.deep : Palette.mistDeep, width: 2),
                  ),
                  child: done ? const GlyphIcon(Glyph.check, size: 14, color: Colors.white, stroke: 2.2) : null,
                ),
                if (!last) Expanded(child: Container(width: 2, color: done ? Palette.deep : Palette.mistDeep)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Palette.mist, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    medication.shape == PillShape.capsule ? const CapsuleArt(size: 26) : const TabletArt(size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(medication.title, style: TextStyles.label.copyWith(fontSize: 14)),
                          Text(medication.timing, style: TextStyles.caption.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(
                      medication.time,
                      style: TextStyles.label.copyWith(color: done ? Palette.inkMuted : Palette.deep),
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
}
