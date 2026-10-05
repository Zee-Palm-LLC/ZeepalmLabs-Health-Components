import 'package:flutter/material.dart';

class Frame extends InheritedWidget {
  const Frame({
    super.key,
    required this.height,
    required this.top,
    required this.bottom,
    required this.keyboard,
    required this.scale,
    required super.child,
  });

  static const width = 402.0;
  static const shortest = 700.0;
  static const mockTop = 62.0;
  static const mockBottom = 34.0;
  static const mockHeight = 874.0;

  final double height;
  final double top;
  final double bottom;
  final double keyboard;
  final double scale;

  double get lift => top - mockTop;

  double get floor => keyboard > bottom ? keyboard + 10 : bottom;

  static Frame of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Frame>()!;

  @override
  bool updateShouldNotify(Frame old) =>
      old.height != height || old.top != top || old.bottom != bottom || old.keyboard != keyboard || old.scale != scale;
}

class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.child, this.backdrop = const Color(0xFFF3F3F0)});

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
        final top = (view.top > pad.top ? view.top : pad.top) / scale;
        final bottom = (view.bottom > pad.bottom ? view.bottom : pad.bottom) / scale;
        final keyboard = media.viewInsets.bottom / scale;
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
                        viewInsets: EdgeInsets.zero,
                      ),
                      child: Frame(
                        height: height,
                        top: top,
                        bottom: bottom,
                        keyboard: keyboard,
                        scale: scale,
                        child: child,
                      ),
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
