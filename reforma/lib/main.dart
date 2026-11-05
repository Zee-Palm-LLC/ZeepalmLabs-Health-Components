import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'icons.dart';
import 'package:flutter/services.dart';

import 'screens/checkin.dart';
import 'screens/home.dart';
import 'screens/mobility.dart';
import 'theme.dart';
import 'three/figures.dart';
import 'widgets/art.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(['Phosphor Icons'], await rootBundle.loadString('assets/fonts/PHOSPHOR_LICENSE.txt'));
  });
  // The check-in body is procedural: build it before the first frame so it
  // can never pop in late.
  await Figures.load();
  ThumbArt.prewarm();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
  runApp(const ReformaApp());
}

class ReformaApp extends StatelessWidget {
  const ReformaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reforma',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: C.bg,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: C.teal),
      ),
      home: const _Shell(),
    );
  }
}

/// Phones get the app edge to edge. Wide screens get it inside device frames
/// at the exact 390 × 844 design size — three side by side (like the mockup)
/// when there is room, each with its own navigator.
class _Shell extends StatelessWidget {
  const _Shell();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 600) {
        // ?s=checkin / ?s=session opens a screen directly (handy for previews).
        return switch (Uri.base.queryParameters['s']) {
          'checkin' => const CheckInScreen(),
          'session' => const MobilityScreen(),
          _ => const HomeScreen(),
        };
      }
      final three = c.maxWidth / c.maxHeight > 1.25;
      final screens = three ? const [HomeScreen(), CheckInScreen(), MobilityScreen()] : const [HomeScreen()];
      return Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE3E8DA), Color(0xFFD5DCCB)],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (i, s) in screens.indexed) ...[
                      if (i > 0) const SizedBox(width: 44),
                      PhoneFrame(child: s),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// An iPhone-style bezel with its own navigator and a painted status bar.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child, this.shadow = true});

  final Widget child;
  final bool shadow; // off for the showcase video

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF15161A),
        borderRadius: BorderRadius.circular(64),
        border: Border.all(color: const Color(0xFF8D9096), width: 2),
        boxShadow: shadow
            ? const [
                BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 24)),
                BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2)),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(52),
        child: SizedBox(
          width: 390,
          height: 844,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: const Size(390, 844),
              padding: const EdgeInsets.only(top: 47, bottom: 34),
              viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
            ),
            child: Stack(
              children: [
                HeroControllerScope(
                  controller: MaterialApp.createMaterialHeroController(),
                  child: Navigator(onGenerateRoute: (_) => PageRouteBuilder(pageBuilder: (_, _, _) => child)),
                ),
                const IgnorePointer(child: _StatusBar()),
                Positioned(
                  bottom: 8,
                  left: (390 - 134) / 2,
                  child: IgnorePointer(
                    child: Container(
                      width: 134,
                      height: 5,
                      decoration: BoxDecoration(color: const Color(0xFF15161A), borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: Stack(
        children: [
          Positioned(
            left: 32,
            top: 15,
            child: Text('9:41', style: inter(15, FontWeight.w600, Colors.black, ls: -0.2)),
          ),
          Positioned(
            top: 11,
            left: (390 - 122) / 2,
            child: Container(
              width: 122,
              height: 35,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(18)),
            ),
          ),
          const Positioned(
            right: 26,
            top: 17,
            child: Row(
              children: [
                Icon(PhFill.cellSignalFull, size: 15, color: Colors.black),
                SizedBox(width: 4),
                Icon(PhBold.wifiHigh, size: 15, color: Colors.black),
                SizedBox(width: 4),
                _Battery(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Battery extends StatelessWidget {
  const _Battery();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 11,
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black54, width: 1),
            borderRadius: BorderRadius.circular(3.5),
          ),
          child: Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(1.5))),
        ),
        Container(
          width: 1.5,
          height: 4,
          margin: const EdgeInsets.only(left: 1),
          decoration: const BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.horizontal(right: Radius.circular(1))),
        ),
      ],
    );
  }
}
