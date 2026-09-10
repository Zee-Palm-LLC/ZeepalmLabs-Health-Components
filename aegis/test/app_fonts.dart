import 'package:aegis/theme/aegis_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled typefaces into the test binding.
///
/// The default test font draws every glyph as a full-em square, which reports
/// overflows the real typefaces never hit. Any test that lays out a screen
/// should call this from `setUpAll`.
Future<void> loadAppFonts() async {
  const families = {
    AegisFonts.sans: [
      'Inter-Light.ttf',
      'Inter-Regular.ttf',
      'Inter-Medium.ttf',
      'Inter-SemiBold.ttf',
    ],
    AegisFonts.serif: [
      'SourceSerif4Display-Regular.ttf',
      'SourceSerif4Display-Medium.ttf',
    ],
  };

  TestWidgetsFlutterBinding.ensureInitialized();
  for (final MapEntry(key: family, value: files) in families.entries) {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(rootBundle.load('assets/fonts/$file'));
    }
    await loader.load();
  }
}
