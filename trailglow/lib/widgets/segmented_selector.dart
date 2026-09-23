import 'package:flutter/material.dart';

import '../app/theme/motion.dart';
import '../app/theme/palette.dart';
import '../app/theme/typography.dart';

class SegmentedSelector extends StatelessWidget {
  const SegmentedSelector({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.height = 40,
    this.fontSize = 11.5,
  });

  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final slot = width / items.length;
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xE6070A11),
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(color: Night.hairlineSoft),
          ),
          child: Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: Motion.quick,
                curve: Motion.enter,
                left: slot * index + 3,
                top: 3,
                bottom: 3,
                width: slot - 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height / 2),
                    gradient: const LinearGradient(
                      colors: <Color>[Spectrum.deep, Spectrum.blue],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Spectrum.blue.withValues(alpha: 0.35),
                        blurRadius: 18,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List<Widget>.generate(items.length, (i) {
                  final selected = i == index;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: Motion.quick,
                          style: Typo.text(
                            fontSize,
                            weight: selected ? 700 : 600,
                            color: selected ? Tone.bright : Tone.muted,
                            height: 1.0,
                            letterSpacing: 1.4,
                          ),
                          child: Text(items[i]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
