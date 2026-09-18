import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/catalog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin, ClockMixin {
  late final AnimationController _intro;
  final Map<String, bool> _toggles = {'Routine reminders': true, 'Weekly skin report': true, 'Face ID lock': false};

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..forward();
    startClock();
  }

  @override
  void dispose() {
    _intro.dispose();
    disposeClock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    const stats = [('12', 'Scans'), ('8', 'Day streak'), ('${Analysis.score}', 'Skin score')];
    return ListView(
      padding: EdgeInsets.fromLTRB(21, top + 20, 21, 130),
      children: [
        Entrance(
          animation: stage(_intro, 0, 0.45, curve: Curves.easeOutBack),
          scale: 0.6,
          offset: Offset.zero,
          child: Column(
            children: [
              ValueListenableBuilder<double>(
                valueListenable: clock,
                builder: (context, s, child) => Container(
                  width: 98,
                  height: 98,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: const [Palette.violet, Palette.rose, Palette.coral, Color(0xFF9DB0F2), Palette.violet],
                      transform: GradientRotation(s * 0.8),
                    ),
                  ),
                  child: child,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    image: const DecorationImage(image: AssetImage('assets/images/avatar.webp'), fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Wilson Carter', style: inter(20, 700, spacing: -0.4)),
              const SizedBox(height: 2),
              Text('Combination skin · Age 29', style: inter(12.5, 400, color: Palette.muted)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Entrance(
          animation: stage(_intro, 0.15, 0.6, curve: const Cubic(0.2, 0.9, 0.25, 1.05)),
          offset: const Offset(0, 40),
          child: SizedBox(
            height: 92,
            child: HoloSurface(
              tone: HoloTone.score,
              radius: 22,
              dots: 1,
              child: AnimatedBuilder(
                animation: _intro,
                builder: (context, _) => Row(
                  children: [
                    for (final (i, (value, label)) in stats.indexed)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(int.parse(value) * Curves.easeOutCubic.transform(window(_intro.value, 0.3 + i * 0.1, 0.9))).round()}',
                              style: inter(24, 700, spacing: -0.6),
                            ),
                            Text(label, style: inter(11.5, 500, color: Palette.muted)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Entrance(
          animation: stage(_intro, 0.25, 0.7, curve: const Cubic(0.2, 0.9, 0.25, 1.05)),
          offset: const Offset(0, 40),
          child: _group([
            for (final entry in _toggles.entries)
              _Row(
                glyph: entry.key.startsWith('Routine')
                    ? Glyph.clock
                    : entry.key.startsWith('Weekly')
                    ? Glyph.analytic
                    : Glyph.shield,
                label: entry.key,
                trailing: _GlowSwitch(value: entry.value, onChanged: (v) => setState(() => _toggles[entry.key] = v)),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        Entrance(
          animation: stage(_intro, 0.35, 0.8, curve: const Cubic(0.2, 0.9, 0.25, 1.05)),
          offset: const Offset(0, 40),
          child: _group(const [
            _Row(glyph: Glyph.drop, label: 'Skin profile', trailing: _Chevron()),
            _Row(glyph: Glyph.bag, label: 'Orders', trailing: _Chevron()),
            _Row(glyph: Glyph.heart, label: 'Saved products', trailing: _Chevron()),
          ]),
        ),
      ],
    );
  }

  Widget _group(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x0D7A4FA0), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(children: rows),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.glyph, required this.label, required this.trailing});

  final Glyph glyph;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: Palette.lilacMid, borderRadius: BorderRadius.circular(12)),
              child: Center(child: GlyphIcon(glyph, size: 19, stroke: 1.6, gradient: Palette.brand)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: inter(14.5, 500))),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) => const GlyphIcon(Glyph.chevronRight, size: 18, color: Palette.faint);
}

class _GlowSwitch extends StatelessWidget {
  const _GlowSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value ? 1 : 0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        builder: (context, t, _) {
          final stretch = (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0) * 7;
          return Container(
            width: 48,
            height: 28,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Color.lerp(Palette.hairline, Palette.rose, t.clamp(0.0, 1.0)),
              gradient: t > 0.5 ? Palette.brand : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: lerp(0, 20, t) - (t > 0.5 ? stretch : 0),
                  child: Container(
                    width: 22 + stretch,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 2))],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
