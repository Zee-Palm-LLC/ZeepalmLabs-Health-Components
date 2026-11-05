import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'wabi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
  runApp(const WabiApp());
}

class WabiApp extends StatelessWidget {
  const WabiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: W.bg),
      home: const Shell(),
    );
  }
}

/// 390 x 844 design canvas: full-bleed on phones, in a device frame on wide
/// screens.
class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: W.bg,
      body: LayoutBuilder(
        builder: (context, box) {
          if (box.maxWidth <= 600) {
            return const SizedBox.expand(
              child: ColoredBox(
                color: W.bg,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(width: 390, height: 844, child: WabiScreen()),
                ),
              ),
            );
          }
          final scale = math.min(1.0, (box.maxHeight - 48) / 868);
          return ColoredBox(
            color: const Color(0xFFEDEEF0),
            child: Center(
              child: SizedBox(
                width: 414 * scale,
                height: 868 * scale,
                child: FittedBox(
                  child: Container(
                    width: 414,
                    height: 868,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF16181B), borderRadius: BorderRadius.circular(64)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(52),
                      child: const SizedBox(width: 390, height: 844, child: WabiScreen()),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
