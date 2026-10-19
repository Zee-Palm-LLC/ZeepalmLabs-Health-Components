import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The mockup's coordinate system: a 402 pt wide phone whose screen is 784 pt tall
/// with a 44 pt status bar. Everything is laid out in these units, then the
/// [DesignCanvas] scales it to the real device.
///
/// Top content is pinned to the safe top ([y]), bottom content to the safe bottom
/// ([b]), so taller or shorter phones open or close the gap in the middle.
class Frame extends InheritedWidget {
  const Frame({super.key, required this.height, required this.top, required this.bottom, required this.scale, required super.child});

  static const width = 402.0;

  /// Shorter screens than this scale the whole design down instead of letting
  /// top and bottom content collide.
  static const shortest = 768.0;
  static const mockHeight = 784.0;
  static const mockTop = 44.0;
  static const mockBottom = 18.0;

  final double height;
  final double top;
  final double bottom;
  final double scale;

  /// How far top-pinned content moves down from its mock position.
  double get lift => top - mockTop;

  /// How far bottom-pinned content moves up from its mock position.
  double get drop => mockHeight - height + bottom - mockBottom;

  /// A top-pinned mock y.
  double y(double mockY) => mockY + lift;

  /// A bottom-pinned mock y.
  double b(double mockY) => mockY - drop;

  static Frame of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Frame>()!;

  /// For callbacks outside build.
  static Frame read(BuildContext context) => context.getInheritedWidgetOfExactType<Frame>()!;

  @override
  bool updateShouldNotify(Frame old) => old.height != height || old.top != top || old.bottom != bottom || old.scale != scale;
}

class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.child, this.backdrop = const Color(0xFF070A24)});

  final Widget child;
  final Color backdrop;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final view = media.viewPadding;
    final pad = media.padding;
    return LayoutBuilder(
      builder: (context, box) {
        final tall = box.maxHeight / box.maxWidth >= Frame.shortest / Frame.width;
        final scale = tall ? box.maxWidth / Frame.width : box.maxHeight / Frame.shortest;
        final height = tall ? box.maxHeight / scale : Frame.shortest;
        final top = math.max(math.max(view.top, pad.top) / scale, Frame.mockTop);
        final bottom = math.max(math.max(view.bottom, pad.bottom) / scale, Frame.mockBottom);
        return ColoredBox(
          color: backdrop,
          child: Center(
            child: SizedBox(
              width: Frame.width * scale,
              height: height * scale,
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.fill,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: Frame.width,
                    height: height,
                    child: MediaQuery(
                      data: media.copyWith(
                        textScaler: TextScaler.noScaling,
                        size: Size(Frame.width, height),
                        padding: EdgeInsets.only(top: top, bottom: bottom),
                        viewPadding: EdgeInsets.only(top: top, bottom: bottom),
                      ),
                      child: Frame(height: height, top: top, bottom: bottom, scale: scale, child: child),
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

/// A mockup plate (background art) pinned to the bottom of the screen at mock
/// scale, so art cut from the same screen lines up with it. Above the plate the
/// screen is filled with [sky] so tall phones never show an edge.
class Plate extends StatelessWidget {
  const Plate({super.key, required this.asset, required this.size, required this.sky, this.offsetY = 0, this.ground});

  final String asset;
  final Size size;
  final Color sky;
  final Color? ground;

  /// Mock y of the plate's top edge.
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    final f = Frame.of(context);
    final top = f.b(offsetY);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [sky, ground ?? sky]),
          ),
        ),
        Positioned(
          left: 0,
          top: top,
          width: size.width,
          height: size.height,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) =>
                LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: const [Color(0x00000000), Color(0xFF000000)], stops: [0, top > 0 ? 0.06 : 0.0]).createShader(r),
            child: Image.asset(asset, fit: BoxFit.fill, filterQuality: FilterQuality.medium, gaplessPlayback: true),
          ),
        ),
        // Below the plate (tall phones with a home indicator) the art continues as a reflection.
        Positioned(
          left: 0,
          top: top + size.height,
          width: size.width,
          height: size.height,
          child: Transform.flip(
            flipY: true,
            child: Image.asset(asset, fit: BoxFit.fill, filterQuality: FilterQuality.low, gaplessPlayback: true),
          ),
        ),
      ],
    );
  }
}
