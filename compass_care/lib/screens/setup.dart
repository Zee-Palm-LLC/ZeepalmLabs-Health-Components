import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../icons.dart';
import '../theme.dart';
import '../widgets/compass.dart';
import '../widgets/confetti.dart';
import '../widgets/sky.dart';
import '../widgets/ui.dart';

/// Ten-step setup. The sky, stepper and CTA persist while each step's
/// content is swapped with a directional depth transition.
class SetupFlow extends StatefulWidget {
  const SetupFlow({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<SetupFlow> createState() => _SetupFlowState();
}

class _Spec {
  const _Spec(this.cta, {this.stepper, this.back = true});
  final String cta;
  final int? stepper;
  final bool back;
}

const _specs = [
  _Spec('Continue', back: false), // 0 who
  _Spec('Continue', stepper: 1), // 1 head
  _Spec('Continue', stepper: 2), // 2 find
  _Spec('Continue', stepper: 3), // 3 emergency
  _Spec('Continue', back: false), // 4 name
  _Spec('Continue', stepper: 4), // 5 parents
  _Spec('Save'), // 6 add parent
  _Spec('Continue', stepper: 5), // 7 reminders
  _Spec('Start my 30-day free trial', back: false), // 8 plan
  _Spec('Go to my dashboard', back: false), // 9 done
];

class _SetupFlowState extends State<SetupFlow> {
  int _step = 0;
  bool _forward = true;
  int _lastStepper = 1;
  String _first = 'Alex', _last = 'Rivers';
  final _answers = <int, int>{};
  final _reminders = <int>{};
  int _plan = 1;
  int _who = 1;
  bool _parentAdded = false;

  void _go(int to) {
    if (to < 0) return;
    if (to >= _specs.length) {
      widget.onDone();
      return;
    }
    HapticFeedback.mediumImpact();
    final st = _specs[_step].stepper;
    setState(() {
      if (st != null) _lastStepper = st;
      _forward = to > _step;
      if (_step == 6 && to == 7) _parentAdded = true;
      _step = to;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spec = _specs[_step];
    return Stack(
      children: [
        const Positioned.fill(child: Sky(mode: SkyMode.setup)),
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 750),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (cur, prev) => Stack(children: [...prev, ?cur]),
            transitionBuilder: (child, anim) {
              final incoming = child.key == ValueKey(_step);
              return AnimatedBuilder(
                animation: anim,
                child: child,
                builder: (context, child) {
                  final a = anim.value;
                  final dir = _forward ? 1.0 : -1.0;
                  // Incoming rises from depth; outgoing drifts up and away.
                  final dx = incoming ? (1 - a) * 70 * dir : -(1 - a) * 70 * dir;
                  final sc = incoming ? 1.06 - 0.06 * a : 0.94 + 0.06 * a;
                  final blur = (1 - a) * 12;
                  Widget w = Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..translateByDouble(dx, 0, 0, 1)
                      ..rotateY(-(dx / 70) * 0.25)
                      ..scaleByDouble(sc, sc, 1, 1),
                    child: child,
                  );
                  w = ImageFiltered(
                    enabled: blur > 0.1,
                    imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: w,
                  );
                  return IgnorePointer(
                    ignoring: !incoming,
                    child: Opacity(opacity: a, child: w),
                  );
                },
              );
            },
            child: KeyedSubtree(key: ValueKey(_step), child: _content(_step)),
          ),
        ),
        // Persistent stepper.
        Positioned(
          left: 30,
          top: 76,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: spec.stepper != null ? 1 : 0,
            child: StepperBar(index: spec.stepper ?? _lastStepper, from: _lastStepper),
          ),
        ),
        // Persistent CTA.
        AnimatedPositioned(
          duration: const Duration(milliseconds: 600),
          curve: springOut,
          left: 16,
          right: 16,
          top: spec.back ? 694 : 741,
          child: PrimaryButton(spec.cta, onTap: () => _go(_step == 5 && !_parentAdded ? 6 : (_step == 5 ? 7 : _step + 1))),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 768,
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 350),
              opacity: spec.back ? 1 : 0,
              child: IgnorePointer(
                ignoring: !spec.back,
                child: BackLink(onTap: () => _go(_step - 1)),
              ),
            ),
          ),
        ),
        const Positioned(left: 0, right: 0, top: 0, child: StatusBar()),
      ],
    );
  }

  Widget _content(int step) {
    final name = _first.trim().isEmpty ? 'Alex' : _first.trim();
    switch (step) {
      case 0:
        return _WhoScreen(name: name, selected: _who, onSelect: (i) => setState(() => _who = i));
      case 1:
        return _QuestionScreen(
          title: '$name, how much are you keeping in your head right now?',
          subtitle: 'Appointments, meds, bills, documents...',
          options: const [
            ('brain', 'More than I can keep straight'),
            ('notepad', 'A few important things'),
            ('sticky', 'Mostly memory and sticky notes'),
            ('calendar', 'I already have a system'),
          ],
          selected: _answers[1],
          onSelect: (i) => setState(() => _answers[1] = i),
        );
      case 2:
        return _QuestionScreen(
          title: 'Last time you needed something fast, how easy was it to find?',
          options: const [
            ('scribble', 'I searched and couldn\'t find it'),
            ('stopwatch', 'It took too long'),
            ('magnifier', 'I found it eventually'),
            ('folder', 'Didn\'t have any trouble finding it'),
          ],
          selected: _answers[2],
          onSelect: (i) => setState(() => _answers[2] = i),
        );
      case 3:
        return _QuestionScreen(
          title: 'If an emergency happened, would you be ready?',
          options: const [
            ('bolt', 'Not at all'),
            ('storm', 'I\'d be scrambling'),
            ('firstaid', 'Somewhat ready'),
            ('shield', 'Fully prepared'),
          ],
          selected: _answers[3],
          onSelect: (i) => setState(() => _answers[3] = i),
        );
      case 4:
        return _NameScreen(
          first: _first,
          last: _last,
          onFirst: (v) => setState(() => _first = v),
          onLast: (v) => setState(() => _last = v),
        );
      case 5:
        return _ParentsScreen(added: _parentAdded, onAdd: () => _go(6));
      case 6:
        return const _AddParentScreen();
      case 7:
        return _RemindersScreen(
          selected: _reminders,
          onToggle: (i) {
            setState(() {
              if (i == 3) {
                _reminders
                  ..clear()
                  ..add(3);
              } else {
                _reminders.remove(3);
                _reminders.contains(i) ? _reminders.remove(i) : _reminders.add(i);
              }
            });
          },
        );
      case 8:
        return _PlanScreen(plan: _plan, onPlan: (p) => setState(() => _plan = p));
      default:
        return const _DoneScreen();
    }
  }
}

// ---------------------------------------------------------------------------
// Shared header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    this.tag,
    required this.title,
    this.subtitle,
    required this.top,
    this.titleSize = 30,
    this.serifTitle = false,
    this.gap = 12,
    this.pad = 36,
  });
  final String? tag;
  final String title;
  final String? subtitle;
  final double top, titleSize, gap, pad;
  final bool serifTitle;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: top,
      child: Column(
        children: [
          if (tag != null) ...[Entrance(delay: 60, scale: 0.7, blur: 6, child: TagPill(tag!)), const SizedBox(height: 22)],
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: BlurText(
              title,
              delay: 120,
              style: serifTitle ? serif(titleSize, w: FontWeight.w600, height: 1.18) : title_(titleSize),
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: gap),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Entrance(
                delay: 380,
                dy: 10,
                blur: 4,
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: sans(13, color: C.muted, height: 1.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

TextStyle title_(double s) => title(s);

// ---------------------------------------------------------------------------
// 0 - Who are you organising care for? (clothesline)
// ---------------------------------------------------------------------------

class _WhoScreen extends StatefulWidget {
  const _WhoScreen({required this.name, required this.selected, required this.onSelect});
  final String name;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  State<_WhoScreen> createState() => _WhoScreenState();
}

class _Pendulum {
  double angle, vel = 0;
  _Pendulum(this.angle);
}

/// Cards hang from pins on a sagging line. Dragging slides them along the
/// rope; the pins' acceleration drives real pendulum dynamics on each card
/// and the rope itself vibrates with the motion.
class _WhoScreenState extends State<_WhoScreen> with SingleTickerProviderStateMixin {
  static const _people = [
    ('assets/images/p_partner.png', 'Partner', 'Spouse or life partner', Color(0xFFE6DDF8)),
    ('assets/images/p_boy.png', 'My child', 'Parent or step-parent', Color(0xFFCDEEDC)),
    ('assets/images/p_grandma.png', 'Aging parents', 'Parent or in-law', Color(0xFFFBD9D4)),
  ];
  static const _spacing = 160.0;

  late final Ticker _ticker;
  double _s = 1; // scroll position along the rope, in cards
  double _sv = 0, _prevV = 0;
  double? _target;
  bool _dragging = false;
  final _cards = [_Pendulum(0.9), _Pendulum(-0.7), _Pendulum(0.8)];
  double _rope = 0, _ropeV = 0, _time = 0, _intro = 0;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _s = widget.selected.toDouble(); // centre the selected card
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration now) {
    final dt = ((now - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _last = now;
    _time = now.inMicroseconds / 1e6;
    _intro = math.min(1, _intro + dt / 1.2);
    final h = dt / 4;
    for (var k = 0; k < 4; k++) {
      if (!_dragging) {
        final tgt = _target ?? _s.roundToDouble();
        _sv += ((tgt - _s) * 60 - _sv * 11) * h;
        _s += _sv * h;
      }
      // Horizontal acceleration of the pins in design px/s^2.
      final acc = (_sv - _prevV) / h * _spacing;
      _prevV = _sv;
      for (var i = 0; i < 3; i++) {
        final p = _cards[i];
        final wind = 0.35 * math.sin(_time * 0.9 + i * 1.7) + 0.2 * math.sin(_time * 2.3 + i);
        // theta'' = -(g/L) sin(theta) - (a/L) cos(theta) - c theta' + wind
        final a = -38 * math.sin(p.angle) + (acc.clamp(-4000, 4000) / 300) * math.cos(p.angle) - 2.6 * p.vel + wind;
        p.vel += a * h;
        p.angle += p.vel * h;
      }
      _ropeV += (-_rope * 220 - _ropeV * 6 - _sv.abs() * 40 * math.sin(_time * 30)) * h;
      _rope += _ropeV * h;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double _titleWidth() {
    final tp = TextPainter(text: TextSpan(text: 'Hi, ${widget.name}', style: title(30)), textDirection: TextDirection.ltr)..layout();
    return tp.width;
  }

  double _ropeY(double x) => 337 - 0.0009 * math.pow(x - 190, 2) + _rope * math.sin((x + 20) / 430 * math.pi);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _Header(
          tag: 'Care set up',
          title: 'Hi, ${widget.name}',
          subtitle: 'Let\'s start shaping your experience.',
          top: 82,
          titleSize: 30,
          gap: 16,
        ),
        // Waving hand next to the greeting.
        Positioned(
          left: 195 + _titleWidth() / 2 + 4,
          top: 134,
          child: Entrance(
            delay: 500,
            scale: 0.2,
            curve: springOut,
            child: Transform.rotate(
              angle: math.sin(_time * 7) * 0.3 * math.max(0, math.sin(_time * 1.3)),
              alignment: const Alignment(0.3, 0.9),
              child: Image.asset('assets/images/i_wave.png', width: 34),
            ),
          ),
        ),
        // Rope + cards.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (_) {
              _dragging = true;
              _target = null;
            },
            onHorizontalDragUpdate: (d) {
              final dv = -d.delta.dx / _spacing;
              _s = (_s + dv).clamp(-0.4, 2.4);
              _sv = dv * 60;
            },
            onHorizontalDragEnd: (d) {
              _dragging = false;
              final v = -d.velocity.pixelsPerSecond.dx / _spacing;
              final t = (_s + v * 0.25).roundToDouble().clamp(0.0, 2.0);
              _target = t;
              _sv = v;
              widget.onSelect(t.toInt());
              HapticFeedback.selectionClick();
            },
            child: CustomPaint(painter: _RopePainter(_ropeY, _intro)),
          ),
        ),
        for (var i = 0; i < 3; i++) _card(i),
        _Header(
          title: 'Who are you organizing care for?',
          subtitle: 'Tell us who you\'re supporting so we can personalize your experience',
          top: 586,
          titleSize: 30,
        ),
      ],
    );
  }

  Widget _card(int i) {
    final x = 190 + (i - _s) * _spacing;
    final pinY = _ropeY(x);
    final p = _people[i];
    final sel = (i - _s).abs() < 0.5;
    final drop = Curves.easeOutBack.transform(((_intro - i * 0.12) / 0.7).clamp(0.0, 1.0));
    const w = 148.0, h = 142.0;
    return Positioned(
      left: x - w / 2,
      top: pinY - 4 - (1 - drop) * 260,
      child: Opacity(
        opacity: drop.clamp(0.0, 1.0),
        child: Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()..rotateZ(_cards[i].angle * 0.5 + (0.2 * (i - _s)).clamp(-0.32, 0.32)),
          child: GestureDetector(
            onTap: () {
              _target = i.toDouble();
              widget.onSelect(i);
              _cards[i].vel += 3;
              HapticFeedback.selectionClick();
            },
            child: SizedBox(
              width: w,
              height: h + 20,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 20,
                    child: AnimatedScale(
                      scale: sel ? 1 : 0.94,
                      duration: const Duration(milliseconds: 400),
                      curve: springOut,
                      alignment: Alignment.topCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: w,
                        height: h,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: sel ? 1 : 0.86),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: sel ? const Color(0x66F0473A) : Colors.transparent, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: sel ? const Color(0x2EB4321F) : const Color(0x14B4321F),
                              blurRadius: sel ? 24 : 14,
                              offset: Offset(_cards[i].angle * -6, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(color: p.$4, borderRadius: BorderRadius.circular(14)),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(p.$1, fit: BoxFit.cover),
                            ),
                            const Spacer(),
                            Text(p.$2, style: serif(14.5, w: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(p.$3, style: sans(10.5, color: C.muted, height: 1.3)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Positioned(left: w / 2 - 9, top: 0, child: _Pin()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin();

  @override
  Widget build(BuildContext context) => CustomPaint(size: const Size(18, 30), painter: _PinPainter());
}

class _PinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(Rect.fromLTWH(1, 2, 16, 26), const Radius.circular(8));
    canvas.drawRRect(
      body.shift(const Offset(0, 2)),
      Paint()
        ..color = const Color(0x40A01C10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawRRect(
      body,
      Paint()..shader = const LinearGradient(colors: [Color(0xFFFF7366), Color(0xFFE23B2E)]).createShader(body.outerRect),
    );
    canvas.drawCircle(const Offset(9, 10), 3.4, Paint()..color = Colors.white);
    canvas.drawLine(
      const Offset(6, 18),
      const Offset(12, 18),
      Paint()
        ..color = const Color(0x55FFFFFF)
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(_PinPainter old) => false;
}

class _RopePainter extends CustomPainter {
  _RopePainter(this.y, this.t);
  final double Function(double) y;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(-20, y(-20));
    final end = -20 + 430 * smoothOut.transform(t);
    for (double x = -20; x <= end; x += 6) {
      path.lineTo(x, y(x));
    }
    canvas.drawPath(
      path.shift(const Offset(0, 3)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x22B4321F)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_RopePainter old) => true;
}

// ---------------------------------------------------------------------------
// 1-3 - Questions
// ---------------------------------------------------------------------------

class _QuestionScreen extends StatelessWidget {
  const _QuestionScreen({
    required this.title,
    this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelect,
  });
  final String title;
  final String? subtitle;
  final List<(String, String)> options;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final top = subtitle != null ? 306.0 : 268.0;
    return Stack(
      children: [
        _Header(title: title, subtitle: subtitle, top: 134, gap: 22, pad: 50),
        for (var i = 0; i < options.length; i++)
          Positioned(
            left: 42,
            right: 42,
            top: top + i * 86,
            child: Entrance(
              delay: 320 + i * 90,
              dy: 46,
              blur: 6,
              scale: 0.94,
              curve: springOut,
              duration: 1000,
              child: OptionCard(
                image: 'assets/images/i_${options[i].$1}.png',
                label: options[i].$2,
                selected: selected == i,
                dimmed: selected != null && selected != i,
                onTap: () => onSelect(i),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 4 - Name (the compass needle follows the field you are typing in)
// ---------------------------------------------------------------------------

class _NameScreen extends StatefulWidget {
  const _NameScreen({required this.first, required this.last, required this.onFirst, required this.onLast});
  final String first, last;
  final ValueChanged<String> onFirst, onLast;

  @override
  State<_NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<_NameScreen> {
  int _focus = -1;
  int _keys = 0;

  @override
  Widget build(BuildContext context) {
    final base = switch (_focus) {
      0 => -0.32,
      1 => 0.3,
      _ => math.pi / 4,
    };
    final heading = base + (_keys.isEven ? 0.07 : -0.07) * (_focus >= 0 ? 1 : 0);
    return Stack(
      children: [
        Positioned(
          left: 195 - 176,
          top: 432,
          child: Entrance(
            delay: 350,
            scale: 0.6,
            blur: 14,
            dy: 80,
            duration: 1300,
            child: CompassEmblem(size: 352, heading: heading),
          ),
        ),
        // Clouds/fog swallowing the bottom of the compass.
        const Positioned(
          left: 0,
          right: 0,
          top: 640,
          height: 110,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00FFFFFF), Color(0xE6FFFFFF), Colors.white],
                ),
              ),
            ),
          ),
        ),
        const _Header(
          tag: 'Care set up',
          title: 'What should\nwe call you?',
          subtitle: 'We use this to personalize your experience.',
          top: 82,
          gap: 22,
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 282,
          child: Entrance(
            delay: 300,
            dy: 30,
            blur: 4,
            child: FieldCard(
              label: 'First name',
              initial: widget.first,
              onFocus: (f) => setState(() => _focus = f ? 0 : (_focus == 0 ? -1 : _focus)),
              onChanged: (v) {
                setState(() => _keys++);
                widget.onFirst(v);
              },
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 352,
          child: Entrance(
            delay: 400,
            dy: 30,
            blur: 4,
            child: FieldCard(
              label: 'Last name',
              initial: widget.last,
              onFocus: (f) => setState(() => _focus = f ? 1 : (_focus == 1 ? -1 : _focus)),
              onChanged: (v) {
                setState(() => _keys++);
                widget.onLast(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 5 - Parents: portraits spiral out of the centre into compass rings
// ---------------------------------------------------------------------------

class _ParentsScreen extends StatefulWidget {
  const _ParentsScreen({required this.added, required this.onAdd});
  final bool added;
  final VoidCallback onAdd;

  @override
  State<_ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends State<_ParentsScreen> with SingleTickerProviderStateMixin, TickerRepaint {
  @override
  Widget build(BuildContext context) {
    final people = [
      ('assets/images/p_grandma.png', 'Mother', 'Patricia Rivers', const Offset(100, 370)),
      ('assets/images/p_grandpa.png', 'Father', 'Robert Rivers', const Offset(292, 370)),
    ];
    return AnimatedBuilder(
      animation: time,
      builder: (context, _) {
        final t = time.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const _Header(
              title: 'Add your parents',
              subtitle: 'Set up your loved ones so you can help with reminders and share what matters most.',
              top: 128,
              gap: 14,
            ),
            for (var i = 0; i < people.length; i++) _orbitIn(i, people[i], t),
            // The add slot.
            Positioned(
              left: 190 - 70,
              top: 548 - 70,
              child: Entrance(
                delay: 1100,
                scale: 0.3,
                curve: springOut,
                child: GestureDetector(
                  onTap: widget.onAdd,
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: CustomPaint(painter: _RingPainter(t, 52 + math.sin(t * 2.2) * 2, plus: true)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _orbitIn(int i, (String, String, String, Offset) p, double t) {
    // 0..1 progress along a spiral from the centre to the ring.
    final k = Curves.easeOutCubic.transform(((t - 0.25 - i * 0.18) / 1.2).clamp(0.0, 1.0));
    const start = Offset(195, 520);
    final end = p.$4;
    final dir = i == 0 ? -1.0 : 1.0;
    final ang = (1 - k) * math.pi * 1.2 * dir;
    final rel = (end - start) * k;
    final pos = start + Offset(rel.dx * math.cos(ang) - rel.dy * math.sin(ang), rel.dx * math.sin(ang) + rel.dy * math.cos(ang));
    final bob = math.sin(t * 1.4 + i * 2) * 3 * k;
    const ring = 132.0;
    return Positioned(
      left: pos.dx - ring / 2,
      top: pos.dy - ring / 2 + bob,
      child: Opacity(
        opacity: (k * 2).clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.3 + 0.7 * k,
          child: SizedBox(
            width: ring,
            height: ring + 50,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                SizedBox(
                  width: ring,
                  height: ring,
                  child: CustomPaint(painter: _RingPainter(t + i, 52)),
                ),
                Positioned(
                  top: ring / 2 - 44,
                  child: Transform.rotate(
                    angle: ang * 0.5,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [BoxShadow(color: Color(0x33B4321F), blurRadius: 16, offset: Offset(0, 8))],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(p.$1, fit: BoxFit.cover),
                    ),
                  ),
                ),
                Positioned(
                  top: ring + 2,
                  child: Opacity(
                    opacity: ((k - 0.7) / 0.3).clamp(0.0, 1.0),
                    child: Column(
                      children: [
                        Text(p.$2, style: sans(12.5, w: FontWeight.w600)),
                        Text(p.$3, style: sans(10, color: C.muted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.t, this.r, {this.plus = false});
  final double t, r;
  final bool plus;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // Soft disc.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFF4F1), Color(0xFFFCDCD5)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
    canvas.drawCircle(
      c,
      r + 8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFF9CFC6),
    );
    // Rotating dashed orbit.
    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFF4A99D);
    for (var i = 0; i < 24; i++) {
      final a0 = t * 0.4 + i * math.pi / 12;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r + 15), a0, math.pi / 30, false, orbit);
    }
    // Cardinal ticks.
    final tick = Paint()..color = const Color(0xFFF7B9AE);
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final d = Offset(math.sin(a), -math.cos(a));
      final n = Offset(-d.dy, d.dx);
      final b = c + d * (r + 10);
      canvas.drawPath(
        Path()
          ..moveTo(b.dx + n.dx * 6, b.dy + n.dy * 6)
          ..lineTo(c.dx + d.dx * (r + 26), c.dy + d.dy * (r + 26))
          ..lineTo(b.dx - n.dx * 6, b.dy - n.dy * 6)
          ..close(),
        tick,
      );
    }
    if (plus) {
      final p = Paint()
        ..color = const Color(0xFFF08A7E)
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(c.translate(-10, 0), c.translate(10, 0), p);
      canvas.drawLine(c.translate(0, -10), c.translate(0, 10), p);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => true;
}

// ---------------------------------------------------------------------------
// 6 - Add a parent: tap the tile and the photo irises open
// ---------------------------------------------------------------------------

class _AddParentScreen extends StatefulWidget {
  const _AddParentScreen();

  @override
  State<_AddParentScreen> createState() => _AddParentScreenState();
}

class _AddParentScreenState extends State<_AddParentScreen> {
  bool _photo = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _Header(tag: 'Care set up', title: 'Add a parent', top: 82),
        Positioned(
          left: 137,
          top: 188,
          child: Entrance(
            delay: 250,
            scale: 0.6,
            blur: 8,
            curve: springOut,
            child: Pressable(
              onTap: () {
                HapticFeedback.heavyImpact();
                setState(() => _photo = !_photo);
              },
              child: Container(
                width: 116,
                height: 124,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: softShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFF7468), C.redDeep],
                            ),
                            boxShadow: const [BoxShadow(color: Color(0x55F0473A), blurRadius: 12, offset: Offset(0, 6))],
                          ),
                          child: const Icon(PhB.plus, color: Colors.white, size: 22),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          'Take or upload\na photo',
                          textAlign: TextAlign.center,
                          style: sans(9.5, color: C.muted, height: 1.25),
                        ),
                      ],
                    ),
                    // Iris reveal of the photo.
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: _photo ? 1 : 0),
                      duration: const Duration(milliseconds: 750),
                      curve: Curves.easeInOutCubic,
                      builder: (context, t, _) {
                        if (t == 0) return const SizedBox.shrink();
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipPath(
                              clipper: _IrisClipper(t),
                              child: Image.asset('assets/images/p_grandma.png', fit: BoxFit.cover),
                            ),
                            // Shutter flash.
                            IgnorePointer(
                              child: Container(color: Colors.white.withValues(alpha: (1 - (t - 0.1).abs() * 4).clamp(0.0, 0.8))),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        for (final (i, l, v) in [(0, 'Title', 'Mother'), (1, 'First name', 'Patricia'), (2, 'Last name', 'Rivers')])
          Positioned(
            left: 16,
            right: 16,
            top: 330 + i * 70.0,
            child: Entrance(
              delay: 350 + i * 90,
              dy: 30,
              blur: 4,
              child: FieldCard(label: l, initial: v),
            ),
          ),
      ],
    );
  }
}

/// Six-bladed camera iris opening to a full rectangle.
class _IrisClipper extends CustomClipper<Path> {
  _IrisClipper(this.t);
  final double t;

  @override
  Path getClip(Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.longestSide * 0.75;
    final r = maxR * t;
    final p = Path();
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3 + t * 1.2;
      final pt = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  @override
  bool shouldReclip(_IrisClipper old) => old.t != t;
}

// ---------------------------------------------------------------------------
// 7 - Reminders (scalloped card unrolls)
// ---------------------------------------------------------------------------

class _RemindersScreen extends StatelessWidget {
  const _RemindersScreen({required this.selected, required this.onToggle});
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    const rows = [
      (Ph.bellRinging, 'Push notifications', 'Recommended'),
      (Ph.chatText, 'SMS text messages', null),
      (Ph.envelope, 'Email', null),
      (Ph.clockCountdown, 'I\'ll set this up later', null),
    ];
    return Stack(
      children: [
        const _Header(
          title: 'Set your care plan reminders',
          subtitle: 'We\'ll remind you about meds,\nappointments and tasks.',
          top: 134,
          gap: 22,
        ),
        Positioned(
          left: 43,
          right: 43,
          top: 300,
          child: ScallopCard(
            delay: 350,
            children: [
              for (var i = 0; i < rows.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Pressable(
                    scale: 0.97,
                    onTap: () => onToggle(i),
                    child: Row(
                      children: [
                        _RedTile(rows[i].$1, ring: selected.contains(i)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rows[i].$2, style: serif(14.5)),
                              if (rows[i].$3 != null) Text(rows[i].$3!, style: sans(10.5, color: C.muted)),
                            ],
                          ),
                        ),
                        CheckBox3(checked: selected.contains(i)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Red gradient icon tile; when active its icon rings like a bell.
class _RedTile extends StatelessWidget {
  const _RedTile(this.icon, {this.ring = false});
  final IconData icon;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(ring),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (context, t, child) {
        final wob = ring ? math.sin(t * math.pi * 6) * (1 - t) * 0.35 : 0.0;
        return Transform.rotate(angle: wob, alignment: Alignment.topCenter, child: child);
      },
      child: IconChip(icon, C.red, size: 42, radius: 11),
    );
  }
}

// ---------------------------------------------------------------------------
// 8 - Plan (odometer prices)
// ---------------------------------------------------------------------------

class _PlanScreen extends StatelessWidget {
  const _PlanScreen({required this.plan, required this.onPlan});
  final int plan;
  final ValueChanged<int> onPlan;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const _Header(
          tag: 'Choose the plan',
          title: 'Choose the plan that fits your family',
          subtitle: 'Start with a 30-day free trial, then continue with the option that works best for you.',
          top: 82,
          gap: 16,
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 290,
          child: Center(
            child: Entrance(
              delay: 400,
              scale: 0.7,
              curve: springOut,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 18, 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: softShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const IconChip(Ph.calendarCheck, C.red, size: 36, radius: 10),
                    const SizedBox(width: 14),
                    Text('30-day free trial', style: serif(14, color: C.red)),
                  ],
                ),
              ),
            ),
          ),
        ),
        for (var i = 0; i < 2; i++)
          Positioned(
            left: i == 0 ? 16 : 199,
            top: 376,
            child: Entrance(
              delay: 500 + i * 120,
              dy: 50,
              blur: 6,
              curve: springOut,
              duration: 1100,
              child: _PlanCard(yearly: i == 1, selected: plan == i, onTap: () => onPlan(i)),
            ),
          ),
        Positioned(
          left: 252,
          top: 364,
          child: Entrance(
            delay: 1100,
            scale: 0.2,
            rotate: -0.6,
            curve: springOut,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: C.red,
                borderRadius: BorderRadius.circular(9),
                boxShadow: const [BoxShadow(color: Color(0x55F0473A), blurRadius: 8, offset: Offset(0, 3))],
              ),
              child: Text(
                'Save 40%',
                style: sans(10, color: Colors.white, w: FontWeight.w600),
              ),
            ),
          ),
        ),
        for (final (i, x, icon, color, label) in [
          (0, 70.0, Ph.shieldCheck, C.green, 'Secure'),
          (1, 192.0, Ph.sparkle, C.purple, 'Full access to all\nfeatures'),
          (2, 318.0, Ph.lockKey, C.red, 'Private'),
        ])
          Positioned(
            left: x - 60,
            top: 556,
            width: 120,
            child: Entrance(
              delay: 800 + i * 110,
              scale: 0.4,
              curve: springOut,
              child: Column(
                children: [
                  IconChip(icon, color, size: 42, radius: 11),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: sans(10.5, color: C.ink2, height: 1.3),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          top: 706,
          child: Entrance(
            delay: 1000,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Ph.lockKey, size: 11, color: C.muted),
                const SizedBox(width: 6),
                Text('Cancel anytime. No commitment.', style: sans(11.5, color: C.muted)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.yearly, required this.selected, required this.onTap});
  final bool yearly, selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        width: 175,
        height: 150,
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? C.red.withValues(alpha: 0.55) : Colors.white, width: selected ? 1.6 : 1),
          boxShadow: [
            BoxShadow(
              color: selected ? const Color(0x30F0473A) : const Color(0x14B4442F),
              blurRadius: selected ? 28 : 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(yearly ? 'Yearly' : 'Monthly', style: sans(12, color: C.muted)),
                const Spacer(),
                _Radio(selected),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Odometer(
                  value: yearly ? 1.92 : 3.25,
                  style: sans(27, w: FontWeight.w700, height: 1.1, ls: -0.8),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 2),
                  child: Text('/week', style: sans(10, color: C.muted)),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(yearly ? '≈\$99.99/yearly' : '≈\$12.99/monthly', style: sans(10.5, color: C.muted)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: yearly ? C.tagBg : const Color(0xFFF2EEED),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                yearly ? 'Best value' : '30 days free',
                style: sans(9.5, color: yearly ? C.red : C.ink2, w: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio(this.on);
  final bool on;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: springOut,
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: on ? C.red : const Color(0xFFE5DEDC), width: on ? 5 : 1.4),
        color: Colors.white,
      ),
    );
  }
}

/// Mechanical odometer: each digit wheel rolls continuously with the value,
/// so lower digits spin through many numbers while higher ones tick over.
class Odometer extends StatelessWidget {
  const Odometer({super.key, required this.value, required this.style});
  final double value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        var cents = v * 100;
        if ((cents - cents.round()).abs() < 1e-3) cents = cents.roundToDouble();
        final h = style.fontSize! * (style.height ?? 1.2);
        Widget wheel(int place) {
          // The units wheel turns continuously; every higher wheel only ticks
          // over while the wheel below it rolls from 9 to 0, like a real one.
          final unit = math.pow(10, place).toDouble();
          final digit = (cents / unit).floor() % 10;
          final below = (cents % unit) / unit;
          final carry = place == 0 ? below : Curves.easeInOut.transform(((below - 0.9) / 0.1).clamp(0.0, 1.0));
          final pos = place == 0 ? cents % 10 : digit + carry;
          return SizedBox(
            width: style.fontSize! * 0.6,
            height: h,
            child: ClipRect(
              child: OverflowBox(
                maxHeight: double.infinity,
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: Offset(0, -pos * h),
                  child: Column(
                    children: [
                      for (var d = 0; d <= 10; d++)
                        SizedBox(
                          height: h,
                          child: Center(child: Text('${d % 10}', style: style)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('\$', style: style),
            wheel(2),
            Text('.', style: style),
            wheel(1),
            wheel(0),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 9 - Done
// ---------------------------------------------------------------------------

class _DoneScreen extends StatelessWidget {
  const _DoneScreen();

  @override
  Widget build(BuildContext context) {
    const rows = [
      (Ph.bellRinging, C.red, 'Smart reminders'),
      (Ph.fileText, C.purple, 'Organized documents'),
      (Ph.usersThree, C.blue, 'Shared family access'),
      (Ph.firstAid, C.green, 'Emergency-ready logs'),
    ];
    return Stack(
      children: [
        Positioned(
          left: 195 - 32,
          top: 70,
          child: Entrance(
            scale: 0.2,
            curve: springOut,
            duration: 1200,
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Color(0xFFFFE6E1), Color(0xFFFBD0C8)]),
                boxShadow: [BoxShadow(color: Color(0x44F0473A), blurRadius: 28, spreadRadius: 4)],
              ),
              child: const Center(child: CompassGlyph(size: 26)),
            ),
          ),
        ),
        const _Header(
          title: 'You\'re officially set up for better care',
          subtitle: 'Your family\'s important details are now easier to organize, share and access when it matters.',
          top: 158,
          titleSize: 28,
          serifTitle: true,
          gap: 18,
        ),
        Positioned(
          left: 40,
          right: 40,
          top: 326,
          child: ScallopCard(
            delay: 500,
            children: [
              for (var i = 0; i < rows.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      IconChip(rows[i].$1, rows[i].$2, size: 42, radius: 11),
                      const SizedBox(width: 14),
                      Expanded(child: Text(rows[i].$3, style: serif(14.5))),
                      _DelayedCheck(delayMs: 1200 + i * 260),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const Positioned.fill(child: Confetti(origin: Offset(195, 100))),
      ],
    );
  }
}

class _DelayedCheck extends StatefulWidget {
  const _DelayedCheck({required this.delayMs});
  final int delayMs;

  @override
  State<_DelayedCheck> createState() => _DelayedCheckState();
}

class _DelayedCheckState extends State<_DelayedCheck> {
  bool _on = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      setState(() => _on = true);
    });
  }

  @override
  Widget build(BuildContext context) => CheckBox3(checked: _on);
}
