import 'package:flutter/material.dart';

import 'glyphs.dart';
import 'motion.dart';
import 'theme.dart';

class QueueNavBar extends StatelessWidget {
  const QueueNavBar({super.key, required this.index, required this.onSelect});

  static const height = 64.0;
  static const width = 393.0;

  final int index;
  final ValueChanged<int> onSelect;

  static const _icons = [Glyph.home, Glyph.queue, Glyph.map, Glyph.user];
  static const _labels = ['Home', 'Queue', 'Map', 'Me'];

  static List<double> _centres(int selected) {
    const pad = 22.0;
    const wide = 97.0;
    const narrow = 44.0;
    const gap = (width - pad * 2 - wide - narrow * 3) / 3;
    final centres = <double>[];
    var x = pad;
    for (var i = 0; i < 4; i++) {
      final w = i == selected ? wide : narrow;
      centres.add(x + w / 2);
      x += w + gap;
    }
    return centres;
  }

  @override
  Widget build(BuildContext context) {
    final centres = _centres(index);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            left: centres[index] - 48.5,
            top: 10.5,
            width: 97,
            height: 43,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0E746B),
                borderRadius: BorderRadius.circular(21.5),
                boxShadow: const [BoxShadow(color: Color(0x4014B8A6), blurRadius: 12, offset: Offset(0, 5))],
              ),
            ),
          ),
          for (var i = 0; i < 4; i++)
            AnimatedPositioned(
              key: ValueKey(i),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              left: centres[i] - (i == index ? 48.5 : 22),
              top: 10.5,
              width: i == index ? 97 : 44,
              height: 43,
              child: Pressable(
                onTap: () => onSelect(i),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlyphIcon(
                      _icons[i],
                      size: i == index ? 16 : 19,
                      color: i == index ? Colors.white : const Color(0xFF3F5553),
                      stroke: 1.9,
                    ),
                    if (i == index) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          softWrap: false,
                          style: jakarta(12.5, 800, color: Colors.white, spacing: -0.25),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
