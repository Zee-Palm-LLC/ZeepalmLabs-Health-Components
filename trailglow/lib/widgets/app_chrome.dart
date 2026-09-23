import 'package:flutter/material.dart';

import '../app/theme/motion.dart';
import '../app/theme/palette.dart';
import '../app/theme/typography.dart';
import 'press_scale.dart';

class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Night.panel,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Night.hairline),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return body;
    return PressScale(onTap: onTap, child: body);
  }
}

class IconPill extends StatelessWidget {
  const IconPill({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 38,
    this.color = Tone.primary,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      scale: 0.9,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Night.panel,
          shape: BoxShape.circle,
          border: Border.all(color: Night.hairline),
        ),
        child: Icon(icon, size: size * 0.44, color: color),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color = Tone.muted});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: Typo.label(9.5, color: color));
}

class MapControls extends StatelessWidget {
  const MapControls({
    super.key,
    required this.onRecenter,
    this.onTilt,
    this.tilted = false,
  });

  final VoidCallback onRecenter;
  final VoidCallback? onTilt;
  final bool tilted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconPill(icon: Icons.my_location_rounded, onTap: onRecenter, size: 40),
        if (onTilt != null) ...<Widget>[
          const SizedBox(height: 10),
          PressScale(
            onTap: onTilt,
            scale: 0.9,
            child: AnimatedContainer(
              duration: Motion.quick,
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tilted
                    ? Spectrum.blue.withValues(alpha: 0.22)
                    : Night.panel,
                shape: BoxShape.circle,
                border: Border.all(
                  color: tilted
                      ? Spectrum.sky.withValues(alpha: 0.5)
                      : Night.hairline,
                ),
              ),
              child: Text(
                '3D',
                style: Typo.text(
                  11,
                  weight: 700,
                  height: 1.0,
                  color: tilted ? Tone.bright : Tone.secondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class DockedNav extends StatelessWidget {
  const DockedNav({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const List<({IconData icon, String label})> items =
      <({IconData icon, String label})>[
        (icon: Icons.near_me_rounded, label: 'Run'),
        (icon: Icons.local_fire_department_rounded, label: 'Lifetime'),
      ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10 + (bottom > 0 ? bottom : 10)),
      decoration: const BoxDecoration(
        color: Color(0xF2050810),
        border: Border(top: BorderSide(color: Night.hairlineSoft)),
      ),
      child: Row(
        children: List<Widget>.generate(items.length, (i) {
          final selected = i == index;
          final item = items[i];
          return Expanded(
            child: PressScale(
              onTap: () => onChanged(i),
              scale: 0.94,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      item.icon,
                      size: 18,
                      color: selected ? Spectrum.cyan : Tone.faint,
                    ),
                    const SizedBox(width: 8),
                    AnimatedDefaultTextStyle(
                      duration: Motion.quick,
                      style: Typo.text(
                        12.5,
                        weight: selected ? 700 : 500,
                        color: selected ? Tone.bright : Tone.muted,
                        height: 1.0,
                      ),
                      child: Text(item.label),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
