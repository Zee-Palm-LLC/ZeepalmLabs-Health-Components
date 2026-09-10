import 'package:flutter/material.dart';

import '../../theme/aegis_theme.dart';

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  static const radius = BorderRadius.all(Radius.circular(16));

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AegisColors.panel,
        borderRadius: radius,
        border: Border.fromBorderSide(BorderSide(color: AegisColors.hairline)),
      ),
      child: onTap == null
          ? content
          : Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: content,
              ),
            ),
    );
  }
}
