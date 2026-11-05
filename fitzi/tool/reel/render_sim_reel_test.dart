// Fitzi "dev desk" reel (1080x1920, 60 fps, 16 s): the app running in the iOS
// Simulator over the project open in VS Code. See sim_kit.dart for the two-pass
// render.
import 'dart:io';

import 'package:fitzi/core/canvas.dart';
import 'package:fitzi/core/motion.dart';
import 'package:fitzi/core/palette.dart';
import 'package:fitzi/features/onboarding/onboarding_screen.dart';
import 'package:fitzi/reel/sim_stage.dart';
import 'package:fitzi/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sim_kit.dart';

// The app's design canvas is taller than the stock bezel, so the screen matches
// it and the app fills the phone with no side bars.
const _screen = Size(390, 887);

class _Bezel extends StatelessWidget {
  const _Bezel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: _screen.width + 26,
        height: _screen.height + 26,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xFF111214),
          borderRadius: BorderRadius.circular(64),
          border: Border.all(color: const Color(0xFF6E7076), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(52),
          child: SizedBox.fromSize(
            size: _screen,
            child: Stack(children: [
              Positioned.fill(child: child),
              Positioned(
                top: 11,
                left: (_screen.width - 120) / 2,
                child: Container(width: 120, height: 34, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(17))),
              ),
            ]),
          ),
        ),
      );
}

void main() {
  testWidgets('render sim reel', (tester) async {
    const device = MediaQueryData(
      size: _screen,
      padding: EdgeInsets.only(top: 59, bottom: 34),
      viewPadding: EdgeInsets.only(top: 59, bottom: 34),
    );
    // Same tree as FitziApp, with the device insets fed in below MaterialApp.
    final phone = _Bezel(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Palette.cream,
          fontFamily: 'Inter',
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        builder: (context, child) => MediaQuery(
          data: device,
          child: ClockHost(child: DesignCanvas(child: child!)),
        ),
        home: const OnboardingScreen(),
      ),
    );
    const tabs = ['onboarding_screen.dart', 'home_screen.dart', 'workout_screen.dart', 'player.dart', 'progress_screen.dart'];
    SimCode file(String path) {
      final name = path.split('/').last;
      return readCode('fitzi', 'lib/features/$path', tabs: [for (final t in tabs) if (t != name) t]);
    }

    final onboarding = file('onboarding/onboarding_screen.dart');
    final home = file('home/home_screen.dart');
    final workout = file('workout/workout_screen.dart');
    final player = file('workout/player.dart');
    final progress = file('progress/progress_screen.dart');

    final kit = SimKit(
      tester,
      name: 'Fitzi-Simulator-9x16.mp4',
      length: 16,
      code: onboarding,
      phone: () => phone,
      phoneSize: Size(_screen.width + 26, _screen.height + 26),
      app: find.byType(MaterialApp).last,
      designWidth: 393,
    );
    await kit.setUp(
      focusOn: 'class _StartButton',
      fonts: () async {
        Future<void> load(String family, String file) async {
          await (FontLoader(family)
                ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync()))))
              .load();
        }

        await load('Inter', 'Inter-Variable.ttf');
        await load('Nunito', 'Nunito-Variable.ttf');
        for (final w in ['Regular', 'Bold', 'Fill', 'Light']) {
          await load('Phosphor$w', 'Phosphor-$w.ttf');
        }
      },
    );
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(OnboardingScreen));
      for (final f in Directory('assets/art').listSync().whereType<File>()) {
        await precacheImage(AssetImage('assets/art/${f.uri.pathSegments.last}'), ctx);
      }
    });
    final lift = tester.widget<Frame>(find.byType(Frame)).lift;

    Offset centre(String text) => tester.getCenter(find.text(text).last);
    Offset nav(int i) => tester.getCenter(
          find.descendant(of: find.byType(NavBar), matching: find.byType(Pressable)).at(i),
        );

    void show(SimCode code, String focus) => kit
      ..code = code
      ..focus(focus, jump: true);

    // 1. Onboarding: the mascot and headline rise, then the circle reveal.
    kit.cue('intro');
    await kit.to(2.9);
    kit.cue('rise');
    await kit.tapAt(centre('Get Started'));
    await kit.to(3.45);
    show(home, 'class _Body');
    kit.cue('whoosh');

    // 2. Home: the cards slide in; open the recommended workout.
    await kit.to(5.3);
    kit.cue('tap');
    await kit.tapAt(centre('Full Body Blast'), code: 'class _RecCard');
    show(workout, 'class WorkoutScreen');
    kit.cue('whoosh');

    // 3. Workout: like it, then start. The button blooms into the player.
    await kit.to(6.9);
    kit.cue('success');
    await kit.tap(358.5, 84.3 + lift, code: 'void _toggleLike');
    await kit.to(7.7);
    kit.cue('rise');
    await kit.tapAt(centre('Start Workout'), code: 'void _start');
    show(player, 'class PlayerScreen');

    // 4. Player: the count-in finishes and the ring starts running.
    await kit.to(8.8);
    kit.focus('void _countTick');
    await kit.to(10.2);
    kit.focus('class _Ring');
    await kit.to(12.4);
    kit.cue('tap');
    await kit.tap(41, 85 + lift);
    show(workout, 'class _Steps');

    // 5. Back home and into Progress, where the weekly chart draws itself.
    await kit.to(13.05);
    kit.cue('tap');
    await kit.tap(41, 85 + lift);
    show(home, 'class HomeScreen');
    await kit.to(13.75);
    kit.cue('whoosh');
    await kit.tapAt(nav(2), code: null);
    show(progress, 'class ProgressScreen');
    await kit.finish();
  }, timeout: const Timeout(Duration(hours: 1)));
}
