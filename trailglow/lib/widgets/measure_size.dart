import 'package:flutter/material.dart';

class MeasureSize extends StatefulWidget {
  const MeasureSize({super.key, required this.child, required this.onChange});

  final Widget child;
  final ValueChanged<Size> onChange;

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  final GlobalKey _key = GlobalKey();
  Size _last = Size.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_report);
  }

  void _report(Duration _) {
    if (!mounted) return;
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    if (box.size != _last) {
      _last = box.size;
      widget.onChange(box.size);
    }
    WidgetsBinding.instance.addPostFrameCallback(_report);
  }

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _key, child: widget.child);
}
