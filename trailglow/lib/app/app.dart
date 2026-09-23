import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/map_controller.dart';
import '../widgets/trailglow_map.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'theme/motion.dart';
import 'theme/palette.dart';

class TrailglowApp extends StatelessWidget {
  const TrailglowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Trailglow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: Routes.preRun,
      getPages: AppPages.pages,
      initialBinding: BindingsBuilder(() {
        Get.put<MapController>(MapController(), permanent: true);
      }),
      builder: (context, child) => MapStage(child: child),
    );
  }
}

class MapStage extends StatelessWidget {
  const MapStage({super.key, required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(textScaler: const TextScaler.linear(1.0)),
      child: ColoredBox(
        color: Night.abyss,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const _MapLayer(),
            const _StageVignette(),
            if (child != null) AppEntrance(child: child!),
          ],
        ),
      ),
    );
  }
}

class _MapLayer extends StatelessWidget {
  const _MapLayer();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MapController>();
    return Obx(
      () => TrailglowMap(
        scene: controller.scene.value,
        initialCamera: controller.initialCamera,
      ),
    );
  }
}

class _StageVignette extends StatelessWidget {
  const _StageVignette();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Night.abyss.withValues(alpha: 0.86),
              Night.abyss.withValues(alpha: 0.12),
              Colors.transparent,
              Night.abyss.withValues(alpha: 0.30),
              Night.abyss.withValues(alpha: 0.88),
            ],
            stops: const <double>[0.0, 0.14, 0.42, 0.72, 1.0],
          ),
        ),
      ),
    );
  }
}

class AppEntrance extends StatefulWidget {
  const AppEntrance({super.key, required this.child});

  final Widget child;

  @override
  State<AppEntrance> createState() => _AppEntranceState();
}

class _AppEntranceState extends State<AppEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.reveal,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Motion.enter.transform(_controller.value);
        return Opacity(
          opacity: t,
          child: Transform.scale(scale: 0.985 + 0.015 * t, child: child),
        );
      },
    );
  }
}
