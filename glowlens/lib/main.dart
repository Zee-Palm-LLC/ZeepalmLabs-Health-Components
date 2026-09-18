import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/shaders.dart';
import 'core/theme.dart';
import 'core/widgets.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Shaders.load();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const GlowLensApp());
}

class GlowLensApp extends StatelessWidget {
  const GlowLensApp({super.key, this.home = const SplashScreen(), this.simulateDevice = kIsWeb});

  final Widget home;
  final bool simulateDevice;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlowLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Palette.canvas,
        colorScheme: ColorScheme.fromSeed(seedColor: Palette.violet),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
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
    final framed = size.width > 520 && size.height > 700;
    final width = framed ? 390.0 : size.width;
    final height = framed ? (size.height - 48).clamp(700.0, 844.0) : size.height;

    final screen = MediaQuery(
      data: media.copyWith(
        size: Size(width, height),
        padding: const EdgeInsets.only(top: 47, bottom: 20),
        viewPadding: const EdgeInsets.only(top: 47, bottom: 20),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: child),
          const Positioned(top: 0, left: 0, right: 0, child: IgnorePointer(child: FakeStatusBar())),
        ],
      ),
    );

    if (!framed) return screen;

    return ColoredBox(
      color: const Color(0xFFEDE8F2),
      child: Center(
        child: Container(
          width: width + 12,
          height: height + 12,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(52),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 60, offset: Offset(0, 24))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(46),
            child: SizedBox(width: width, height: height, child: screen),
          ),
        ),
      ),
    );
  }
}
