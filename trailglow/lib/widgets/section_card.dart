import 'package:flutter/material.dart';

import '../app/theme/typography.dart';
import 'glass_panel.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(18, 16, 18, 18),
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 24,
      blur: 18,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: Typo.sectionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
