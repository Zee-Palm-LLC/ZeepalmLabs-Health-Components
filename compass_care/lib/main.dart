import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/intro.dart';
import 'screens/setup.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
  runApp(const CompassCareApp());
}

class CompassCareApp extends StatelessWidget {
  const CompassCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compass Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: Colors.white, colorSchemeSeed: C.red),
      home: const Shell(),
    );
  }
}

const _images = [
  'pill', 'p_partner', 'p_boy', 'p_grandma', 'p_grandpa', 'p_man', 'p_woman', //
  'i_brain', 'i_notepad', 'i_sticky', 'i_calendar', 'i_scribble', 'i_stopwatch', 'i_magnifier', 'i_folder',
  'i_bolt', 'i_storm', 'i_firstaid', 'i_shield', 'i_wave',
];

/// Lays the 390x844 design out at true proportions: full-bleed on phones, in
/// a device frame on wide screens.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    for (final i in _images) {
      precacheImage(AssetImage('assets/images/$i.png'), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth > 600;
          if (!wide) {
            return const SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(width: 390, height: 844, child: AppFlow()),
              ),
            );
          }
          final scale = math.min(1.0, (box.maxHeight - 48) / 868);
          return ColoredBox(
            color: const Color(0xFFF3EFEE),
            child: Center(
              child: SizedBox(
                width: 414 * scale,
                height: 868 * scale,
                child: FittedBox(
                  child: Container(
                    width: 390 + 24,
                    height: 844 + 24,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF16181B), borderRadius: BorderRadius.circular(64)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(52),
                      child: const SizedBox(width: 390, height: 844, child: AppFlow()),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Intro -> setup -> (dashboard restarts the demo), joined by a cloud wipe.
class AppFlow extends StatefulWidget {
  const AppFlow({super.key, this.startInSetup = false});
  final bool startInSetup;

  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> with SingleTickerProviderStateMixin {
  late final _wipe = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  late bool _setup = widget.startInSetup;
  int _gen = 0;

  void _to(bool setup) {
    if (_wipe.isAnimating) return;
    HapticFeedback.mediumImpact();
    var swapped = false;
    void listener() {
      if (!swapped && _wipe.value >= 0.5) {
        swapped = true;
        setState(() {
          _setup = setup;
          _gen++;
        });
      }
    }

    _wipe.addListener(listener);
    _wipe.forward(from: 0).whenComplete(() => _wipe.removeListener(listener));
  }

  @override
  void dispose() {
    _wipe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _setup
              ? SetupFlow(key: ValueKey(_gen), onDone: () => _to(false))
              : IntroScreen(key: ValueKey(_gen), onDone: () => _to(true)),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _wipe,
              builder: (context, _) => _wipe.value == 0 || _wipe.isCompleted
                  ? const SizedBox.shrink()
                  : CustomPaint(painter: _CloudWipePainter(_wipe.value)),
            ),
          ),
        ),
      ],
    );
  }
}

/// A wall of billowing cloud puffs rises from the bottom, swallows the
/// screen, then lifts away and thins out to reveal the next scene.
class _CloudWipePainter extends CustomPainter {
  _CloudWipePainter(this.t);
  final double t;

  static final _puffs = () {
    final r = math.Random(11);
    return List.generate(46, (i) => (r.nextDouble(), r.nextDouble(), 0.5 + r.nextDouble() * 0.7, r.nextDouble()));
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 390;
    final rise = Curves.easeInOutCubic.transform((t * 2).clamp(0.0, 1.0));
    final leave = Curves.easeInCubic.transform(((t - 0.5) * 2).clamp(0.0, 1.0));
    final fill = (1 - (t - 0.5).abs() * 6).clamp(0.0, 1.0);
    if (fill > 0) {
      canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFFF7F5).withValues(alpha: fill));
    }
    for (final (fx, fy, k, ph) in _puffs) {
      final baseY = size.height * (1.25 - rise * 1.35 + fy * 1.1) - leave * size.height * (1.0 + ph * 0.8);
      final r = 90 * k * s * (1 + 0.4 * rise);
      final c = Offset(fx * size.width + math.sin(t * 6 + ph * 6) * 12 * s, baseY);
      final a = (1 - leave * 1.1).clamp(0.0, 1.0);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.25, -0.35),
            colors: [
              Colors.white.withValues(alpha: a),
              const Color(0xFFFFF0EC).withValues(alpha: a),
              const Color(0xFFFBD9D1).withValues(alpha: 0),
            ],
            stops: const [0, 0.6, 1],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_CloudWipePainter old) => old.t != t;
}
