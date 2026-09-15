import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design.dart';
import '../../../core/motion/pressable.dart';
import '../../../core/palette.dart';
import '../../../core/type.dart';

/// The call to action.
///
/// A sheen crosses it every few seconds, once, slowly. It is the only thing
/// on the screen that moves on its own without being asked, which is how the
/// eye finds it after the entrance has finished.
class StartButton extends StatefulWidget {
  const StartButton({
    super.key,
    required this.label,
    required this.idle,
    this.charge = 0,
    this.onTap,
  });

  final String label;
  final double idle;

  /// 0..1 while the journey is launching.
  final double charge;
  final VoidCallback? onTap;

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> {
  bool _held = false;

  @override
  Widget build(BuildContext context) {
    // One sweep per cycle, then a rest, so it never looks like a spinner.
    final cycle = (widget.idle / 3.8) % 1.0;
    final sheen = (cycle / 0.34).clamp(0.0, 1.0);
    final lit = _held || widget.charge > 0;

    return Pressable(
      onTap: widget.onTap,
      pressedScale: 0.965,
      onPressedChanged: (bool v) => setState(() => _held = v),
      child: Container(
        height: D.buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(D.buttonHeight / 2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Spectrum.violetDeep
                  .withValues(alpha: lit ? 0.62 : 0.40),
              blurRadius: lit ? 34 : 24,
              spreadRadius: lit ? 2 : 0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Spectrum.blueDeep
                  .withValues(alpha: lit ? 0.48 : 0.30),
              blurRadius: lit ? 30 : 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(D.buttonHeight / 2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: Spectrum.action,
              borderRadius: BorderRadius.circular(D.buttonHeight / 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // A soft top light, the way a moulded plastic key catches it.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          const Color(0xFFFFFFFF).withValues(alpha: 0.22),
                          const Color(0x00FFFFFF),
                          const Color(0xFF000000).withValues(alpha: 0.18),
                        ],
                        stops: const <double>[0, 0.52, 1],
                      ),
                    ),
                  ),
                ),
                // The sheen.
                if (sheen > 0 && sheen < 1)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(
                                -1.6 + 3.2 * Curves.easeInOut.transform(sheen)
                                    - 0.42,
                                0),
                            end: Alignment(
                                -1.6 + 3.2 * Curves.easeInOut.transform(sheen)
                                    + 0.42,
                                0),
                            colors: const <Color>[
                              Color(0x00FFFFFF),
                              Color(0x4DFFFFFF),
                              Color(0x00FFFFFF),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // The charge wipe, left to right, when the journey starts.
                if (widget.charge > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widget.charge.clamp(0.0, 1.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: <Color>[
                                Spectrum.cyan.withValues(alpha: 0.10),
                                Spectrum.cyan.withValues(alpha: 0.42),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Shrinks rather than overflows. A long label, a wide
                      // accessibility scale or a 320-wide phone would all
                      // otherwise push the chevron off the end.
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            style: T.button.copyWith(
                              shadows: const <Shadow>[
                                Shadow(color: Color(0x66000000), blurRadius: 8,
                                    offset: Offset(0, 2)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                      CustomPaint(
                        size: const Size(16, 20),
                        painter: _Chevron(
                          nudge: math.sin(widget.idle * 2.1) * 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                // Lit rim, drawn last so it sits above every wash.
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(D.buttonHeight / 2),
                        border: Border.all(
                          color: const Color(0xFFFFFFFF)
                              .withValues(alpha: lit ? 0.55 : 0.34),
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chevron extends CustomPainter {
  const _Chevron({required this.nudge});

  /// Drifts a pixel or two to the right and back, pointing the way.
  final double nudge;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width * 0.28 + nudge;
    final h = size.height * 0.36;
    canvas.drawPath(
      Path()
        ..moveTo(x, size.height / 2 - h)
        ..lineTo(x + size.width * 0.44, size.height / 2)
        ..lineTo(x, size.height / 2 + h),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFFFFFFF)
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_Chevron old) => old.nudge != nudge;
}
