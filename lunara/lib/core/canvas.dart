import 'dart:math' as math;

import 'package:flutter/material.dart';

const canvasKey = Key('lunara-canvas');

class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.child, this.background, this.backdrop});

  static const width = 393.0;
  static const height = 852.0;
  static const statusAllowance = 52.0;
  static const navHeight = 62.0;
  static const navGap = 30.0;
  static const breathing = 12.0;
  static const contentFloor = 822.0;

  final Widget child;
  final Widget? background;
  final Widget? backdrop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final media = MediaQuery.of(context);
        final insets = EdgeInsets.fromLTRB(
          math.max(media.viewPadding.left, media.padding.left),
          math.max(media.viewPadding.top, media.padding.top),
          math.max(media.viewPadding.right, media.padding.right),
          math.max(media.viewPadding.bottom, media.padding.bottom),
        );
        final w = box.maxWidth;
        final h = box.maxHeight;

        var scale = w / width;
        var canvasHeight = height;
        for (var i = 0; i < 3; i++) {
          final shiftTop = math.max(0.0, insets.top / scale - statusAllowance);
          final bottom = math.max(insets.bottom / scale, breathing);
          final needed = contentFloor + navGap + bottom;
          canvasHeight = math.max(height, needed) + shiftTop;
          scale = math.min(w / width, h / canvasHeight);
        }
        final shiftTop = math.max(0.0, insets.top / scale - statusAllowance);
        canvasHeight = h / scale - shiftTop;

        final scope = CanvasScope(
          height: canvasHeight,
          bottomInset: insets.bottom / scale,
          bleed: (w / scale - width) / 2,
          child: MediaQuery(
            data: media.copyWith(padding: EdgeInsets.zero, textScaler: TextScaler.noScaling),
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                if (background != null) Positioned.fill(child: background!),
                child,
              ],
            ),
          ),
        );

        return ClipRect(
          child: FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(
              width: w / scale,
              height: h / scale,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (backdrop != null) Positioned.fill(child: backdrop!),
                  Padding(
                    padding: EdgeInsets.only(top: shiftTop),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(key: canvasKey, width: width, height: canvasHeight, child: scope),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CanvasScope extends InheritedWidget {
  const CanvasScope({
    super.key,
    required this.height,
    required this.bottomInset,
    required this.bleed,
    required super.child,
  });

  final double height;
  final double bottomInset;
  final double bleed;

  double get lift => math.max(bottomInset, DesignCanvas.breathing);

  double get navTop => height - DesignCanvas.navHeight - lift;

  double pin(double designGap) {
    final gap = math.max(designGap, bottomInset + DesignCanvas.breathing);
    return (height - DesignCanvas.height) - (gap - designGap);
  }

  static CanvasScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CanvasScope>();
    assert(scope != null, 'CanvasScope missing');
    return scope!;
  }

  @override
  bool updateShouldNotify(CanvasScope oldWidget) {
    return oldWidget.height != height || oldWidget.bottomInset != bottomInset || oldWidget.bleed != bleed;
  }
}
