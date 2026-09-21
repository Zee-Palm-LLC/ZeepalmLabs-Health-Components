import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/status_bar.dart';
import 'scene/orb.dart';
import 'scene/stage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OrbShader.load();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const AiraApp());
}

class AiraApp extends StatelessWidget {
  const AiraApp({super.key, this.home = const Stage(), this.simulateDevice = kIsWeb});

  final Widget home;
  final bool simulateDevice;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aira',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.black,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFF26A1B),
          selectionColor: Color(0x55F26A1B),
          selectionHandleColor: Color(0xFFF26A1B),
        ),
      ),
      builder: simulateDevice ? (context, child) => DeviceViewport(child: child!) : null,
      home: home,
    );
  }
}

class DeviceViewport extends StatelessWidget {
  const DeviceViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final framed = size.width > 520 && size.height > 720;
    final width = framed ? 393.0 : size.width;
    final height = framed ? (size.height - 40).clamp(700.0, 852.0) : size.height;

    final screen = MediaQuery(
      data: media.copyWith(
        size: Size(width, height),
        padding: const EdgeInsets.only(top: 59, bottom: 34),
        viewPadding: const EdgeInsets.only(top: 59, bottom: 34),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: child),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(child: Material(type: MaterialType.transparency, child: StatusBar())),
          ),
        ],
      ),
    );

    if (!framed) return screen;

    return ColoredBox(
      color: const Color(0xFF0A0605),
      child: Center(
        child: Container(
          width: width + 14,
          height: height + 14,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFF151012),
            borderRadius: BorderRadius.circular(62),
            boxShadow: const [BoxShadow(color: Color(0x66A0300A), blurRadius: 90, offset: Offset(0, 30))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(55),
            child: SizedBox(width: width, height: height, child: screen),
          ),
        ),
      ),
    );
  }
}
