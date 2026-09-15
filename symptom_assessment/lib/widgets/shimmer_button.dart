import 'package:flutter/widgets.dart';

import '../core/design.dart';
import '../core/motion/pressable.dart';
import '../core/palette.dart';
import '../core/type.dart';

/// The green call-to-action. A soft sheen sweeps across it every few
/// seconds - once, slowly - so it reads as the live thing on the page
/// without shouting.
class ShimmerButton extends StatefulWidget {
  const ShimmerButton({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  State<ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<ShimmerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheen = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat();

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: widget.onTap,
      pressedScale: 0.965,
      child: Container(
        height: D.ctaHeight,
        decoration: BoxDecoration(
          gradient: Leaf.button,
          borderRadius: BorderRadius.circular(D.ctaHeight / 2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Leaf.base.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(D.ctaHeight / 2),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Center(child: Text(widget.label, style: T.button)),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _sheen,
                    builder: (BuildContext context, Widget? _) {
                      // Sweeps for the first 40% of the cycle, rests after.
                      final p = (_sheen.value / 0.4).clamp(0.0, 1.0);
                      final x = -1.4 + 2.8 * Curves.easeInOut.transform(p);
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(x - 0.5, 0),
                            end: Alignment(x + 0.5, 0),
                            colors: <Color>[
                              Paper.white.withValues(alpha: 0),
                              Paper.white.withValues(alpha: 0.28),
                              Paper.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
