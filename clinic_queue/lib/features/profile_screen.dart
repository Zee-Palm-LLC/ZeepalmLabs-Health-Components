import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/motion.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../data/visit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.visit, required this.onQueue, required this.onToken});

  final Visit visit;
  final VoidCallback onQueue;
  final VoidCallback onToken;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
  }

  static const _history = [
    ('Dental check-up', 'Aug 12 · Dr. Amir Khan', Glyph.calendar),
    ('General · Flu symptoms', 'Jun 3 · Dr. Oliver Hayes', Glyph.calendar),
    ('Lab Tests · Blood panel', 'Apr 20 · CityCare Lab', Glyph.calendar),
  ];

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Widget _stage(double begin, Widget child) {
    return Staged(animation: _enter, begin: begin, end: begin + 0.5, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 20,
          right: 20,
          top: 62,
          child: _stage(
            0,
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF19A393), Color(0xFF0F766E)]),
                    boxShadow: const [BoxShadow(color: Color(0x4014B8A6), blurRadius: 14, offset: Offset(0, 6))],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Text('GB', style: jakarta(19, 800, color: Colors.white, spacing: 0.4)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Grace Bennett', style: jakarta(22, 800, spacing: -0.7, height: 1.2)),
                      const SizedBox(height: 2),
                      Text('12 visits · member since 2024', style: jakarta(12.5, 500, color: Hue.gray)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(left: 20, right: 20, top: 150, height: 92, child: _stage(0.1, _current())),
        Positioned(
          left: 22,
          top: 266,
          child: _stage(0.2, Text('Past visits', style: jakarta(14.5, 800, spacing: -0.29))),
        ),
        Positioned(
          left: 20,
          right: 20,
          top: 294,
          child: _stage(
            0.25,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: cardShadow(0.9),
              ),
              child: Column(
                children: [
                  for (final (i, visit) in _history.indexed) ...[
                    if (i > 0) const Divider(height: 1, color: Color(0xFFEAF1EF)),
                    SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F5F0),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            alignment: Alignment.center,
                            child: const GlyphIcon(Glyph.check, size: 15, color: Hue.teal, stroke: 2.4),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(visit.$1, style: jakarta(13.5, 700)),
                                const SizedBox(height: 2),
                                Text(visit.$2, style: jakarta(11.5, 500, color: Hue.gray)),
                              ],
                            ),
                          ),
                          const GlyphIcon(Glyph.back, size: 14, color: Color(0xFFA7B6B3), stroke: 2).flipped(),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Positioned(left: 22, top: 492, child: _stage(0.35, Text('Alerts', style: jakarta(14.5, 800, spacing: -0.29)))),
        Positioned(left: 20, right: 20, top: 520, child: _stage(0.4, const _Settings())),
      ],
    );
  }

  Widget _current() {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.visit, widget.visit.sim]),
      builder: (context, _) {
        final visit = widget.visit;
        final has = visit.hasToken;
        return Pressable(
          onTap: has ? widget.onQueue : widget.onToken,
          scale: 0.97,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0F5550), Color(0xFF0E403C)]),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [BoxShadow(color: Color(0x330F3B3A), blurRadius: 20, offset: Offset(0, 10))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        has ? 'ACTIVE TOKEN' : 'NO ACTIVE TOKEN',
                        style: caps(9.5, color: const Color(0xFFB8CFCB), tracking: 0.16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        has ? 'A–${QueueSim.you} · ${ordinal(visit.sim.rank)} in line' : 'Join a line from home',
                        style: jakarta(18, 800, color: Colors.white, spacing: -0.4),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        has ? 'CityCare · ${visit.department} · ~${visit.sim.wait} min' : 'CityCare Family Clinic',
                        style: jakarta(12, 600, color: const Color(0xFFD5E6E3)),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: has ? Hue.yellow : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    has ? 'Open' : 'Get token',
                    style: jakarta(12.5, 800, color: has ? const Color(0xFF4A3304) : Hue.teal),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension on GlyphIcon {
  Widget flipped() => Transform.flip(flipX: true, child: this);
}

class _Settings extends StatefulWidget {
  const _Settings();

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
  final _on = [true, true, false];

  static const _rows = [
    (Glyph.bell, 'Leave-time alerts', 'Ping me when it is time to go'),
    (Glyph.shield, 'Hold my spot', 'Keep my place 10 min after my turn'),
    (Glyph.map, 'Share live location', 'Let the clinic see my ETA'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: cardShadow(0.9),
      ),
      child: Column(
        children: [
          for (final (i, row) in _rows.indexed) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFEAF1EF)),
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: const Color(0xFFFDEBD6), borderRadius: BorderRadius.circular(11)),
                    alignment: Alignment.center,
                    child: GlyphIcon(row.$1, size: 15, color: const Color(0xFFD96A3A), stroke: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.$2, style: jakarta(13.5, 700)),
                        const SizedBox(height: 2),
                        Text(row.$3, style: jakarta(11.5, 500, color: Hue.gray)),
                      ],
                    ),
                  ),
                  _Switch(on: _on[i], onChanged: (v) => setState(() => _on[i] = v)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({required this.on, required this.onChanged});

  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: on ? Hue.teal : const Color(0xFFDCE6E3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}
