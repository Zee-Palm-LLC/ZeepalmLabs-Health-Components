import 'package:flutter/material.dart';

import 'home.dart';
import 'widgets/phone_frame.dart';
import 'layout.dart';

void main() => runApp(const LullApp());

class LullApp extends StatelessWidget {
  const LullApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lull — Moods',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, splashFactory: NoSplash.splashFactory),
      home: const _Shell(),
    );
  }
}

/// Phones get the app edge to edge; wide screens (web/desktop) get it inside
/// a device frame at the exact 390 × 844 design size, scaled to fit.
class _Shell extends StatelessWidget {
  const _Shell();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 600) return const Scaffold(body: LullHome());
      return Scaffold(
        backgroundColor: const Color(0xFFE8E9EC),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: c.maxHeight * 0.9 - 28,
                child: FittedBox(
                  child: const PhoneFrame(),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Tap or drag the switch  ·  swipe sideways  ·  poke the face',
                style: inter(12, FontWeight.w500, const Color(0xFF8A8D94)),
              ),
            ],
          ),
        ),
      );
    });
  }
}
