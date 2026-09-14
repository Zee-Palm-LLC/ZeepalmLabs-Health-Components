import 'package:flutter/material.dart';

import '../../../core/design.dart';

/// Close / info affordances. They tint with the background rather than sitting
/// on a fixed neutral, so they stay part of the same surface.
class HeaderBar extends StatelessWidget {
  const HeaderBar({
    super.key,
    required this.fill,
    this.onClose,
    this.onInfo,
  });

  final Color fill;
  final VoidCallback? onClose;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: Design.gutter,
      top: Design.headerButtonCenterY - Design.headerButtonSize / 2,
      width: Design.width - Design.gutter * 2,
      height: Design.headerButtonSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _CircleButton(
            fill: fill,
            icon: Icons.close_rounded,
            semanticLabel: 'Close',
            onTap: onClose,
          ),
          _CircleButton(
            fill: fill,
            icon: Icons.info_outline_rounded,
            semanticLabel: 'About this scale',
            onTap: onInfo,
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.fill,
    required this.icon,
    required this.semanticLabel,
    this.onTap,
  });

  final Color fill;
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: Design.headerButtonSize,
      child: Material(
        color: fill,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Icon(
            icon,
            size: Design.headerGlyphSize,
            color: kInk,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}
