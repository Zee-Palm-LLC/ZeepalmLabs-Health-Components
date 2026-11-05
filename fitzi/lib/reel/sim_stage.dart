import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 9:16 "dev desk" reel stage: black bars around a 3:4 crop of a macOS
/// desktop, the project open in VS Code and the iOS Simulator in front of it,
/// driven by a mouse pointer. Shared by every showcase app; the app supplies
/// its phone (with bezel), its source file and the pointer track.
const simSize = Size(1080, 1920);
const _scene = Rect.fromLTWH(0, 240, 1080, 1440);
const _phoneTop = 122.0, _phoneH = 1135.0;

/// What VS Code shows for the project.
class SimCode {
  const SimCode({required this.project, required this.path, required this.lines, this.tabs = const []});

  final String project;

  /// Path inside the project, e.g. `lib/home.dart`.
  final String path;
  final List<String> lines;

  /// Other open tabs.
  final List<String> tabs;

  String get file => path.split('/').last;
}

class SimStage extends StatelessWidget {
  const SimStage({
    super.key,
    required this.t,
    required this.length,
    required this.phone,
    required this.phoneSize,
    required this.code,
    required this.scroll,
    required this.active,
    this.cursor,
    this.down = false,
  });

  final double t, length;

  /// The device with its bezel, laid out at [phoneSize].
  final Widget phone;
  final Size phoneSize;
  final SimCode code;

  /// First visible editor line (0-based, fractional while scrolling).
  final double scroll;

  /// Current line (0-based).
  final int active;
  final Offset? cursor;
  final bool down;

  static Rect phoneRect(Size phoneSize) {
    final w = _phoneH * phoneSize.width / phoneSize.height;
    return Rect.fromLTWH(45, _scene.top + _phoneTop, w, _phoneH);
  }

  @override
  Widget build(BuildContext context) {
    final fade = t < 0.4 ? 1 - t / 0.4 : (t > length - 0.6 ? ((t - length + 0.6) / 0.6).clamp(0.0, 1.0) : 0.0);
    final phoneRect = SimStage.phoneRect(phoneSize);
    return SizedBox.fromSize(
      size: simSize,
      child: Stack(children: [
        const Positioned.fill(child: ColoredBox(color: Colors.black)),
        Positioned.fromRect(
          rect: _scene,
          child: ClipRect(
            child: Stack(children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF141826), Color(0xFF0A0B10), Color(0xFF1B1530)],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 40,
                right: 0,
                height: 1236,
                child: _VsCode(code: code, scroll: scroll, active: active, t: t, left: phoneRect.right + 14),
              ),
              const Positioned(left: 0, top: 0, right: 0, height: 40, child: _MenuBar()),
              const Positioned(left: 0, right: 0, bottom: 22, height: 96, child: _Dock()),
              Positioned(left: phoneRect.left, top: 54, width: phoneRect.width, height: 58, child: const _SimToolbar()),
            ]),
          ),
        ),
        Positioned.fromRect(
          rect: phoneRect,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(phoneRect.width * 0.155),
              boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 60, offset: Offset(0, 24))],
            ),
            child: FittedBox(child: SizedBox.fromSize(size: phoneSize, child: phone)),
          ),
        ),
        if (cursor != null) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _Pointer(cursor!, down)))),
        Positioned.fill(child: IgnorePointer(child: ColoredBox(color: Colors.black.withValues(alpha: fade)))),
      ]),
    );
  }
}

TextStyle _ui(double size, {Color color = const Color(0xFFCCCCCC), FontWeight w = FontWeight.w400, double height = 1.2}) =>
    GoogleFonts.inter(fontSize: size, color: color, fontWeight: w, height: height);

TextStyle _mono(Color color) => GoogleFonts.jetBrainsMono(fontSize: 15, color: color, height: 1.0);

// ── macOS ─────────────────────────────────────────────────────────────────

class _MenuBar extends StatelessWidget {
  const _MenuBar();

  @override
  Widget build(BuildContext context) {
    final item = _ui(15, color: Colors.white, w: FontWeight.w500);
    return ColoredBox(
      color: const Color(0xF2000000),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          const Icon(Icons.apple, size: 20, color: Colors.white),
          const SizedBox(width: 22),
          Text('Simulator', style: _ui(15, color: Colors.white, w: FontWeight.w700)),
          for (final m in ['File', 'Edit', 'Device', 'I/O', 'Features', 'Debug', 'Window', 'Help']) ...[
            const SizedBox(width: 22),
            Text(m, style: item),
          ],
        ]),
      ),
    );
  }
}

class _Dock extends StatelessWidget {
  const _Dock();

  static const _apps = <(List<Color>, IconData?, bool)>[
    ([Color(0xFF6CC7FF), Color(0xFF1F7BEA)], Icons.sentiment_satisfied_alt_rounded, true),
    ([Color(0xFFE9E9EE), Color(0xFFB9BAC4)], Icons.apps_rounded, false),
    ([Color(0xFF5FE07A), Color(0xFF18B83B)], Icons.chat_bubble_rounded, true),
    ([Color(0xFF5AB8FF), Color(0xFF1468F0)], Icons.mail_rounded, false),
    ([Color(0xFF8FE39A), Color(0xFF3DA0F0)], Icons.near_me_rounded, false),
    ([Color(0xFFFFFFFF), Color(0xFFEDEDF2)], Icons.local_florist_rounded, false),
    ([Color(0xFF5FE07A), Color(0xFF16A836)], Icons.videocam_rounded, false),
    ([Color(0xFFFFFFFF), Color(0xFFF2F2F5)], null, false),
    ([Color(0xFFD8B48C), Color(0xFF9C7550)], Icons.person_rounded, false),
    ([Color(0xFFFFE27A), Color(0xFFF6C531)], Icons.sticky_note_2_rounded, false),
    ([Color(0xFF3FA9F5), Color(0xFF0065A9)], Icons.code_rounded, true),
    ([Color(0xFF55585F), Color(0xFF23252A)], Icons.phone_iphone_rounded, true),
  ];

  @override
  Widget build(BuildContext context) {
    Widget icon((List<Color>, IconData?, bool) a, int i) {
      final (colors, glyph, running) = a;
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Stack(clipBehavior: Clip.none, children: [
            Center(
              child: glyph == null
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('OCT', style: _ui(11, color: const Color(0xFFFF3B30), w: FontWeight.w700, height: 1)),
                      Text('29', style: _ui(30, color: const Color(0xFF222222), height: 1.05)),
                    ])
                  : Icon(glyph, size: 38, color: i == 5 ? const Color(0xFFFF8A3D) : (i == 1 ? const Color(0xFF6D6F7A) : Colors.white)),
            ),
            if (i == 2)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(11)),
                  child: Text('48', style: _ui(13, color: Colors.white, w: FontWeight.w600)),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 4),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: running ? const Color(0xCCFFFFFF) : Colors.transparent, shape: BoxShape.circle),
        ),
      ]);
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 2),
        decoration: BoxDecoration(
          color: const Color(0x40C8C8D2),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0x40FFFFFF)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < _apps.length; i++) ...[
            if (i > 0) const SizedBox(width: 11),
            if (i == 10) ...[
              Container(width: 1, height: 60, color: const Color(0x55FFFFFF)),
              const SizedBox(width: 11),
            ],
            icon(_apps[i], i),
          ],
        ]),
      ),
    );
  }
}

/// macOS 26 Simulator toolbar: a floating capsule above the device.
class _SimToolbar extends StatelessWidget {
  const _SimToolbar();

  @override
  Widget build(BuildContext context) {
    Widget dot(Color c) => Container(
          width: 13,
          height: 13,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        );
    const ic = Color(0xFFE6E6EA);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xF22A2A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x33FFFFFF)),
        boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Row(children: [
        dot(const Color(0xFFFF5F57)),
        dot(const Color(0xFFFEBC2E)),
        dot(const Color(0xFF28C840)),
        const SizedBox(width: 10),
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('iPhone 17 Pro Max', style: _ui(15, color: Colors.white, w: FontWeight.w600, height: 1.1)),
          const SizedBox(height: 2),
          Text('iOS 26.3', style: _ui(12, color: const Color(0xFFA0A0A8), height: 1.1)),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: const Color(0x22FFFFFF), borderRadius: BorderRadius.circular(14)),
          child: const Row(children: [
            Icon(Icons.home_outlined, size: 20, color: ic),
            SizedBox(width: 14),
            Icon(Icons.photo_camera_outlined, size: 20, color: ic),
            SizedBox(width: 14),
            Icon(Icons.screen_rotation_alt_rounded, size: 19, color: ic),
          ]),
        ),
      ]),
    );
  }
}

class _Pointer extends CustomPainter {
  _Pointer(this.at, this.down);
  final Offset at;
  final bool down;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.scale(down ? 1.35 : 1.5);
    final p = Path()
      ..moveTo(0, 0)
      ..lineTo(0, 22)
      ..lineTo(5.2, 17)
      ..lineTo(8.8, 25.4)
      ..lineTo(12.4, 23.9)
      ..lineTo(8.8, 15.8)
      ..lineTo(15.8, 15.8)
      ..close();
    canvas.drawShadow(p, Colors.black, 3, false);
    canvas.drawPath(p, Paint()..color = Colors.black);
    canvas.drawPath(
      p,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Pointer old) => old.at != at || old.down != down;
}

// ── VS Code ───────────────────────────────────────────────────────────────

const _bg = Color(0xFF1F1F1F);
const _chrome = Color(0xFF181818);
const _border = Color(0xFF2B2B2B);
const _blue = Color(0xFF0078D4);
const _lineH = 25.0;
const _codeTop = 104.0;

class _VsCode extends StatelessWidget {
  const _VsCode({required this.code, required this.scroll, required this.active, required this.t, required this.left});

  final SimCode code;
  final double scroll, t;
  final int active;

  /// Where the editor starts (just right of the device).
  final double left;

  @override
  Widget build(BuildContext context) {
    final gutter = left, codeX = left + 76;
    final caretOn = (t / 0.53).floor().isEven;
    final first = scroll.floor().clamp(0, code.lines.length - 1);
    final dy = (scroll - first) * _lineH;
    final visible = ((1236 - _codeTop - 28) / _lineH).ceil() + 2;
    final parts = code.path.split('/');
    final activeText = active < code.lines.length ? code.lines[active] : '';
    return ColoredBox(
      color: _bg,
      child: Stack(children: [
        // Code (scrolls under the tabs and breadcrumb).
        Positioned(
          left: gutter,
          right: 0,
          top: _codeTop,
          bottom: 28,
          child: ClipRect(
            child: Stack(children: [
              Positioned(
                left: 0,
                right: 0,
                top: (active - scroll) * _lineH,
                height: _lineH,
                child: DecoratedBox(decoration: BoxDecoration(border: Border.all(color: const Color(0xFF282828), width: 2))),
              ),
              for (var i = first; i < first + visible && i < code.lines.length; i++) ...[
                Positioned(
                  left: 0,
                  width: 54,
                  top: (i - first) * _lineH - dy + 5,
                  child: Text(
                    '${i + 1}',
                    textAlign: TextAlign.right,
                    style: _mono(i == active ? const Color(0xFFCCCCCC) : const Color(0xFF6E7681)),
                  ),
                ),
                Positioned(
                  left: codeX - gutter,
                  top: (i - first) * _lineH - dy + 5,
                  child: Text.rich(_highlight(code.lines[i]), softWrap: false, maxLines: 1),
                ),
              ],
              if (caretOn)
                Positioned(
                  left: codeX - gutter + _indent(activeText) * 9.0,
                  top: (active - scroll) * _lineH + 2,
                  width: 2,
                  height: _lineH - 4,
                  child: const ColoredBox(color: Color(0xFFAEAFAD)),
                ),
            ]),
          ),
        ),
        // Title bar with the command centre.
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 40,
          child: Container(
            color: _chrome,
            alignment: const Alignment(0.35, 0),
            child: Container(
              width: 380,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF3C3C3C)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.search_rounded, size: 15, color: Color(0xFF9D9D9D)),
                const SizedBox(width: 6),
                Text(code.project, style: _ui(13, color: const Color(0xFF9D9D9D))),
              ]),
            ),
          ),
        ),
        // Activity bar.
        Positioned(
          left: 0,
          top: 40,
          bottom: 28,
          width: 52,
          child: Container(
            decoration: const BoxDecoration(color: _chrome, border: Border(right: BorderSide(color: _border))),
            child: Column(children: [
              for (final (i, ic) in [
                Icons.file_copy_outlined,
                Icons.search_rounded,
                Icons.account_tree_outlined,
                Icons.play_circle_outline_rounded,
                Icons.extension_outlined,
                Icons.flutter_dash,
                Icons.science_outlined,
              ].indexed)
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Icon(ic, size: 26, color: i == 0 ? const Color(0xFFD7D7D7) : const Color(0xFF868686)),
                ),
              const Spacer(),
              const Icon(Icons.account_circle_outlined, size: 26, color: Color(0xFF868686)),
              const SizedBox(height: 18),
              const Icon(Icons.settings_outlined, size: 26, color: Color(0xFF868686)),
              const SizedBox(height: 16),
            ]),
          ),
        ),
        // Explorer (mostly behind the simulator).
        Positioned(
          left: 52,
          top: 40,
          bottom: 28,
          width: gutter - 52,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 0, 0),
            decoration: const BoxDecoration(color: _chrome, border: Border(right: BorderSide(color: _border))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('EXPLORER', style: _ui(12, color: const Color(0xFFBBBBBB))),
              const SizedBox(height: 14),
              Text(code.project.toUpperCase(), style: _ui(14, w: FontWeight.w700)),
              const SizedBox(height: 9),
              for (final (d, name) in [(1, 'lib'), (2, code.file), for (final f in code.tabs) (2, f), (1, 'pubspec.yaml')])
                Padding(
                  padding: EdgeInsets.only(left: d * 14.0, bottom: 9),
                  child: Text(name, style: _ui(14)),
                ),
            ]),
          ),
        ),
        // Tabs.
        Positioned(
          left: gutter,
          right: 0,
          top: 40,
          height: 40,
          child: Container(
            decoration: const BoxDecoration(color: _chrome, border: Border(bottom: BorderSide(color: _border))),
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: double.infinity,
                child: Row(children: [
                  _Tab(code.file, active: true),
                  for (final f in code.tabs) _Tab(f),
                ]),
              ),
            ),
          ),
        ),
        // Breadcrumb.
        Positioned(
          left: gutter,
          right: 0,
          top: 80,
          height: 24,
          child: Container(
            color: _bg,
            padding: const EdgeInsets.only(left: 18, top: 3),
            child: Text(parts.join('  ›  '), style: _ui(13, color: const Color(0xFFA9A9A9)), softWrap: false),
          ),
        ),
        // Status bar.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 28,
          child: Container(
            decoration: const BoxDecoration(color: _chrome, border: Border(top: BorderSide(color: _border))),
            child: Row(children: [
              Container(width: 40, color: _blue, child: const Icon(Icons.code_rounded, size: 16, color: Colors.white)),
              const SizedBox(width: 14),
              const Icon(Icons.call_split_rounded, size: 15, color: Color(0xFFCCCCCC)),
              Text(' main', style: _ui(13)),
              const SizedBox(width: 14),
              const Icon(Icons.cancel_outlined, size: 14, color: Color(0xFFCCCCCC)),
              Text(' 0  ', style: _ui(13)),
              const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFCCCCCC)),
              Text(' 0', style: _ui(13)),
              const Spacer(),
              Text('Ln ${active + 1}, Col ${_indent(activeText) + 1}    Dart    iPhone 17 Pro Max (ios simulator)    ',
                  style: _ui(13), softWrap: false),
            ]),
          ),
        ),
      ]),
    );
  }
}

int _indent(String l) => l.length - l.trimLeft().length;

class _Tab extends StatelessWidget {
  const _Tab(this.name, {this.active = false});
  final String name;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? _bg : _chrome,
          border: Border(
            top: BorderSide(color: active ? _blue : Colors.transparent, width: 2),
            right: const BorderSide(color: _border),
          ),
        ),
        child: Row(children: [
          const Icon(Icons.flutter_dash, size: 15, color: Color(0xFF42A5F5)),
          const SizedBox(width: 7),
          Text(name, style: _ui(14, color: active ? Colors.white : const Color(0xFF9D9D9D))),
          if (active) ...[
            const SizedBox(width: 10),
            const Icon(Icons.close_rounded, size: 15, color: Color(0xFFCCCCCC)),
          ],
        ]),
      );
}

// ── Dart highlighting (VS Code Dark Modern) ───────────────────────────────

const _kw = {
  'var', 'final', 'const', 'void', 'double', 'int', 'bool', 'true', 'false', 'null', 'this', 'class', 'extends', //
  'with', 'static', 'late', 'super', 'required', 'import', 'get', 'set', 'new', 'enum', 'String', 'num', 'dynamic',
};
const _ctrl = {'if', 'else', 'return', 'for', 'while', 'switch', 'case', 'await', 'async', 'break', 'continue', 'in'};
final _token = RegExp(r"(///.*|//.*)|('[^']*'?)|(\b\d+(?:\.\d+)?\b)|(@?[A-Za-z_]\w*)|(\s+)|(.)");

TextSpan _highlight(String line) {
  final spans = <TextSpan>[];
  final matches = _token.allMatches(line).toList();
  for (var i = 0; i < matches.length; i++) {
    final m = matches[i];
    final s = m.group(0)!;
    Color c;
    if (m.group(1) != null) {
      c = const Color(0xFF6A9955);
    } else if (m.group(2) != null) {
      c = const Color(0xFFCE9178);
    } else if (m.group(3) != null) {
      c = const Color(0xFFB5CEA8);
    } else if (m.group(4) != null) {
      final next = i + 1 < matches.length ? matches[i + 1].group(0) : null;
      if (_ctrl.contains(s)) {
        c = const Color(0xFFC586C0);
      } else if (_kw.contains(s) || s.startsWith('@')) {
        c = const Color(0xFF569CD6);
      } else if (next == '(') {
        c = const Color(0xFFDCDCAA);
      } else if (s[0].toUpperCase() == s[0] && s[0] != '_') {
        c = const Color(0xFF4EC9B0);
      } else {
        c = const Color(0xFF9CDCFE);
      }
    } else {
      c = const Color(0xFFD4D4D4);
    }
    spans.add(TextSpan(text: s, style: _mono(c)));
  }
  return TextSpan(children: spans);
}


/// Plain iPhone bezel (416 × 870) for apps that ship without one.
class SimBezel extends StatelessWidget {
  const SimBezel({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: 416,
        height: 870,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xFF111214),
          borderRadius: BorderRadius.circular(64),
          border: Border.all(color: const Color(0xFF6E7076), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(52),
          child: SizedBox(
            width: 390,
            height: 844,
            child: Stack(children: [
              Positioned.fill(child: child),
              Positioned(
                top: 11,
                left: (390 - 120) / 2,
                child: Container(width: 120, height: 34, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(17))),
              ),
            ]),
          ),
        ),
      );
}
