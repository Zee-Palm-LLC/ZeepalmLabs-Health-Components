import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';

class CircleButton extends StatelessWidget {
  const CircleButton({
    super.key,
    required this.glyph,
    required this.onTap,
    this.size = 40,
    this.icon = 21,
    this.stroke = 1.8,
    this.ring = true,
  });

  final Glyph glyph;
  final VoidCallback onTap;
  final double size;
  final double icon;
  final double stroke;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.88,
      child: Container(
        width: size,
        height: size,
        decoration: ring
            ? BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x140A0402),
                border: Border.all(color: hairlineSoft),
              )
            : null,
        child: Center(
          child: GlyphIcon(
            glyph,
            size: icon,
            stroke: stroke,
            color: Ember.cream,
            shadow: const Color(0x73000000),
          ),
        ),
      ),
    );
  }
}

class SegmentChips extends StatelessWidget {
  const SegmentChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelect,
    required this.seconds,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 18, right: 18),
      physics: const BouncingScrollPhysics(),
      itemCount: labels.length,
      separatorBuilder: (_, _) => const SizedBox(width: 9),
      itemBuilder: (context, i) =>
          _Chip(label: labels[i], on: i == selected, seconds: seconds, onTap: () => onSelect(i)),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.on, required this.onTap, required this.seconds});

  final String label;
  final bool on;
  final VoidCallback onTap;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    final glow = 0.6 + 0.4 * math.sin(seconds * 1.7);
    return Pressable(
      onTap: onTap,
      scale: 0.93,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: gentle,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: on ? const Color(0x730F0603) : const Color(0x1A0A0402),
          border: Border.all(color: on ? Ember.gold.withValues(alpha: 0.62) : hairlineSoft),
          boxShadow: on
              ? [BoxShadow(color: Ember.amber.withValues(alpha: 0.26 * glow), blurRadius: 18)]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 320),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.4,
            height: 1.0,
            fontWeight: on ? FontWeight.w500 : FontWeight.w400,
            color: on ? Ember.gold : Ember.ash.withValues(alpha: 0.78),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
