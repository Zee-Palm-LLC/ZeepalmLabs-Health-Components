import 'package:flutter/material.dart';

class CanvasScope extends InheritedWidget {
  const CanvasScope({
    super.key,
    required this.height,
    required this.top,
    required this.bottom,
    required this.scale,
    required super.child,
  });

  static const width = 393.0;
  static const reference = 852.0;

  final double height;
  final double top;
  final double bottom;
  final double scale;

  double get slack => height - reference;

  double get depth => height / reference;

  static CanvasScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CanvasScope>()!;

  @override
  bool updateShouldNotify(CanvasScope old) => old.height != height || old.top != top || old.bottom != bottom;
}

class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.child, this.backdrop = const Color(0xFF020C30)});

  final Widget child;
  final Color backdrop;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final view = media.viewPadding;
    final pad = media.padding;
    return LayoutBuilder(
      builder: (context, box) {
        final tall = box.maxHeight / box.maxWidth >= CanvasScope.reference / CanvasScope.width;
        final scale = tall ? box.maxWidth / CanvasScope.width : box.maxHeight / CanvasScope.reference;
        final height = tall ? box.maxHeight / scale : CanvasScope.reference;
        final top = (view.top > pad.top ? view.top : pad.top) / scale;
        final bottom = (view.bottom > pad.bottom ? view.bottom : pad.bottom) / scale;
        return ColoredBox(
          color: backdrop,
          child: Center(
            child: SizedBox(
              width: CanvasScope.width * scale,
              height: height * scale,
              child: CanvasScope(
                height: height,
                top: top,
                bottom: bottom,
                scale: scale,
                child: FittedBox(
                  fit: BoxFit.fill,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: CanvasScope.width,
                    height: height,
                    child: MediaQuery(
                      data: media.copyWith(textScaler: TextScaler.noScaling),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SceneLayer extends StatelessWidget {
  const SceneLayer({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scope = CanvasScope.of(context);
    final k = scope.depth;
    return Positioned(
      left: CanvasScope.width * (1 - k) / 2,
      top: 0,
      width: CanvasScope.width * k,
      height: scope.height,
      child: FittedBox(
        fit: BoxFit.fill,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: CanvasScope.width,
          height: CanvasScope.reference,
          child: Stack(clipBehavior: Clip.none, children: children),
        ),
      ),
    );
  }
}

class Floor extends StatelessWidget {
  const Floor({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scope = CanvasScope.of(context);
    return Positioned(
      left: 0,
      top: scope.slack,
      width: CanvasScope.width,
      height: CanvasScope.reference,
      child: Stack(clipBehavior: Clip.none, children: children),
    );
  }
}
