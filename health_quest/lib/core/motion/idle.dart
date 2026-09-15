import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Supplies free-running seconds to its builder, one value per frame.
///
/// Every screen here has something that breathes - a glow, a sheen, a shimmer
/// along a bar - and all of it is a function of elapsed time rather than of a
/// controller with a start and an end. This is that clock, in one place, so
/// each screen does not grow its own ticker and its own dispose.
class IdleBuilder extends StatefulWidget {
  const IdleBuilder({super.key, required this.builder, this.child});

  final Widget Function(BuildContext context, double seconds, Widget? child)
      builder;
  final Widget? child;

  @override
  State<IdleBuilder> createState() => _IdleBuilderState();
}

class _IdleBuilderState extends State<IdleBuilder>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _seconds = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration elapsed) {
      setState(() => _seconds = elapsed.inMicroseconds / 1e6);
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _seconds, widget.child);
}
