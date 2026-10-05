import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/glyphs.dart';
import '../core/palette.dart';
import '../core/type.dart';
import '../widgets/surfaces.dart';

class FrostBand extends StatelessWidget {
  const FrostBand({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final steps = [(1.0, 2.0), (0.8, 4.0), (0.62, 8.0), (0.44, 14.0)];
    return IgnorePointer(
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            for (final (portion, sigma) in steps)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: height * portion,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Shade.ground.withValues(alpha: 0.92), Shade.ground.withValues(alpha: 0.6), Shade.ground.withValues(alpha: 0)],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key, required this.top, required this.onBack, required this.onCompose, this.title = 'Momo'});

  final double top;
  final VoidCallback onBack;
  final VoidCallback onCompose;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: top + 72,
      child: Stack(
        children: [
          Positioned.fill(child: FrostBand(height: top + 72)),
          Positioned(left: 39.7 - 22.25, top: top + 22 - 22.25, child: GlassCircle(icon: Ph.caretLeft, onTap: onBack)),
          Positioned(left: 362.3 - 22.25, top: top + 22 - 22.25, child: GlassCircle(icon: Ph.notePencil, onTap: onCompose)),
          Positioned(
            left: 100,
            right: 100,
            top: top + 29.3 - 17.5 * interAscent,
            child: Center(child: BaseText(title, style: Typo.title)),
          ),
        ],
      ),
    );
  }
}
