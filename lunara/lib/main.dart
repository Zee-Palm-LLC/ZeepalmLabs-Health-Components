import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const LunaraApp());
}

class LunaraApp extends StatelessWidget {
  const LunaraApp({super.key, this.simulateDevice = false, this.initial = 0});

  final bool simulateDevice;
  final int initial;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Poppins', scaffoldBackgroundColor: const Color(0xFF1B1029)),
      home: Builder(
        builder: (context) {
          final flow = LunaraFlow(initial: initial);
          if (!simulateDevice) return flow;
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              padding: const EdgeInsets.only(top: 59, bottom: 34),
              viewPadding: const EdgeInsets.only(top: 59, bottom: 34),
            ),
            child: flow,
          );
        },
      ),
    );
  }
}
