import 'package:flutter/widgets.dart';

import '../../../core/design.dart';
import '../../../core/palette.dart';
import '../../../data/today.dart';
import 'avatar.dart';
import 'flame.dart';

/// One row of the leaderboard below the podium.
///
/// The user's own row is lifted — a brighter fill, a blue edge and full-weight
/// ink — because finding yourself in a list of ten is the single thing anyone
/// does on this screen.
class RankRow extends StatelessWidget {
  const RankRow({
    super.key,
    required this.place,
    required this.racer,
    required this.t,
  });

  final int place;
  final Racer racer;

  /// Entrance progress for this row, 0..1.
  final double t;

  @override
  Widget build(BuildContext context) {
    final settled = t.clamp(0.0, 1.0);
    final you = racer.isYou;

    return Opacity(
      opacity: settled,
      child: Transform.translate(
        // Slides in from the right, so the column reads as dealing itself out.
        offset: Offset((1 - settled) * 28, 0),
        child: Container(
          height: D.rowHeight,
          margin: const EdgeInsets.only(bottom: D.rowGap),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: you
                ? Accent.blue.withValues(alpha: 0.16)
                : Paper.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(D.rowRadius),
            border: Border.all(
              color: you ? Accent.blue.withValues(alpha: 0.55) : Paper.rowEdge,
            ),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 26,
                child: Text(
                  '$place',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    height: 1.1,
                    color: you ? Paper.primary : Paper.muted,
                    fontVariations: <FontVariation>[
                      FontVariation('wght', you ? 700 : 600),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Avatar(
                url: racer.photo,
                name: racer.name,
                tint: racer.tint,
                size: 36,
                ring: you ? Accent.blueSoft : null,
                ringWidth: 1.8,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  racer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    height: 1.2,
                    color: Paper.primary,
                    fontVariations: <FontVariation>[
                      FontVariation('wght', you ? 700 : 600),
                    ],
                  ),
                ),
              ),
              if (racer.streak != null) ...<Widget>[
                const FlameMark(size: 11),
                const SizedBox(width: 3),
                Text(
                  '${racer.streak}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    height: 1.1,
                    color: Paper.secondary,
                    fontVariations: <FontVariation>[FontVariation('wght', 500)],
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                grouped(racer.steps),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  height: 1.2,
                  color: you ? Paper.primary : Paper.secondary,
                  fontVariations: <FontVariation>[
                    FontVariation('wght', you ? 700 : 500),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
