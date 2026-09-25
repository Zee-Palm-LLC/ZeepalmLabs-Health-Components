import 'package:flutter/material.dart';

class Frame extends InheritedWidget {
  const Frame({
    super.key,
    required this.height,
    required this.top,
    required this.bottom,
    required this.scale,
    required super.child,
  });

  static const width = 393.0;
  static const reference = 852.0;
  static const mockTop = 50.0;

  final double height;
  final double top;
  final double bottom;
  final double scale;

  double get lift => top - mockTop;

  static Frame of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Frame>()!;

  @override
  bool updateShouldNotify(Frame old) =>
      old.height != height || old.top != top || old.bottom != bottom || old.scale != scale;
}

class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.child, this.backdrop = const Color(0xFF000410)});

  final Widget child;
  final Color backdrop;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final view = media.viewPadding;
    final pad = media.padding;
    return LayoutBuilder(
      builder: (context, box) {
        final tall = box.maxHeight / box.maxWidth >= Frame.reference / Frame.width;
        final scale = tall ? box.maxWidth / Frame.width : box.maxHeight / Frame.reference;
        final height = tall ? box.maxHeight / scale : Frame.reference;
        final top = (view.top > pad.top ? view.top : pad.top) / scale;
        final bottom = (view.bottom > pad.bottom ? view.bottom : pad.bottom) / scale;
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
