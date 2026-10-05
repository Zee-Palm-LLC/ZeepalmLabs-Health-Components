import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../calendar/day_sheet.dart';
import '../camera/camera_layer.dart';
import '../core/art.dart';
import '../core/canvas.dart';
import '../core/diary.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../mascot/momo.dart';
import '../widgets/surfaces.dart';
import 'composer.dart';
import 'header.dart';
import 'log_menu.dart';
import 'thread.dart';

enum Dock { home, corner, perch }

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.name = 'Maya', this.script});

  final String name;
  final ChatScript? script;

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScript {
  ChatScript();

  ChatScreenState? state;
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _stackKey = GlobalKey();
  final _scroll = ScrollController();
  final _input = TextEditingController();
  final _focus = FocusNode();
  final _pillKey = GlobalKey();
  final _cameraKey = GlobalKey();

  late final AnimationController _intro;
  late final AnimationController _stage;
  late final AnimationController _menu;
  late final AnimationController _camera;
  late final AnimationController _flight;
  late final AnimationController _calendar;
  late final AnimationController _dock;
  late final AnimationController _wave;

  final List<Entry> _entries = [];
  bool _chat = false;
  bool _review = false;
  bool _flying = false;
  bool _menuFromComposer = false;
  bool _busy = false;
  bool _calendarOpen = false;
  Mood _mood = Mood.idle;
  Timer? _moodTimer;
  Dock _dockFrom = Dock.home;
  Dock _dockTo = Dock.home;
  Rect _flightFrom = Rect.zero;
  Rect _flightTo = Rect.zero;
  PhotoEntry? _flyingEntry;
  int _calendarSeed = 0;

  @override
  void initState() {
    super.initState();
    widget.script?.state = this;
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _stage = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _menu = AnimationController(vsync: this, duration: const Duration(milliseconds: 620));
    _camera = AnimationController(vsync: this, duration: const Duration(milliseconds: 640));
    _flight = AnimationController(vsync: this, duration: const Duration(milliseconds: 860));
    _calendar = AnimationController(vsync: this, duration: const Duration(milliseconds: 760));
    _dock = AnimationController(vsync: this, duration: const Duration(milliseconds: 820), value: 1);
    _wave = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _focus.addListener(() => setState(() {}));
    _intro.forward();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _wave.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _moodTimer?.cancel();
    _scroll.dispose();
    _input.dispose();
    _focus.dispose();
    _intro.dispose();
    _stage.dispose();
    _menu.dispose();
    _camera.dispose();
    _flight.dispose();
    _calendar.dispose();
    _dock.dispose();
    _wave.dispose();
    super.dispose();
  }

  double _composerTop(Frame f) => f.height - f.floor - Composer.size.height;

  double _sheetTop(Frame f) => math.max(f.top + 88, f.height - f.bottom - 17.7 - DaySheet.size.height);

  Rect _dockRect(Dock dock, Frame f) {
    switch (dock) {
      case Dock.home:
        final drift = 26 * Curves.easeIn.transform(_stage.value);
        return Rect.fromLTWH(201 - 95.4, f.top + 121 - drift, 190.8, 212);
      case Dock.corner:
        const s = 0.407;
        return Rect.fromLTWH(349 - 90 * s, _composerTop(f) + 1 - 190.5 * s, 180 * s, 200 * s);
      case Dock.perch:
        final deck = _sheetTop(f) + 1;
        final s = ((deck - f.top - 4) / 190.5).clamp(0.42, 0.56);
        final clear = deck - 190.5 * s > f.top + 46;
        final cx = clear ? 322.5 : 268.0;
        return Rect.fromLTWH(cx - 90 * s, deck - 190.5 * s, 180 * s, 200 * s);
    }
  }

  void _moveDock(Dock to, {Duration? duration}) {
    if (to == _dockTo && _dock.value == 1) return;
    _dockFrom = _dockTo;
    _dockTo = to;
    _dock.duration = duration ?? const Duration(milliseconds: 820);
    _dock.forward(from: 0);
  }

  void _setMood(Mood mood, {Duration? hold}) {
    _moodTimer?.cancel();
    setState(() => _mood = mood);
    if (hold != null) {
      _moodTimer = Timer(hold, () {
        if (mounted) setState(() => _mood = Mood.idle);
      });
    }
  }

  late final _signals = Signals(
    thinking: (v) {
      setState(() => _busy = v);
      if (v) {
        _setMood(Mood.think);
      } else if (_mood == Mood.think) {
        _setMood(Mood.idle);
      }
      _toEnd();
    },
    talking: (v) {
      if (v) {
        _setMood(Mood.talk);
      } else if (_mood == Mood.talk) {
        _setMood(Mood.idle);
      }
    },
    done: () {
      _setMood(Mood.happy, hold: const Duration(milliseconds: 1600));
      _toEnd();
    },
    openDay: () => openCalendar(),
  );

  void _toEnd({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      if (jump) {
        _scroll.jumpTo(max);
      } else if ((_scroll.offset - max).abs() > 0.5) {
        _scroll.animateTo(max, duration: const Duration(milliseconds: 720), curve: gentle);
      }
    });
  }

  void openMenu({bool fromComposer = false}) {
    if (_flying) return;
    HapticFeedback.lightImpact();
    _focus.unfocus();
    setState(() => _menuFromComposer = fromComposer || _chat);
    _menu.forward(from: _menu.value);
    _setMood(Mood.curious);
  }

  void closeMenu() {
    _menu.animateBack(0, duration: const Duration(milliseconds: 260), curve: Curves.easeIn);
    if (_mood == Mood.curious) _setMood(Mood.idle);
  }

  void pick(LogSource source) {
    HapticFeedback.selectionClick();
    closeMenu();
    setState(() => _review = source != LogSource.camera);
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _camera.animateTo(1, duration: const Duration(milliseconds: 640), curve: gentle);
    });
  }

  void shutter() => setState(() => _review = true);

  void retake() => setState(() => _review = false);

  void closeCamera() {
    _camera.animateBack(0, duration: const Duration(milliseconds: 460), curve: Curves.easeInCubic).whenComplete(() {
      if (mounted) setState(() => _review = false);
    });
  }

  Future<void> usePhoto() async {
    if (_flying) return;
    HapticFeedback.mediumImpact();
    final frame = Frame.of(context);
    final entry = PhotoEntry(Art.spaghetti);
    final firstChat = !_chat;
    setState(() {
      if (firstChat) {
        _entries.clear();
        _chat = true;
      }
      _entries.add(entry);
      _flying = true;
      _flyingEntry = entry;
      _flightFrom = CameraLayer.viewfinder(frame.top);
      _flightTo = Rect.fromCenter(center: Offset(289, frame.top + 153.4), width: Gap.photo.width, height: Gap.photo.height);
    });
    if (firstChat) _stage.forward(from: 0);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    _toEnd(jump: true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final target = _rectOf(entry.key);
    if (target != null) setState(() => _flightTo = Rect.fromCenter(center: target.center, width: Gap.photo.width, height: Gap.photo.height));
    _camera.animateBack(0, duration: const Duration(milliseconds: 620), curve: Curves.easeInCubic);
    Future<void>.delayed(const Duration(milliseconds: 260), () {
      if (mounted) _moveDock(Dock.corner);
    });
    await _flight.forward(from: 0).orCancel.catchError((_) {});
    if (!mounted) return;
    entry.landed.value = true;
    HapticFeedback.lightImpact();
    setState(() {
      _flying = false;
      _flyingEntry = null;
      _review = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    setState(() => _entries.add(MealEntry(entry.asset)));
    _toEnd();
  }

  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stack == null || !box.hasSize) return null;
    final center = stack.globalToLocal(box.localToGlobal(box.size.center(Offset.zero)));
    return Rect.fromCenter(center: center, width: box.size.width, height: box.size.height);
  }

  void openCalendar() {
    if (_calendarOpen) return;
    HapticFeedback.lightImpact();
    _focus.unfocus();
    closeMenu();
    setState(() {
      _calendarOpen = true;
      _calendarSeed++;
    });
    _calendar.animateTo(1, duration: const Duration(milliseconds: 760), curve: Curves.linear);
    _moveDock(Dock.perch, duration: const Duration(milliseconds: 900));
  }

  void closeCalendar() {
    HapticFeedback.selectionClick();
    _moveDock(_chat ? Dock.corner : Dock.home, duration: const Duration(milliseconds: 760));
    _calendar.animateBack(0, duration: const Duration(milliseconds: 520), curve: Curves.linear).whenComplete(() {
      if (mounted) setState(() => _calendarOpen = false);
    });
    _setMood(Mood.idle);
  }

  void send() {
    final text = _input.text.trim();
    if (text.isEmpty || _busy) return;
    _input.clear();
    _focus.unfocus();
    final firstChat = !_chat;
    setState(() {
      if (firstChat) {
        _entries.clear();
        _chat = true;
      }
      _entries.add(UserEntry(text));
    });
    if (firstChat) {
      _stage.forward(from: 0);
      _moveDock(Dock.corner);
    }
    _toEnd();
    Future<void>.delayed(const Duration(milliseconds: 520), () {
      if (!mounted) return;
      setState(() => _entries.add(AnswerEntry(intentOf(text))));
      _toEnd();
    });
  }

  void stop() {
    HapticFeedback.selectionClick();
    setState(() => _busy = false);
  }

  void startOver() {
    if (!_chat) {
      _setMood(Mood.happy, hold: const Duration(milliseconds: 900));
      _wave.forward(from: 0);
      return;
    }
    HapticFeedback.mediumImpact();
    _focus.unfocus();
    setState(() => _busy = false);
    _stage.animateBack(0, duration: const Duration(milliseconds: 620), curve: Curves.easeOut).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _chat = false;
        _entries.clear();
      });
      _intro.forward(from: 0.35);
    });
    _moveDock(Dock.home);
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _wave.forward(from: 0);
    });
  }

  bool get _anyOverlay => _menu.value > 0 || _camera.value > 0 || _calendarOpen;

  void _back() {
    if (_calendarOpen) return closeCalendar();
    if (_camera.value > 0) return _review ? retake() : closeCamera();
    if (_menu.value > 0) return closeMenu();
    startOver();
  }

  String get _greeting {
    final hour = DiaryScope.read(context).now.hour;
    if (hour < 5) return 'Hey night owl,';
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final diary = DiaryScope.of(context);
    return PopScope(
      canPop: !_chat && !_anyOverlay,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: Shade.ground,
        resizeToAvoidBottomInset: false,
        body: Listener(
          onPointerDown: (e) => Gaze.pointer.value = e.position,
          onPointerMove: (e) => Gaze.pointer.value = e.position,
          onPointerUp: (_) => Future<void>.delayed(const Duration(milliseconds: 900), () => Gaze.pointer.value = null),
          child: AnimatedBuilder(
            animation: Listenable.merge([_intro, _stage, _menu, _camera, _flight, _calendar, _dock, _wave]),
            builder: (context, _) {
              return Stack(
                key: _stackKey,
                children: [
                  _ground(frame),
                  if (!_chat || _stage.value < 1) _greetingLayer(frame),
                  if (_chat) _thread(frame),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Opacity(
                      opacity: span(_intro.value, 0.05, 0.35),
                      child: ChatHeader(top: frame.top, onBack: _back, onCompose: startOver),
                    ),
                  ),
                  _composerLayer(frame),
                  if (_calendarOpen) ..._calendarLayer(frame, diary),
                  _mascot(frame),
                  if (_menu.value > 0) ..._menuLayer(frame),
                  if (_camera.value > 0) _cameraLayer(frame),
                  if (_flying && _flyingEntry != null) _flightLayer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _ground(Frame f) {
    final halo = 1 - _stage.value;
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Shade.ground),
          child: Opacity(
            opacity: halo * span(_intro.value, 0, 0.4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, ((f.top + 205) / f.height) * 2 - 1),
                  radius: 0.62,
                  colors: [Colors.white.withValues(alpha: 0.75), Colors.white.withValues(alpha: 0.32), Colors.white.withValues(alpha: 0)],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _greetingLayer(Frame f) {
    final out = _stage.value;
    final i = _intro.value;
    Widget word(String text, double baseline, double begin) {
      final a = span(i, begin, begin + 0.28, Curves.linear);
      final e = Curves.easeOutCubic.transform(a);
      return Positioned(
        left: 0,
        right: 0,
        top: f.top + baseline - 30.5 * interAscent,
        child: Opacity(
          opacity: a,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - e)),
            child: ImageFiltered(
              enabled: a < 1,
              imageFilter: ui.ImageFilter.blur(sigmaX: 6 * (1 - e), sigmaY: 6 * (1 - e)),
              child: Center(child: BaseText(text, style: Typo.greet)),
            ),
          ),
        ),
      );
    }

    final pill = span(i, 0.55, 0.95, Curves.linear);
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: _chat,
        child: Opacity(
          opacity: 1 - span(out, 0, 0.6),
          child: Transform.translate(
            offset: Offset(0, 22 * Curves.easeIn.transform(out)),
            child: Stack(
              children: [
                word(_greeting, 399.8, 0.25),
                word('${widget.name}.', 437.6, 0.38),
                Positioned(
                  left: 129,
                  top: f.top + 473,
                  child: Opacity(
                    opacity: 1 - _menu.value.clamp(0.0, 1.0) * 0.0,
                    child: _LogPill(key: _pillKey, t: pill, onTap: () => openMenu()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _thread(Frame f) {
    final lead = _entries.isEmpty || _entries.first is PhotoEntry ? 41.4 : 80.0;
    final children = <Widget>[SizedBox(height: f.top + lead)];
    for (var k = 0; k < _entries.length; k++) {
      final entry = _entries[k];
      if (k > 0) {
        children.add(SizedBox(height: switch (entry) {
          MealEntry() => 24,
          AnswerEntry() => 20,
          UserEntry() => 25,
          PhotoEntry() => 25,
        }));
      }
      children.add(switch (entry) {
        PhotoEntry() => PhotoBubble(key: ValueKey(entry), entry: entry),
        MealEntry() => Padding(
          key: ValueKey(entry),
          padding: const EdgeInsets.only(left: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: MealCard(entry: entry, signals: _signals, photoKey: _lastPhotoKey(k)),
          ),
        ),
        UserEntry() => UserBubble(key: ValueKey(entry), entry: entry),
        AnswerEntry() => Padding(
          key: ValueKey(entry),
          padding: const EdgeInsets.only(left: 24),
          child: Align(alignment: Alignment.centerLeft, child: AnswerCard(entry: entry, signals: _signals)),
        ),
      });
    }
    children.add(SizedBox(height: f.floor + Composer.size.height + 99.5));
    final fade = span(_stage.value, 0.3, 1);
    return Positioned.fill(
      child: Opacity(
        opacity: _stage.isAnimating && _stage.status == AnimationStatus.reverse ? fade : 1,
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (_) => false,
          child: SingleChildScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ),
      ),
    );
  }

  GlobalKey _lastPhotoKey(int index) {
    for (var k = index; k >= 0; k--) {
      final e = _entries[k];
      if (e is PhotoEntry) return e.key;
    }
    return GlobalKey();
  }

  Widget _composerLayer(Frame f) {
    final a = span(_intro.value, 0.1, 0.5, Curves.linear);
    final s = spring(a, bounce: 0.2, freq: 1.6);
    return Positioned(
      left: 15.2,
      top: _composerTop(f),
      child: Opacity(
        opacity: a,
        child: Transform.translate(
          offset: Offset(0, 40 * (1 - s)),
          child: Composer(
            controller: _input,
            focus: _focus,
            busy: _busy,
            cameraKey: _cameraKey,
            onCamera: () => openMenu(fromComposer: true),
            onCalendar: openCalendar,
            onSend: send,
            onStop: stop,
          ),
        ),
      ),
    );
  }

  List<Widget> _menuLayer(Frame f) {
    final composerTop = _composerTop(f);
    final fromComposer = _menuFromComposer;
    final top = fromComposer ? composerTop - 10 - LogMenu.size.height : f.top + 532;
    final pivot = fromComposer ? const Alignment(-0.82, 1) : const Alignment(0.52, -1);
    return [
      Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: closeMenu,
          child: ColoredBox(color: Shade.ground.withValues(alpha: 0.18 * _menu.value.clamp(0.0, 1.0))),
        ),
      ),
      Positioned(
        left: 23.5,
        top: top,
        child: LogMenu(t: _menu.value, pivot: pivot, onPick: pick),
      ),
    ];
  }

  Widget _cameraLayer(Frame f) {
    final t = _camera.value;
    return Positioned.fill(
      child: Transform.translate(
        offset: Offset(0, (1 - t) * f.height),
        child: CameraLayer(
          review: _review,
          photoHidden: _flying,
          onClose: closeCamera,
          onShutter: shutter,
          onRetake: retake,
          onUse: usePhoto,
        ),
      ),
    );
  }

  Widget _flightLayer() {
    final t = _flight.value;
    final e = const Cubic(0.5, 0.0, 0.18, 1.0).transform(t);
    final land = spring(t, bounce: 0.2, freq: 1.5);
    final rect = Rect.lerp(_flightFrom, _flightTo, e)!;
    final lift = -70 * math.sin(e * math.pi);
    final angle = lerp(0, Gap.photoTilt, land) + 0.12 * math.sin(e * math.pi);
    final radius = lerp(24, 15, e);
    final border = lerp(0, 3, span(t, 0.2, 0.7));
    final tilt = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..rotateX(-0.35 * math.sin(e * math.pi))
      ..rotateZ(angle);
    return Positioned(
      left: rect.left,
      top: rect.top + lift,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: Transform(
          alignment: Alignment.center,
          transform: tilt,
          child: Photo(_flyingEntry!.asset, radius: radius - border, border: border),
        ),
      ),
    );
  }

  double _sheetY(Frame f) {
    final t = _calendar.value;
    final open = _calendar.status != AnimationStatus.reverse;
    final rise = open ? spring(t, bounce: 0.16, freq: 1.4) : Curves.easeIn.transform(t);
    final top = _sheetTop(f);
    return top + (1 - rise) * (f.height - top + 40);
  }

  List<Widget> _calendarLayer(Frame f, Diary diary) {
    final t = _calendar.value;
    return [
      Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: closeCalendar,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 22 * t, sigmaY: 22 * t),
            child: ColoredBox(color: Shade.groundHi.withValues(alpha: 0.5 * t)),
          ),
        ),
      ),
      Positioned(
        left: 15.2,
        top: _sheetY(f),
        child: DaySheet(
          key: ValueKey(_calendarSeed),
          diary: diary,
          onSelect: (meals) => _setMood(meals.isEmpty ? Mood.curious : Mood.happy, hold: const Duration(milliseconds: 1400)),
        ),
      ),
      Positioned(
        left: 362.3 - 22.25,
        top: f.top + 22 - 22.25,
        child: Opacity(
          opacity: span(t, 0.3, 1),
          child: Transform.scale(scale: lerp(0.6, 1, spring(span(t, 0.2, 1, Curves.linear))), child: GlassCircle(icon: Ph.x, iconSize: 22, onTap: closeCalendar)),
        ),
      ),
    ];
  }

  Widget _mascot(Frame f) {
    final from = _dockRect(_dockFrom, f);
    final to = _dockRect(_dockTo, f);
    final t = _dock.value;
    final e = const Cubic(0.45, 0, 0.2, 1).transform(t);
    var rect = Rect.lerp(from, to, e)!;
    final hop = from.center.dy > to.center.dy ? 90.0 : 60.0;
    rect = rect.shift(Offset(0, -hop * math.sin(e * math.pi) * (t < 1 ? 1 : 0)));
    if (_calendarOpen && _calendar.value > 0) {
      final deck = _sheetY(f) + 1;
      final feet = rect.top + rect.height * 190.5 / 200;
      if (feet > deck) rect = rect.shift(Offset(0, deck - feet));
    }
    double squash;
    if (t < 0.18) {
      squash = 0.12 * math.sin(t / 0.18 * math.pi);
    } else if (t < 0.82) {
      squash = -0.09 * math.sin((t - 0.18) / 0.64 * math.pi);
    } else {
      final k = (t - 0.82) / 0.18;
      squash = 0.14 * math.sin(k * math.pi) * (1 - k * 0.4);
    }
    final intro = span(_intro.value, 0, 0.45, Curves.linear);
    final drop = _chat ? 1.0 : spring(intro, bounce: 0.35, freq: 2.0);
    final introSquash = _chat ? 0.0 : 0.16 * math.sin(span(_intro.value, 0.18, 0.4, Curves.linear) * math.pi);
    final w = _wave.value;
    final waving = w <= 0 || w >= 1 ? 0.0 : math.sin(w * math.pi).clamp(0.0, 1.0) * (0.75 + 0.25 * math.sin(w * math.pi * 6));
    final mood = _wave.isAnimating && _mood == Mood.idle ? Mood.happy : _mood;
    return Positioned.fromRect(
      rect: rect.shift(Offset(0, -120 * (1 - drop))),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _wave.forward(from: 0);
          _setMood(Mood.happy, hold: const Duration(milliseconds: 1200));
        },
        child: Opacity(
          opacity: _chat ? 1 : span(_intro.value, 0, 0.12),
          child: Momo(
            mood: mood,
            squash: squash + introSquash,
            wave: waving,
            lean: t < 1 ? 0.18 * math.sin(e * math.pi) * (to.center.dx > from.center.dx ? 1 : -1) : 0,
          ),
        ),
      ),
    );
  }
}

class _LogPill extends StatelessWidget {
  const _LogPill({super.key, required this.t, required this.onTap});

  final double t;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = spring(t, bounce: 0.3, freq: 1.8);
    return Opacity(
      opacity: span(t, 0, 0.4),
      child: Transform.scale(
        scale: lerp(0.8, 1, s),
        child: Pressable(
          onTap: onTap,
          scale: 0.94,
          child: Container(
            width: 144,
            height: 48,
            decoration: pillDecoration(radius: 24),
            child: Stack(
              children: [
                Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(24), child: const _Sheen())),
                const Positioned(left: 30 - 10, top: 24.5 - 10, child: PhIcon(Ph.camera, size: 20, color: Color(0xFF85827B))),
                Positioned(left: 48, top: 28.9 - 14.6 * interAscent, child: BaseText('Log a meal', style: Typo.pill)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Sheen extends StatelessWidget {
  const _Sheen();

  @override
  Widget build(BuildContext context) {
    return Tick(
      builder: (context, t, _) {
        final cycle = (t % 5.2) / 5.2;
        final x = -2.0 + cycle * 5.6;
        if (x > 1.6) return const SizedBox.expand();
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(x - 0.5, -1),
              end: Alignment(x + 0.5, 1),
              colors: [Colors.white.withValues(alpha: 0), Shade.apricot.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0)],
              stops: const [0, 0.5, 1],
            ),
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}
