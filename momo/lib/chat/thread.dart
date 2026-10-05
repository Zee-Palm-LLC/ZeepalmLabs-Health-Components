import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/art.dart';
import '../core/diary.dart';
import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/kinetic.dart';
import '../widgets/surfaces.dart';

sealed class Entry {
  Entry() : key = GlobalKey();

  final GlobalKey key;
}

class PhotoEntry extends Entry {
  PhotoEntry(this.asset);

  final String asset;
  final landed = ValueNotifier<bool>(false);
}

class MealEntry extends Entry {
  MealEntry(this.photo);

  final String photo;
}

class UserEntry extends Entry {
  UserEntry(this.text);

  final String text;
}

enum Intent { protein, carbs, calories, other }

class AnswerEntry extends Entry {
  AnswerEntry(this.intent);

  final Intent intent;
}

Intent intentOf(String text) {
  final t = text.toLowerCase();
  if (t.contains('protein')) return Intent.protein;
  if (t.contains('carb') || t.contains('sugar')) return Intent.carbs;
  if (t.contains('calor') || t.contains('kcal') || t.contains('eat')) return Intent.calories;
  return Intent.other;
}

class Signals {
  const Signals({required this.thinking, required this.talking, required this.done, required this.openDay});

  final ValueChanged<bool> thinking;
  final ValueChanged<bool> talking;
  final VoidCallback done;
  final VoidCallback openDay;
}

abstract final class Gap {
  static const photo = Size(168, 224);
  static const photoTilt = 0.0436;
  static const card = Size(326, 279);
  static const answer = Size(326, 225.7);
  static const bubble = Size(60, 38);
}

class PhotoBubble extends StatelessWidget {
  const PhotoBubble({super.key, required this.entry});

  final PhotoEntry entry;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 402 - 289 - 84),
        child: ValueListenableBuilder<bool>(
          valueListenable: entry.landed,
          builder: (context, landed, child) => Opacity(opacity: landed ? 1 : 0, child: child),
          child: Transform.rotate(
            angle: Gap.photoTilt,
            child: SizedBox.fromSize(
              key: entry.key,
              size: Gap.photo,
              child: Photo(entry.asset, radius: 15, border: 3),
            ),
          ),
        ),
      ),
    );
  }
}

class Morph extends StatelessWidget {
  const Morph({super.key, required this.t, required this.size, required this.child});

  final double t;
  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = spring(t, bounce: 0.18, freq: 1.6);
    final w = lerp(Gap.bubble.width, size.width, s);
    final h = lerp(Gap.bubble.height, size.height, s);
    final r = lerp(19, 24, s.clamp(0.0, 1.0));
    return SizedBox.fromSize(
      size: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: w,
            height: h,
            child: DecoratedBox(decoration: cardDecoration(radius: r)),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: w,
            height: h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(r),
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: size.width,
                maxWidth: size.width,
                minHeight: size.height,
                maxHeight: size.height,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key, required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1 - span(t, 0.0, 0.35, Curves.easeOut),
      child: const SizedBox(width: 60, height: 38, child: Center(child: Dots())),
    );
  }
}

enum MealPhase { typing, asking, analyzing, done }

class MealCard extends StatefulWidget {
  const MealCard({super.key, required this.entry, required this.signals, required this.photoKey, this.instant = false});

  final MealEntry entry;
  final Signals signals;
  final GlobalKey photoKey;
  final bool instant;

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> with TickerProviderStateMixin {
  late final AnimationController _open;
  late final AnimationController _ask;
  late final AnimationController _pick;
  late final AnimationController _thumb;
  late final AnimationController _reveal;
  MealPhase _phase = MealPhase.typing;
  Course? _picked;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _open = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _ask = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _pick = AnimationController(vsync: this, duration: const Duration(milliseconds: 440));
    _thumb = AnimationController(vsync: this, duration: const Duration(milliseconds: 820));
    _reveal = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    if (widget.instant) {
      _phase = MealPhase.done;
      _picked = Course.dinner;
      _open.value = 1;
      _ask.value = 1;
      _pick.value = 1;
      _thumb.value = 1;
      _reveal.value = 1;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.signals.thinking(true);
      });
      _timer = Timer(const Duration(milliseconds: 1250), _expand);
    }
  }

  Future<void> _expand() async {
    if (!mounted) return;
    widget.signals.thinking(false);
    setState(() => _phase = MealPhase.asking);
    widget.signals.talking(true);
    _open.forward();
    await Future<void>.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    await _ask.forward().orCancel.catchError((_) {});
    if (mounted) widget.signals.talking(false);
  }

  Future<void> _choose(Course course) async {
    if (_phase != MealPhase.asking || _picked != null) return;
    HapticFeedback.selectionClick();
    setState(() => _picked = course);
    await _pick.forward().orCancel.catchError((_) {});
    if (!mounted) return;
    setState(() => _phase = MealPhase.analyzing);
    widget.signals.thinking(true);
    _thumb.forward();
    await Future<void>.delayed(const Duration(milliseconds: 1150));
    if (!mounted) return;
    widget.signals.thinking(false);
    final diary = DiaryScope.read(context);
    diary.log(Meal(course: course, name: Diary.supper.name, kcal: Diary.supper.kcal, art: Diary.supper.art, protein: Diary.supper.protein, photo: true));
    setState(() => _phase = MealPhase.done);
    widget.signals.talking(true);
    HapticFeedback.lightImpact();
    await _reveal.forward().orCancel.catchError((_) {});
    if (!mounted) return;
    widget.signals.talking(false);
    widget.signals.done();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _open.dispose();
    _ask.dispose();
    _pick.dispose();
    _thumb.dispose();
    _reveal.dispose();
    super.dispose();
  }

  String get _question {
    final hour = DiaryScope.read(context).now.hour;
    if (hour < 11) return 'For breakfast?';
    if (hour < 16) return 'For lunch?';
    if (hour < 22) return 'For dinner?';
    return 'A late snack?';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_open, _ask, _pick, _thumb, _reveal]),
      builder: (context, _) {
        return SizedBox.fromSize(
          key: widget.entry.key,
          size: Gap.card,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (_phase == MealPhase.typing)
                Positioned(left: 0, top: 0, child: _typingShell())
              else
                Morph(
                  t: _open.value,
                  size: Gap.card,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (_phase == MealPhase.asking || _pick.value < 1) ..._askLayer(),
                      if (_phase == MealPhase.analyzing || _phase == MealPhase.done) ..._resultLayer(),
                    ],
                  ),
                ),
              if (_phase == MealPhase.analyzing || _phase == MealPhase.done) _flyingThumb(),
            ],
          ),
        );
      },
    );
  }

  Widget _typingShell() {
    return Entrance(
      duration: const Duration(milliseconds: 520),
      builder: (context, a) => AnimatedBuilder(
        animation: a,
        builder: (context, child) => Pop(t: a.value, from: 0.4, alignment: Alignment.bottomLeft, child: child!),
        child: Container(
          width: Gap.bubble.width,
          height: Gap.bubble.height,
          decoration: cardDecoration(radius: 19),
          alignment: Alignment.center,
          child: const Dots(),
        ),
      ),
    );
  }

  List<Widget> _askLayer() {
    final fadeOut = 1 - span(_pick.value, 0.45, 1, Curves.easeIn);
    final title = span(_ask.value, 0.0, 0.42, Curves.linear);
    final tiles = <Widget>[];
    const spots = [Offset(19.5, 67), Offset(167, 67), Offset(19.5, 169), Offset(167, 169)];
    for (var i = 0; i < Course.values.length; i++) {
      final course = Course.values[i];
      final appear = span(_ask.value, 0.28 + i * 0.12, 0.28 + i * 0.12 + 0.36, Curves.linear);
      final picked = _picked == course;
      final others = _picked != null && !picked;
      final pulse = picked ? math.sin(_pick.value * math.pi) : 0.0;
      tiles.add(
        Positioned(
          left: spots[i].dx,
          top: spots[i].dy,
          child: Opacity(
            opacity: others ? (1 - span(_pick.value, 0, 0.5)) * fadeOut : fadeOut,
            child: Pop(
              t: appear,
              from: 0.72,
              dy: 10,
              child: Transform.scale(
                scale: (1 + 0.05 * pulse) * (others ? lerp(1, 0.92, span(_pick.value, 0, 0.6)) : 1),
                child: _Tile(course: course, highlight: picked ? span(_pick.value, 0, 0.4) : 0, onTap: () => _choose(course)),
              ),
            ),
          ),
        ),
      );
    }
    return [
      Positioned(
        left: 20.7,
        top: 42.7 - 22.5 * interAscent,
        child: Opacity(opacity: fadeOut, child: Typed(_question, progress: title, style: Typo.ask)),
      ),
      ...tiles,
    ];
  }

  List<Widget> _resultLayer() {
    final r = _reveal.value;
    final name = span(r, 0.0, 0.22, Curves.linear);
    final count = span(r, 0.06, 0.5, Curves.easeOutCubic);
    final meta = span(r, 0.32, 0.5);
    final body = span(r, 0.46, 0.8, Curves.linear);
    final chip = span(r, 0.72, 1.0, Curves.linear);
    final waiting = _phase == MealPhase.analyzing;
    return [
      if (waiting)
        Positioned(
          left: 152.7,
          top: 70,
          child: Opacity(opacity: span(_thumb.value, 0.5, 1), child: const Dots()),
        ),
      if (!waiting) ...[
        Positioned(left: 152.7, top: 54.8 - 13.2 * interAscent, child: Typed(Diary.supper.name, progress: name, style: Typo.dish)),
        Positioned(
          left: 150.4,
          top: 113.8 - 52.5 * interAscent,
          child: Opacity(
            opacity: span(r, 0.04, 0.14),
            child: Odometer(value: Diary.supper.kcal, progress: count, style: Typo.big),
          ),
        ),
        Positioned(
          left: 152.7,
          top: 137.6 - 11.4 * interAscent,
          child: Opacity(
            opacity: meta,
            child: Transform.translate(
              offset: Offset(0, 4 * (1 - meta)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BaseText('kcal · estimated', style: Typo.meta),
                  const SizedBox(width: 9),
                  Transform.translate(offset: const Offset(0, -0.6), child: const PhIcon(Ph.pencil, size: 13, color: Shade.faint)),
                ],
              ),
            ),
          ),
        ),
        Positioned(left: 20.3, top: 179.9 - 17 * interAscent, child: Typed('A little over. Worth it.', progress: body, style: Typo.body)),
        Positioned(
          left: 19.5,
          top: 201,
          child: Pop(t: chip, from: 0.7, alignment: Alignment.centerLeft, child: DayChip(onTap: widget.signals.openDay)),
        ),
      ],
    ];
  }

  Widget _flyingThumb() {
    final t = _thumb.value;
    final e = Curves.easeInOutCubic.transform(t);
    final land = spring(t, bounce: 0.25, freq: 1.8);
    final card = context.findRenderObject() as RenderBox?;
    final photo = widget.photoKey.currentContext?.findRenderObject() as RenderBox?;
    var from = const Offset(183, -231);
    if (card != null && photo != null && card.attached && photo.attached && card.hasSize && photo.hasSize) {
      final pc = photo.localToGlobal(photo.size.center(Offset.zero));
      final cc = card.localToGlobal(const Offset(79.5, 90.9));
      final scale = card.getTransformTo(null).getMaxScaleOnAxis();
      from = (pc - cc) / scale;
    }
    final arc = Offset(from.dx * (1 - e), from.dy * (1 - e) - math.sin(e * math.pi) * 40);
    final scale = lerp(2, 1, land);
    final angle = lerp(Gap.photoTilt, -0.07, e);
    return Positioned(
      left: 79.5 - 43,
      top: 90.9 - 57,
      child: Opacity(
        opacity: span(t, 0, 0.08),
        child: Transform.translate(
          offset: arc,
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: scale,
              child: const SizedBox(width: 86, height: 114, child: Photo(Art.spaghetti, radius: 9, border: 2)),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.course, required this.highlight, required this.onTap});

  final Course course;
  final double highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.94,
      child: Container(
        width: 138.5,
        height: 90,
        decoration: BoxDecoration(
          color: Color.lerp(Shade.tile, Colors.white, highlight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color.lerp(const Color(0x0F000000), Shade.peach.withValues(alpha: 0.7), highlight)!, width: 0.9 + highlight * 0.6),
          boxShadow: [
            const BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
            BoxShadow(color: Shade.coral.withValues(alpha: 0.16 * highlight), blurRadius: 18, offset: const Offset(0, 6)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 69.25 - 31,
              top: 33.3 - 31,
              child: Tick(
                builder: (context, t, child) {
                  final bob = highlight > 0 ? math.sin(t * 9) * 3 * highlight : 0.0;
                  return Transform.rotate(angle: bob * 0.03, child: Transform.translate(offset: Offset(0, -bob.abs()), child: child));
                },
                child: Image.asset(course.art, width: 62, height: 62, filterQuality: FilterQuality.medium),
              ),
            ),
            Positioned(left: 0, right: 0, top: 78.6 - 12.9 * interAscent, child: Center(child: BaseText(course.title, style: Typo.tile))),
          ],
        ),
      ),
    );
  }
}

class DayChip extends StatelessWidget {
  const DayChip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.93,
      child: Container(
        width: 124.5,
        height: 45,
        decoration: pillDecoration(radius: 22.5, lifted: false),
        child: Stack(
          children: [
            const Positioned(left: 24.8 - 8.5, top: 22.5 - 8.5, child: PhIcon(Ph.calendar, size: 17, color: Color(0xFF5E5B55))),
            Positioned(left: 40.4, top: 26.9 - 13.9 * interAscent, child: BaseText('My day', style: Typo.link)),
            const Positioned(left: 102.5 - 6.5, top: 22.5 - 6.5, child: PhIcon(Ph.arrowUpRight, size: 13, color: Color(0xFF7D7A73))),
          ],
        ),
      ),
    );
  }
}

class UserBubble extends StatelessWidget {
  const UserBubble({super.key, required this.entry});

  final UserEntry entry;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 23.5),
        child: Entrance(
          duration: const Duration(milliseconds: 650),
          builder: (context, a) => AnimatedBuilder(
            animation: a,
            builder: (context, child) {
              final s = spring(a.value, bounce: 0.3, freq: 1.9);
              return Opacity(
                opacity: span(a.value, 0, 0.3),
                child: Transform.translate(
                  offset: Offset(0, 60 * (1 - s)),
                  child: Transform.scale(scale: lerp(0.7, 1, s), alignment: Alignment.bottomRight, child: child),
                ),
              );
            },
            child: Container(
              key: entry.key,
              height: 46.7,
              padding: const EdgeInsets.only(left: 16.5, right: 17),
              decoration: BoxDecoration(
                color: Shade.cocoa,
                borderRadius: BorderRadius.circular(23.35),
                boxShadow: const [BoxShadow(color: Color(0x1F2E2B27), blurRadius: 14, offset: Offset(0, 5))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [BaseText(entry.text, style: Typo.bubble)]),
            ),
          ),
        ),
      ),
    );
  }
}

class AnswerCard extends StatefulWidget {
  const AnswerCard({super.key, required this.entry, required this.signals});

  final AnswerEntry entry;
  final Signals signals;

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> with TickerProviderStateMixin {
  late final AnimationController _open;
  late final AnimationController _reveal;
  late final AnimationController _copied;
  bool _typing = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _open = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _reveal = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _copied = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.signals.thinking(true);
    });
    _timer = Timer(const Duration(milliseconds: 950), _expand);
  }

  Future<void> _expand() async {
    if (!mounted) return;
    widget.signals.thinking(false);
    setState(() => _typing = false);
    widget.signals.talking(true);
    _open.forward();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    await _reveal.forward().orCancel.catchError((_) {});
    if (!mounted) return;
    widget.signals.talking(false);
    widget.signals.done();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _open.dispose();
    _reveal.dispose();
    _copied.dispose();
    super.dispose();
  }

  ({String label, int value, String unit, String meta, String body, String art}) _content(Diary diary) {
    switch (widget.entry.intent) {
      case Intent.protein:
        return (label: 'Protein', value: diary.proteinToday, unit: 'g', meta: 'Today · estimated', body: 'Solid fuel. Big plans.', art: Art.protein);
      case Intent.carbs:
        final carbs = (diary.todayMeals.fold(0, (s, m) => s + m.kcal) * 0.48 / 4).round();
        return (label: 'Carbs', value: carbs, unit: 'g', meta: 'Today · estimated', body: 'Energy in the tank.', art: Art.dinner);
      case Intent.calories:
        final kcal = diary.todayMeals.fold(0, (s, m) => s + m.kcal);
        return (label: 'Calories', value: kcal, unit: 'kcal', meta: 'Today · guide 2,000', body: 'Right around your guide.', art: Art.lunch);
      case Intent.other:
        return (label: 'Meals', value: diary.todayMeals.length, unit: 'today', meta: 'Ask me about protein', body: 'Food talk is my thing.', art: Art.snack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _content(DiaryScope.read(context));
    return AnimatedBuilder(
      animation: Listenable.merge([_open, _reveal, _copied]),
      builder: (context, _) {
        final r = _reveal.value;
        return SizedBox.fromSize(
          key: widget.entry.key,
          size: Gap.answer,
          child: _typing
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Entrance(
                    duration: const Duration(milliseconds: 520),
                    builder: (context, a) => AnimatedBuilder(
                      animation: a,
                      builder: (context, child) => Pop(t: a.value, from: 0.4, alignment: Alignment.bottomLeft, child: child!),
                      child: Container(
                        width: Gap.bubble.width,
                        height: Gap.bubble.height,
                        decoration: cardDecoration(radius: 19),
                        alignment: Alignment.center,
                        child: const Dots(),
                      ),
                    ),
                  ),
                )
              : Morph(
                  t: _open.value,
                  size: Gap.answer,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 71.7 - 46,
                        top: 78.2 - 46,
                        child: Pop(
                          t: span(r, 0.0, 0.35, Curves.linear),
                          from: 0.3,
                          child: Tick(
                            builder: (context, t, child) => Transform.rotate(angle: 0.04 * wave(t, 4.2), child: child),
                            child: SizedBox.square(
                              dimension: 92,
                              child: widget.entry.intent == Intent.protein
                                  ? const EggArt()
                                  : Image.asset(c.art, width: 92, height: 92, filterQuality: FilterQuality.medium),
                            ),
                          ),
                        ),
                      ),
                      Positioned(left: 134.7, top: 43.1 - 12.7 * interAscent, child: Typed(c.label, progress: span(r, 0.05, 0.2, Curves.linear), style: Typo.label)),
                      Positioned(
                        left: 133,
                        top: 97.2 - 52.5 * interAscent,
                        child: Opacity(
                          opacity: span(r, 0.1, 0.2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Odometer(value: c.value, progress: span(r, 0.1, 0.5, Curves.easeOutCubic), style: Typo.big, grouped: true),
                              const SizedBox(width: 5),
                              Opacity(opacity: span(r, 0.4, 0.55), child: BaseText(c.unit, style: Typo.unitBig)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 134.3,
                        top: 121.2 - 11.4 * interAscent,
                        child: Opacity(opacity: span(r, 0.42, 0.58), child: BaseText(c.meta, style: Typo.meta)),
                      ),
                      Positioned(left: 20.7, top: 157.4 - 16.4 * interAscent, child: Typed(c.body, progress: span(r, 0.55, 0.88, Curves.linear), style: Typo.answer)),
                      Positioned(
                        left: 284 - 18,
                        top: 184.7 - 18,
                        child: Opacity(
                          opacity: span(r, 0.85, 1),
                          child: Pressable(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: '${c.label}: ${c.value} ${c.unit}'));
                              _copied.forward(from: 0);
                            },
                            child: SizedBox.square(
                              dimension: 36,
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Opacity(opacity: 1 - _bump(_copied.value), child: const PhIcon(Ph.copy, size: 18, color: Color(0xFFA9A8A3))),
                                    Opacity(
                                      opacity: _bump(_copied.value),
                                      child: Transform.scale(scale: lerp(0.5, 1, spring(span(_copied.value, 0, 0.3, Curves.linear))), child: const PhIcon(Ph.check, size: 18, color: Shade.coral)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  double _bump(double t) => t <= 0 ? 0 : (t < 0.15 ? t / 0.15 : (t > 0.8 ? (1 - t) / 0.2 : 1));
}

class EggArt extends StatelessWidget {
  const EggArt({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -6,
          top: -4,
          child: Transform.rotate(angle: -0.32, child: Image.asset(Art.protein, width: 76, height: 76, filterQuality: FilterQuality.medium)),
        ),
        Positioned(
          left: 28,
          top: 26,
          width: 64,
          height: 67,
          child: Tick(
            builder: (context, t, _) => CustomPaint(painter: _HalfEggPainter(wobble: 0.6 * math.sin(t * 2.4))),
          ),
        ),
      ],
    );
  }
}

class _HalfEggPainter extends CustomPainter {
  _HalfEggPainter({required this.wobble});

  final double wobble;

  @override
  void paint(Canvas canvas, Size size) {
    final white = Path()
      ..moveTo(size.width * 0.5, 0)
      ..cubicTo(size.width * 0.86, 0, size.width, size.height * 0.42, size.width, size.height * 0.62)
      ..cubicTo(size.width, size.height * 0.88, size.width * 0.78, size.height, size.width * 0.5, size.height)
      ..cubicTo(size.width * 0.22, size.height, 0, size.height * 0.88, 0, size.height * 0.62)
      ..cubicTo(0, size.height * 0.42, size.width * 0.14, 0, size.width * 0.5, 0)
      ..close();
    canvas.drawPath(
      white.shift(const Offset(1.5, 4)),
      Paint()
        ..color = const Color(0x2E6B4A2A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    final bounds = Offset.zero & size;
    canvas.drawPath(
      white,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.45),
          radius: 1.0,
          colors: [Colors.white, Color(0xFFF6F1E7), Color(0xFFE6DCCB)],
          stops: [0, 0.6, 1],
        ).createShader(bounds),
    );
    canvas.drawPath(
      white,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x22000000),
    );
    final yolkCenter = Offset(size.width * 0.52, size.height * 0.6 + wobble * 0.4);
    final yolk = Rect.fromCenter(center: yolkCenter, width: size.width * 0.56 + wobble, height: size.width * 0.54 - wobble * 0.5);
    canvas.drawOval(
      yolk.inflate(2.2),
      Paint()..color = const Color(0x33F2A33A),
    );
    canvas.drawOval(
      yolk,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.35),
          radius: 0.9,
          colors: [Color(0xFFFFE07A), Color(0xFFFFB21E), Color(0xFFF08A12)],
          stops: [0, 0.55, 1],
        ).createShader(yolk),
    );
    canvas.drawOval(
      Rect.fromCenter(center: yolkCenter + Offset(-yolk.width * 0.18, -yolk.height * 0.2), width: yolk.width * 0.28, height: yolk.height * 0.18),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
  }

  @override
  bool shouldRepaint(_HalfEggPainter old) => old.wobble != wobble;
}
