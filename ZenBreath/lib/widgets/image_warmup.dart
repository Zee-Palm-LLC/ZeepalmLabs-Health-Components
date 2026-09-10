import 'package:flutter/material.dart';

class ImageWarmup extends StatefulWidget {
  const ImageWarmup({super.key, required this.sources, required this.child});
  final List<String> sources;
  final Widget child;

  @override
  State<ImageWarmup> createState() => _ImageWarmupState();
}

class _ImageWarmupState extends State<ImageWarmup> {
  bool _warmed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_warmed) return;
    _warmed = true;

    for (final source in widget.sources) {
      final provider = source.startsWith('http')
          ? NetworkImage(source) as ImageProvider
          : AssetImage(source);

      precacheImage(provider, context, onError: (_, _) {});
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
