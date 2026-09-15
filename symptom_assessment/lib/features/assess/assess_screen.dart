import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/design.dart';
import '../../core/motion/entrance.dart';
import '../../core/motion/routes.dart';
import '../../core/type.dart';
import '../../data/symptoms.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/glass_orb.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/mic_button.dart';
import '../../widgets/privacy_card.dart';
import '../../widgets/search_field.dart';
import '../../widgets/symptom_chip.dart';
import '../search/search_screen.dart';

/// Screen one: "What symptom is bothering you most?"
///
/// Everything arrives on one controller, top to bottom, with the orb and the
/// search field popping on a spring while text settles on an expo curve.
/// Tapping the field flies it to the top of the results screen; tapping a
/// chip sends a copy of the chip into the field first, then follows it.
class AssessScreen extends StatefulWidget {
  const AssessScreen({super.key});

  @override
  State<AssessScreen> createState() => _AssessScreenState();
}

class _AssessScreenState extends State<AssessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: D.entrance,
  )..forward();

  final GlobalKey _fieldKey = GlobalKey();
  final List<GlobalKey> _chipKeys = List<GlobalKey>.generate(
    Catalogue.popular.length,
    (int _) => GlobalKey(),
  );
  bool _listening = false;
  bool _busy = false;

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  Future<void> _openSearch({String query = ''}) async {
    if (_busy) return;
    _busy = true;
    await Navigator.of(context).push<void>(
      SharedAxisRoute<void>(
        builder: (BuildContext _) => SearchScreen(initialQuery: query),
      ),
    );
    _busy = false;
  }

  /// A copy of the chip lifts off, arcs into the search field and shrinks
  /// away; the results screen opens as it lands.
  Future<void> _flyChip(int index) async {
    if (_busy) return;
    final from = rectOf(_chipKeys[index]);
    final to = rectOf(_fieldKey);
    final symptom = Catalogue.popular[index];
    if (from == null || to == null) {
      await _openSearch(query: symptom.name);
      return;
    }
    _busy = true;
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext _) => _FlyingChip(
        symptom: symptom,
        from: from,
        to: to,
        onLanded: () {
          entry.remove();
        },
      ),
    );
    overlay.insert(entry);
    // Push a beat before the copy finishes, so the flight overlaps the route.
    await Future<void>.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;
    _busy = false;
    await _openSearch(query: symptom.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const AuroraBackground(),
          SafeArea(
            bottom: false,
            child: AnimatedBuilder(
              animation: _in,
              builder: (BuildContext context, Widget? _) =>
                  _page(context, _in.value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _page(BuildContext context, double t) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: <Widget>[
        HeaderBar(
          title: 'Symptom Assessment',
          t: D.headerIn.transform(t),
          onBack: () => Navigator.maybePop(context),
          onClose: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: D.orbBlockTop),
                        Center(
                          child: GlassOrb(
                            size: D.orb,
                            haloScale: D.haloIn.transform(t),
                            appear: D.orbIn.transform(t),
                            excited: _listening,
                          ),
                        ),
                        const SizedBox(height: D.headlineGap),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: WordReveal(
                            text: 'What symptom is bothering you most?',
                            style: T.headline,
                            t: D.headlineIn.transform(t),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Rise(
                          t: D.subIn.transform(t),
                          distance: 10,
                          child: Text(
                            "For example, you can search 'runny nose'.",
                            style: T.sub,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: D.fieldGap),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: D.gutter),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Rise(
                                  t: D.fieldIn.transform(t),
                                  distance: 26,
                                  scaleFrom: 0.9,
                                  child: SearchField(
                                    key: _fieldKey,
                                    readOnly: true,
                                    onTap: _openSearch,
                                  ),
                                ),
                              ),
                              const SizedBox(width: D.micGap),
                              Rise(
                                t: D.micIn.transform(t),
                                distance: 26,
                                scaleFrom: 0.6,
                                child: MicButton(
                                  onListeningChanged: (bool on) =>
                                      setState(() => _listening = on),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: D.chipsGap),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: D.gutter),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Rise(
                              t: D.chipsLabelIn.transform(t),
                              distance: 8,
                              child: Text('Popular searches', style: T.label),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: D.chipHeight + 12,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            clipBehavior: Clip.none,
                            padding: const EdgeInsets.symmetric(
                                horizontal: D.gutter, vertical: 6),
                            itemCount: Catalogue.popular.length,
                            separatorBuilder: (BuildContext _, int _) =>
                                const SizedBox(width: 10),
                            itemBuilder: (BuildContext context, int i) {
                              final p = D.stagger(t, D.chipsStart,
                                  math.min(i, 5), D.chipStagger, D.chipSpan);
                              return Rise(
                                t: D.pop.transform(p),
                                distance: 18,
                                scaleFrom: 0.8,
                                child: SymptomChip(
                                  chipKey: _chipKeys[i],
                                  symptom: Catalogue.popular[i],
                                  onTap: () => _flyChip(i),
                                ),
                              );
                            },
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              D.gutter, 0, D.gutter, 16 + bottomInset),
                          child: Rise(
                            t: D.privacyIn.transform(t),
                            distance: 40,
                            child: const PrivacyCard(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// The chip copy in flight. Arcs up and across on a quadratic curve, shrinks
/// toward the field's lens and fades in the last third.
class _FlyingChip extends StatefulWidget {
  const _FlyingChip({
    required this.symptom,
    required this.from,
    required this.to,
    required this.onLanded,
  });

  final Symptom symptom;
  final Rect from;
  final Rect to;
  final VoidCallback onLanded;

  @override
  State<_FlyingChip> createState() => _FlyingChipState();
}

class _FlyingChipState extends State<_FlyingChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
  )
    ..addStatusListener((AnimationStatus s) {
      if (s == AnimationStatus.completed) widget.onLanded();
    })
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.from.center;
    // Land on the lens disc at the left of the field.
    final end = Offset(widget.to.left + 27, widget.to.center.dy);
    final lift = Offset((start.dx + end.dx) / 2, math.min(start.dy, end.dy) - 70);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (BuildContext context, Widget? child) {
          final t = D.emphasized.transform(_c.value);
          // quadratic bezier: start -> lift -> end
          final u = 1 - t;
          final pos = start * (u * u) + lift * (2 * u * t) + end * (t * t);
          final scale = 1 - 0.55 * Curves.easeIn.transform(t);
          final fade = 1 - ((t - 0.62) / 0.38).clamp(0.0, 1.0);
          return Stack(
            children: <Widget>[
              Positioned(
                left: pos.dx - widget.from.width / 2,
                top: pos.dy - widget.from.height / 2,
                width: widget.from.width,
                height: widget.from.height,
                child: Opacity(
                  opacity: fade,
                  child: Transform.scale(scale: scale, child: child),
                ),
              ),
            ],
          );
        },
        child: Material(
          type: MaterialType.transparency,
          child: ChipBody(symptom: widget.symptom, selected: true),
        ),
      ),
    );
  }
}
