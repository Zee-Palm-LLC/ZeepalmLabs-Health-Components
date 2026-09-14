import 'package:flutter/material.dart';

import '../../../core/design.dart';

/// One pill, two affordances: a note field that tints with the background, and
/// a primary submit pill nested flush against its right edge.
///
/// The submit pill keeps a fixed cream fill through every mood, which is what
/// makes it read as the primary action no matter what colour the screen is.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.fill,
    required this.chipFill,
    this.note,
    this.onAddNote,
    this.onSubmit,
  });

  /// Darkened background tint used for the pill itself.
  final Color fill;

  /// The undarkened background colour, used for the leading chip so it reads
  /// as punched out of the pill rather than stuck on top of it.
  final Color chipFill;

  /// The note the user has written, or null when there is none yet.
  final String? note;

  final VoidCallback? onAddNote;
  final VoidCallback? onSubmit;

  bool get _hasNote => note != null && note!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: Design.barGutter,
      top: Design.barTop,
      width: Design.barWidth,
      height: Design.barHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(Design.barRadius),
          // Soft and wide rather than tight and dark — it should read as the
          // bar sitting slightly above the page, not as a drop shadow.
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: kInk.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: _NoteField(
              chipFill: chipFill,
              note: _hasNote ? note!.trim() : null,
              onTap: onAddNote,
            )),
            _SubmitPill(onTap: onSubmit),
          ],
        ),
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({required this.chipFill, required this.note, this.onTap});

  final Color chipFill;
  final String? note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasNote = note != null;

    return Material(
      color: const Color(0x00000000),
      borderRadius: BorderRadius.circular(Design.barRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(
            left: Design.barInset,
            right: 10,
          ),
          child: Row(
            children: <Widget>[
              // A chip in the *undamped* background colour: it reads as a hole
              // punched through the pill, which gives the flat bar some depth
              // without a shadow.
              Container(
                width: Design.noteChipSize,
                height: Design.noteChipSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: chipFill, shape: BoxShape.circle),
                child: Icon(
                  hasNote ? Icons.edit_rounded : Icons.add_rounded,
                  size: hasNote ? 16 : 20,
                  color: kInk,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: hasNote
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'NOTE',
                            style: TextStyle(
                              color: kInk.withValues(alpha: 0.45),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            note!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kInk,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ],
                      )
                    // Placeholder weight, not body weight — it should read as
                    // an empty field, not as a label.
                    : Text(
                        'Add note',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: kInk.withValues(alpha: 0.62),
                          fontSize: Design.barLabelSize,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
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

class _SubmitPill extends StatelessWidget {
  const _SubmitPill({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Inset on three sides so a ring of the bar shows around the button.
      padding: const EdgeInsets.fromLTRB(
        0,
        Design.barInset,
        Design.barInset,
        Design.barInset,
      ),
      child: SizedBox(
        width: Design.submitWidth - Design.barInset,
        height: Design.controlHeight,
        child: Material(
          color: kSubmitFill,
          borderRadius: BorderRadius.circular(Design.controlRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Submit',
                  style: TextStyle(
                    color: kSubmitInk,
                    fontSize: Design.barLabelSize,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 16, color: kSubmitInk),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
