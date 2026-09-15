import 'package:flutter/widgets.dart';

import '../core/design.dart';
import '../core/motion/pressable.dart';
import '../core/palette.dart';
import '../core/type.dart';
import 'icons/glyphs.dart';

/// Back, title, close. The two buttons are white discs with a soft shadow,
/// as in the reference; the title is set in the secondary ink.
class HeaderBar extends StatelessWidget {
  const HeaderBar({
    super.key,
    required this.title,
    this.onBack,
    this.onClose,
    this.t = 1,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  /// Entrance progress.
  final double t;

  @override
  Widget build(BuildContext context) {
    final settled = t.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(D.gutter, D.headerTop, D.gutter, 0),
      child: SizedBox(
        height: D.headerButton,
        child: Row(
          children: <Widget>[
            _Disc(
              glyph: Glyph.back,
              onTap: onBack,
              t: ((t - 0.0) / 0.7).clamp(0.0, 1.0),
            ),
            Expanded(
              child: Opacity(
                opacity: settled,
                child: Transform.translate(
                  offset: Offset(0, (1 - settled) * 8),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: T.appBar,
                  ),
                ),
              ),
            ),
            _Disc(
              glyph: Glyph.close,
              onTap: onClose,
              t: ((t - 0.15) / 0.7).clamp(0.0, 1.0),
            ),
          ],
        ),
      ),
    );
  }
}

class _Disc extends StatelessWidget {
  const _Disc({required this.glyph, required this.onTap, required this.t});

  final Glyph glyph;
  final VoidCallback? onTap;
  final double t;

  @override
  Widget build(BuildContext context) {
    final scale = D.pop.transform(t);
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale <= 0 ? 0.001 : scale,
        child: Pressable(
          onTap: onTap,
          pressedScale: 0.88,
          child: Container(
            width: D.headerButton,
            height: D.headerButton,
            decoration: BoxDecoration(
              color: Paper.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF1F272C).withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(child: Icon2(glyph, size: 18, color: Slate.secondary)),
          ),
        ),
      ),
    );
  }
}
