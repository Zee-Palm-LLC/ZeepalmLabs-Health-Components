// Fit Profile "dev desk" reel (1080x1920, 60 fps, 16 s): the app running in the
// iOS Simulator over the project open in VS Code. See sim_kit.dart for the
// two-pass render.
import 'dart:io';

import 'package:fit_profile/core/theme/app_colors.dart';
import 'package:fit_profile/features/profile_setup/profile_setup_view.dart';
import 'package:fit_profile/reel/sim_stage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sim_kit.dart';

void main() {
  testWidgets('render sim reel', (tester) async {
    const device = MediaQueryData(
      size: Size(390, 844),
      padding: EdgeInsets.only(top: 59, bottom: 34),
      viewPadding: EdgeInsets.only(top: 59, bottom: 34),
    );
    ScreenUtil.configure(data: device, designSize: const Size(390, 844), minTextAdapt: true, splitScreenMode: true);
    // Same app, with the device insets fed in below its own MaterialApp.
    final phone = SimBezel(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        scrollBehavior: const ScrollBehavior().copyWith(overscroll: false, physics: const BouncingScrollPhysics()),
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.accent,
            brightness: Brightness.dark,
            surface: AppColors.surface,
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        builder: (context, child) => MediaQuery(data: device, child: child!),
        home: const ProfileSetupView(),
      ),
    );
    const tabs = ['gender_step.dart', 'age_step.dart', 'weight_step.dart', 'height_step.dart'];
    SimCode file(String name) => readCode(
          'fit_profile',
          'lib/features/profile_setup/widgets/$name',
          tabs: [for (final t in tabs) if (t != name) t],
        );
    final gender = file('gender_step.dart');
    final age = file('age_step.dart');
    final weight = file('weight_step.dart');
    final height = file('height_step.dart');

    final kit = SimKit(
      tester,
      name: 'FitProfile-Simulator-9x16.mp4',
      length: 16,
      code: gender,
      phone: () => phone,
      phoneSize: const Size(416, 870),
      app: find.byType(GetMaterialApp),
      designWidth: 390,
    );
    await kit.setUp(
      focusOn: 'class GenderStep',
      fonts: () async {
        for (final w in [FontWeight.w400, FontWeight.w500, FontWeight.w600, FontWeight.w700, FontWeight.w800]) {
          GoogleFonts.plusJakartaSans(fontWeight: w);
        }
        final pub = Platform.environment['LOCALAPPDATA']!;
        final icons = File('$pub/Pub/Cache/hosted/pub.dev/iconsax_flutter-1.0.1/fonts/FlutterIconsax.ttf').readAsBytesSync();
        await (FontLoader('packages/iconsax_flutter/FlutterIconsax')..addFont(Future.value(ByteData.sublistView(icons)))).load();
      },
    );

    Offset centre(String text) => tester.getCenter(find.text(text).last);

    // Screen point to the app's design points, for the drags.
    Offset design(Offset p) {
      final r = tester.getRect(find.byType(GetMaterialApp));
      return (p - r.topLeft) / (r.width / 390);
    }

    void show(SimCode code, String focus) => kit
      ..code = code
      ..focus(focus, jump: true);

    Future<void> go(String label, SimCode code, String focus) async {
      kit.cue('whoosh');
      await kit.tapAt(centre(label));
      show(code, focus);
    }

    Future<void> slide(Finder target, Offset by, double dur) async {
      final a = design(tester.getCenter(target)) - by / 2;
      kit.cue('tick');
      await kit.drag(a.dx, a.dy, a.dx + by.dx, a.dy + by.dy, dur: dur);
    }

    // 1. Gender: the cards rise in, then the selection moves between them.
    kit.cue('intro');
    await kit.to(1.7);
    kit.cue('tap');
    await kit.tapAt(centre('Female'));
    await kit.to(2.6);
    kit.cue('tap');
    await kit.tapAt(centre('Others'));
    await kit.to(3.5);
    kit.cue('tap');
    await kit.tapAt(centre('Male'));
    await kit.to(4.3);
    await go('Continue', age, 'class AgeStep');

    // 2. Age: spin the wheel.
    await kit.to(5.3);
    await slide(find.byType(ListWheelScrollView), const Offset(0, -220), 0.7);
    await kit.to(7.1);
    await go('Continue', weight, 'class WeightStep');

    // 3. Weight: slide the ruler, the value counts along.
    await kit.to(8.1);
    await slide(find.byType(ListView), const Offset(-230, 0), 0.8);
    await kit.to(9.7);
    await go('Continue', height, 'class HeightStep');

    // 4. Height: slide the vertical ruler, then finish.
    await kit.to(10.7);
    await slide(find.byType(ListView), const Offset(0, -170), 0.8);
    kit.focus('void _onScroll');
    await kit.to(12.4);
    kit.cue('success');
    await kit.tapAt(centre('Done'));
    await kit.finish();
  }, timeout: const Timeout(Duration(hours: 1)));
}
