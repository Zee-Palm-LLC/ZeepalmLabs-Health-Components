import 'package:flutter/widgets.dart';

import '../core/design.dart';
import '../core/motion/pressable.dart';
import '../core/palette.dart';
import '../core/type.dart';
import 'icons/glyphs.dart';

/// A white card with an icon tile, title, subtitle and a chevron that turns
/// as the body opens. The body is height-animated on a spring-like curve and
/// its contents rise in a beat after the frame.
class ExpandableSection extends StatefulWidget {
  const ExpandableSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.glyph,
    required this.glyphColor,
    required this.body,
    this.initiallyOpen = false,
  });

  final String title;
  final String subtitle;
  final Glyph glyph;
  final Color glyphColor;
  final Widget body;
  final bool initiallyOpen;

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _open = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
    reverseDuration: const Duration(milliseconds: 380),
    value: widget.initiallyOpen ? 1 : 0,
  );

  @override
  void dispose() {
    _open.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_open.status == AnimationStatus.forward || _open.value == 1) {
      _open.reverse();
    } else {
      _open.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Paper.white,
        borderRadius: BorderRadius.circular(D.tileRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF1F272C).withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Pressable(
            onTap: _toggle,
            pressedScale: 0.985,
            child: SizedBox(
              height: D.sectionHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Paper.tile,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Icon2(widget.glyph,
                            size: 24, color: widget.glyphColor, strokeWidth: 2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.title, style: T.tileTitle),
                          const SizedBox(height: 2),
                          Text(widget.subtitle, style: T.tileSub),
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _open,
                      builder: (BuildContext context, Widget? _) => Icon2(
                        Glyph.chevronDown,
                        size: 22,
                        color: Slate.secondary,
                        strokeWidth: 2,
                        progress: D.emphasized.transform(_open.value),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _open,
            builder: (BuildContext context, Widget? child) {
              final t = _open.value;
              final grow = D.emphasized.transform(t);
              final settle = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: grow,
                  child: Opacity(
                    opacity: Curves.easeOut.transform(settle),
                    child: Transform.translate(
                      offset: Offset(0, (1 - settle) * 10),
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: widget.body,
            ),
          ),
        ],
      ),
    );
  }
}
