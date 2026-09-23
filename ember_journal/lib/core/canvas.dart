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
  static const referenceTop = 59.0;

  final double height;
  final double top;
  final double bottom;
  final double scale;

  double get floor => height - bottom;

  double get slack => height - reference;

  static CanvasScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CanvasScope>()!;

  @override
  bool updateShouldNotify(CanvasScope old) => old.height != height || old.top != top || old.bottom != bottom;
}

class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final view = media.viewPadding;
    final pad = media.padding;
    return LayoutBuilder(
      builder: (context, box) {
        final scale = box.maxWidth / CanvasScope.width;
        final height = box.maxHeight / scale;
        final top = (view.top > pad.top ? view.top : pad.top) / scale;
        final bottom = (view.bottom > pad.bottom ? view.bottom : pad.bottom) / scale;
        return CanvasScope(
          height: height,
          top: top < 24 ? 24 : top,
          bottom: bottom < 16 ? 16 : bottom,
          scale: scale,
          child: SizedBox(
            width: box.maxWidth,
            height: box.maxHeight,
            child: FittedBox(
              fit: BoxFit.fill,
              alignment: Alignment.topLeft,
              child: SizedBox(width: CanvasScope.width, height: height, child: child),
            ),
          ),
        );
      },
    );
  }
}
