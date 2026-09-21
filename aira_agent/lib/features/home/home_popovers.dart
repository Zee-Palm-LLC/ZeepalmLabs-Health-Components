import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../scene/frame.dart';

enum Popover { alerts, history, model }

class PopoverLayer extends StatelessWidget {
  const PopoverLayer({
    super.key,
    required this.which,
    required this.frame,
    required this.model,
    required this.onModel,
    required this.onHistory,
    required this.dockLift,
  });

  final Popover? which;
  final Frame frame;
  final String model;
  final ValueChanged<String> onModel;
  final VoidCallback onHistory;
  final double dockLift;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: which == null,
        child: Stack(
          children: [
            _slot(
              Popover.alerts,
              Positioned(right: 16, top: frame.headerY + 30, child: const _Alerts()),
              Alignment.topRight,
            ),
            _slot(
              Popover.history,
              Positioned(right: 16, top: frame.headerY + 30, child: _History(onOpen: onHistory)),
              Alignment.topRight,
            ),
            _slot(
              Popover.model,
              Positioned(
                left: 86,
                bottom: frame.height - (frame.dockY - dockLift) + 34,
                child: _Models(selected: model, onPick: onModel),
              ),
              Alignment.bottomLeft,
            ),
          ],
        ),
      ),
    );
  }

  Widget _slot(Popover kind, Positioned placed, Alignment anchor) {
    final open = which == kind;
    return Positioned(
      left: placed.left,
      right: placed.right,
      top: placed.top,
      bottom: placed.bottom,
      child: IgnorePointer(
        ignoring: !open,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: open ? 1 : 0),
          duration: Duration(milliseconds: open ? 460 : 220),
          curve: open ? Curves.easeOutBack : Curves.easeInCubic,
          child: placed.child,
          builder: (context, t, child) {
            if (t <= 0.001) return const SizedBox.shrink();
            return Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: lerp(0.82, 1, t),
                alignment: anchor,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.width, required this.children});

  final double width;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xE6120605),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x14FFFFFF), width: 0.8),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 30, offset: Offset(0, 14))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.caption, this.leading, this.trailing, this.onTap});

  final String title;
  final String caption;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap ?? () {},
      scale: 0.97,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 11)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: inter(13.5, 500, color: Tone.snow), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(caption, style: inter(11.5, 400, color: const Color(0xFF8E8683)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

Widget _dot(Color color) {
  return Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(color: color.withValues(alpha: 0.16), shape: BoxShape.circle),
    alignment: Alignment.center,
    child: Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
  );
}

class _Alerts extends StatelessWidget {
  const _Alerts();

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      width: 264,
      children: [
        _Row(title: 'AlphaRaptor.sh finished', caption: '12 trades · +2.4% · 2m ago', leading: _dot(Tone.flame)),
        _Row(title: 'Gas spike on Base', caption: '42 gwei · paused 1 job · 18m ago', leading: _dot(const Color(0xFFE8B04A))),
        _Row(title: 'Audit report ready', caption: 'No critical issues · 1h ago', leading: _dot(const Color(0xFF7BC47F))),
      ],
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    const arrow = GlyphIcon(Glyph.chevron, size: 14, color: Color(0xFF8E8683), stroke: 1.4);
    return _Sheet(
      width: 250,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Text('Recent chats', style: inter(11.5, 500, color: const Color(0xFF8E8683), spacing: 0.2)),
        ),
        _Row(title: 'Liquidity pool monitor', caption: 'Aira is working...', trailing: Transform.rotate(angle: -1.5708, child: arrow), onTap: onOpen),
        _Row(title: 'ZK-proof gas audit', caption: 'Yesterday', trailing: Transform.rotate(angle: -1.5708, child: arrow)),
        _Row(title: 'Momentum backtest', caption: 'Mon', trailing: Transform.rotate(angle: -1.5708, child: arrow)),
      ],
    );
  }
}

class _Models extends StatelessWidget {
  const _Models({required this.selected, required this.onPick});

  final String selected;
  final ValueChanged<String> onPick;

  static const models = [
    ('Opus 4.8', 'Deepest reasoning'),
    ('Sonnet 4.8', 'Fast and capable'),
    ('Haiku 4.5', 'Lightning quick'),
  ];

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      width: 220,
      children: [
        for (final (name, caption) in models)
          _Row(
            title: name,
            caption: caption,
            onTap: () => onPick(name),
            trailing: AnimatedOpacity(
              opacity: name == selected ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: const GlyphIcon(Glyph.check, size: 16, color: Tone.flame, stroke: 1.8),
            ),
          ),
      ],
    );
  }
}
