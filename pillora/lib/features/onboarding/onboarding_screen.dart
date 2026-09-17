import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/motion/routes.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/text_styles.dart';
import '../shell/app_shell.dart';
import 'pill_city.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin, ClockMixin {
  late final AnimationController _intro;
  late final AnimationController _exit;
  final ValueNotifier<Offset> _look = ValueNotifier(Offset.zero);
  Offset _lookTarget = Offset.zero;
  final GlobalKey _startKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400))..forward();
    _exit = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    startClock();
    clock.addListener(_followLook);
  }

  @override
  void dispose() {
    clock.removeListener(_followLook);
    _intro.dispose();
    _exit.dispose();
    _look.dispose();
    disposeClock();
    super.dispose();
  }

  void _followLook() {
    final next = Offset.lerp(_look.value, _lookTarget, 0.06)!;
    if ((next - _look.value).distanceSquared > 0.000001) _look.value = next;
  }

  void _aim(Offset position, Size size) {
    _lookTarget = Offset(
      (position.dx / size.width * 2 - 1).clamp(-1.0, 1.0),
      (position.dy / size.height * 2 - 1).clamp(-1.0, 1.0),
    );
  }

  void _start() {
    final box = _startKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box == null
        ? Offset(MediaQuery.sizeOf(context).width / 2, MediaQuery.sizeOf(context).height)
        : box.localToGlobal(box.size.center(Offset.zero));
    _exit.forward(from: 0);
    Navigator.of(context).pushReplacement(RevealRoute(origin: origin, builder: (_) => const AppShell()));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final artHeight = math.max(size.height * 0.67, 470.0);

    return Scaffold(
      backgroundColor: Palette.deep,
      body: MouseRegion(
        onHover: (event) => _aim(event.localPosition, size),
        onExit: (_) => _lookTarget = Offset.zero,
        child: Listener(
          onPointerMove: (event) => _aim(event.localPosition, size),
          onPointerUp: (_) => _lookTarget = Offset.zero,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: artHeight,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: PillCityPainter(intro: _intro, clock: clock, look: _look, exit: _exit),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: math.max(padding.bottom, 22),
                child: _Copy(intro: _intro, clock: clock, startKey: _startKey, onStart: _start),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Copy extends StatelessWidget {
  const _Copy({required this.intro, required this.clock, required this.startKey, required this.onStart});

  final Animation<double> intro;
  final ValueNotifier<double> clock;
  final GlobalKey startKey;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    const lineOne = ['Never', 'miss', 'your'];
    const lineTwo = ['pills', 'again'];
    var index = 0;

    Widget word(String text) {
      final begin = 0.36 + index * 0.035;
      index++;
      return Entrance(
        animation: stage(intro, begin, begin + 0.2, curve: Curves.easeOutCubic),
        offset: const Offset(0, 26),
        blur: 10,
        child: Text(text, style: TextStyles.display),
      );
    }

    final wordsOne = [for (final w in lineOne) word(w)];
    final wordsTwo = [for (final w in lineTwo) word(w)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(spacing: 10, children: wordsOne),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Wrap(spacing: 10, children: wordsTwo),
            _PillEmoji(intro: intro, clock: clock),
          ],
        ),
        const SizedBox(height: 18),
        Entrance(
          animation: stage(intro, 0.55, 0.78),
          offset: const Offset(0, 14),
          blur: 4,
          child: Text(
            'Stay on top of your healthcare with timely dose\nreminders every pill track  medications',
            style: TextStyles.body.copyWith(color: const Color(0xE6FFFFFF), fontSize: 13.9, height: 1.53),
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: Entrance(
                animation: stage(intro, 0.62, 0.9, curve: Curves.easeOutBack),
                offset: const Offset(0, 30),
                child: _GetStarted(key: startKey, clock: clock, onTap: onStart),
              ),
            ),
            const SizedBox(width: 12),
            Entrance(
              animation: stage(intro, 0.68, 0.94, curve: Curves.easeOutBack),
              offset: const Offset(0, 30),
              scale: 0.6,
              child: _RoundProvider(
                onTap: onStart,
                child: const Text(
                  'G',
                  style: TextStyle(
                    fontFamily: TextStyles.family,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Entrance(
              animation: stage(intro, 0.72, 0.98, curve: Curves.easeOutBack),
              offset: const Offset(0, 30),
              scale: 0.6,
              child: _RoundProvider(
                onTap: onStart,
                child: const Icon(Icons.apple, color: Colors.white, size: 23),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PillEmoji extends StatelessWidget {
  const _PillEmoji({required this.intro, required this.clock});

  final Animation<double> intro;
  final ValueNotifier<double> clock;

  @override
  Widget build(BuildContext context) {
    final spin = stage(intro, 0.46, 0.8, curve: Curves.elasticOut);
    return AnimatedBuilder(
      animation: Listenable.merge([spin, clock]),
      builder: (context, child) {
        final t = spin.value;
        final idle = intro.value >= 1 ? wave(clock.value, 2.6) * 0.12 : 0.0;
        final hop = intro.value >= 1 ? math.max(0.0, math.sin(clock.value * math.pi / 2.6 * 2)) * -2.0 : 0.0;
        return Transform.translate(
          offset: Offset(0, -9 + hop),
          child: Transform.rotate(
            angle: lerp(-2.4, 0, t) + idle,
            child: Transform.scale(scale: t.clamp(0.0, 1.4), child: child),
          ),
        );
      },
      child: Image.asset('assets/emoji/pill.png', width: 27, height: 27),
    );
  }
}

class _GetStarted extends StatelessWidget {
  const _GetStarted({super.key, required this.clock, required this.onTap});

  final ValueNotifier<double> clock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: SizedBox(
        height: 52,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: CustomPaint(
            painter: RimPainter(clock: clock),
            child: const Center(
              child: Text(
                'Get started',
                style: TextStyle(
                  fontFamily: TextStyles.family,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RimPainter extends CustomPainter {
  RimPainter({this.clock, this.fill = Palette.onboardButton, this.shimmer = true}) : super(repaint: clock);

  final ValueNotifier<double>? clock;
  final Color fill;
  final bool shimmer;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height / 2;
    final shape = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    canvas.drawRRect(shape, Paint()..color = fill);

    final rim = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, -2.5, size.width - 1, size.height + 2),
      Radius.circular(radius),
    );
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5));
    canvas.drawRRect(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..shader = const LinearGradient(
          colors: [Color(0x00FFFFFF), Color(0xE6FFFFFF), Color(0xE6FFFFFF), Color(0x00FFFFFF)],
          stops: [0, 0.18, 0.82, 1],
        ).createShader(Offset.zero & size),
    );
    canvas.restore();

    final seconds = clock?.value ?? 0;
    if (shimmer && clock != null) {
      final phase = (seconds / 4.2) % 1;
      if (phase < 0.35) {
        final x = lerp(-size.width * 0.4, size.width * 1.4, phase / 0.35);
        canvas.drawRRect(
          shape,
          Paint()
            ..shader = const LinearGradient(
              colors: [Color(0x00FFFFFF), Color(0x24FFFFFF), Color(0x00FFFFFF)],
              transform: GradientRotation(0.35),
            ).createShader(Rect.fromLTWH(x - 60, 0, 120, size.height)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(RimPainter oldDelegate) => oldDelegate.fill != fill;
}

class _RoundProvider extends StatelessWidget {
  const _RoundProvider({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: Container(
        width: 55,
        height: 55,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Palette.onboardCircle),
        child: child,
      ),
    );
  }
}
