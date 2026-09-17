import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../core/icons/glyphs.dart';
import '../../core/motion/motion.dart';
import '../../core/motion/routes.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/aurora.dart';
import '../onboarding/onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onScrollDirection});

  final ValueChanged<ScrollDirection> onScrollDirection;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  final Map<String, bool> _toggles = {
    'Dose reminders': true,
    'Refill alerts': true,
    'Voice replies': false,
    'Caregiver updates': false,
  };

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _signOut(Offset origin) {
    Navigator.of(
      context,
    ).pushAndRemoveUntil(RevealRoute(origin: origin, builder: (_) => const OnboardingScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: Palette.canvas,
      child: Stack(
        children: [
          const Positioned(top: 0, left: 0, right: 0, child: Aurora()),
          NotificationListener<UserScrollNotification>(
            onNotification: (n) {
              widget.onScrollDirection(n.direction);
              return false;
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, top + 24, 16, 130),
              children: [
                Entrance(
                  animation: stage(_intro, 0, 0.45, curve: Curves.easeOutBack),
                  scale: 0.6,
                  offset: Offset.zero,
                  child: Column(
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 3),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/avatar_robert.jpg'),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10))],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Robert fox', style: TextStyles.headline.copyWith(fontSize: 22, height: 1.2)),
                      const SizedBox(height: 2),
                      Text(
                        'Patient ID  PX-20418',
                        style: TextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.65)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Entrance(
                  animation: stage(_intro, 0.15, 0.55, curve: const Cubic(0.2, 0.9, 0.25, 1.05)),
                  offset: const Offset(0, 40),
                  child: _group([
                    for (final entry in _toggles.entries)
                      _Row(
                        glyph: _glyphFor(entry.key),
                        label: entry.key,
                        trailing: PillSwitch(
                          value: entry.value,
                          onChanged: (v) => setState(() => _toggles[entry.key] = v),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(height: 14),
                Entrance(
                  animation: stage(_intro, 0.25, 0.65, curve: const Cubic(0.2, 0.9, 0.25, 1.05)),
                  offset: const Offset(0, 40),
                  child: _group(const [
                    _Row(glyph: Glyph.care, label: 'My doctors', trailing: _Chevron()),
                    _Row(glyph: Glyph.clock, label: 'Refill history', trailing: _Chevron()),
                    _Row(glyph: Glyph.settings, label: 'Privacy & data', trailing: _Chevron()),
                  ]),
                ),
                const SizedBox(height: 22),
                Entrance(
                  animation: stage(_intro, 0.35, 0.75, curve: Curves.easeOutBack),
                  offset: const Offset(0, 30),
                  child: Builder(
                    builder: (context) => Pressable(
                      onTap: () {
                        final box = context.findRenderObject() as RenderBox;
                        _signOut(box.localToGlobal(box.size.center(Offset.zero)));
                      },
                      scale: 0.96,
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Palette.surface, borderRadius: BorderRadius.circular(26)),
                        child: Text('Sign out', style: TextStyles.label.copyWith(color: Palette.alert, fontSize: 14)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Glyph _glyphFor(String label) {
    return switch (label) {
      'Dose reminders' => Glyph.bell,
      'Refill alerts' => Glyph.calendar,
      'Voice replies' => Glyph.mic,
      _ => Glyph.care,
    };
  }

  Widget _group(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x0F0B2A2D), blurRadius: 30, offset: Offset(0, 12))],
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
              decoration: BoxDecoration(color: Palette.mist, borderRadius: BorderRadius.circular(12)),
              child: Center(child: GlyphIcon(glyph, size: 19, color: Palette.deep, stroke: 1.5)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyles.label.copyWith(fontSize: 14.5, fontWeight: FontWeight.w400)),
            ),
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
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 3.14159,
      child: const GlyphIcon(Glyph.back, size: 18, color: Palette.inkFaint, stroke: 1.6),
    );
  }
}

class PillSwitch extends StatelessWidget {
  const PillSwitch({super.key, required this.value, required this.onChanged});

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
        duration: const Duration(milliseconds: 520),
        curve: Curves.linear,
        builder: (context, t, _) {
          final move = const ElasticOutCurve(0.7).transform(t);
          final stretch = (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0) * 8;
          return Container(
            width: 48,
            height: 28,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Color.lerp(Palette.mistDeep, Palette.deep, Curves.easeOut.transform(t)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: lerp(0, 20, move) - (t > 0.5 ? stretch : 0),
                  top: 0,
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
