import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/app_colors.dart';
import '../../core/app_motion.dart';
import '../../core/app_text.dart';
import '../../widgets/animations.dart';
import '../../widgets/charts.dart';
import '../../widgets/status_badge.dart';

const _modelAsset = 'assets/images/human_body.glb';
const _posterAsset = 'assets/images/body_map.png';

String get modelSrc => kIsWeb ? 'assets/$_modelAsset' : _modelAsset;

class BodySystem {
  const BodySystem({
    required this.name,
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.unit,
    required this.decimals,
    required this.status,
    required this.marker,
    required this.orbit,
    required this.series,
  });

  final String name;
  final String label;
  final IconData icon;
  final Color color;
  final double value;
  final String unit;
  final int decimals;
  final String status;
  final Alignment marker;
  final ({double theta, double phi, double radius}) orbit;
  final List<double> series;
}

const kBodySystems = <BodySystem>[
  BodySystem(
    name: 'Heart',
    label: 'Resting heart rate',
    icon: Iconsax.heart,
    color: AppColors.rose,
    value: 82,
    unit: 'bpm',
    decimals: 0,
    status: 'Normal',
    marker: Alignment(0.06, -0.46),
    orbit: (theta: 0, phi: 82, radius: 1.35),
    series: [40, 52, 44, 66, 50, 72, 58, 80],
  ),
  BodySystem(
    name: 'Mind',
    label: 'Focus index',
    icon: Iconsax.cpu,
    color: AppColors.violet,
    value: 92,
    unit: '%',
    decimals: 0,
    status: 'Sharp',
    marker: Alignment(0.02, -0.86),
    orbit: (theta: 0, phi: 74, radius: 1.1),
    series: [55, 62, 58, 70, 66, 78, 84, 92],
  ),
  BodySystem(
    name: 'Lungs',
    label: 'Blood oxygen',
    icon: Iconsax.drop,
    color: AppColors.cyan,
    value: 98,
    unit: '%',
    decimals: 0,
    status: 'Normal',
    marker: Alignment(-0.14, -0.44),
    orbit: (theta: 0, phi: 84, radius: 1.35),
    series: [94, 96, 95, 97, 96, 98, 97, 98],
  ),
  BodySystem(
    name: 'Core',
    label: 'Energy reserve',
    icon: Iconsax.flash_1,
    color: AppColors.amber,
    value: 34,
    unit: '%',
    decimals: 0,
    status: 'Low',
    marker: Alignment(0.0, -0.14),
    orbit: (theta: 0, phi: 88, radius: 1.5),
    series: [70, 64, 58, 52, 48, 42, 38, 34],
  ),
  BodySystem(
    name: 'Mobility',
    label: 'Steps today',
    icon: Iconsax.activity,
    color: AppColors.green,
    value: 8240,
    unit: 'steps',
    decimals: 0,
    status: 'On track',
    marker: Alignment(-0.03, 0.56),
    orbit: (theta: 0, phi: 92, radius: 2.0),
    series: [20, 34, 30, 48, 44, 62, 70, 86],
  ),
];

class BodyScannerStage extends StatefulWidget {
  const BodyScannerStage({super.key, this.height = 356});

  final double height;

  @override
  State<BodyScannerStage> createState() => BodyScannerStageState();
}

class BodyScannerStageState extends State<BodyScannerStage> {
  Flutter3DController? _controller;

  int _selected = 0;
  bool _want3d = false;
  bool _viewerMounted = false;
  bool _stageVisible = true;
  bool _loaded = false;
  bool _failed = false;
  bool _freeLook = false;
  double _progress = 0;

  BodySystem get _system => kBodySystems[_selected];
  bool get _live3d => _viewerMounted && _loaded && !_failed;

  /// Called by [HomeScreen] when the scanner scrolls on/off screen.
  /// Unmounts the WebView off-screen so scrolling stays smooth.
  void setStageVisible(bool visible) {
    if (_stageVisible == visible) return;
    _stageVisible = visible;
    if (!mounted) return;

    if (!visible && _viewerMounted) {
      setState(_tearDownViewer);
    } else if (visible && _want3d && !_viewerMounted) {
      setState(_mountViewer);
    }
  }

  void _mountViewer() {
    _controller = Flutter3DController();
    _viewerMounted = true;
    _loaded = false;
    _failed = false;
    _freeLook = false;
    _progress = 0;
  }

  void _tearDownViewer() {
    _controller = null;
    _viewerMounted = false;
    _loaded = false;
    _failed = false;
    _freeLook = false;
    _progress = 0;
  }

  void _enable3d() {
    HapticFeedback.selectionClick();
    setState(() {
      _want3d = true;
      if (_stageVisible) _mountViewer();
    });
  }

  void _exit3d() {
    HapticFeedback.lightImpact();
    setState(() {
      _want3d = false;
      _tearDownViewer();
    });
  }

  void _select(int index, {bool haptic = true}) {
    if (haptic) HapticFeedback.selectionClick();
    final system = kBodySystems[index];
    setState(() {
      _selected = index;
      _freeLook = false;
    });
    final c = _controller;
    if (!_loaded || c == null) return;
    c.stopRotation();
    c.setCameraOrbit(
      system.orbit.theta,
      system.orbit.phi,
      system.orbit.radius,
    );
  }

  void _applyCamera() {
    final c = _controller;
    if (c == null || !_loaded) return;
    final system = kBodySystems[_selected];
    c.stopRotation();
    c.setCameraOrbit(
      system.orbit.theta,
      system.orbit.phi,
      system.orbit.radius,
    );
  }

  void _recenter() {
    HapticFeedback.lightImpact();
    final c = _controller;
    if (c == null) return;
    setState(() => _freeLook = false);
    c.resetCameraOrbit();
    c.resetCameraTarget();
    _select(_selected, haptic: false);
  }

  void _onManualLook() {
    if (_freeLook || !_loaded) return;
    _controller?.stopRotation();
    setState(() => _freeLook = true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height.h,
          child: RepaintBoundary(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ScannerAura(color: _system.color),
                Positioned.fill(
                  child: _viewerMounted
                      ? _LiveModelLayer(
                          controller: _controller!,
                          onManualLook: _onManualLook,
                          onProgress: (value) {
                            if (!mounted || _loaded) return;
                            if ((value - _progress).abs() < 0.05) return;
                            setState(() => _progress = value);
                          },
                          onLoad: () {
                            if (!mounted) return;
                            setState(() => _loaded = true);
                            // No auto-rotate — continuous spin keeps the WebView GPU hot.
                            _applyCamera();
                          },
                          onError: () {
                            if (!mounted) return;
                            setState(() => _failed = true);
                          },
                        )
                      : const _StaticBodyPoster(),
                ),
                if ((_live3d || !_want3d) && !_failed)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: _live3d && _freeLook,
                      child: AnimatedOpacity(
                        opacity: _live3d && _freeLook ? 0 : 1,
                        duration: AppMotion.medium,
                        child: Stack(
                          children: [
                            for (var i = 0; i < kBodySystems.length; i++)
                              Align(
                                alignment: kBodySystems[i].marker,
                                child: ScaleIn(
                                  delay: AppMotion.stagger(
                                    i,
                                    step: 90,
                                    from: 200,
                                  ),
                                  child: BodyHotspot(
                                    system: kBodySystems[i],
                                    active: i == _selected,
                                    onTap: () => _select(i),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  child: _StageHeader(
                    mode: !_want3d
                        ? _StageMode.preview
                        : _loaded
                            ? _StageMode.live
                            : _failed
                                ? _StageMode.preview
                                : _StageMode.loading,
                    onExit3d: _want3d ? _exit3d : null,
                  ),
                ),
                if (_viewerMounted && !_loaded && !_failed)
                  ScannerLoader(progress: _progress, color: _system.color),
                if (_failed) const ScannerFallback(),
                if (!_want3d)
                  Positioned(
                    bottom: 8.h,
                    child: _Enable3dPill(onTap: _enable3d),
                  )
                else
                  Positioned(
                    bottom: 0,
                    child: AnimatedSwitcher(
                      duration: AppMotion.medium,
                      child: _freeLook
                          ? RecenterPill(
                              key: const ValueKey(true),
                              onTap: _recenter,
                            )
                          : DragHint(
                              key: const ValueKey(false),
                              visible: _loaded,
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 14.h),
        SystemRail(
          selected: _selected,
          onSelected: _select,
        ),
        SizedBox(height: 16.h),
        SystemReadout(system: _system),
      ],
    );
  }
}

enum _StageMode { preview, loading, live }

class _StageHeader extends StatelessWidget {
  const _StageHeader({required this.mode, this.onExit3d});

  final _StageMode mode;
  final VoidCallback? onExit3d;

  @override
  Widget build(BuildContext context) {
    final live = mode == _StageMode.live;
    final loading = mode == _StageMode.loading;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FULL BODY SCAN', style: AppText.overline()),
            SizedBox(height: 3.h),
            Text(
              live ? 'Interactive 3D' : 'Body map',
              style: AppText.h3(),
            ),
          ],
        ),
        const Spacer(),
        if (onExit3d != null && (live || loading)) ...[
          GestureDetector(
            onTap: onExit3d,
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.r),
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: AppColors.strokeSoft),
              ),
              child: Text(
                'Exit 3D',
                style: GoogleFonts.poppins(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
        StatusBadge(
          label: live
              ? '3D'
              : loading
                  ? 'Loading'
                  : 'Ready',
          color: live
              ? AppColors.green
              : loading
                  ? AppColors.textTertiary
                  : AppColors.cyan,
          showDot: true,
          pulse: false,
        ),
      ],
    );
  }
}

class _StaticBodyPoster extends StatelessWidget {
  const _StaticBodyPoster();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Image.asset(
        _posterAsset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
      ),
    );
  }
}

class _LiveModelLayer extends StatelessWidget {
  const _LiveModelLayer({
    required this.controller,
    required this.onManualLook,
    required this.onProgress,
    required this.onLoad,
    required this.onError,
  });

  final Flutter3DController controller;
  final VoidCallback onManualLook;
  final ValueChanged<double> onProgress;
  final VoidCallback onLoad;
  final VoidCallback onError;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onManualLook(),
      onPointerSignal: (_) => onManualLook(),
      child: Flutter3DViewer(
        src: modelSrc,
        controller: controller,
        progressBarColor: Colors.transparent,
        onProgress: onProgress,
        onLoad: (_) => onLoad(),
        onError: (_) => onError(),
      ),
    );
  }
}

class _Enable3dPill extends StatelessWidget {
  const _Enable3dPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          gradient: LinearGradient(
            colors: [
              AppColors.indigo.withValues(alpha: 0.9),
              AppColors.violet.withValues(alpha: 0.85),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: AppColors.indigo.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.box_1, size: 13.sp, color: Colors.white),
            SizedBox(width: 7.w),
            Text(
              'Explore in 3D',
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerAura extends StatelessWidget {
  const ScannerAura({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    // Static aura — animated ticks were a major continuous GPU cost under the 3D view.
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _AuraPainter(turn: 0.12, color: color),
      ),
    );
  }
}

class _AuraPainter extends CustomPainter {
  _AuraPainter({required this.turn, required this.color});

  final double turn;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.54);
    final radius = size.width * 0.46;

    canvas.drawCircle(
      center,
      radius * 1.7,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.22),
            AppColors.indigo.withValues(alpha: 0.10),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(
          Rect.fromCircle(center: center, radius: radius * 1.7),
        ),
    );

    final plate = Rect.fromCenter(
      center: Offset(center.dx, size.height * 0.93),
      width: size.width * 0.62,
      height: size.height * 0.10,
    );
    canvas.drawOval(
      plate,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.30),
            Colors.transparent,
          ],
        ).createShader(plate),
    );

    for (final ring in const [1.0, 0.78]) {
      final rect = Rect.fromCenter(
        center: center,
        width: radius * 2 * ring,
        height: radius * 0.62 * ring,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: 0.06),
      );
    }

    const ticks = 24;
    for (var i = 0; i < ticks; i++) {
      final angle = (i / ticks) * 2 * math.pi + turn * 2 * math.pi;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius * 0.31,
      );
      final major = i % 3 == 0;
      canvas.drawCircle(
        point,
        major ? 1.4 : 0.7,
        Paint()..color = color.withValues(alpha: major ? 0.28 : 0.12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuraPainter old) =>
      old.turn != turn || old.color != color;
}

class BodyHotspot extends StatefulWidget {
  const BodyHotspot({
    super.key,
    required this.system,
    required this.active,
    required this.onTap,
  });

  final BodySystem system;
  final bool active;
  final VoidCallback onTap;

  @override
  State<BodyHotspot> createState() => _BodyHotspotState();
}

class _BodyHotspotState extends State<BodyHotspot>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  @override
  void initState() {
    super.initState();
    if (widget.active) _startPulse();
  }

  @override
  void didUpdateWidget(covariant BodyHotspot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _startPulse();
    } else if (!widget.active && oldWidget.active) {
      _pulse?.stop();
      _pulse?.dispose();
      _pulse = null;
    }
  }

  void _startPulse() {
    _pulse?.dispose();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.system.color;
    final pulse = _pulse;

    return PressableScale(
      onTap: widget.onTap,
      scale: 0.88,
      child: SizedBox(
        width: 44.w,
        height: 44.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.active && pulse != null)
              AnimatedBuilder(
                animation: pulse,
                builder: (_, _) {
                  final t = pulse.value;
                  return Container(
                    width: 16.w + 28.w * t,
                    height: 16.w + 28.w * t,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.55 * (1 - t)),
                        width: 1.4,
                      ),
                    ),
                  );
                },
              ),
            AnimatedContainer(
              duration: AppMotion.medium,
              curve: AppMotion.emphasized,
              width: widget.active ? 20.w : 13.w,
              height: widget.active ? 20.w : 13.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.active
                    ? color
                    : color.withValues(alpha: 0.28),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: widget.active ? 0.85 : 0.35,
                  ),
                  width: 1.4,
                ),
                boxShadow: widget.active
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.55),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: widget.active
                  ? Icon(widget.system.icon, size: 9.sp, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class SystemRail extends StatelessWidget {
  const SystemRail({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: kBodySystems.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final system = kBodySystems[i];
          final active = i == selected;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: AppMotion.medium,
              curve: AppMotion.emphasized,
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.r),
                gradient: active
                    ? LinearGradient(
                        colors: [
                          system.color.withValues(alpha: 0.28),
                          system.color.withValues(alpha: 0.10),
                        ],
                      )
                    : null,
                color: active ? null : Colors.white.withValues(alpha: 0.04),
                border: Border.all(
                  color: active
                      ? system.color.withValues(alpha: 0.5)
                      : AppColors.strokeSoft,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    system.icon,
                    size: 13.sp,
                    color: active ? system.color : AppColors.textTertiary,
                  ),
                  SizedBox(width: 7.w),
                  AnimatedDefaultTextStyle(
                    duration: AppMotion.fast,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? system.color : AppColors.textTertiary,
                    ),
                    child: Text(system.name),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SystemReadout extends StatelessWidget {
  const SystemReadout({super.key, required this.system});

  final BodySystem system;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: AppMotion.enter,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.18),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Row(
        key: ValueKey(system.name),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 3.w,
            height: 42.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.r),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  system.color,
                  system.color.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(system.label.toUpperCase(), style: AppText.overline()),
                SizedBox(height: 4.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AnimatedCountText(
                      value: system.value,
                      decimals: system.decimals,
                      style: AppText.metric().copyWith(fontSize: 26.sp),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      system.unit,
                      style: AppText.caption().copyWith(fontSize: 10.sp),
                    ),
                    SizedBox(width: 9.w),
                    StatusBadge(label: system.status, color: system.color),
                  ],
                ),
              ],
            ),
          ),
          Sparkline(
            values: system.series,
            color: system.color,
            size: Size(86.w, 38.h),
          ),
        ],
      ),
    );
  }
}

class ScannerLoader extends StatelessWidget {
  const ScannerLoader({
    super.key,
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RingProgress(
          progress: progress.clamp(0.0, 1.0),
          color: color,
          size: 62,
          child: Text(
            '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
            style: AppText.h3().copyWith(fontSize: 11.sp),
          ),
        ),
        SizedBox(height: 14.h),
        Text('Rendering body model', style: AppText.caption()),
      ],
    );
  }
}

class ScannerFallback extends StatelessWidget {
  const ScannerFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Iconsax.close_circle,
          size: 26.sp,
          color: AppColors.textTertiary,
        ),
        SizedBox(height: 10.h),
        Text('Model could not be loaded', style: AppText.caption()),
      ],
    );
  }
}

class DragHint extends StatelessWidget {
  const DragHint({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: AppMotion.slow,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.rotate_left,
            size: 11.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(width: 6.w),
          Text('Drag to rotate', style: AppText.overline()),
        ],
      ),
    );
  }
}

class RecenterPill extends StatelessWidget {
  const RecenterPill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          color: Colors.white.withValues(alpha: 0.07),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.refresh_2, size: 12.sp, color: Colors.white),
            SizedBox(width: 7.w),
            Text(
              'Recenter',
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
