import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design.dart';
import '../../core/motion/entrance.dart';
import '../../core/motion/pressable.dart';
import '../../core/motion/routes.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../data/symptoms.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/mic_button.dart';
import '../../widgets/rolling_number.dart';
import '../../widgets/search_field.dart';
import '../../widgets/symptom_tile.dart';
import '../report/report_screen.dart';

/// Screen two: the search field, landed at the top, with live results.
///
/// The field arrives as a Hero from the assess screen; focus is requested
/// only once the flight has landed, so the keyboard rises after the field
/// and never during. Results deal themselves out on every change of query.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _text =
      TextEditingController(text: widget.initialQuery);
  final FocusNode _focus = FocusNode();

  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: D.entrance,
  );

  /// Re-run on each query change so the list re-deals rather than snaps.
  late final AnimationController _reflow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    value: 1,
  );

  List<Symptom> _results = const <Symptom>[];
  bool _focusRequested = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _results = _query(widget.initialQuery);
    _in.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_focusRequested) return;
    _focusRequested = true;
    final route = ModalRoute.of(context);
    if (route == null) {
      _focus.requestFocus();
      return;
    }
    void onStatus(AnimationStatus s) {
      if (s == AnimationStatus.completed) {
        route.animation!.removeStatusListener(onStatus);
        if (mounted) _focus.requestFocus();
      }
    }

    if (route.animation!.isCompleted) {
      _focus.requestFocus();
    } else {
      route.animation!.addStatusListener(onStatus);
    }
  }

  @override
  void dispose() {
    _in.dispose();
    _reflow.dispose();
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<Symptom> _query(String q) =>
      q.trim().isEmpty ? Catalogue.popular : Catalogue.search(q);

  void _onChanged(String q) {
    final next = _query(q);
    if (_sameIds(next, _results)) return;
    setState(() => _results = next);
    _reflow.forward(from: 0);
  }

  bool _sameIds(List<Symptom> a, List<Symptom> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  Future<void> _open(Symptom symptom, GlobalKey key) async {
    if (_busy) return;
    _busy = true;
    _focus.unfocus();
    final origin = rectOf(key);
    final assessment = Catalogue.assess(symptom);
    final route = origin == null
        ? SharedAxisRoute<void>(
            builder: (BuildContext _) => ReportScreen(assessment: assessment),
          )
        : ContainerTransformRoute<void>(
            origin: origin,
            originChild: TileBody(symptom: symptom),
            builder: (BuildContext _) => ReportScreen(assessment: assessment),
          );
    await Navigator.of(context).push<void>(route);
    _busy = false;
  }

  void _info(Symptom symptom) {
    HapticFeedback.selectionClick();
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: const Color(0xFF1F272C).withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (BuildContext context, Animation<double> a,
              Animation<double> _) =>
          _InfoCard(symptom: symptom),
      transitionBuilder: (BuildContext context, Animation<double> a,
          Animation<double> _, Widget child) {
        final pop = CurvedAnimation(parent: a, curve: D.pop,
            reverseCurve: Curves.easeIn);
        return FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.82, end: 1).animate(pop),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final empty = _text.text.trim().isEmpty;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const AuroraBackground(drift: 0.6),
          SafeArea(
            bottom: false,
            child: AnimatedBuilder(
              animation: Listenable.merge(<Listenable>[_in, _reflow]),
              builder: (BuildContext context, Widget? _) {
                final t = _in.value;
                final r = _reflow.value;
                return Column(
                  children: <Widget>[
                    HeaderBar(
                      title: 'Symptom Assessment',
                      t: 1,
                      onBack: () => Navigator.maybePop(context),
                      onClose: () =>
                          Navigator.of(context).popUntil((Route r) => r.isFirst),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: D.gutter),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Rise(
                          t: D.hintIn.transform(t),
                          distance: 8,
                          child: Text(
                            "For example, you can search 'runny nose'",
                            style: T.label,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: D.gutter),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: SearchField(
                              controller: _text,
                              focusNode: _focus,
                              onChanged: _onChanged,
                              onClear: () => _onChanged(''),
                            ),
                          ),
                          const SizedBox(width: D.micGap),
                          const MicButton(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: D.gutter),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Rise(
                          t: D.foundIn.transform(t),
                          distance: 8,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                empty ? 'Popular symptoms: ' : 'Symptoms found: ',
                                style: T.label,
                              ),
                              RollingNumber(
                                  value: _results.length, style: T.label),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _results.isEmpty
                          ? _Empty(t: D.foundIn.transform(t))
                          : _ResultsList(
                              results: _results,
                              t: t,
                              reflow: r,
                              onOpen: _open,
                              onInfo: _info,
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsList extends StatefulWidget {
  const _ResultsList({
    required this.results,
    required this.t,
    required this.reflow,
    required this.onOpen,
    required this.onInfo,
  });

  final List<Symptom> results;
  final double t;
  final double reflow;
  final void Function(Symptom, GlobalKey) onOpen;
  final ValueChanged<Symptom> onInfo;

  @override
  State<_ResultsList> createState() => _ResultsListState();
}

class _ResultsListState extends State<_ResultsList> {
  final Map<String, GlobalKey> _keys = <String, GlobalKey>{};

  GlobalKey _keyFor(Symptom s) => _keys.putIfAbsent(s.id, GlobalKey.new);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(D.gutter, 2, D.gutter, 24 + bottom),
      itemCount: widget.results.length,
      separatorBuilder: (BuildContext _, int _) =>
          const SizedBox(height: D.tileGap),
      itemBuilder: (BuildContext context, int i) {
        final s = widget.results[i];
        // First arrival uses the page entrance; later changes use the
        // shorter reflow, which staggers less so long lists do not lag.
        final enter = D.stagger(
            widget.t, D.tilesStart, i.clamp(0, 7), D.tileStagger, D.tileSpan);
        final re = D.stagger(widget.reflow, 0, i.clamp(0, 9), 0.05, 0.5);
        final p = enter < 1 ? enter : re;
        return Rise(
          t: D.outExpo.transform(p),
          distance: enter < 1 ? 28 : 14,
          child: SymptomTile(
            key: ValueKey<String>(s.id),
            tileKey: _keyFor(s),
            symptom: s,
            onTap: () => widget.onOpen(s, _keyFor(s)),
            onInfo: () => widget.onInfo(s),
          ),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    return Rise(
      t: t,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(D.gutter, 26, D.gutter, 0),
        child: Column(
          children: <Widget>[
            Image.asset('assets/emoji/leaf.png', width: 56, height: 56),
            const SizedBox(height: 12),
            Text('Nothing matches that yet', style: T.tileTitle),
            const SizedBox(height: 4),
            Text(
              'Try a simpler word, like "pain" or "cough".',
              style: T.tileSub,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// The "?" popover: what this symptom means and where it sits.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.symptom});

  final Symptom symptom;

  @override
  Widget build(BuildContext context) {
    final hint = symptom.hint;
    final related = symptom.terms.take(3).join(', ');
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Material(
          color: Paper.white,
          borderRadius: BorderRadius.circular(D.radius),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (symptom.emoji != null)
                  Image.asset(symptom.emojiAsset, width: 54, height: 54)
                else
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: Leaf.soft,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        symptom.name.substring(0, 1),
                        style: T.style(22, weight: 800, color: Leaf.deep),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(symptom.name,
                    style: T.cardTitle, textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(
                  hint != null
                      ? '$hint. People also describe it as $related.'
                      : 'People also describe it as $related.',
                  style: T.cardBody,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Pressable(
                  onTap: () => Navigator.of(context).pop(),
                  pressedScale: 0.95,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    decoration: BoxDecoration(
                      gradient: Leaf.button,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: Center(child: Text('Got it', style: T.button)),
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
