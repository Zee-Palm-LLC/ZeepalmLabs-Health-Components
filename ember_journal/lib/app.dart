import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/canvas.dart';
import 'core/glow.dart';
import 'core/motion.dart';
import 'core/palette.dart';
import 'data/journal.dart';
import 'data/prompts.dart';
import 'features/ask_screen.dart';
import 'features/journal_screen.dart';
import 'features/reflect_screen.dart';
import 'features/you_sheet.dart';
import 'widgets/nav_bar.dart';
import 'widgets/screen_swap.dart';

enum Stage { ask, reflect, journal }

class EmberApp extends StatelessWidget {
  const EmberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ember Journal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Ember.void_,
        colorScheme: const ColorScheme.dark(surface: Ember.void_, primary: Ember.gold),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> with TickerProviderStateMixin, ClockMixin {
  late final AnimationController _enter;
  late final AnimationController _swap;
  late final AnimationController _flight;
  late final AnimationController _sheet;

  final deck = PromptDeck(DateTime.now().millisecondsSinceEpoch);
  final store = JournalStore();

  Stage _stage = Stage.ask;
  Widget? _outgoing;
  SwapStyle _style = SwapStyle.depth;
  Offset _origin = const Offset(196, 560);
  bool _forward = true;
  int _tab = 1;
  double _focus = 0;
  Color _tint = Ember.gold;
  double _top = 59;
  Rect _flightFrom = Rect.zero;
  Rect _flightTo = Rect.zero;
  Entry? _inFlight;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1180))..forward();
    _swap = AnimationController(vsync: this, duration: const Duration(milliseconds: 820), value: 1);
    _flight = AnimationController(vsync: this, duration: const Duration(milliseconds: 880));
    _sheet = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  }

  @override
  void dispose() {
    _enter.dispose();
    _swap.dispose();
    _flight.dispose();
    _sheet.dispose();
    super.dispose();
  }

  Widget _screen(Stage stage, Animation<double> enter) {
    return switch (stage) {
      Stage.ask => AskScreen(
        enter: enter,
        seconds: seconds,
        deck: deck,
        onBack: () => _go(Stage.journal, SwapStyle.depth, forward: false),
        onAsk: _openReflection,
        onDepth: _pulse,
      ),
      Stage.reflect => ReflectScreen(
        enter: enter,
        seconds: seconds,
        deck: deck,
        onBack: () => _go(Stage.ask, SwapStyle.depth, forward: false),
        onMood: (i) {
          setState(() => _tint = Mood.all[i].tint);
          _pulse();
        },
        onAdd: _commit,
      ),
      Stage.journal => JournalScreen(enter: enter, seconds: seconds, store: store, landing: _flight),
    };
  }

  void _go(Stage next, SwapStyle style, {bool forward = true, Offset? origin}) {
    if (_stage == next) return;
    setState(() {
      _outgoing = _screen(_stage, const AlwaysStoppedAnimation(1));
      _stage = next;
      _style = style;
      _forward = forward;
      if (origin != null) _origin = origin;
      _tab = next == Stage.journal ? 1 : 0;
    });
    _swap.forward(from: 0).then((_) {
      if (mounted) setState(() => _outgoing = null);
    });
    _enter.forward(from: 0);
  }

  void _pulse() {
    _focusTo(1);
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) _focusTo(0);
    });
  }

  void _focusTo(double value) {
    if (!mounted) return;
    setState(() => _focus = value);
  }

  void _openReflection(Offset origin) {
    _pulse();
    _go(Stage.reflect, SwapStyle.reveal, origin: origin);
  }

  Future<void> _commit(Entry entry, Rect from) async {
    setState(() {
      _inFlight = entry;
      _flightFrom = from;
      _flightTo = Rect.fromLTWH(entryLeft, _top + journalListTop + 4, entryWidth, 218);
      _tint = entry.tone.tint;
    });
    store.add(entry);
    _go(Stage.journal, SwapStyle.dissolve);
    _pulse();
    unawaited(_land());
    await Future.delayed(const Duration(milliseconds: 60));
  }

  Future<void> _land() async {
    await _flight.forward(from: 0);
    if (!mounted) return;
    setState(() => _inFlight = null);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    store.clearHighlight();
  }

  void _navigate(int index) {
    setState(() => _tab = index);
    switch (index) {
      case 0:
        _go(Stage.ask, SwapStyle.depth, forward: false);
      case 1:
        _sheet.reverse();
        if (_stage != Stage.journal) _go(Stage.journal, SwapStyle.depth, forward: false);
      case 2:
        deck.setDepth(Depth.values[(Depth.values.indexOf(deck.depth) + 1) % Depth.values.length]);
        _go(Stage.ask, SwapStyle.depth, forward: false);
      case 3:
        _sheet.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Ember.void_,
        body: DesignCanvas(
          child: Builder(
            builder: (context) {
              final scope = CanvasScope.of(context);
              _top = scope.top;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: _focus),
                      duration: const Duration(milliseconds: 620),
                      curve: gentle,
                      builder: (context, focus, _) => EmberBackdrop(
                        seconds: seconds,
                        intensity: 1 + focus * 0.12,
                        focus: focus * 0.55,
                        tint: _tint,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _swap,
                      builder: (context, _) => ScreenSwap(
                        t: _swap.value,
                        style: _style,
                        origin: _origin,
                        forward: _forward,
                        outgoing: _outgoing,
                        incoming: _screen(_stage, _enter),
                      ),
                    ),
                  ),
                  if (_stage == Stage.journal)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: scope.floor - LiquidNav.height,
                      height: scope.height - scope.floor + LiquidNav.height,
                      child: Staged(
                        animation: _enter,
                        begin: 0.30,
                        end: 0.86,
                        offset: const Offset(0, 54),
                        child: AnimatedBuilder(
                          animation: _sheet,
                          builder: (context, _) => LiquidNav(
                            selected: _tab,
                            seconds: seconds,
                            skirt: scope.height - scope.floor,
                            composing: _sheet.value,
                            onSelect: _navigate,
                            onCompose: () => _go(
                              Stage.reflect,
                              SwapStyle.reveal,
                              origin: Offset(LiquidNav.fabX, scope.floor - 72),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_inFlight != null)
                    AnimatedBuilder(
                      animation: _flight,
                      builder: (context, _) => _FlightCard(
                        entry: _inFlight!,
                        from: _flightFrom,
                        to: _flightTo,
                        t: _flight.value,
                        seconds: seconds,
                      ),
                    ),
                  YouSheet(
                    reveal: _sheet,
                    seconds: seconds,
                    store: store,
                    onClose: () {
                      _sheet.reverse();
                      setState(() => _tab = 1);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FlightCard extends StatelessWidget {
  const _FlightCard({
    required this.entry,
    required this.from,
    required this.to,
    required this.t,
    required this.seconds,
  });

  final Entry entry;
  final Rect from;
  final Rect to;
  final double t;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    final travel = Curves.easeInOutCubic.transform(t.clamp(0.0, 1.0));
    final rect = Rect.lerp(from, to, travel)!;
    final arc = -46 * (1 - (2 * travel - 1).abs());
    final fade = 1 - span(t, 0.78, 1.0);
    return Positioned(
      left: rect.left,
      top: rect.top + arc,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: Opacity(
          opacity: fade.clamp(0.0, 1.0),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateZ(0.06 * (1 - (2 * travel - 1).abs()))
              ..rotateX(-0.22 * (1 - (2 * travel - 1).abs())),
            child: FittedBox(
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              child: EntryCard(entry: entry, seconds: seconds, ghost: true),
            ),
          ),
        ),
      ),
    );
  }
}
