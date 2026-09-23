import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadAppFonts() async {
  const families = <String, String>{
    'Inter': 'assets/fonts/Inter-Variable.ttf',
    'Saira': 'assets/fonts/Saira-Variable.ttf',
  };
  for (final entry in families.entries) {
    final loader = FontLoader(entry.key)..addFont(rootBundle.load(entry.value));
    await loader.load();
  }
}
