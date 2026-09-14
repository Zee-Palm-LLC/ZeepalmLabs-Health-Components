import 'package:flutter/widgets.dart';

import '../../../core/design.dart';
import '../../../core/mood.dart';

/// The large mood word.
///
/// It is a [PageView] rather than an animated text swap, because the reference
/// interaction slides the outgoing word out while the incoming one slides in —
/// a cross-fade reads completely differently. Because it is a real pager, the
/// word is also swipeable, and a swipe drives the rest of the screen.
class MoodWordPager extends StatelessWidget {
  const MoodWordPager({
    super.key,
    required this.controller,
    required this.color,
    required this.onSwipedTo,
  });

  final PageController controller;
  final Color color;

  /// Fires only for a swipe the user actually made, once it settles.
  final ValueChanged<int> onSwipedTo;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: Design.wordCenterY - Design.wordBandHeight / 2,
      width: Design.width,
      height: Design.wordBandHeight,
      child: _UserSwipeDetector(
        controller: controller,
        onSwipedTo: onSwipedTo,
        child: PageView.builder(
          controller: controller,
          itemCount: Mood.values.length,
          itemBuilder: (context, i) => Center(
            child: SizedBox(
              width: Design.wordMaxWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                // Long words like OVERWHELMED scale down to the gutter instead
                // of wrapping, which keeps every mood on one optical line.
                child: Text(
                  Mood.values[i].word,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: color,
                    fontSize: Design.wordSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                    height: 1.0,
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

/// Reports the settled page, but only when the scroll began under the user's
/// finger.
///
/// `onPageChanged` cannot be used for this: animating the pager to a
/// non-adjacent page sweeps through the pages in between and reports each one,
/// so the screen would be told to change mood two or three times on the way to
/// the stop the user actually picked — visibly interrupting the spring. The
/// presence of `dragDetails` is the only reliable signal that a scroll is the
/// user's rather than our own.
class _UserSwipeDetector extends StatefulWidget {
  const _UserSwipeDetector({
    required this.controller,
    required this.onSwipedTo,
    required this.child,
  });

  final PageController controller;
  final ValueChanged<int> onSwipedTo;
  final Widget child;

  @override
  State<_UserSwipeDetector> createState() => _UserSwipeDetectorState();
}

class _UserSwipeDetectorState extends State<_UserSwipeDetector> {
  bool _fromUser = false;

  bool _onNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (notification is ScrollStartNotification) {
      _fromUser = notification.dragDetails != null;
    } else if (notification is ScrollEndNotification && _fromUser) {
      _fromUser = false;
      final page = widget.controller.page?.round();
      if (page != null) widget.onSwipedTo(page);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => NotificationListener<ScrollNotification>(
    onNotification: _onNotification,
    child: widget.child,
  );
}
