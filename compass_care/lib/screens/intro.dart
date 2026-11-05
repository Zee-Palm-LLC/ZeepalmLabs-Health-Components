import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../icons.dart';
import '../theme.dart';
import '../widgets/compass.dart';
import '../widgets/sky.dart';
import '../widgets/ui.dart';

class _Page {
  const _Page(this.tag, this.tagIcon, this.title, this.body, this.hero);
  final String tag;
  final IconData? tagIcon;
  final String title, body;
  final Widget Function() hero;
}

final _pages = <_Page>[
  _Page(
    'Compass Care',
    null,
    'Care feels lighter when\neverything\'s in\none place',
    'Store documents, medications, contacts, and plans. Ready when it matters.',
    () => const _WelcomeHero(),
  ),
  _Page(
    'Medication Tracking',
    Ph.pill,
    'Snap a bottle.\nSave the details.',
    'Take a quick photo so the app remembers your medications, dosage and refill dates.',
    () => const _MedsHero(),
  ),
  _Page(
    'Family Sharing',
    PhB.heart,
    'Keep everyone\nin the loop',
    'Invite family, share access, and send helpful reminders without endless group chat chaos.',
    () => const _FamilyHero(),
  ),
  _Page(
    'Crisis Mode',
    null,
    'When something goes wrong, don\'t scramble',
    'Bring medications, allergies, doctors, insurance and emergency contacts info.',
    () => const _CrisisHero(),
  ),
  _Page(
    'Calendar',
    null,
    'Appointments and tasks, organized',
    'See what\'s next, set reminders, and stay on track with ease.',
    () => const _CalendarHero(),
  ),
];

/// Five-page intro. The sky is shared and parallaxes with the pager; each
/// page's hero swings through 3D space while its copy dissolves through blur.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _pc = PageController();
  final _page = ValueNotifier(0.0);
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pc.addListener(() {
      _page.value = _pc.page ?? 0;
      final i = _page.value.round();
      if (i != _index) {
        HapticFeedback.selectionClick();
        setState(() => _index = i);
      }
    });
  }

  @override
  void dispose() {
    _pc.dispose();
    _page.dispose();
    super.dispose();
  }

  void _next() {
    if (_index >= _pages.length - 1) {
      widget.onDone();
    } else {
      _pc.nextPage(duration: const Duration(milliseconds: 900), curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Sky(mode: SkyMode.intro, parallax: _page, cloudLine: 360, layer: SkyLayer.back),
        ),
        // Mini phones sit inside the cloud bank...
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _page,
              builder: (context, _) => Stack(
                children: [
                  for (var i = 0; i < _pages.length; i++)
                    if ((_page.value - i).abs() < 1)
                      KeyedSubtree(
                        key: ValueKey(i),
                        child: Transform.translate(
                          offset: Offset((i - _page.value) * 390, 0),
                          child: _swing(_page.value - i, _HeroLayer(back: true, child: _pages[i].hero())),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: Sky(mode: SkyMode.intro, parallax: _page, cloudLine: 360, layer: SkyLayer.front),
        ),
        // Fog floor: the cloud bank dissolves into the white page.
        const Positioned(left: 0, right: 0, top: 440, height: 70, child: _Fog()),
        const Positioned(left: 0, right: 0, top: 509, bottom: 0, child: ColoredBox(color: Colors.white)),
        // ...while the cards float in front of it.
        Positioned.fill(
          child: PageView.builder(
            controller: _pc,
            itemCount: _pages.length,
            itemBuilder: (context, i) => AnimatedBuilder(
              animation: _page,
              builder: (context, child) => _swing(_page.value - i, child!),
              child: _HeroLayer(back: false, child: _pages[i].hero()),
            ),
          ),
        ),
        // The emblem sits on the clouds on the welcome page.
        AnimatedBuilder(
          animation: _page,
          builder: (context, child) {
            final d = _page.value;
            return Positioned(
              left: 192 - 80 - d * 260,
              top: 405 - 80,
              child: Opacity(opacity: (1 - d * 1.4).clamp(0.0, 1.0), child: child),
            );
          },
          child: const IgnorePointer(child: Entrance(delay: 500, scale: 0.4, blur: 10, dy: 30, child: CompassEmblem(size: 160))),
        ),
        // Copy.
        Positioned(
          left: 0,
          right: 0,
          top: 498,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _page,
              builder: (context, _) {
                // All copies stay mounted (keyed) so the headline's word reveal
                // plays once instead of restarting as pages enter and leave.
                return Stack(
                  children: [
                    for (var i = 0; i < _pages.length; i++)
                      KeyedSubtree(
                        key: ValueKey('copy$i'),
                        child: Visibility.maintain(
                          visible: (_page.value - i).abs() < 1,
                          child: _copy(i, (_page.value - i).clamp(-1.0, 1.0)),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 752,
          child: Entrance(delay: 900, dy: 30, child: PrimaryButton(_index == 0 ? 'Start my setup' : 'Continue', onTap: _next)),
        ),
        const Positioned(left: 0, right: 0, top: 0, child: StatusBar(color: Colors.white)),
      ],
    );
  }

  /// Each hero swings through 3D space around its leading edge as it pages.
  Widget _swing(double raw, Widget child) {
    final d = raw.clamp(-1.0, 1.0);
    return Transform(
      alignment: Alignment(d < 0 ? -1 : 1, -0.2),
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0011)
        ..translateByDouble(d * 150, d.abs() * 40, 0, 1)
        ..rotateY(d * 0.9)
        ..scaleByDouble(1 - d.abs() * 0.18, 1 - d.abs() * 0.18, 1, 1),
      child: Opacity(opacity: (1 - d.abs() * 1.1).clamp(0.0, 1.0), child: child),
    );
  }

  Widget _copy(int i, double d) {
    final p = _pages[i];
    final a = d.abs();
    final blur = a * 14;
    Widget w = Column(
      key: ValueKey(i),
      children: [
        TagPill(p.tag, icon: p.tagIcon),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 46),
          child: i == 0
              ? BlurText(p.title, delay: 300, style: title(32))
              : Text(p.title, textAlign: TextAlign.center, style: title(32)),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Text(
            p.body,
            textAlign: TextAlign.center,
            style: sans(13.5, color: C.muted, height: 1.5),
          ),
        ),
      ],
    );
    w = ImageFiltered(
      enabled: blur > 0.1,
      imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur * 0.4),
      child: w,
    );
    return Transform.translate(
      offset: Offset(-d * 70, 0),
      child: Opacity(opacity: (1 - a * 1.6).clamp(0.0, 1.0), child: w),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared hero pieces
// ---------------------------------------------------------------------------

/// The pale "mini phone" that the hero content sits on.
class _MiniPhone extends StatelessWidget {
  const _MiniPhone({required this.left, required this.top, required this.width, this.child});
  final double left, top, width;
  static const height = 420.0;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (r) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white, Color(0x00FFFFFF)],
          stops: [0, 0.62, 0.86],
        ).createShader(r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xF5FFF6F3), Color(0xE6FDE1DA), Color(0xCCFBCFC5)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.2),
            boxShadow: const [BoxShadow(color: Color(0x33B4321F), blurRadius: 40, offset: Offset(0, 18))],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Which half of a hero to build: the mini phone (behind the clouds) or
/// everything else (in front of them).
class _HeroLayer extends InheritedWidget {
  const _HeroLayer({required this.back, required super.child});
  final bool back;

  @override
  bool updateShouldNotify(_HeroLayer old) => old.back != back;
}

class _HeroStack extends StatelessWidget {
  const _HeroStack({required this.children, this.clipBehavior = Clip.hardEdge});
  final List<Widget> children;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final back = context.dependOnInheritedWidgetOfExactType<_HeroLayer>()?.back ?? false;
    return Stack(
      clipBehavior: clipBehavior,
      children: [
        for (final c in children)
          if ((c is _MiniPhone) == back) c,
      ],
    );
  }
}

class _Fog extends StatelessWidget {
  const _Fog();

  @override
  Widget build(BuildContext context) => const IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00FFFFFF), Colors.white],
        ),
      ),
    ),
  );
}

/// Continuous gentle float, phase-shifted per instance.
class _Float extends StatefulWidget {
  const _Float({required this.child, this.amp = 4, this.phase = 0, this.rot = 0});
  final Widget child;
  final double amp, phase, rot;

  @override
  State<_Float> createState() => _FloatState();
}

class _FloatState extends State<_Float> with SingleTickerProviderStateMixin, TickerRepaint {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: time,
      child: widget.child,
      builder: (context, child) {
        final t = time.value * 1.2 + widget.phase;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translateByDouble(0, math.sin(t) * widget.amp, 0, 1)
            ..rotateZ(math.sin(t * 0.7) * widget.rot),
          child: child,
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.color, this.title, this.sub, {this.avatar, this.trailing});
  final IconData? icon;
  final Color color;
  final String title, sub;
  final String? avatar;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (avatar != null)
          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(avatar!, width: 34, height: 34))
        else
          IconChip(icon!, color, size: 32, radius: 9),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sans(12.5, w: FontWeight.w600, height: 1.2),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sans(10, color: C.muted, height: 1.2),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

BoxDecoration _whiteCard([double r = 18]) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(r),
  boxShadow: const [
    BoxShadow(color: Color(0x1FB4321F), blurRadius: 22, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
  ],
);

// ---------------------------------------------------------------------------
// 1 - Welcome
// ---------------------------------------------------------------------------

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    const rows = [
      (Ph.usersThree, C.blue, 'Family', '3 members'),
      (Ph.pill, C.green, 'Medications', '4 active · next at 6 pm'),
      (Ph.fileText, C.purple, 'Documents', '12 files · all up to date'),
    ];
    return _HeroStack(
      children: [
        _MiniPhone(
          left: 83,
          top: 70,
          width: 224,
          child: Entrance(
            delay: 100,
            dy: 60,
            scale: 0.9,
            blur: 8,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('9:41', style: sans(8, w: FontWeight.w600)),
                      const Spacer(),
                      const Icon(Ph.signal, size: 8, color: C.ink),
                      const SizedBox(width: 2),
                      const Icon(Ph.battery, size: 10, color: C.ink),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Text('Good afternoon, Alex', style: sans(13, w: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Thursday, Jun 5', style: sans(9.5, color: C.muted)),
                ],
              ),
            ),
          ),
        ),
        for (var i = 0; i < rows.length; i++)
          Positioned(
            left: 74,
            top: 160 + i * 62.0,
            width: 242,
            child: Entrance(
              delay: 350 + i * 140,
              dx: i.isEven ? -90 : 90,
              rotate: i.isEven ? -0.12 : 0.12,
              blur: 6,
              curve: springOut,
              duration: 1100,
              child: _Float(
                amp: 2.2,
                phase: i * 1.3,
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: _whiteCard(16),
                  child: _Row(rows[i].$1, rows[i].$2, rows[i].$3, rows[i].$4),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 2 - Medication scan
// ---------------------------------------------------------------------------

class _MedsHero extends StatefulWidget {
  const _MedsHero();

  @override
  State<_MedsHero> createState() => _MedsHeroState();
}

class _MedsHeroState extends State<_MedsHero> with SingleTickerProviderStateMixin, TickerRepaint {
  @override
  Widget build(BuildContext context) {
    const rows = [
      (Ph.pill, C.blue, 'Lisinopril', '10 mg · once daily'),
      (Ph.calendarCheck, C.purple, 'Refill date', 'June 12'),
      (Ph.prescription, C.green, 'Quantity', '30 Tablets'),
      (Ph.user, C.amber, 'Prescriber', 'Dr. Martinez'),
    ];
    return _HeroStack(
      children: [
        _MiniPhone(
          left: 76,
          top: 72,
          width: 238,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scan your medication', style: sans(11.5, w: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('Hold the label inside the frame', style: sans(8.5, color: C.muted)),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(PhB.x, size: 10, color: C.ink),
                ),
              ],
            ),
          ),
        ),
        // Photo with a live scanning beam and focus brackets.
        Positioned(
          left: 122,
          top: 140,
          width: 146,
          height: 148,
          child: Entrance(
            delay: 200,
            scale: 0.85,
            blur: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AnimatedBuilder(
                animation: time,
                builder: (context, _) {
                  final t = time.value;
                  final beam = (math.sin(t * 1.8) * 0.5 + 0.5);
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.scale(
                        scale: 1.25 + 0.03 * math.sin(t * 0.6),
                        child: Image.asset('assets/images/pill.png', fit: BoxFit.cover),
                      ),
                      CustomPaint(painter: _ScanPainter(beam, t)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(
          left: 80,
          top: 290,
          width: 232,
          child: Entrance(
            delay: 450,
            dy: 70,
            blur: 6,
            curve: springOut,
            duration: 1100,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: _whiteCard(18),
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: _Detected(delayMs: 900 + i * 420, child: _Row(rows[i].$1, rows[i].$2, rows[i].$3, rows[i].$4)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A row that "gets recognised": shimmering skeleton first, then the content
/// resolves with a check flash.
class _Detected extends StatefulWidget {
  const _Detected({required this.child, required this.delayMs});
  final Widget child;
  final int delayMs;

  @override
  State<_Detected> createState() => _DetectedState();
}

class _DetectedState extends State<_Detected> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.delayMs + 600),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final total = widget.delayMs + 600;
        final ms = _c.value * total;
        final t = ((ms - widget.delayMs) / 600).clamp(0.0, 1.0);
        final shimmer = (ms / 900) % 1;
        return Stack(
          children: [
            Opacity(
              opacity: 1 - t,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: const Color(0xFFF4EEEC), borderRadius: BorderRadius.circular(9)),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (r) => LinearGradient(
                        begin: Alignment(-1 + shimmer * 3 - 0.6, 0),
                        end: Alignment(-1 + shimmer * 3 + 0.6, 0),
                        colors: const [Color(0xFFF1EAE8), Color(0xFFFFFFFF), Color(0xFFF1EAE8)],
                      ).createShader(r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 8, width: 80, color: Colors.white),
                          const SizedBox(height: 5),
                          Container(height: 6, width: 54, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: t,
              child: Transform.translate(offset: Offset(8 * (1 - smoothOut.transform(t)), 0), child: child),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _ScanPainter extends CustomPainter {
  _ScanPainter(this.beam, this.t);
  final double beam, t;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * (0.08 + beam * 0.84);
    final band = Rect.fromLTWH(0, y - 30, size.width, 30);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [C.red.withValues(alpha: 0), C.red.withValues(alpha: 0.28)],
        ).createShader(band),
    );
    canvas.drawLine(
      Offset(6, y),
      Offset(size.width - 6, y),
      Paint()
        ..color = const Color(0xFFFF8A7E)
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    // Focus brackets breathing in and out.
    final inset = 12 + math.sin(t * 2.4) * 3;
    final r = Rect.fromLTRB(inset, inset, size.width - inset, size.height - inset);
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const l = 16.0;
    for (final (c, dx, dy) in [
      (r.topLeft, 1.0, 1.0),
      (r.topRight, -1.0, 1.0),
      (r.bottomLeft, 1.0, -1.0),
      (r.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy + dy * l)
          ..lineTo(c.dx, c.dy)
          ..lineTo(c.dx + dx * l, c.dy),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_ScanPainter old) => true;
}

// ---------------------------------------------------------------------------
// 3 - Family
// ---------------------------------------------------------------------------

class _FamilyHero extends StatelessWidget {
  const _FamilyHero();

  @override
  Widget build(BuildContext context) {
    const members = [
      ('assets/images/p_woman.png', 'Sarah', 'Daughter · Admin'),
      ('assets/images/p_grandpa.png', 'Dad', 'Robert Rivers'),
      ('assets/images/p_grandma.png', 'Mom', 'Patricia Rivers'),
    ];
    return _HeroStack(
      clipBehavior: Clip.none,
      children: [
        _MiniPhone(
          left: 90,
          top: 72,
          width: 220,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 22, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: C.tagBg, borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Ph.heart, size: 15, color: C.red),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Family', style: sans(12.5, w: FontWeight.w600)),
                    Text('4 members', style: sans(9, color: C.muted)),
                  ],
                ),
              ],
            ),
          ),
        ),
        for (var i = 0; i < members.length; i++)
          Positioned(
            left: 102,
            top: 135 + i * 54.0,
            width: 200,
            child: Entrance(
              delay: 150 + i * 120,
              dy: 30,
              scale: 0.92,
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 9),
                decoration: _whiteCard(13),
                child: _Row(null, C.ink, members[i].$2, members[i].$3, avatar: members[i].$1),
              ),
            ),
          ),
        Positioned(
          left: 102,
          top: 297,
          width: 200,
          child: Entrance(
            delay: 520,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(13)),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(color: Color(0xFFEDE4FD), shape: BoxShape.circle),
                    child: const Icon(PhB.userPlus, size: 12, color: C.purple),
                  ),
                  const SizedBox(width: 9),
                  Text('Invite a family member', style: sans(10.5, w: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        // Notification chips sling in from off-screen and keep floating.
        Positioned(
          left: 196,
          top: 178,
          child: Entrance(
            delay: 750,
            dx: 220,
            dy: -40,
            rotate: 0.5,
            curve: springOut,
            duration: 1300,
            child: _Float(
              amp: 5,
              phase: 0,
              rot: 0.03,
              child: _chip(Ph.calendarBlank, C.purple, 'Dad\'s appointment', 'Tomorrow · 10:30 AM'),
            ),
          ),
        ),
        Positioned(
          left: 44,
          top: 288,
          child: Entrance(
            delay: 1000,
            dx: -220,
            dy: 30,
            rotate: -0.5,
            curve: springOut,
            duration: 1300,
            child: _Float(
              amp: 5,
              phase: 2,
              rot: 0.03,
              child: _chip(Ph.pill, C.green, 'Mom\'s medication', 'Sarah marked as taken'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, Color color, String t, String s) {
    return Transform.rotate(
      angle: -0.03,
      child: Container(
        width: 190,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: _whiteCard(16),
        child: _Row(icon, color, t, s),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4 - Crisis
// ---------------------------------------------------------------------------

class _CrisisHero extends StatefulWidget {
  const _CrisisHero();

  @override
  State<_CrisisHero> createState() => _CrisisHeroState();
}

class _CrisisHeroState extends State<_CrisisHero> with SingleTickerProviderStateMixin, TickerRepaint {
  @override
  Widget build(BuildContext context) {
    const rows = [
      (Ph.warning, C.amber, 'Allergies', 'Peanuts, Penicillin'),
      (Ph.pill, C.green, 'Medications', '3 medications'),
      (Ph.phone, C.purple, 'Emergency contact', 'Michael Rivers · (555) 012-4433'),
    ];
    return _HeroStack(
      clipBehavior: Clip.none,
      children: [
        _MiniPhone(left: 92, top: 112, width: 206),
        // Sonar rings + warning core.
        Positioned(
          left: 192 - 110,
          top: 128 - 110,
          width: 220,
          height: 220,
          child: AnimatedBuilder(
            animation: time,
            builder: (context, _) => CustomPaint(painter: _SonarPainter(time.value)),
          ),
        ),
        Positioned(
          left: 82,
          top: 192,
          width: 226,
          child: Entrance(
            delay: 250,
            dy: 60,
            blur: 6,
            curve: springOut,
            duration: 1100,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              decoration: _whiteCard(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Ph.firstAid, size: 11, color: C.red),
                      const SizedBox(width: 6),
                      Text('Your emergency profile', style: sans(10.5, w: FontWeight.w600)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 17, top: 1, bottom: 6),
                    child: Text('Shared with 4 trusted contacts', style: sans(8, color: C.muted)),
                  ),
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: Color(0xFFF2ECEA)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Entrance(delay: 600 + i * 160, dx: 30, child: _Row(rows[i].$1, rows[i].$2, rows[i].$3, rows[i].$4)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 82,
          top: 398,
          width: 226,
          child: Entrance(
            delay: 900,
            scale: 0.8,
            child: AnimatedBuilder(
              animation: time,
              builder: (context, child) {
                final g = 0.5 + 0.5 * math.sin(time.value * 3);
                return Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: C.red,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: C.red.withValues(alpha: 0.25 + 0.3 * g),
                        blurRadius: 10 + 14 * g,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: child,
                );
              },
              child: Text(
                'Activate emergency alert',
                style: sans(11.5, color: Colors.white, w: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SonarPainter extends CustomPainter {
  _SonarPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var k = 0; k < 3; k++) {
      final ph = ((t * 0.55) + k / 3) % 1;
      final r = 44 + ph * 66;
      canvas.drawCircle(c, r, Paint()..color = Colors.white.withValues(alpha: 0.22 * (1 - ph)));
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.white.withValues(alpha: 0.6 * (1 - ph)),
      );
    }
    // Core with heartbeat squeeze.
    final p = t % 1.2;
    final beat = math.exp(-math.pow((p - 0.1) / 0.05, 2)) + 0.5 * math.exp(-math.pow((p - 0.3) / 0.06, 2));
    final r = 44 * (1 + 0.06 * beat);
    canvas.drawCircle(
      c.translate(0, 6),
      r,
      Paint()
        ..color = const Color(0x55A3180D)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFFFF6F61), Color(0xFFE5392C)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // Warning triangle.
    final tw = r * 0.62;
    final tri = Path()
      ..moveTo(c.dx, c.dy - tw * 0.55)
      ..lineTo(c.dx + tw * 0.55, c.dy + tw * 0.42)
      ..lineTo(c.dx - tw * 0.55, c.dy + tw * 0.42)
      ..close();
    canvas.drawPath(
      tri,
      Paint()
        ..color = Colors.white
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 5
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      tri,
      Paint()
        ..color = Colors.white
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke,
    );
    final ex = Paint()
      ..color = const Color(0xFFE5392C)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c.translate(0, -tw * 0.18), c.translate(0, tw * 0.1), ex);
    canvas.drawCircle(c.translate(0, tw * 0.26), 1.8, Paint()..color = const Color(0xFFE5392C));
  }

  @override
  bool shouldRepaint(_SonarPainter old) => true;
}

// ---------------------------------------------------------------------------
// 5 - Calendar: cards rain down with physics and can be flung around.
// ---------------------------------------------------------------------------

class _CalendarHero extends StatelessWidget {
  const _CalendarHero();

  @override
  Widget build(BuildContext context) {
    // (x, y, angle, icon, colour, title, sub, delay)
    const cards = [
      (-70.0, 154.0, -0.30, Ph.chatText, C.blue, 'Text Dr. Lee', 'Today', 0),
      (88.0, 186.0, 0.12, Ph.phoneCall, C.purple, 'Call insurance', 'Tomorrow', 120),
      (272.0, 152.0, 0.0, Ph.phoneCall, C.purple, 'Call insurance', 'Jun 14', 220),
      (296.0, 218.0, 0.30, Ph.heartbeat, C.red, 'Cardiology', 'Jun 16', 300),
      (-62.0, 248.0, 0.0, Ph.pill, C.green, 'Refill', 'Jun 18', 380),
      (118.0, 252.0, 0.0, Ph.heartbeat, C.red, 'Cardiology appointment', 'Jun 12 · 9:00', 460),
      (66.0, 312.0, 0.06, Ph.prescription, C.green, 'Pick up prescription', 'Jun 12 · 2:00', 560),
      (288.0, 318.0, 0.0, Ph.phoneCall, C.purple, 'Call insurance', 'Jun 20', 620),
      (-80.0, 370.0, -0.02, Ph.calendarBlank, C.blue, 'Lab work prep', 'Jun 21', 700),
      (140.0, 372.0, -0.04, Ph.firstAid, C.amber, 'Vaccine reminder', 'Jun 22', 780),
    ];
    return _HeroStack(
      clipBehavior: Clip.none,
      children: [
        Positioned(left: 88, top: 92, width: 214, height: 46, child: Entrance(delay: 0, dy: -30, child: _week())),
        for (final c in cards)
          _PhysicsCard(
            key: ValueKey(c),
            home: Offset(c.$1, c.$2),
            angle: c.$3,
            delayMs: 250 + c.$8,
            child: Container(
              width: 190,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 9),
              decoration: _whiteCard(14),
              child: _Row(
                c.$4,
                c.$5,
                c.$6,
                c.$7,
                trailing: Text('All day', style: sans(8, color: C.muted)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _week() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Container(
      decoration: _whiteCard(14),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Row(
        children: [
          for (var i = 0; i < 6; i++)
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: i == 2 ? C.tagBg : null, borderRadius: BorderRadius.circular(9)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(days[i], style: sans(7.5, color: i == 2 ? C.red : C.muted)),
                    Text(
                      '${10 + i}',
                      style: sans(10.5, w: FontWeight.w600, color: i == 2 ? C.red : C.ink),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Drops from the sky under gravity, bounces on landing, and can be grabbed
/// and flung; a 2D spring then pulls it home while its tilt follows velocity.
class _PhysicsCard extends StatefulWidget {
  const _PhysicsCard({super.key, required this.home, required this.angle, required this.delayMs, required this.child});
  final Offset home;
  final double angle;
  final int delayMs;
  final Widget child;

  @override
  State<_PhysicsCard> createState() => _PhysicsCardState();
}

class _PhysicsCardState extends State<_PhysicsCard> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  VelocityTracker? _tracker;
  late Offset _p = widget.home.translate(0, -520);
  Offset _v = Offset.zero;
  double _rot = 0, _rv = 0;
  bool _drag = false, _falling = true, _started = false;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _rot = widget.angle + (widget.home.dx.isNegative ? -0.6 : 0.6);
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration now) {
    final dt = ((now - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _last = now;
    if (!_started) {
      if (now.inMilliseconds < widget.delayMs) return;
      _started = true;
    }
    if (_drag) return;
    final h = dt / 3;
    for (var i = 0; i < 3; i++) {
      if (_falling) {
        _v += const Offset(0, 2600) * h;
        _p += _v * h;
        if (_p.dy >= widget.home.dy) {
          _p = Offset(_p.dx, widget.home.dy);
          if (_v.dy.abs() < 160) {
            _falling = false;
            _v = Offset.zero;
          } else {
            _v = Offset(_v.dx, -_v.dy * 0.32); // bounce
            _rv += (widget.home.dx.isNegative ? 1 : -1) * 1.5;
          }
        }
      } else {
        final f = (widget.home - _p) * 140 - _v * 14;
        _v += f * h;
        _p += _v * h;
      }
      final targetRot = widget.angle + _v.dx * 0.0009;
      _rv += ((targetRot - _rot) * 120 - _rv * 11) * h;
      _rot += _rv * h;
    }
    setState(() {});
  }

  void _dragBy(Offset delta) => setState(() {
        _p += delta;
        _rot = widget.angle + delta.dx * 0.03;
      });

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _p.dx,
      top: _p.dy,
      child: Opacity(
        opacity: _started ? 1 : 0,
        // Claims the pointer on touch-down, so grabbing a card drags the card
        // instead of turning the page underneath it.
        child: RawGestureDetector(
          gestures: {
            EagerGestureRecognizer: GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
              EagerGestureRecognizer.new,
              (_) {},
            ),
          },
          child: Listener(
            onPointerDown: (e) {
              _drag = true;
              _falling = false;
              _tracker = VelocityTracker.withKind(e.kind)..addPosition(e.timeStamp, e.position);
              HapticFeedback.selectionClick();
            },
            onPointerMove: (e) {
              _tracker?.addPosition(e.timeStamp, e.position);
              _dragBy(e.localDelta);
            },
            onPointerUp: (e) {
              _v = _tracker?.getVelocity().pixelsPerSecond ?? Offset.zero;
              _drag = false;
            },
            onPointerCancel: (_) => _drag = false,
            child: Transform.rotate(angle: _rot, child: widget.child),
          ),
        ),
      ),
    );
  }
}
