import 'package:flutter/material.dart';

import '../core/design.dart';
import '../core/motion/pressable.dart';
import '../core/palette.dart';
import '../core/type.dart';
import 'icons/glyphs.dart';

/// The symptom search field. One widget serves both screens: on the assess
/// screen it is a static prompt that flies to the results screen as a Hero,
/// where it becomes a live text field with a clear button.
///
/// The border brightens with focus, the lens icon sits in a pale green disc,
/// and the clear button spins in when there is something to clear.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.readOnly = false,
    this.autofocus = false,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hint = 'Search for a symptom',
    this.heroTag = 'search-field',
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool autofocus;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hint;
  final Object heroTag;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  late final TextEditingController _text =
      widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_rebuild);
    _text.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_rebuild);
    _text.removeListener(_rebuild);
    if (widget.focusNode == null) _focus.dispose();
    if (widget.controller == null) _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus && !widget.readOnly;
    final hasText = _text.text.isNotEmpty;

    final shell = AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      height: D.fieldHeight,
      decoration: BoxDecoration(
        color: Paper.white,
        borderRadius: BorderRadius.circular(D.fieldHeight / 2),
        border: Border.all(
          color: focused ? Leaf.base : Leaf.border,
          width: focused ? 1.6 : 1.2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Leaf.base.withValues(alpha: focused ? 0.22 : 0.10),
            blurRadius: focused ? 22 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 7),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Leaf.soft,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon2(Glyph.search, size: 18, color: Leaf.base),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: widget.readOnly
                ? Text(widget.hint, style: T.placeholder)
                : TextField(
                    controller: _text,
                    focusNode: _focus,
                    autofocus: widget.autofocus,
                    style: T.input,
                    cursorColor: Leaf.base,
                    textInputAction: TextInputAction.search,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: widget.hint,
                      hintStyle: T.placeholder,
                    ),
                  ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: D.pop,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (Widget child, Animation<double> a) =>
                ScaleTransition(
              scale: a,
              child: RotationTransition(
                turns: Tween<double>(begin: -0.25, end: 0).animate(a),
                child: child,
              ),
            ),
            child: hasText && !widget.readOnly
                ? Pressable(
                    key: const ValueKey<String>('clear'),
                    pressedScale: 0.8,
                    onTap: () {
                      _text.clear();
                      widget.onChanged?.call('');
                      widget.onClear?.call();
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: Paper.tile,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon2(Glyph.close, size: 16, color: Slate.secondary),
                      ),
                    ),
                  )
                : const SizedBox(width: 16, key: ValueKey<String>('none')),
          ),
        ],
      ),
    );

    final hero = Hero(
      tag: widget.heroTag,
      createRectTween: (Rect? a, Rect? b) =>
          RectTween(begin: a, end: b),
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection direction,
        BuildContext fromContext,
        BuildContext toContext,
      ) =>
          Material(
        type: MaterialType.transparency,
        child: _Shuttle(hint: widget.hint),
      ),
      child: Material(type: MaterialType.transparency, child: shell),
    );

    if (widget.readOnly && widget.onTap != null) {
      return Pressable(
        onTap: widget.onTap,
        pressedScale: 0.975,
        haptic: false,
        child: hero,
      );
    }
    return hero;
  }
}

/// What flies between the two screens: the shell with the prompt only, so
/// the text field's caret and keyboard never take part in the flight.
class _Shuttle extends StatelessWidget {
  const _Shuttle({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: D.fieldHeight,
      decoration: BoxDecoration(
        color: Paper.white,
        borderRadius: BorderRadius.circular(D.fieldHeight / 2),
        border: Border.all(color: Leaf.border, width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Leaf.base.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 7),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Leaf.soft,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon2(Glyph.search, size: 18, color: Leaf.base),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(hint, style: T.placeholder, maxLines: 1,
                overflow: TextOverflow.clip),
          ),
        ],
      ),
    );
  }
}
