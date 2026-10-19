import 'package:flutter/material.dart';

class Frame extends InheritedWidget {
  const Frame({super.key, required this.extraX, required this.extraY, required this.scale, required super.child});

  static const width = 402.0;
  static const height = 874.0;

  final double extraX;
  final double extraY;
  final double scale;

  static Frame of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Frame>()!;

  static Frame? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Frame>();

  @override
  bool updateShouldNotify(Frame old) => old.extraX != extraX || old.extraY != extraY || old.scale != scale;
}

class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.child, this.backdrop = const Color(0xFF1B1950)});

  final Widget child;
  final Color backdrop;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final scale = (box.maxWidth / Frame.width) < (box.maxHeight / Frame.height) ? box.maxWidth / Frame.width : box.maxHeight / Frame.height;
        final w = box.maxWidth / scale;
        final h = box.maxHeight / scale;
        final extraX = (w - Frame.width) / 2;
        final extraY = (h - Frame.height) / 2;
        return ColoredBox(
          color: backdrop,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.center,
              minWidth: 0,
              minHeight: 0,
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: SizedBox(
                width: Frame.width * scale,
                height: Frame.height * scale,
                child: FittedBox(
                  fit: BoxFit.fill,
                  alignment: Alignment.topLeft,
                  clipBehavior: Clip.none,
                  child: SizedBox(
                    width: Frame.width,
                    height: Frame.height,
                    child: MediaQuery(
                      data: media.copyWith(
                        textScaler: TextScaler.noScaling,
                        size: const Size(Frame.width, Frame.height),
                        padding: const EdgeInsets.only(top: 62, bottom: 34),
                        viewPadding: const EdgeInsets.only(top: 62, bottom: 34),
                      ),
                      child: Frame(extraX: extraX, extraY: extraY, scale: scale, child: child),
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
