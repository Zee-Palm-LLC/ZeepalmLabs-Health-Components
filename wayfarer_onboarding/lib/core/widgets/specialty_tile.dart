import 'package:flutter/material.dart';

/// A specialty glyph on a soft tint of its own colour, sized for the leading
/// slot of a list row.
class SpecialtyTile extends StatelessWidget {
  const SpecialtyTile({super.key, required this.icon, required this.color, this.size = 30});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      child: Icon(icon, size: size * 0.55, color: color),
    );
  }
}
