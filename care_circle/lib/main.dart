import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/status_bar.dart';
import 'core/theme.dart';
import 'features/welcome/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const CareApp());
}

class CareApp extends StatelessWidget {
  const CareApp({super.key, this.home = const WelcomeScreen(), this.simulateDevice = kIsWeb});

  final Widget home;
  final bool simulateDevice;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareCircle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Jakarta',
        scaffoldBackgroundColor: Hue.canvas,
        colorScheme: ColorScheme.fromSeed(seedColor: Hue.iris),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Hue.iris,
          selectionColor: Color(0x447B5CF5),
          selectionHandleColor: Hue.iris,
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
            child: IgnorePointer(
              child: Material(type: MaterialType.transparency, child: StatusBar()),
            ),
          ),
        ],
      ),
    );

    if (!framed) return screen;

    return ColoredBox(
      color: const Color(0xFFEFE9E2),
      child: Center(
        child: Container(
          width: width + 14,
          height: height + 14,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(62),
            boxShadow: const [BoxShadow(color: Color(0x225B3FD0), blurRadius: 70, offset: Offset(0, 26))],
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
