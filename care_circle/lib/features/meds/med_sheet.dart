import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/store.dart';

class MedSheet extends StatefulWidget {
  const MedSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x6B2A2230),
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 460),
        reverseDuration: Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (context) => const MedSheet(),
    );
  }

  @override
  State<MedSheet> createState() => _MedSheetState();
}

class _MedSheetState extends State<MedSheet> with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _float;
  late final AnimationController _celebrate;
  final _store = CareStore.instance;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
    _float = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat();
    _celebrate = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _store.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _store.removeListener(_changed);
    _enter.dispose();
    _float.dispose();
    _celebrate.dispose();
    super.dispose();
  }

  void _take() {
    if (_store.morningTaken) return;
    _store.markTaken();
    _celebrate.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottom = math.max(media.viewPadding.bottom, 12.0);
    final maxHeight = media.size.height - math.max(media.viewPadding.top, 20) - 70;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: Hue.canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 10, 16, bottom + 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(color: const Color(0xFFDCD4E6), borderRadius: BorderRadius.circular(3)),
                  ),
                ),
                const SizedBox(height: 16),
                _rise(0, _header()),
                const SizedBox(height: 18),
                _rise(0.06, _doses()),
                const SizedBox(height: 16),
                _rise(0.12, _schedule()),
                const SizedBox(height: 12),
                _rise(0.18, _assignee()),
                const SizedBox(height: 16),
                _rise(
                  0.24,
                  PrimaryButton(
                    label: 'Send gentle reminder',
                    leading: Glyph.send,
                    height: 54,
                    done: _store.reminderSent,
                    doneLabel: 'Reminder sent to ${CareStore.byId(_store.assignee).name}',
                    onTap: _store.sendReminder,
                  ),
                ),
                const SizedBox(height: 10),
                _rise(0.28, _takeButton()),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const GlyphIcon(Glyph.heart, size: 14, color: Hue.irisLight, fill: Hue.irisLight, stroke: 1),
                    const SizedBox(width: 6),
                    Text('Better together', style: jakarta(12, 600, color: Hue.inkMute)),
                    const SizedBox(width: 6),
                    const GlyphIcon(Glyph.leaf, size: 14, color: Hue.sage, stroke: 1.8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rise(double begin, Widget child) {
    return AnimatedBuilder(
      animation: _enter,
      child: child,
      builder: (context, child) {
        final v = span(_enter.value, begin, begin + 0.55, Curves.easeOutCubic);
        if (v >= 1) return child!;
        return Transform.translate(offset: Offset(0, 36 * (1 - v)), child: child);
      },
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(center: Alignment(-0.3, -0.4), colors: [Colors.white, Color(0xFFE9E1FF)]),
            boxShadow: [BoxShadow(color: Hue.iris.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          alignment: Alignment.center,
          child: const GlyphIcon(Glyph.pill, size: 28, color: Hue.iris, stroke: 2, fill: Color(0x337B5CF5)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Metformin 500mg', style: jakarta(22, 800, spacing: -0.6)),
              const SizedBox(height: 2),
              Text('For blood sugar management', style: jakarta(14, 550, color: Hue.inkSoft)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _doses() {
    return Row(
      children: [
        Column(
          children: [
            SizedBox.square(
              dimension: 148,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_enter, _celebrate]),
                        builder: (context, _) => CustomPaint(
                          painter: _DoseRing(
                            draw: span(_enter.value, 0.3, 1, Curves.easeInOutCubic),
                            doses: [for (final s in _store.slots) s.dose],
                            celebrate: _celebrate.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: Listenable.merge([_float, _celebrate]),
                    child: const RepaintBoundary(
                      child: CustomPaint(size: Size(58, 26), painter: _Capsule()),
                    ),
                    builder: (context, child) {
                      final wave = math.sin(_float.value * math.pi * 2);
                      return Transform.translate(
                        offset: Offset(0, wave * 4),
                        child: Transform.rotate(
                          angle: -0.6 + wave * 0.08 + Curves.easeOutBack.transform(_celebrate.value) * math.pi * 2,
                          child: child,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Daily dose',
                    style: jakarta(12, 600, color: Hue.inkSoft),
                  ),
                  TextSpan(
                    text: '  ·  ',
                    style: jakarta(12, 800, color: Hue.blush),
                  ),
                  TextSpan(
                    text: '3 times a day',
                    style: jakarta(12, 600, color: Hue.inkSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, slot) in _store.slots.indexed) ...[if (i > 0) const SizedBox(height: 14), _legend(slot)],
            ],
          ),
        ),
      ],
    );
  }

  Widget _legend(Slot slot) {
    final (tone, label) = _status(slot.dose);
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: slot.dose == Dose.upcoming ? const Color(0xFFD8D2E3) : tone,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [BoxShadow(color: tone.withValues(alpha: 0.35), blurRadius: 8)],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(slot.label, style: jakarta(14.5, 700)),
            Row(
              children: [
                Text(slot.time, style: jakarta(14, 650, color: Hue.inkSoft)),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    label,
                    key: ValueKey(label),
                    style: jakarta(12.5, 700, color: tone),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  (Color, String) _status(Dose dose) {
    return switch (dose) {
      Dose.missed => (Hue.coral, 'Missed'),
      Dose.taken => (Hue.sage, 'Taken'),
      Dose.upcoming => (Hue.iris, 'Upcoming'),
    };
  }

  Widget _schedule() {
    const tones = [Hue.honey, Color(0xFFE08B3E), Hue.iris];
    return Surface(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
      child: Column(
        children: [
          Row(
            children: [
              const GlyphIcon(Glyph.calendar, size: 20, color: Hue.iris, stroke: 2),
              const SizedBox(width: 10),
              Text('Schedule', style: jakarta(16, 800, spacing: -0.2)),
              const Spacer(),
              Text('Edit', style: jakarta(13, 650, color: Hue.iris)),
            ],
          ),
          const SizedBox(height: 6),
          for (final (i, slot) in _store.slots.indexed) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: Color(0xFFF3EEF6)),
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  GlyphIcon(slot.glyph, size: 21, color: tones[i], stroke: 2),
                  const SizedBox(width: 14),
                  Expanded(child: Text(slot.label, style: jakarta(14.5, 600))),
                  Text(slot.time, style: jakarta(15, 750)),
                  const SizedBox(width: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: SizedBox(
                      key: ValueKey(slot.dose),
                      width: 82,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SoftChip(label: _status(slot.dose).$2, tone: _status(slot.dose).$1, dense: true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const GlyphIcon(Glyph.forward, size: 16, color: Hue.inkMute, stroke: 2),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _assignee() {
    return Surface(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlyphIcon(Glyph.users, size: 22, color: Hue.iris, stroke: 2),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Who's on it?", style: jakarta(16, 800, spacing: -0.2)),
                  Text('Assign to a family member', style: jakarta(12.5, 550, color: Hue.inkSoft)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _choice('mom')),
              const SizedBox(width: 10),
              Expanded(child: _choice('dad')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _choice(String id) {
    final member = CareStore.byId(id);
    final selected = _store.assignee == id;
    return Pressable(
      onTap: () => _store.assign(id),
      scale: 0.96,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        decoration: BoxDecoration(
          color: selected ? Hue.irisMist : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? Hue.iris : const Color(0xFFEDE7F1), width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            HaloAvatar(photo: member.photo, size: 44, halo: id == 'mom' ? Hue.honey : Hue.sage, glow: 0, ring: 2),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: jakarta(14.5, 750)),
                  Text(id == 'mom' ? 'Nearby' : '2 km away', style: jakarta(11.5, 550, color: Hue.inkMute)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutBack,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Hue.iris : Colors.white,
                border: Border.all(color: selected ? Hue.iris : const Color(0xFFCFC6DA), width: 1.6),
              ),
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                child: const GlyphIcon(Glyph.check, size: 13, color: Colors.white, stroke: 2.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _takeButton() {
    final taken = _store.morningTaken;
    return Pressable(
      onTap: _take,
      scale: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        height: 52,
        decoration: BoxDecoration(
          color: taken ? Hue.sageSoft : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: taken ? Hue.sage.withValues(alpha: 0.4) : const Color(0xFFE3DCEB), width: 1.4),
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          child: Row(
            key: ValueKey(taken),
            mainAxisSize: MainAxisSize.min,
            children: [
              if (taken) ...[
                const GlyphIcon(Glyph.check, size: 18, color: Hue.sage, stroke: 2.4),
                const SizedBox(width: 8),
              ],
              Text(
                taken ? 'Taken · morning dose logged' : 'Mark as taken',
                style: jakarta(15.5, 700, color: taken ? Hue.sage : Hue.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoseRing extends CustomPainter {
  const _DoseRing({required this.draw, required this.doses, required this.celebrate});

  final double draw;
  final List<Dose> doses;
  final double celebrate;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 12;
    const stroke = 20.0;
    canvas.drawCircle(c, r - stroke * 0.9, Paint()..color = Colors.white);
    canvas.drawCircle(
      c,
      r - stroke * 0.9,
      Paint()
        ..color = Hue.shadow.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    const gap = 0.07;
    final sweep = math.pi * 2 / 3;
    for (var i = 0; i < 3; i++) {
      final start = -math.pi / 2 + i * sweep + gap / 2;
      final local = span(draw, i / 3, (i + 1) / 3);
      if (local <= 0) continue;
      final length = (sweep - gap) * local;
      final rect = Rect.fromCircle(center: c, radius: r);
      final dose = doses[i];
      final List<Color> colors = switch (dose) {
        Dose.missed => const [Color(0xFFFF8F7E), Color(0xFFEF5F57)],
        Dose.taken => const [Color(0xFF6FD3A2), Color(0xFF2FAF77)],
        Dose.upcoming => const [Color(0xFFE9E5F1), Color(0xFFD9D3E6)],
      };
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt
        ..shader = SweepGradient(
          startAngle: start,
          endAngle: start + sweep,
          colors: colors,
          transform: const GradientRotation(0),
        ).createShader(rect);
      if (dose != Dose.upcoming) {
        canvas.drawArc(
          rect,
          start,
          length,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..color = colors.last.withValues(alpha: 0.28)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
      canvas.drawArc(rect, start, length, false, paint);
    }
    if (celebrate > 0 && celebrate < 1) {
      final e = Curves.easeOutCubic.transform(celebrate);
      for (var k = 0; k < 12; k++) {
        final a = k * math.pi / 6;
        final d = r * (0.7 + e * 0.75);
        canvas.drawCircle(
          c + Offset(math.cos(a) * d, math.sin(a) * d),
          3.2 * (1 - celebrate) + 0.5,
          Paint()..color = (k.isEven ? Hue.sage : Hue.honey).withValues(alpha: 1 - celebrate),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DoseRing oldDelegate) => true;
}

class _Capsule extends CustomPainter {
  const _Capsule();

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2;
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.shift(const Offset(0, 6)), Radius.circular(r)),
      Paint()
        ..color = const Color(0x33EF5F57)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    final left = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width / 2, size.height),
      topLeft: Radius.circular(r),
      bottomLeft: Radius.circular(r),
    );
    final right = RRect.fromRectAndCorners(
      Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height),
      topRight: Radius.circular(r),
      bottomRight: Radius.circular(r),
    );
    canvas.drawRRect(
      left,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), const [
          Color(0xFFFF8F7E),
          Color(0xFFE2463F),
        ]),
    );
    canvas.drawRRect(
      right,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), const [
          Color(0xFFFFFFFF),
          Color(0xFFE6E0EC),
        ]),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(r * 0.6, size.height * 0.16, size.width - r * 1.2, size.height * 0.2),
        Radius.circular(r),
      ),
      Paint()..color = const Color(0x80FFFFFF),
    );
  }

  @override
  bool shouldRepaint(_Capsule oldDelegate) => false;
}
