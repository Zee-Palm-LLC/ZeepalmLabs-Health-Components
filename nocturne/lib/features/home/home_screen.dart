import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../core/widgets.dart';
import '../../scene/orb.dart';
import '../../sound/mixer.dart';
import '../../sound/sounds.dart';

String greetingFor(DateTime now) {
  final h = now.hour;
  if (h >= 5 && h < 12) return 'Good Morning';
  if (h >= 12 && h < 17) return 'Good Afternoon';
  return 'Good Evening';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenMix, this.now});

  final VoidCallback onOpenMix;
  final DateTime? now;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  final _query = TextEditingController();
  final _focus = FocusNode();
  Category _category = Category.all;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _query.addListener(() => setState(() {}));
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _intro.dispose();
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _toggle(Sound sound) {
    final mixer = MixerScope.read(context);
    final wasIn = mixer.contains(sound);
    final ok = mixer.toggle(sound);
    if (!ok) {
      HapticFeedback.heavyImpact();
      Toast.show(
        context,
        'Your mix holds up to four sounds',
        glyph: G.moonFill,
      );
      return;
    }
    final count = mixer.sounds.length;
    Toast.show(
      context,
      wasIn
          ? '${sound.label} left  ·  $count in mix'
          : '${sound.label} added  ·  $count in mix',
      glyph: wasIn ? G.close : G.check,
      action: count > 0 ? 'Open Mix' : null,
      onAction: widget.onOpenMix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / 393;
    final top = mq.padding.top;
    final navH = 78 * s + mq.padding.bottom;
    return GestureDetector(
      onTap: () => _focus.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: top, bottom: navH + 24 * s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Staged(
              controller: _intro,
              end: 0.5,
              slide: 10,
              child: _Header(
                scale: s,
                greeting: greetingFor(widget.now ?? DateTime.now()),
              ),
            ),
            SizedBox(height: 30 * s),
            Staged(
              controller: _intro,
              begin: 0.1,
              end: 0.6,
              slide: 10,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 21 * s),
                child: _SearchField(
                  controller: _query,
                  focus: _focus,
                  scale: s,
                ),
              ),
            ),
            SizedBox(height: 19 * s),
            Staged(
              controller: _intro,
              begin: 0.18,
              end: 0.68,
              slide: 10,
              child: _Chips(
                scale: s,
                selected: _category,
                onSelect: (c) => setState(() => _category = c),
              ),
            ),
            SizedBox(height: 22 * s),
            _OrbGrid(
              scale: s,
              intro: _intro,
              category: _category,
              query: _query.text,
              onTap: _toggle,
              onLongPress: (sound) {
                final mixer = MixerScope.read(context);
                if (!mixer.contains(sound)) mixer.toggle(sound);
                widget.onOpenMix();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.scale, required this.greeting});

  final double scale;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 104 * s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 24 * s,
            top: 20 * s,
            child: Text(
              greeting,
              style: Typo.ui(
                16.5 * s,
                color: const Color(0xFFC9C8DA),
                weight: 380,
                spacing: 0.1 * s,
              ),
            ),
          ),
          Positioned(
            left: 24 * s,
            top: 43 * s,
            child: Text(
              'Let’s Create Your\nPeace Tonight',
              style: Typo.serifText(
                26 * s,
                spacing: -0.15 * s,
                height: 1.33,
                color: const Color(0xFFF3F1FA),
                weight: 430,
              ),
            ),
          ),
          Positioned(
            right: 23 * s,
            top: 18 * s,
            child: Pressable(
              onTap: () =>
                  Toast.show(context, 'Sleep well, dreamer', glyph: G.moonFill),
              child: GlassCircle(
                size: 44 * s,
                fill: const Color(0x14FFFFFF),
                border: const Color(0x2EC7BFFF),
                child: Glyph(
                  G.user,
                  size: 20 * s,
                  color: const Color(0xFFF1EEFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focus,
    required this.scale,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final active = focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Ease.out,
      height: 48 * s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24 * s),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x14FFFFFF), Color(0x0AFFFFFF)],
        ),
        border: Border.all(
          color: active ? const Color(0x66B9A9FF) : const Color(0x1FFFFFFF),
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: const Color(0xFF8C7BFF).withValues(alpha: 0.18),
                  blurRadius: 18,
                ),
              ]
            : const [],
      ),
      child: Row(
        children: [
          SizedBox(width: 17 * s),
          Glyph(
            G.search,
            size: 20 * s,
            color: const Color(0xFFC8C5DC),
            stroke: 1.5 * s,
          ),
          SizedBox(width: 11 * s),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focus,
              cursorColor: Night.lavender,
              cursorWidth: 1.5,
              style: Typo.ui(13.5 * s, color: Night.text),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search sounds, moods or moments...',
                hintStyle: Typo.ui(13 * s, color: const Color(0xFF9E9BB8)),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: controller.text.isEmpty ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: Pressable(
              onTap: controller.clear,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14 * s),
                child: Glyph(G.close, size: 16 * s, color: Night.textDim),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({
    required this.scale,
    required this.selected,
    required this.onSelect,
  });

  final double scale;
  final Category selected;
  final ValueChanged<Category> onSelect;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      height: 40 * s,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        padding: EdgeInsets.symmetric(horizontal: 21 * s),
        itemCount: Category.values.length,
        separatorBuilder: (_, _) => SizedBox(width: 9 * s),
        itemBuilder: (context, i) {
          final c = Category.values[i];
          return Center(
            child: _Chip(
              label: c.label,
              active: c == selected,
              scale: s,
              onTap: () => onSelect(c),
            ),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool active;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Ease.out,
        height: 35 * s,
        constraints: BoxConstraints(minWidth: 50 * s),
        padding: EdgeInsets.symmetric(horizontal: 13 * s),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17.5 * s),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: active
                ? const [Color(0xFFC6B8FF), Color(0xFFAE9CF6)]
                : const [Color(0x0AFFFFFF), Color(0x05FFFFFF)],
          ),
          border: Border.all(
            color: active ? const Color(0x66FFFFFF) : const Color(0x21FFFFFF),
            width: active ? 0.8 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF9F8BFF).withValues(alpha: 0.5),
                    blurRadius: 16 * s,
                    spreadRadius: -2 * s,
                  ),
                ]
              : const [BoxShadow(color: Color(0x009F8BFF), blurRadius: 0)],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 320),
          style: Typo.ui(
            12 * s,
            color: active ? Night.ink : const Color(0xFFE2E0EE),
            weight: active ? 520 : 440,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _OrbGrid extends StatelessWidget {
  const _OrbGrid({
    required this.scale,
    required this.intro,
    required this.category,
    required this.query,
    required this.onTap,
    required this.onLongPress,
  });

  final double scale;
  final Animation<double> intro;
  final Category category;
  final String query;
  final ValueChanged<Sound> onTap;
  final ValueChanged<Sound> onLongPress;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final mixer = MixerScope.of(context);
    final visible = Sound.values
        .where((x) => x.matches(category, query))
        .toList();
    final rows = (visible.length / 3).ceil();
    final pitchX = 124.5 * s;
    final pitchY = 149.5 * s;
    final d = 86 * s;
    final width = MediaQuery.of(context).size.width;
    final height = rows == 0 ? 160 * s : rows * pitchY;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 520),
      curve: Ease.out,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (visible.isEmpty)
            Positioned.fill(
              child: Center(
                child: Text(
                  'No sounds match that yet',
                  style: Typo.serifText(17 * s, color: Night.textDim),
                ),
              ),
            ),
          for (final sound in Sound.values)
            _GridSlot(
              key: ValueKey(sound),
              sound: sound,
              index: visible.indexOf(sound),
              lastIndex: Sound.values.indexOf(sound),
              center: width / 2,
              pitchX: pitchX,
              pitchY: pitchY,
              diameter: d,
              scale: s,
              intro: intro,
              selected: mixer.contains(sound),
              onTap: () => onTap(sound),
              onLongPress: () => onLongPress(sound),
            ),
        ],
      ),
    );
  }
}

class _GridSlot extends StatefulWidget {
  const _GridSlot({
    super.key,
    required this.sound,
    required this.index,
    required this.lastIndex,
    required this.center,
    required this.pitchX,
    required this.pitchY,
    required this.diameter,
    required this.scale,
    required this.intro,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final Sound sound;
  final int index;
  final int lastIndex;
  final double center;
  final double pitchX;
  final double pitchY;
  final double diameter;
  final double scale;
  final Animation<double> intro;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<_GridSlot> createState() => _GridSlotState();
}

class _GridSlotState extends State<_GridSlot> {
  late int _placed = widget.index >= 0 ? widget.index : widget.lastIndex;

  @override
  void didUpdateWidget(_GridSlot old) {
    super.didUpdateWidget(old);
    if (widget.index >= 0) _placed = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final shown = widget.index >= 0;
    final col = _placed % 3;
    final row = _placed ~/ 3;
    final cellW = widget.pitchX;
    final left = widget.center + (col - 1) * widget.pitchX - cellW / 2;
    final top = row * widget.pitchY;
    final delay =
        0.22 + (widget.lastIndex ~/ 3) * 0.1 + (widget.lastIndex % 3) * 0.04;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 560),
      curve: Ease.out,
      left: left,
      top: top,
      width: cellW,
      height: widget.pitchY,
      child: IgnorePointer(
        ignoring: !shown,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 360),
          opacity: shown ? 1 : 0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 460),
            curve: Ease.out,
            scale: shown ? 1 : 0.7,
            child: Staged(
              controller: widget.intro,
              begin: delay,
              end: delay + 0.45,
              slide: 18,
              scaleFrom: 0.85,
              child: Pressable(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                scale: 0.92,
                child: Column(
                  children: [
                    Hero(
                      tag: 'orb-${widget.sound.name}',
                      flightShuttleBuilder: orbFlight(widget.sound),
                      createRectTween: arcTween,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: widget.selected ? 1 : 0),
                        duration: const Duration(milliseconds: 600),
                        curve: Ease.out,
                        builder: (context, t, _) => Orb(
                          sound: widget.sound,
                          diameter: widget.diameter,
                          glow: 0.85 + 0.35 * t,
                          life: 0.9 + 0.2 * t,
                        ),
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    Text(
                      widget.sound.label,
                      style: Typo.ui(
                        13.4 * s,
                        color: const Color(0xFFF1F0F8),
                        weight: 500,
                        spacing: 0.05,
                      ),
                    ),
                    SizedBox(height: 5 * s),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Ease.out,
                      width: widget.selected ? 14 * s : 0,
                      height: 2 * s,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: widget.sound.glow.withValues(alpha: 0.9),
                        boxShadow: [
                          BoxShadow(
                            color: widget.sound.glow.withValues(alpha: 0.8),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

HeroFlightShuttleBuilder orbFlight(Sound sound) {
  return (context, animation, direction, from, to) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => LayoutBuilder(
        builder: (context, box) => Orb(
          sound: sound,
          diameter: box.biggest.shortestSide,
          glow: 1.1,
          life: 1.1,
        ),
      ),
    );
  };
}
