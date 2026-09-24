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
  static const referenceFloor = 818.0;

  final double height;
  final double top;
  final double bottom;
  final double scale;

  double get floor => height - bottom;

  double get lift => top - referenceTop;

  double get drop => floor - referenceFloor;

  double fromTop(double y) => y + lift;

  double fromFloor(double y) => y + drop;

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
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.noScaling),
          child: CanvasScope(
            height: height,
            top: top < 24 ? 24 : top,
            bottom: bottom < 12 ? 12 : bottom,
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
          ),
        );
      },
    );
  }
}

class Plate extends StatelessWidget {
  const Plate({super.key, required this.child, this.alignment = Alignment.bottomCenter});

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        alignment: alignment,
        child: SizedBox(width: CanvasScope.width, height: CanvasScope.reference, child: child),
      ),
    );
  }
}
