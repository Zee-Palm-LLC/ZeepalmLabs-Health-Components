import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design.dart';
import '../../core/mood.dart';
import 'widgets/bottom_action_bar.dart';
import 'widgets/header_bar.dart';
import 'widgets/mood_face.dart';
import 'widgets/mood_picker_row.dart';
import 'widgets/mood_word_pager.dart';

/// The mood check-in.
///
/// Background, word, face geometry, surface tint and the picker circles all
/// read from one controller. That shared timing is why a mood change looks
/// like one object changing state rather than five widgets animating
/// independently.
class MoodScreen extends StatefulWidget {
  const MoodScreen({
    super.key,
    this.initialMood = 2,
    this.initialNote,
    this.eyebrow,
    this.autoPlay = false,
    this.onSubmit,
  });

  /// Where the scale starts. 2 == OKAY, the neutral middle.
  final int initialMood;

  /// A note to start with, for reopening an entry that was already logged.
  final String? initialNote;

  /// Small caps line above the headline. Defaults to today's date; pass a
  /// fixed value to keep tests and screenshots stable.
  final String? eyebrow;

  /// Cycles through the moods on its own. Off by default — an app should never
  /// move the user's answer for them. Turn it on to record a demo.
  final bool autoPlay;

  final void Function(Mood mood, String? note)? onSubmit;

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Design.transition,
    value: 1,
  );

  /// Colour progress: smooth, no overshoot, done in the first half.
  late final CurvedAnimation _eased =
      CurvedAnimation(parent: _controller, curve: Design.colorCurve);

  /// Spring progress: goes past 1 and rings back. The face and the picker
  /// circles read from this, which is where the bounce comes from.
  late final CurvedAnimation _bounce =
      CurvedAnimation(parent: _controller, curve: Design.bounceCurve);

  late final PageController _pager =
      PageController(initialPage: widget.initialMood);

  late int _index = widget.initialMood;

  // Where the last transition started from. Captured separately per property so
  // that interrupting a spring mid-bounce continues from what is on screen
  // rather than snapping back to the previous stop.
  late double _fromValue = _index.toDouble();
  late FaceShape _fromFace = Mood.values[_index].face;
  late List<double> _fromEmphasis = _restingEmphasis(_index);

  /// Non-null while the user is dragging across the picker row.
  double? _drag;

  late String? _note = widget.initialNote;
  int _autoStep = 0;

  late final String _eyebrow = widget.eyebrow ?? _todayLabel(DateTime.now());

  /// Hand-rolled rather than pulling in `intl` for one line of text.
  static String _todayLabel(DateTime now) {
    const days = <String>['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const months = <String>[
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]}'
        '   ·   CHECK-IN';
  }

  double get _value =>
      _drag ?? lerpDouble(_fromValue, _index.toDouble(), _eased.value)!;

  static List<double> _restingEmphasis(int index) =>
      <double>[for (int i = 0; i <= Mood.last; i++) i == index ? 1 : 0];

  /// How large each picker circle should be, 0 resting to 1 selected.
  ///
  /// Springing the emphasis rather than a position on the scale is what makes
  /// the chosen circle overshoot *larger* and settle, instead of sliding past
  /// its own slot.
  List<double> get _emphasis {
    final drag = _drag;
    if (drag != null) {
      return <double>[
        for (int i = 0; i <= Mood.last; i++)
          (1 - (drag - i).abs()).clamp(0.0, 1.0),
      ];
    }
    final spring = _bounce.value;
    return <double>[
      for (int i = 0; i <= Mood.last; i++)
        lerpDouble(_fromEmphasis[i], i == _index ? 1.0 : 0.0, spring)!,
    ];
  }

  /// Springing the *shape* rather than the scale position is what keeps the
  /// overshoot inside this mood's face: it never borrows geometry from a mood
  /// further along the scale.
  FaceShape get _face => _drag != null
      ? Mood.faceAt(_drag!)
      : FaceShape.lerp(_fromFace, Mood.values[_index].face, _bounce.value);

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) _queueAutoPlay();
  }

  @override
  void dispose() {
    _bounce.dispose();
    _eased.dispose();
    _controller.dispose();
    _pager.dispose();
    super.dispose();
  }

  // ---- State transitions --------------------------------------------------

  void _select(int index, {bool animatePager = true}) {
    final target = index.clamp(0, Mood.last);
    final changed = target != _index;

    setState(() {
      _fromValue = _value;
      _fromFace = _face;
      _fromEmphasis = _emphasis;
      _index = target;
      _drag = null;
    });
    _controller.forward(from: 0);

    if (animatePager && _pager.hasClients) {
      _pager.animateToPage(
        target,
        duration: Design.wordTransition,
        curve: Design.wordCurve,
      );
    }
    if (changed) HapticFeedback.selectionClick();
  }

  void _scrub(double t) {
    final crossedStop = t.round() != _value.round();
    _controller.stop();
    setState(() => _drag = t);

    // Drive the word pager by hand so the word tracks the finger instead of
    // waiting for the drag to end.
    if (!_pager.hasClients) return;
    final position = _pager.position;
    if (position.hasContentDimensions) {
      position.jumpTo(
        (t * position.viewportDimension)
            .clamp(position.minScrollExtent, position.maxScrollExtent),
      );
    }
    if (crossedStop) HapticFeedback.selectionClick();
  }

  /// A real swipe of the word. The pager reports only settled, user-driven
  /// pages, so this can move the scale without second-guessing it.
  void _onSwipedTo(int page) {
    if (page == _index || _drag != null) return;
    _select(page, animatePager: false);
  }

  void _queueAutoPlay() {
    const order = <int>[2, 4, 3, 1, 0];
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted || !widget.autoPlay) return;
      _select(order[_autoStep % order.length]);
      _autoStep++;
      _queueAutoPlay();
    });
  }

  // ---- Sheets -------------------------------------------------------------

  Future<void> _openNoteSheet(Mood mood) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: mood.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // The sheet owns its own TextEditingController. Creating it here and
      // disposing it after the await would tear it down while the sheet is
      // still animating out and still rebuilding the TextField.
      builder: (context) => _NoteSheet(mood: mood, initialNote: _note),
    );

    if (result == null || !mounted) return;
    setState(() => _note = result.trim().isEmpty ? null : result.trim());
  }

  void _openInfoSheet(Mood mood) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: mood.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _SheetShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'The scale',
              style: TextStyle(
                color: kInk,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            for (final m in Mood.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // The same face the picker shows, so the legend and the
                    // control cannot drift apart.
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: m.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: m.wordColor, width: 1.5),
                      ),
                      child: MoodFaceIcon(shape: m.face, size: 40, ink: kInk),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            m.tick,
                            style: const TextStyle(
                              color: kInk,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            m.blurb,
                            style: TextStyle(
                              color: mood.wordColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _submit(Mood mood) {
    HapticFeedback.mediumImpact();
    widget.onSubmit?.call(mood, _note);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: mood.wordColor,
          shape: const StadiumBorder(),
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          content: Text(
            'Logged - ${mood.tick.toLowerCase()}.',
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
  }

  // ---- Build --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _value;
        final mood = Mood.values[t.round().clamp(0, Mood.last)];
        final background = Mood.colorAt(t);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: const Color(0x00000000),
            systemNavigationBarColor: background,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            // Full bleed: the colour owns the whole window, and the fixed
            // design canvas floats centred inside it.
            backgroundColor: background,
            body: DecoratedBox(
              // A dead-flat fill is what separates a mockup from a product.
              // This is a barely-there radial lift behind the face and a
              // matching fall-off at the corners — a few percent of lightness,
              // enough to give the colour somewhere to go.
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.42),
                  radius: 1.2,
                  colors: <Color>[
                    Mood.shade(background, 1.07),
                    background,
                    Mood.shade(background, 0.93),
                  ],
                  stops: const <double>[0, 0.52, 1],
                ),
              ),
              child: MediaQuery.withNoTextScaling(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: Design.width,
                      height: Design.height,
                      child: _canvas(t, mood),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _canvas(double t, Mood mood) {
    final surface = Mood.surfaceColorAt(t);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        HeaderBar(
          fill: surface,
          onClose: () => Navigator.of(context).maybePop(),
          onInfo: () => _openInfoSheet(mood),
        ),

        Positioned(
          left: 0,
          top: Design.eyebrowTop,
          width: Design.width,
          child: Text(
            _eyebrow,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kInk.withValues(alpha: 0.42),
              fontSize: Design.eyebrowSize,
              fontWeight: FontWeight.w700,
              letterSpacing: Design.eyebrowTracking,
              height: 1.2,
            ),
          ),
        ),

        const Positioned(
          left: (Design.width - Design.titleMaxWidth) / 2,
          top: Design.titleTop,
          width: Design.titleMaxWidth,
          child: Text(
            'How are you feeling\nright now?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kInk,
              fontSize: Design.titleSize,
              fontWeight: FontWeight.w600,
              height: 1.22,
              letterSpacing: -0.4,
            ),
          ),
        ),

        // The word sits behind the face, exactly as in the reference.
        MoodWordPager(
          controller: _pager,
          color: Mood.wordColorAt(t),
          onSwipedTo: _onSwipedTo,
        ),

        // The blurb swaps rather than morphs — the face and the word already
        // carry the continuity, so a short cross-fade here is enough.
        Positioned(
          left: (Design.width - Design.blurbMaxWidth) / 2,
          top: Design.blurbTop,
          width: Design.blurbMaxWidth,
          child: AnimatedSwitcher(
            duration: Design.blurbTransition,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.4),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              mood.blurb,
              key: ValueKey<String>(mood.word),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kInk.withValues(alpha: 0.58),
                fontSize: Design.blurbSize,
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),

        IgnorePointer(child: MoodFace(shape: _face)),

        MoodPickerRow(
          emphasis: _emphasis,
          // Translucent rather than a flat tint: the ground under it is a
          // gradient, so a fixed colour would read lighter than the page at
          // the tray's ends and darker in the middle.
          trayFill: kInk.withValues(alpha: 0.13),
          onScrub: _scrub,
          onSettle: _select,
        ),

        BottomActionBar(
          fill: surface,
          chipFill: Mood.colorAt(t),
          note: _note,
          onAddNote: () => _openNoteSheet(mood),
          onSubmit: () => _submit(mood),
        ),
      ],
    );
  }
}

/// Common chrome for the bottom sheets.
///
/// Scrollable and keyboard-aware: without this the content is laid out against
/// whatever height is left once the IME is up, and a sheet that is a few pixels
/// too tall throws a RenderFlex overflow mid-animation instead of just
/// scrolling.
class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// The "add a note" sheet.
///
/// Stateful so the [TextEditingController] lives exactly as long as the route
/// does — it is disposed when the sheet is torn down, not when the caller's
/// `await` returns, which happens while the exit animation is still building
/// this widget.
class _NoteSheet extends StatefulWidget {
  const _NoteSheet({required this.mood, required this.initialNote});

  final Mood mood;
  final String? initialNote;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialNote ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = widget.mood;

    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'What is going on?',
            style: TextStyle(
              color: kInk,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Optional. A few words is plenty.',
            style: TextStyle(
              color: mood.wordColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            cursorColor: kInk,
            style: const TextStyle(
              color: kInk,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: mood.surfaceColor,
              hintText: 'Back to back meetings, no lunch...',
              hintStyle: TextStyle(color: mood.wordColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              if (widget.initialNote != null)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(''),
                  style: TextButton.styleFrom(
                    foregroundColor: kInk,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    minimumSize: const Size(0, 52),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Remove'),
                ),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_controller.text),
                    style: FilledButton.styleFrom(
                      backgroundColor: kSubmitFill,
                      foregroundColor: kSubmitInk,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Save note'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
