import 'package:flutter/material.dart';

import 'core/palette.dart';
import 'core/widgets.dart';
import 'features/welcome/welcome_screen.dart';
import 'scene/clock.dart';
import 'sound/mixer.dart';

class NocturneApp extends StatefulWidget {
  const NocturneApp({
    super.key,
    required this.mixer,
    this.simulateDevice = false,
    this.home,
  });

  final Mixer mixer;
  final bool simulateDevice;
  final Widget? home;

  @override
  State<NocturneApp> createState() => _NocturneAppState();
}

class _NocturneAppState extends State<NocturneApp> {
  @override
  void dispose() {
    widget.mixer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClockDriver(
      child: MixerScope(
        mixer: widget.mixer,
        child: MaterialApp(
          title: 'Nocturne',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Night.base,
            colorScheme: const ColorScheme.dark(
              primary: Night.lavender,
              surface: Night.base,
            ),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            fontFamily: 'Poppins',
          ),
          builder: (context, child) {
            final app = child ?? const SizedBox.shrink();
            if (!widget.simulateDevice) return app;
            return _PhoneViewport(child: DeviceChrome(child: app));
          },
          home: widget.home ?? const WelcomeScreen(),
        ),
      ),
    );
  }
}

class _PhoneViewport extends StatelessWidget {
  const _PhoneViewport({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth <= 520) return child;
        final h = box.maxHeight.clamp(0.0, 852.0);
        return ColoredBox(
          color: const Color(0xFF05060C),
          child: Center(
            child: SizedBox(
              width: 393,
              height: h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(size: Size(393, h)),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
