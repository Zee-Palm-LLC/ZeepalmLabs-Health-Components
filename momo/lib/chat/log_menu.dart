import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/type.dart';

enum LogSource { camera, library, sample }

class LogMenu extends StatelessWidget {
  const LogMenu({super.key, required this.t, required this.pivot, required this.onPick});

  static const size = Size(233, 172.5);

  final double t;
  final Alignment pivot;
  final ValueChanged<LogSource> onPick;

  @override
  Widget build(BuildContext context) {
    final s = spring(t, bounce: 0.22, freq: 1.7);
    final rows = [
      (Ph.camera, 'Take a photo', LogSource.camera, 34.8, 39.2),
      (Ph.image, 'Photo library', LogSource.library, 86.8, 91.5),
      (Ph.forkKnife, 'Try a sample meal', LogSource.sample, 138.7, 143.5),
    ];
    return Opacity(
      opacity: span(t, 0, 0.35, Curves.easeOut),
      child: Transform.scale(
        scale: lerp(0.35, 1, s),
        alignment: pivot,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: const Color(0xFFFBFAF6),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x10000000), width: 0.8),
            boxShadow: const [
              BoxShadow(color: Color(0x1A3A2A1A), blurRadius: 40, offset: Offset(0, 14)),
              BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Stack(
            children: [
              for (var i = 0; i < rows.length; i++)
                Positioned(
                  left: 6,
                  right: 6,
                  top: rows[i].$4 - 24,
                  height: 48,
                  child: _Row(
                    appear: span(t, 0.12 + i * 0.1, 0.62 + i * 0.1),
                    icon: rows[i].$1,
                    label: rows[i].$2,
                    iconCenterY: 24,
                    baseline: rows[i].$5 - rows[i].$4 + 24,
                    onTap: () => onPick(rows[i].$3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatefulWidget {
  const _Row({required this.appear, required this.icon, required this.label, required this.iconCenterY, required this.baseline, required this.onTap});

  final double appear;
  final IconData icon;
  final String label;
  final double iconCenterY;
  final double baseline;
  final VoidCallback onTap;

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: Opacity(
        opacity: widget.appear,
        child: Transform.translate(
          offset: Offset(0, -8 * (1 - widget.appear)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: _down ? const Color(0xFFF0EEE8) : const Color(0x00F0EEE8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                Positioned(left: 28.5 - 6 - 10.5, top: widget.iconCenterY - 10.5, child: PhIcon(widget.icon, size: 21, color: const Color(0xFF7E7B74))),
                Positioned(left: 50.5 - 6, top: widget.baseline - 15.8 * interAscent, child: BaseText(widget.label, style: Typo.menu)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
