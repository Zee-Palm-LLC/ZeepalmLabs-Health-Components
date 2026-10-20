import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/data.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/style.dart';
import '../widgets/kit.dart';

/// Medication names live only here. On the open spread they show plainly;
/// on a single screen they stay veiled until the person asks.
class MedsCard extends StatefulWidget {
  const MedsCard({super.key, required this.veiled});

  final bool veiled;

  @override
  State<MedsCard> createState() => MedsCardState();
}

class MedsCardState extends State<MedsCard> {
  bool revealed = false;
  final takenNow = <String>{};

  void toggle() {
    HapticFeedback.lightImpact();
    setState(() => revealed = !revealed);
  }

  void take(Med m) {
    HapticFeedback.mediumImpact();
    setState(() => takenNow.add(m.name));
  }

  @override
  Widget build(BuildContext context) {
    final hidden = widget.veiled && !revealed;
    return Panel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHead(
            accent: Accent.ink,
            glyph: Glyph.lock,
            title: 'Medications',
            trailing: Tag(widget.veiled ? 'Hidden on this screen' : 'Only shown when open', color: Tone.slate),
          ),
          const SizedBox(height: 8),
          for (final m in Demo.meds) _row(m, hidden),
          if (widget.veiled)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: toggle,
                  style: TextButton.styleFrom(
                    foregroundColor: Tone.ink,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    backgroundColor: Tone.track,
                  ),
                  icon: GlyphIcon(revealed ? Glyph.lock : Glyph.eye, size: 16, weight: 18),
                  label: Text(revealed ? 'Hide names' : 'Show names', style: Typo.chip),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(Med m, bool hidden) {
    final taken = m.taken ?? (takenNow.contains(m.name) ? 'now' : null);
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Tone.line))),
      child: Row(
        children: [
          SizedBox(width: 44, child: Text(m.time, style: Typo.meta)),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: swift,
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(a), child: child),
              ),
              layoutBuilder: (current, previous) => Stack(alignment: Alignment.centerLeft, children: [...previous, ?current]),
              child: hidden
                  ? Row(
                      key: const ValueKey('veil'),
                      children: [
                        Flexible(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 92),
                            height: 10,
                            decoration: BoxDecoration(color: Tone.line, borderRadius: BorderRadius.circular(999)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('1 dose', style: Typo.meta),
                      ],
                    )
                  : Text.rich(
                      key: const ValueKey('name'),
                      TextSpan(text: m.name, children: [TextSpan(text: '  ${m.dose}', style: Typo.meta)]),
                      style: Typo.row,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            switchInCurve: settle,
            transitionBuilder: (child, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: child)),
            child: taken != null
                ? Tag(taken == 'now' ? 'Taken just now' : 'Taken $taken', key: ValueKey('t$taken'), glyph: Glyph.check, color: Tone.slate)
                : Semantics(
                    key: const ValueKey('due'),
                    button: true,
                    label: 'Due at ${m.time}. Mark as taken',
                    child: GestureDetector(
                      onTap: () => take(m),
                      child: const SizedBox(
                        height: 44,
                        child: Center(child: Tag('Due · Mark taken', background: Tone.dueBg, color: Tone.dueInk)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
