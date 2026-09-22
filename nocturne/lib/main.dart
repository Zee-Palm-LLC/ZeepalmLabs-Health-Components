import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'scene/clock.dart';
import 'sound/engine.dart';
import 'sound/mixer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Shaders.load();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    NocturneApp(
      mixer: Mixer(engine: LoopEngine()),
      simulateDevice: kIsWeb,
    ),
  );
}
