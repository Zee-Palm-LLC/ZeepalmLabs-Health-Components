import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class Model3D extends StatefulWidget {
  const Model3D({
    super.key,
    required this.src,
    required this.fallback,
    this.interactive = true,
    this.onReady,
    this.keepFallback = false,
    this.viewport,
  });

  static bool enabled = true;

  final String src;
  final Widget fallback;
  final bool interactive;
  final bool keepFallback;
  final Rect? viewport;
  final void Function(Flutter3DController controller)? onReady;

  @override
  State<Model3D> createState() => Model3DState();
}

class Model3DState extends State<Model3D> {
  Widget _place(Widget child) {
    final v = widget.viewport;
    if (v == null) return Positioned.fill(child: child);
    return Positioned.fromRect(rect: v, child: child);
  }

  final controller = Flutter3DController();
  bool _ready = false;

  bool get ready => _ready;

  void _loaded(String _) {
    if (!mounted) return;
    widget.onReady?.call(controller);
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!Model3D.enabled) return widget.fallback;
    final viewer = Flutter3DViewer(
      src: widget.src,
      controller: controller,
      enableTouch: widget.interactive,
      activeGestureInterceptor: widget.interactive,
      progressBarColor: Colors.transparent,
      onLoad: _loaded,
      onError: (_) {},
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!_ready || widget.keepFallback)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 450),
            opacity: _ready ? 0 : 1,
            child: widget.fallback,
          ),
        _place(
          AnimatedOpacity(
            duration: const Duration(milliseconds: 450),
            opacity: _ready ? 1 : 0,
            child: widget.interactive ? viewer : IgnorePointer(child: viewer),
          ),
        ),
      ],
    );
  }
}
