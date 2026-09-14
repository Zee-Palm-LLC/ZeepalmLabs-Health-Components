import 'package:flutter/widgets.dart';

import '../../../core/design.dart';
import '../../../core/mood.dart';
import 'mood_face.dart';

/// Five circular faces in a row. The one you have picked is enlarged.
///
/// Each face is the same geometry as the big face on the screen, shrunk to fit
/// its circle — so the picker is a genuine preview of what you are choosing
/// rather than a separate set of icons that can drift out of sync.
///
/// Slots sit on a fixed pitch and each circle scales about its own centre.
/// That is what lets the selected one spring past full size without shoving
/// its neighbours sideways.
class MoodPickerRow extends StatelessWidget {
  const MoodPickerRow({
    super.key,
    required this.emphasis,
    required this.trayFill,
    required this.onScrub,
    required this.onSettle,
  });

  /// Fill for the tray the circles sit on. Expected to be a translucent ink
  /// rather than an opaque tint, so it darkens the gradient beneath it evenly
  /// instead of fighting it.
  final Color trayFill;

  /// Per-mood emphasis, 0 (resting) to 1 (selected). Values can exceed 1
  /// while the spring overshoots, and dip slightly below 0 as the outgoing
  /// circle recoils — both are wanted, so neither is clamped away here.
  final List<double> emphasis;

  /// Called continuously while the user drags across the row.
  final ValueChanged<double> onScrub;

  /// Called with the chosen mood when the user lifts, or taps a circle.
  final ValueChanged<int> onSettle;

  double _valueForDx(double dx) {
    final raw = (dx - Design.gutter - Design.moodRowPitch / 2) /
        Design.moodRowPitch;
    return raw.clamp(0.0, Mood.last.toDouble());
  }

  double get _value {
    var best = 0;
    for (var i = 1; i <= Mood.last; i++) {
      if (emphasis[i] > emphasis[best]) best = i;
    }
    return best.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    const centerY = Design.moodRowCenterY - Design.moodRowTop;

    return Positioned(
      left: 0,
      top: Design.moodRowTop,
      width: Design.width,
      height: Design.moodRowHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) => onSettle(_valueForDx(d.localPosition.dx).round()),
        onHorizontalDragStart: (d) => onScrub(_valueForDx(d.localPosition.dx)),
        onHorizontalDragUpdate: (d) => onScrub(_valueForDx(d.localPosition.dx)),
        onHorizontalDragEnd: (_) => onSettle(_value.round()),
        onHorizontalDragCancel: () => onSettle(_value.round()),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              left: (Design.width - Design.pickerTrayWidth) / 2,
              top: (Design.moodRowHeight - Design.pickerTrayHeight) / 2,
              width: Design.pickerTrayWidth,
              height: Design.pickerTrayHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: trayFill,
                  borderRadius:
                      BorderRadius.circular(Design.pickerTrayRadius),
                ),
              ),
            ),
            for (int i = 0; i <= Mood.last; i++)
              _MoodDot(
                mood: Mood.values[i],
                emphasis: emphasis[i],
                centerX: Design.moodDotCenterX(i),
                centerY: centerY,
                index: i,
              ),
          ],
        ),
      ),
    );
  }
}

class _MoodDot extends StatelessWidget {
  const _MoodDot({
    required this.mood,
    required this.emphasis,
    required this.centerX,
    required this.centerY,
    required this.index,
  });

  final Mood mood;
  final double emphasis;
  final double centerX;
  final double centerY;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Allow a little overshoot above and a little recoil below, but never let
    // a circle collapse or grow into its neighbour.
    final t = emphasis.clamp(-0.35, 1.45);
    final size = Design.moodDotSize +
        (Design.moodDotSelectedSize - Design.moodDotSize) * t;

    // Selected inverts: an ink circle with the mood's colour as the face. It
    // has to invert, because an unselected circle carries its own mood colour
    // and the selected mood's colour is already the whole background.
    final selected = emphasis > 0.5;
    final fill = selected ? kInk : mood.color;
    final faceInk = selected ? mood.color : kInk;

    return Positioned(
      left: centerX - size / 2,
      top: centerY - size / 2,
      width: size,
      height: size,
      child: Semantics(
        button: true,
        selected: selected,
        label: mood.tick,
        child: DecoratedBox(
          key: ValueKey<String>('mood-dot-$index'),
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: selected
                ? null
                // A hairline in the mood's own darkened tint, so a circle
                // whose colour sits near the current background still reads
                // as a separate object.
                : Border.all(color: mood.wordColor, width: 1.5),
            // The shadow fades in with the emphasis, so the circle reads as
            // lifting off the page as it grows rather than having a shadow
            // switched on under it.
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: kInk.withValues(alpha: 0.18 * t.clamp(0.0, 1.0)),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: MoodFaceIcon(shape: mood.face, size: size, ink: faceInk),
        ),
      ),
    );
  }
}
