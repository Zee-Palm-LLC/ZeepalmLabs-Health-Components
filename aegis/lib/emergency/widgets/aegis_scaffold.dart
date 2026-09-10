import 'package:flutter/material.dart';

import '../../theme/aegis_theme.dart';
import 'aegis_app_bar.dart';

/// Shared page chrome: the frosted [AegisAppBar] over a scrolling column, with
/// a soft glow behind the content so the near-black background has depth.
///
/// The body runs behind the app bar, so the top inset is added here rather
/// than by a [SafeArea] the app bar would otherwise consume.
class AegisScaffold extends StatelessWidget {
  const AegisScaffold({
    super.key,
    required this.children,
    this.leading,
    this.actions,
    this.glow = AegisColors.amber,
    this.topGap = 12,
    this.gutter = 18,
  });

  final List<Widget> children;
  final Widget? leading;
  final List<Widget>? actions;

  /// Tint of the ambient wash behind the content.
  final Color glow;

  /// Space between the app bar and the first child.
  final double topGap;

  final double gutter;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AegisAppBar(leading: leading, actions: actions),
      body: Stack(
        children: [
          Positioned.fill(child: _AmbientWash(tint: glow)),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                gutter,
                insets.top + AegisAppBar.height + topGap,
                gutter,
                insets.bottom + 22,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientWash extends StatelessWidget {
  const _AmbientWash({required this.tint});

  final Color tint;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.55),
            radius: 1.1,
            colors: [
              tint.withValues(alpha: 0.07),
              tint.withValues(alpha: 0.02),
              AegisColors.background.withValues(alpha: 0),
            ],
            stops: const [0, 0.45, 1],
          ),
        ),
      ),
    );
  }
}
