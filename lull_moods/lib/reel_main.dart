import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/widgets.dart';

import 'reel/reel.dart';
import 'reel/x_reel.dart';

/// Web-only entrypoint for recording the showcase videos.
///
/// The host page (tool/reel/index.html) defines `lullReelSfx(kind)` and
/// `lullReelDone()`, then calls `lullReelStart()` once audio and recording
/// are rolling. Query flags: `?vertical` for the 9:16 reel (default is the
/// 4:5 X-style cut), `?auto` to just watch the script play.
void main() {
  final controller = ReelController();
  globalContext['lullReelStart'] = controller.start.toJS;

  void call(String name, [String? arg]) {
    if (globalContext.has(name)) globalContext.callMethod(name.toJS, arg?.toJS);
  }

  final hooks = ReelHooks(sfx: (k) => call('lullReelSfx', k), onDone: () => call('lullReelDone'));
  final query = Uri.base.queryParameters;
  runApp(ReelApp(
    child: query.containsKey('vertical')
        ? LullReel(controller: controller, hooks: hooks)
        : XReel(controller: controller, hooks: hooks),
  ));
  if (query.containsKey('auto')) controller.start();
}
