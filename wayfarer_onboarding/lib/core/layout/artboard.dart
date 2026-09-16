import 'package:flutter/widgets.dart';

/// Lays children out in the 375x812 design frame and scales it uniformly to the
/// screen, so every coordinate measured from the design maps 1:1.
class Artboard extends StatelessWidget {
  const Artboard({super.key, required this.child});

  static const Size size = Size(375, 812);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: SizedBox.expand(
        child: FittedBox(
          child: SizedBox.fromSize(size: size, child: child),
        ),
      ),
    );
  }
}
