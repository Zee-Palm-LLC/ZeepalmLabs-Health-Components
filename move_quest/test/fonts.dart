import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _load(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = File('assets/fonts/$file').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

Future<void> loadCabin() async {
  await _load('Cabin', [
    for (final name in ['Regular', 'Medium', 'SemiBold', 'Bold', 'SemiBoldItalic']) 'Cabin-$name.ttf',
  ]);
  await _load('PhosphorFill', ['Phosphor-Fill.ttf']);
  await _load('PhosphorRegular', ['Phosphor-Regular.ttf']);
  await _load('PhosphorBold', ['Phosphor-Bold.ttf']);
}
