import 'package:flutter/widgets.dart';

import '../../../core/design.dart';
import '../../../core/motion/entrance.dart';
import '../../../core/palette.dart';
import '../../../core/type.dart';

/// "LEVEL UP / YOUR HEALTH", then the supporting line.
///
/// Both display lines are struck in by a travelling wipe rather than faded,
/// because a 40pt italic display face that simply fades reads as a loading
/// state. The second line carries the identity gradient and glows in its own
/// colour; the shader mask tints the glow too, which is why it is applied
/// over the shadow rather than under it.
class Headline extends StatelessWidget {
  const Headline({super.key, required this.t, this.message});

  /// Entrance progress for the whole screen, 0..1.
  final double t;

  /// Set while a stat badge is tapped: its blurb takes the supporting line's
  /// place for a couple of seconds, then hands it back. The two are the same
  /// height, so nothing below moves.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final levelUp = D.levelUpIn.transform(t);
    final yourHealth = D.yourHealthIn.transform(t);
    final sub = D.subIn.transform(t);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Rise(
          t: levelUp,
          distance: 14,
          child: SweepReveal(
            t: levelUp,
            child: Text(
              'LEVEL UP',
              textAlign: TextAlign.center,
              style: T.levelUp.copyWith(
                shadows: const <Shadow>[
                  Shadow(color: Color(0xCC000000), blurRadius: 12,
                      offset: Offset(0, 3)),
                  Shadow(color: Color(0x668B44F7), blurRadius: 26),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: D.headlineGap),
        Rise(
          t: yourHealth,
          distance: 18,
          child: SweepReveal(
            t: yourHealth,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect bounds) =>
                  Spectrum.headline.createShader(bounds),
              child: Text(
                'YOUR HEALTH',
                textAlign: TextAlign.center,
                style: T.yourHealth.copyWith(
                  // The mask tints these too, so a white shadow comes out
                  // violet on the left and blue on the right - which is the
                  // glow the reference has. Keep it tight; a wide one turns
                  // the line into a lit box.
                  shadows: const <Shadow>[
                    Shadow(color: Color(0x73FFFFFF), blurRadius: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: D.subGap),
        Rise(
          t: sub,
          distance: 10,
          child: SizedBox(
            height: D.subSize * D.subLineHeight * 2,
            // Both the default line and every stat blurb wrap to exactly two
            // lines at this width, so the swap never moves anything below it.
            width: 310,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (Widget child, Animation<double> a) =>
                  FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.28),
                    end: Offset.zero,
                  ).animate(a),
                  child: child,
                ),
              ),
              child: message == null
                  ? Text.rich(
                      key: const ValueKey<String>('default'),
                      TextSpan(
                        style: T.sub,
                        children: <InlineSpan>[
                          const TextSpan(
                              text: 'Every healthy choice\nearns you '),
                          TextSpan(text: 'XP!', style: T.subAccent),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      message!,
                      key: ValueKey<String>(message!),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: T.sub,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
