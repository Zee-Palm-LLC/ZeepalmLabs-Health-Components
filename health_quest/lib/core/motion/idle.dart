import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

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
