import 'package:flutter/widgets.dart';

import '../../../core/palette.dart';

/// A remote avatar that always occupies its space.
///
/// Every state — loading, loaded, failed — renders the same circle at the same
/// size, so a slow or dead network shifts nothing on the page. The tint behind
/// it is the person's own colour, and the initial sits on top of it, which
/// means a failed image still reads as *them* rather than as a broken tile.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.url,
    required this.name,
    required this.tint,
    required this.size,
    this.ring,
    this.ringWidth = 1.4,
  });

  final String url;
  final String name;
  final Color tint;
  final double size;

  final Color? ring;
  final double ringWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint,
        shape: BoxShape.circle,
        border: Border.all(
          color: ring ?? const Color(0xFF2A3040),
          width: ring != null ? ringWidth : 1.2,
        ),
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _initial(),
            Image.network(
              url,
              fit: BoxFit.cover,
              // Fade in over the initial rather than popping, so a late image
              // is not a flash of movement in the corner of the eye.
              frameBuilder: (context, child, frame, wasSync) {
                if (wasSync) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              errorBuilder: (context, error, stack) =>
                  const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initial() => Center(
        child: Text(
          name.characters.first.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: size * 0.38,
            height: 1,
            color: Paper.primary.withValues(alpha: 0.85),
            fontVariations: const <FontVariation>[FontVariation('wght', 600)],
          ),
        ),
      );
}
