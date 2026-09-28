import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/art.dart';
import '../../core/canvas.dart';
import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../widgets/blobs.dart';
import '../../widgets/nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _in;
  final _toggles = [true, false, true];

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900))..forward();
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = Frame.of(context);
    final lift = frame.lift;
    final name = inter(24, 800, color: Palette.ink, track: 0.01);
    final sub = inter(14.5, 400, color: Palette.body, track: -0.01);
    const settings = ['Workout reminders', 'Haptic feedback', 'Sound effects'];
    return Scaffold(
      backgroundColor: Palette.cream,
      body: Stack(
        children: [
          Positioned.fill(
            child: BlobField(
              entrance: _in,
              blobs: [
                Blob(
                  center: Offset(-10, 60 + lift),
                  radii: const Size(110, 100),
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [Color(0xFFDEF864), Color(0xFFDFF866), Color(0x00F1F8CF)],
                  stops: const [0, 0.75, 1],
                  seed: 0.9,
                ),
                Blob(
                  center: Offset(410, 170 + lift),
                  radii: const Size(70, 70),
                  colors: const [Color(0xFF9A7CF7), Color(0xFFD2C4FB)],
                  stops: const [0, 1],
                  seed: 2.7,
                  delay: 0.1,
                ),
              ],
            ),
          ),
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: 76 + lift, bottom: NavBar.height(frame) + 20),
            children: [
              Center(
                child: Staged(
                  animation: _in,
                  begin: 0,
                  end: 0.45,
                  scale: 0.3,
                  child: Tick(
                    builder: (context, seconds, child) => Container(
                      width: 112,
                      height: 112,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          transform: GradientRotation(seconds * 0.8),
                          colors: const [Color(0xFF8D35FD), Color(0xFF5E5FF2), Color(0xFFDEF864), Color(0xFF8D35FD)],
                        ),
                        boxShadow: const [BoxShadow(color: Color(0x336A2FF2), blurRadius: 24, offset: Offset(0, 10))],
                      ),
                      child: child,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Palette.cream),
                      padding: const EdgeInsets.all(3),
                      child: ClipOval(child: Image.asset(Art.avatar.asset, fit: BoxFit.cover)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: Staged(animation: _in, begin: 0.15, end: 0.45, offset: const Offset(0, 12), child: Text('John Doe', style: name))),
              const SizedBox(height: 6),
              Center(child: Staged(animation: _in, begin: 0.2, end: 0.5, offset: const Offset(0, 12), child: Text('Level 7 · Fitzi Explorer', style: sub))),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    for (final (i, s) in const [('12', 'Day streak', Color(0xFFFDF1E4)), ('48', 'Workouts', Color(0xFFF1EFFD)), ('9.2k', 'Kcal', Color(0xFFEFF7D0))].indexed) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: Staged(
                          animation: _in,
                          begin: 0.25 + i * 0.07,
                          end: 0.6 + i * 0.07,
                          offset: const Offset(0, 30),
                          scale: 0.9,
                          child: Container(
                            height: 84,
                            decoration: BoxDecoration(color: s.$3, borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(s.$1, style: inter(22, 800, track: -0.02)),
                                const SizedBox(height: 4),
                                Text(s.$2, style: inter(12.5, 500, color: Palette.muted, track: -0.02)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Staged(
                  animation: _in,
                  begin: 0.45,
                  end: 0.8,
                  offset: const Offset(0, 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [BoxShadow(color: Color(0x0F655A80), blurRadius: 18, offset: Offset(0, 6))],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        for (var i = 0; i < settings.length; i++) ...[
                          if (i > 0) const Divider(height: 1, indent: 18, endIndent: 18, color: Color(0xFFF1ECE4)),
                          _SettingRow(
                            label: settings[i],
                            value: _toggles[i],
                            onChanged: (v) {
                              HapticFeedback.selectionClick();
                              setState(() => _toggles[i] = v);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Staged(
                  animation: _in,
                  begin: 0.55,
                  end: 0.9,
                  offset: const Offset(0, 30),
                  child: Pressable(
                    onTap: () {},
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(color: Palette.night, borderRadius: BorderRadius.circular(28)),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PhIcon(Ph.gear, size: 20, color: Colors.white),
                          const SizedBox(width: 10),
                          Text('Account settings', style: inter(16, 600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      scale: 0.99,
      haptic: false,
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(label, style: inter(15, 500, color: Palette.inkSoft, track: -0.01))),
            _Toggle(value: value),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value ? 1 : 0),
      duration: const Duration(milliseconds: 520),
      curve: settle,
      builder: (context, v, _) {
        final stretch = math.sin(v.clamp(0.0, 1.0) * math.pi) * 6;
        return Container(
          width: 50,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color.lerp(const Color(0xFFE7E2DA), Palette.violet, v.clamp(0.0, 1.0)),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 20 * v - (v > 0.5 ? stretch : 0),
                child: Container(
                  width: 24 + stretch,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 2))],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
