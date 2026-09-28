import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/type.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.entrance});

  static const rect = Rect.fromLTRB(18.5, 170.5, 375.5, 219.5);

  final Animation<double> entrance;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const hint = 'Search recipes, ingredients...';
    final style = inter(14.1, 400, color: const Color(0xFF7B797B));
    final typed = inter(14.1, 500, color: const Color(0xFF1A1920));
    final e = widget.entrance;
    final r = SearchField.rect;
    return AnimatedBuilder(
      animation: e,
      builder: (context, child) {
        final t = span(e.value, 0.2, 0.55, const Cubic(0.2, 1.2, 0.35, 1));
        final w = lerp(r.height, r.width, t.clamp(0.0, 1.2));
        return Opacity(
          opacity: span(e.value, 0.2, 0.3, Curves.linear),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(width: w, height: r.height, child: child),
          ),
        );
      },
      child: GestureDetector(
        onTap: _focus.requestFocus,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          decoration: BoxDecoration(
            color: const Color(0xFFF5EFEA),
            borderRadius: BorderRadius.circular(r.height / 2),
            border: Border.all(
              color: _focus.hasFocus ? const Color(0x66FC2240) : const Color(0xFFEEE8E3),
              width: _focus.hasFocus ? 1.4 : 0.9,
            ),
            boxShadow: [if (_focus.hasFocus) const BoxShadow(color: Color(0x22FC2240), blurRadius: 16, offset: Offset(0, 6))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(r.height / 2),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 46 - r.left - 13,
                  top: 195.4 - r.top - 13,
                  child: AnimatedBuilder(
                    animation: e,
                    builder: (context, child) {
                      final t = span(e.value, 0.22, 0.6, settle);
                      return Transform.rotate(angle: -2.4 * (1 - t), child: child);
                    },
                    child: const PhIcon(Ph.search, size: 26, color: Color(0xFF111016)),
                  ),
                ),
                if (_controller.text.isEmpty && !_focus.hasFocus)
                  AnimatedBuilder(
                    animation: e,
                    builder: (context, _) {
                      final t = span(e.value, 0.42, 0.95, Curves.linear);
                      final n = (hint.length * t).round();
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [Pin(x: 69 - r.left, base: 200.0 - r.top, text: hint.substring(0, n), style: style)],
                      );
                    },
                  ),
                Positioned(
                  left: 70 - r.left - bearing('S', typed),
                  right: 18,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: EditableText(
                      controller: _controller,
                      focusNode: _focus,
                      style: typed,
                      cursorColor: const Color(0xFFFC2240),
                      backgroundCursorColor: const Color(0xFFCCCCCC),
                      cursorWidth: 1.6,
                      cursorRadius: const Radius.circular(1),
                      maxLines: 1,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _focus.unfocus(),
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
