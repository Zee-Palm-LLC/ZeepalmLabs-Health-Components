import 'package:flutter/material.dart';

import '../../theme/aegis_theme.dart';
import '../../theme/motion.dart';

/// A contact's face.
///
/// Photos fade in once decoded; until then, and whenever one can't be fetched,
/// the initials tile stands in so the row never collapses or shows a broken
/// image. The tile's colour is derived from the name, so the same person keeps
/// the same placeholder between launches.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    this.photo,
    this.size = 52,
    this.ring,
    this.connected = false,
  });

  final String name;
  final ImageProvider? photo;
  final double size;

  /// Accent drawn around the photo. Defaults to a plain hairline.
  final Color? ring;

  /// Shows the small "linked" dot at the lower right.
  final bool connected;

  static const _tiles = <List<Color>>[
    [Color(0xFF3C5A6B), Color(0xFF24363F)],
    [Color(0xFF5A4A6B), Color(0xFF33293F)],
    [Color(0xFF6B5340), Color(0xFF3F3126)],
    [Color(0xFF3F5C4E), Color(0xFF25372F)],
    [Color(0xFF56616B), Color(0xFF363F47)],
  ];

  String get _initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part.characters.first.toUpperCase())
      .join();

  List<Color> get _tile =>
      _tiles[name.hashCode.abs() % _tiles.length];

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    final border = ring ?? Colors.white.withValues(alpha: 0.16);

    final fallback = _InitialsTile(
      initials: _initials,
      colors: _tile,
      size: size,
    );

    Widget face = fallback;
    if (photo != null) {
      face = Image(
        image: photo,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        // Photos of people are the point here; without a description a screen
        // reader would read the name twice, so the label sits on the parent.
        excludeFromSemantics: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedSwitcher(
            duration: AegisMotion.medium,
            child: frame == null
                ? _InitialsTile(
                    initials: _initials,
                    colors: _tile,
                    size: size,
                    dim: true,
                  )
                : child,
          );
        },
        errorBuilder: (context, error, stack) => fallback,
      );
    }

    return Semantics(
      label: name,
      image: photo != null,
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: 1.2),
                ),
                child: ClipOval(child: face),
              ),
            ),
            if (connected)
              Positioned(
                right: -1,
                bottom: -1,
                child: _ConnectedDot(size: size * 0.28),
              ),
          ],
        ),
      ),
    );
  }
}

class _InitialsTile extends StatelessWidget {
  const _InitialsTile({
    required this.initials,
    required this.colors,
    required this.size,
    this.dim = false,
  });

  final String initials;
  final List<Color> colors;
  final double size;

  /// Muted while a photo is still on its way in.
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w500,
          color: AegisColors.textPrimary.withValues(alpha: dim ? 0.4 : 1),
        ),
      ),
    );
  }
}

class _ConnectedDot extends StatelessWidget {
  const _ConnectedDot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AegisColors.tealBright,
        border: Border.all(color: AegisColors.background, width: size * 0.16),
        boxShadow: [
          BoxShadow(
            color: AegisColors.teal.withValues(alpha: 0.55),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}
