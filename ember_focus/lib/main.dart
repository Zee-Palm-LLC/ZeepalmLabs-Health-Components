import 'package:flutter/material.dart';

import 'focus_screen.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Ember', debugShowCheckedModeBanner: false, home: Shell());
  }
}

/// Fills a phone; on wide screens (web, desktop) shows the 390 × 844 design
/// inside a device frame.
class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const app = FittedBox(child: FocusScreen());
    if (size.width < 600) {
      return const Scaffold(body: SizedBox.expand(child: app));
    }
    final s = ((size.height - 48) / 868).clamp(0.3, 1.2);
    return Scaffold(
      backgroundColor: const Color(0xFFEDEBE8),
      body: Center(
        child: Container(
          width: 414 * s,
          height: 868 * s,
          padding: EdgeInsets.all(12 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF111418),
            borderRadius: BorderRadius.circular(62 * s),
            boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 50, offset: Offset(0, 24))],
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(50 * s), child: app),
        ),
      ),
    );
  }
}
