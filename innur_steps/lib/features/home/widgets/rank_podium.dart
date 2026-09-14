import 'package:flutter/widgets.dart';

import '../../../core/design.dart';
import '../../../core/palette.dart';
import '../../../data/today.dart';
import 'avatar.dart';
import 'flame.dart';

/// Second, first, third — laid out in that order so the winner sits centre.
///
/// Each place gets its own metal. The blocks grow out of the floor third,
/// second, first, so the eye is walked up to the winner rather than shown the
/// answer, and each contender lands just after their own block does.
class RankPodium extends StatelessWidget {
  const RankPodium({super.key, required this.podium, required this.t});

  /// Exactly three, in layout order: second, first, third.
  final List<Racer> podium;

  /// Entrance progress, 0..1, shared with the rest of the page.
  final double t;

  static const List<int> _places = <int>[2, 1, 3];
  static const List<double> _heights = <double>[
    D.blockSecond,
    D.blockFirst,
    D.blockThird,
  ];

  @override
  Widget build(BuildContext context) {
    const slot = (D.w - D.gutter * 2) / 3;

    return SizedBox(
      height: D.contenderHeight + D.podiumPointsGap + D.blockFirst,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          for (var i = 0; i < 3; i++) ...<Widget>[
            Positioned(
              left: D.gutter + slot * i + 3,
              bottom: 0,
              width: slot - 6,
              height: _heights[i],
              child: _Block(
                place: _places[i],
                t: D.blockIn[i].transform(t.clamp(0.0, 1.0)),
              ),
            ),
            Positioned(
              left: D.gutter + slot * i,
              bottom: _heights[i] + D.podiumPointsGap,
              width: slot,
              child: _Contender(
                racer: podium[i],
                place: _places[i],
                t: D.contenderIn[i].transform(t.clamp(0.0, 1.0)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.place, required this.t});

  final int place;

  /// 0 is flat on the floor, 1 is full height. Overshoots slightly.
  final double t;

  @override
  Widget build(BuildContext context) {
    final medal = Medal.forPlace(place);

    return Align(
      alignment: Alignment.bottomCenter,
      // Scaled about its own base, so it grows *out of the floor* rather than
      // inflating from its middle.
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.diagonal3Values(1, t.clamp(0.0, 1.4), 1),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[medal.top, medal.body],
              stops: const <double>[0, 0.42],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: medal.body.withValues(alpha: 0.35 * t.clamp(0.0, 1.0)),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox.expand(
            child: Center(
              // Counter-scaled, so the numeral does not squash while the slab
              // is still rising.
              child: Transform.scale(
                scaleY: t <= 0.02 ? 1 : 1 / t.clamp(0.02, 1.4),
                child: Text(
                  '$place',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: place == 1 ? 34 : 28,
                    height: 1,
                    color: medal.numeral,
                    fontVariations: const <FontVariation>[
                      FontVariation('wght', 700),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Contender extends StatelessWidget {
  const _Contender({
    required this.racer,
    required this.place,
    required this.t,
  });

  final Racer racer;
  final int place;
  final double t;

  @override
  Widget build(BuildContext context) {
    if (t <= 0) return const SizedBox(height: D.contenderHeight);

    final first = place == 1;
    final medal = Medal.forPlace(place);
    final avatar = first ? 60.0 : 50.0;
    final settled = t.clamp(0.0, 1.0);

    return Opacity(
      opacity: settled,
      child: Transform.translate(
        // Drops the last few units into place.
        offset: Offset(0, (1 - t) * 22),
        child: SizedBox(
          height: D.contenderHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Avatar(
                url: racer.photo,
                name: racer.name,
                tint: racer.tint,
                size: avatar,
                // Every place is ringed in its own metal, not just the winner —
                // that is what makes the top three read as a set.
                ring: medal.ring,
                ringWidth: first ? 2.6 : 2,
              ),
              const SizedBox(height: 6),
              Text(
                racer.isYou ? 'You' : racer.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  height: 1.2,
                  color: racer.isYou ? Paper.primary : Paper.secondary,
                  fontVariations: <FontVariation>[
                    FontVariation('wght', racer.isYou ? 600 : 500),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    grouped(racer.steps),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: first ? 14 : 12.5,
                      height: 1.1,
                      color: first ? medal.ring : Paper.primary,
                      fontVariations: const <FontVariation>[
                        FontVariation('wght', 700),
                      ],
                    ),
                  ),
                  if (racer.streak != null) ...<Widget>[
                    const SizedBox(width: 4),
                    const FlameMark(size: 11),
                    const SizedBox(width: 2),
                    Text(
                      '${racer.streak}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5,
                        height: 1.1,
                        color: Paper.secondary,
                        fontVariations: <FontVariation>[
                          FontVariation('wght', 500),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
