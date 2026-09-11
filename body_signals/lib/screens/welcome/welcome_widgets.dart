import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/app_colors.dart';
import '../../core/app_motion.dart';
import '../../core/app_text.dart';
import '../../widgets/animations.dart';
import '../../widgets/pulse_mark.dart';

class KenBurns extends StatefulWidget {
  const KenBurns({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 26),
    this.maxScale = 1.14,
  });

  final Widget child;
  final Duration duration;
  final double maxScale;

  @override
  State<KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends State<KenBurns>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );

    return ScaleTransition(
      scale: Tween(begin: 1.0, end: widget.maxScale).animate(curved),
      child: SlideTransition(
        position: Tween(
          begin: Offset.zero,
          end: const Offset(0, -0.03),
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}

class Wordmark extends StatelessWidget {
  const Wordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PulseMark(width: 24.w),
            SizedBox(width: 9.w),
            Text(
              'BodySignals',
              style: GoogleFonts.poppins(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          'Your health, in real time.',
          style: AppText.caption().copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class Headline extends StatelessWidget {
  const Headline({super.key});

  static const _lines = ['Your body', 'speaks.', 'We just help'];

  @override
  Widget build(BuildContext context) {
    final style = AppText.display();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _lines.length; i++)
          FadeSlideIn(
            delay: AppMotion.stagger(i, step: 90, from: 160),
            offset: const Offset(-0.05, 0.3),
            child: Text(_lines[i], style: style),
          ),
        FadeSlideIn(
          delay: AppMotion.stagger(3, step: 90, from: 160),
          offset: const Offset(-0.05, 0.3),
          child: RichText(
            text: TextSpan(
              style: style,
              children: [
                const TextSpan(text: 'you '),
                TextSpan(
                  text: 'listen.',
                  style: TextStyle(
                    color: AppColors.cyan,
                    shadows: [
                      Shadow(
                        color: AppColors.cyan.withValues(alpha: 0.55),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FeatureOrbData {
  const FeatureOrbData(this.icon, this.label, this.color, this.dx, this.dy);

  final IconData icon;
  final String label;
  final Color color;
  final double dx;
  final double dy;
}

class FeatureConstellation extends StatefulWidget {
  const FeatureConstellation({super.key});

  static const _orbs = <FeatureOrbData>[
    FeatureOrbData(Iconsax.moon, 'Sleep', AppColors.indigo, 0.04, 0),
    FeatureOrbData(Iconsax.cpu, 'Mind', AppColors.violet, 0.96, 0),
    FeatureOrbData(Iconsax.activity, 'Activity', AppColors.green, -0.02, 84),
    FeatureOrbData(Iconsax.reserve, 'Nutrition', AppColors.cyan, 1.02, 84),
    FeatureOrbData(Iconsax.heart, 'Heart', AppColors.rose, 0.04, 168),
    FeatureOrbData(Iconsax.tree, 'Recovery', AppColors.amber, 0.96, 168),
  ];

  @override
  State<FeatureConstellation> createState() => _FeatureConstellationState();
}

class _FeatureConstellationState extends State<FeatureConstellation>
    with SingleTickerProviderStateMixin {
  static const _count = 6;
  static const _stiffness = 190.0;
  static const _damping = 16.0;

  late final List<Offset> _offset =
      List<Offset>.generate(_count, (_) => Offset.zero);
  late final List<Offset> _velocity =
      List<Offset>.generate(_count, (_) => Offset.zero);

  List<Offset> _homes = List<Offset>.generate(_count, (_) => Offset.zero);
  double _orbWidth = 70;
  double _collisionRadius = 30;

  int? _dragging;
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  void _ensureTicker() {
    _ticker ??= createTicker(_onTick);
    if (!(_ticker?.isActive ?? false)) {
      _lastTick = Duration.zero;
      _ticker!.start();
    }
  }

  void _onTick(Duration elapsed) {
    var dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0) return;
    dt = dt.clamp(0.0, 1 / 30);

    _integrateSprings(dt);
    _resolveCollisions();

    if (mounted) setState(() {});

    if (_isSleeping()) {
      _ticker?.stop();
      _lastTick = Duration.zero;
    }
  }

  bool _isSleeping() {
    if (_dragging != null) return false;
    for (var i = 0; i < _count; i++) {
      if (_offset[i].distance > 0.6 || _velocity[i].distance > 4) {
        return false;
      }
    }
    return true;
  }

  void _integrateSprings(double dt) {
    for (var i = 0; i < _count; i++) {
      if (i == _dragging) {
        _velocity[i] = Offset.zero;
        continue;
      }

      // Soft spring home: a = -k x - c v
      final force =
          _offset[i] * -_stiffness - _velocity[i] * _damping;
      _velocity[i] += force * dt;
      _offset[i] += _velocity[i] * dt;

      if (_offset[i].distance < 0.5 && _velocity[i].distance < 6) {
        _offset[i] = Offset.zero;
        _velocity[i] = Offset.zero;
      }
    }
  }

  void _resolveCollisions() {
    final minDist = _collisionRadius * 2;
    // Circle center inside the orb column widget.
    final centerLocal = Offset(_orbWidth / 2, FeatureOrb.size / 2 + 2);

    for (var iter = 0; iter < 5; iter++) {
      for (var a = 0; a < _count; a++) {
        for (var b = a + 1; b < _count; b++) {
          final pa = _homes[a] + _offset[a] + centerLocal;
          final pb = _homes[b] + _offset[b] + centerLocal;
          var delta = pb - pa;
          var dist = delta.distance;

          if (dist < 1e-4) {
            delta = Offset(0.8 * (a + 1), -0.8 * (b + 1));
            dist = delta.distance;
          }
          if (dist >= minDist) continue;

          final normal = delta / dist;
          final overlap = minDist - dist;

          if (a == _dragging) {
            _offset[b] += normal * overlap;
            _velocity[b] += normal * (overlap * 10);
          } else if (b == _dragging) {
            _offset[a] -= normal * overlap;
            _velocity[a] -= normal * (overlap * 10);
          } else {
            final half = normal * (overlap * 0.5);
            _offset[a] -= half;
            _offset[b] += half;
            _velocity[a] -= half * 4;
            _velocity[b] += half * 4;
          }
        }
      }
    }
  }

  void _onDragStart(int i) {
    _dragging = i;
    _velocity[i] = Offset.zero;
    HapticFeedback.selectionClick();
    _ensureTicker();
    setState(() {});
  }

  void _onDragUpdate(int i, Offset delta) {
    _offset[i] += delta;
    _velocity[i] = Offset.zero;
    _resolveCollisions();
    _ensureTicker();
    setState(() {});
  }

  void _onDragEnd(int i, Velocity velocity) {
    // Seed spring with release flick so bounce feels physical.
    _velocity[i] = velocity.pixelsPerSecond * 0.35;
    _dragging = null;
    HapticFeedback.lightImpact();
    _ensureTicker();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 252.h,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _orbWidth = 70.w;
          _collisionRadius = FeatureOrb.size * 0.58;
          final travel = constraints.maxWidth - _orbWidth;

          _homes = [
            for (final orb in FeatureConstellation._orbs)
              Offset(orb.dx * travel, orb.dy.h),
          ];

          final order = List<int>.generate(_count, (i) => i);
          if (_dragging != null) {
            order
              ..remove(_dragging)
              ..add(_dragging!);
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (final i in order)
                Positioned(
                  key: ValueKey('orb-seat-$i'),
                  left: _homes[i].dx + _offset[i].dx,
                  top: _homes[i].dy + _offset[i].dy,
                  child: ScaleIn(
                    delay: AppMotion.stagger(i, step: 95, from: 620),
                    child: SizedBox(
                      width: _orbWidth,
                      child: PlayableOrb(
                        key: ValueKey('orb-$i'),
                        data: FeatureConstellation._orbs[i],
                        dragging: _dragging == i,
                        onDragStart: () => _onDragStart(i),
                        onDragUpdate: (d) => _onDragUpdate(i, d),
                        onDragEnd: (v) => _onDragEnd(i, v),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class PlayableOrb extends StatelessWidget {
  const PlayableOrb({
    super.key,
    required this.data,
    required this.dragging,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final FeatureOrbData data;
  final bool dragging;
  final VoidCallback onDragStart;
  final ValueChanged<Offset> onDragUpdate;
  final ValueChanged<Velocity> onDragEnd;

  @override
  Widget build(BuildContext context) {
    final orb = FeatureOrb(data: data, lifted: dragging);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) => onDragStart(),
      onPanUpdate: (d) => onDragUpdate(d.delta),
      onPanEnd: (d) => onDragEnd(d.velocity),
      onPanCancel: () => onDragEnd(Velocity.zero),
      child: AnimatedScale(
        scale: dragging ? 1.1 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.enter,
        child: orb,
      ),
    );
  }
}

class FeatureOrb extends StatelessWidget {
  const FeatureOrb({super.key, required this.data, this.lifted = false});

  final FeatureOrbData data;
  final bool lifted;

  static double get size => 50.w;
  static double get _size => size;

  @override
  Widget build(BuildContext context) {
    final accent = data.color;
    final size = _size;
    final lit = Color.lerp(accent, Colors.white, 0.18)!;
    final mid = accent;
    final shade = Color.lerp(accent, const Color(0xFF0A0E16), 0.42)!;
    final deep = Color.lerp(accent, const Color(0xFF05070C), 0.62)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size + 8.w,
          height: size + 8.w,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: lifted ? -2 : 1,
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  width: size * (lifted ? 0.86 : 0.72),
                  height: size * (lifted ? 0.2 : 0.16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.r),
                    color: Colors.black.withValues(alpha: lifted ? 0.28 : 0.35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: lifted ? 0.35 : 0.45),
                        blurRadius: lifted ? 16 : 10,
                        spreadRadius: lifted ? 2 : 1,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [lit, mid, shade, deep],
                    stops: const [0.0, 0.38, 0.78, 1.0],
                  ),
                  border: Border.all(
                    width: 2,
                    color: Color.lerp(accent, const Color(0xFF1A2230), 0.35)!,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: lifted ? 16 : 10,
                      offset: Offset(0, lifted ? 10 : 6),
                    ),
                    BoxShadow(
                      color: accent.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: FractionallySizedBox(
                        heightFactor: 0.48,
                        widthFactor: 0.92,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(size),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                lit.withValues(alpha: 0.55),
                                lit.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: 0.42,
                        widthFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(size),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.38),
                                Colors.black.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(2.5.w),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.22),
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        data.icon,
                        size: 20.sp,
                        color: Colors.white.withValues(alpha: 0.96),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 0,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          data.label,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: Colors.white.withValues(alpha: 0.95),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
