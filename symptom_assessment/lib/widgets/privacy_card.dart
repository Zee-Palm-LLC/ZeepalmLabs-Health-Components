import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../core/design.dart';
import '../core/palette.dart';
import '../core/type.dart';

/// "Your health, your data" - the mint card at the foot of the assess screen.
///
/// The illustration floats on a slow figure-eight and two confetti flecks
/// twinkle beside it. Idle motion, not attention-seeking: the amplitude is
/// three pixels.
class PrivacyCard extends StatefulWidget {
  const PrivacyCard({super.key});

  @override
  State<PrivacyCard> createState() => _PrivacyCardState();
}

class _PrivacyCardState extends State<PrivacyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: D.privacyHeight),
      padding: const EdgeInsets.only(left: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(D.radius),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Paper.mintCard, Paper.mintCardEnd],
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Your health, your data', style: T.cardTitle),
                  const SizedBox(height: 5),
                  Text(
                    'Your information is private and secure.\n'
                    'We\'re here to help you feel better.',
                    // A touch under the other cards' body size: at 393 wide
                    // the two lines of the reference fit only at 11.5.
                    style: T.cardBody.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 118,
            height: D.privacyHeight,
            child: AnimatedBuilder(
              animation: _idle,
              builder: (BuildContext context, Widget? child) {
                final a = _idle.value * math.pi * 2;
                return Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned(
                      left: -2,
                      top: -2 + math.sin(a) * 3,
                      width: 118,
                      height: 110,
                      child: Transform.translate(
                        offset: Offset(math.sin(a * 2) * 1.5, 0),
                        child: child,
                      ),
                    ),
                    _Fleck(x: 10, y: 24, phase: a, color: Leaf.orange),
                    _Fleck(x: 102, y: 88, phase: a + 2.1, color: Leaf.base),
                    _Fleck(x: 22, y: 92, phase: a + 4.0, color: Leaf.base),
                  ],
                );
              },
              child: Image.asset(
                'assets/images/privacy_illustration.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fleck extends StatelessWidget {
  const _Fleck({
    required this.x,
    required this.y,
    required this.phase,
    required this.color,
  });

  final double x;
  final double y;
  final double phase;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final twinkle = (0.5 + 0.5 * math.sin(phase * 1.7)).clamp(0.0, 1.0);
    return Positioned(
      left: x,
      top: y + math.sin(phase) * 2,
      child: Opacity(
        opacity: 0.35 + 0.65 * twinkle,
        child: Transform.rotate(
          angle: phase * 0.5,
          child: Container(
            width: 4 + 2 * twinkle,
            height: 4 + 2 * twinkle,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      ),
    );
  }
}
