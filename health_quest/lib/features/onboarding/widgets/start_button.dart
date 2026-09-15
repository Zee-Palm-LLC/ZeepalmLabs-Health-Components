import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design.dart';
import '../../../core/motion/pressable.dart';
import '../../../core/palette.dart';
import '../../../core/type.dart';
import '../../../widgets/hud.dart';

/// The call to action.
///
/// A chamfered, bevelled key rather than a pill: the corners are cut, the face
/// has a hard top highlight and a bottom shade like moulded plastic, and a
/// sheen crosses it every few seconds. It is the only thing on the screen that
/// moves on its own once the entrance has finished, which is how the eye finds
/// it.
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
    return Pressable(
      onTap: widget.onTap,
      pressedScale: 0.965,
      onPressedChanged: (bool v) => setState(() => _held = v),
      child: BevelButton(
        height: D.buttonHeight,
        cut: 17,
        gradient: Spectrum.action,
        glowColor: Spectrum.violetDeep,
        lit: _held || widget.charge > 0,
        idle: widget.idle,
        charge: widget.charge,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Shrinks rather than overflows. A long label, a wide
              // accessibility scale or a 320-wide phone would all otherwise
              // push the chevron off the end.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    style: T.button.copyWith(
                      shadows: const <Shadow>[
                        Shadow(
                            color: Color(0x66000000),
                            blurRadius: 8,
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
