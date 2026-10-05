import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';

class GlassCircle extends StatelessWidget {
  const GlassCircle({super.key, required this.icon, this.onTap, this.size = 44.5, this.iconSize = 24, this.color = Shade.soft});

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFCFCFA), Color(0xFFF3F3F0)],
          ),
          border: Border.all(color: const Color(0x12000000), width: 0.8),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 3)),
            BoxShadow(color: Color(0xCCFFFFFF), blurRadius: 0, spreadRadius: -1.2, offset: Offset(0, 0.6)),
          ],
        ),
        alignment: Alignment.center,
        child: PhIcon(icon, size: iconSize, color: color),
      ),
    );
  }
}

BoxDecoration cardDecoration({double radius = 24, Color color = Shade.card}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0x0A000000), width: 0.8),
    boxShadow: const [
      BoxShadow(color: Color(0x0A2A1A0A), blurRadius: 24, offset: Offset(0, 8)),
      BoxShadow(color: Color(0x06000000), blurRadius: 3, offset: Offset(0, 1)),
    ],
  );
}

BoxDecoration pillDecoration({double radius = 24, bool lifted = true}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFBFBF8), Color(0xFFF6F6F3)],
    ),
    border: Border.all(color: const Color(0x14000000), width: 0.8),
    boxShadow: lifted
        ? const [
            BoxShadow(color: Color(0x0C000000), blurRadius: 12, offset: Offset(0, 4)),
            BoxShadow(color: Color(0xE6FFFFFF), blurRadius: 0, spreadRadius: -1.4, offset: Offset(0, 0.8)),
          ]
        : const [],
  );
}

class Photo extends StatelessWidget {
  const Photo(this.asset, {super.key, this.radius = 10, this.border = 0, this.shadow = true, this.width, this.height});

  final String asset;
  final double radius;
  final double border;
  final bool shadow;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(border),
      decoration: BoxDecoration(
        color: border > 0 ? Colors.white : null,
        borderRadius: BorderRadius.circular(radius + border),
        boxShadow: shadow
            ? const [
                BoxShadow(color: Color(0x1F3A2414), blurRadius: 16, offset: Offset(0, 6)),
                BoxShadow(color: Color(0x0F000000), blurRadius: 2, offset: Offset(0, 1)),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(asset, fit: BoxFit.cover, width: double.infinity, height: double.infinity, filterQuality: FilterQuality.medium),
      ),
    );
  }
}
