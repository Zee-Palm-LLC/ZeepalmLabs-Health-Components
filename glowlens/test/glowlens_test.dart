import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowlens/core/glyphs.dart';
import 'package:glowlens/core/shaders.dart';
import 'package:glowlens/data/catalog.dart';
import 'package:glowlens/features/products/product_card.dart';
import 'package:glowlens/features/products/product_detail.dart';
import 'package:glowlens/features/scan/scan_screen.dart';
import 'package:glowlens/features/shell/app_shell.dart';
import 'package:glowlens/main.dart';

void main() {
  setUpAll(() async {
    final inter = FontLoader('Inter')..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
    await inter.load();
    await Shaders.load();
  });

  setUp(Bag.instance.reset);

  void usePhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Future<void> settle(WidgetTester tester, [int millis = 3000]) async {
    for (var elapsed = 0; elapsed < millis; elapsed += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Finder glyph(Glyph value) => find.byWidgetPredicate((w) => w is GlyphIcon && w.glyph == value);

  group('data', () {
    test('filters split the catalog by routine', () {
      final morning = Catalog.products.where((p) => p.matches(Filter.morning));
      final evening = Catalog.products.where((p) => p.matches(Filter.evening));
      expect(morning.length + evening.length, Catalog.products.length);
      expect(morning.every((p) => p.routine == Routine.morning), isTrue);
    });

    test('bag counts and totals', () {
      Bag.instance.add('retinol');
      Bag.instance.add('retinol');
      Bag.instance.add('peptide');
      expect(Bag.instance.count, 3);
      expect(Bag.instance.total, 88 * 2 + 28);
      Bag.instance.remove('retinol');
      expect(Bag.instance.count, 2);
    });

    test('mesh edges reference real points', () {
      for (final (a, b) in meshEdges) {
        expect(a, lessThan(meshPoints.length));
        expect(b, lessThan(meshPoints.length));
      }
    });
  });

  testWidgets('home dashboard opens the scanner, which scans and hands off to analytic', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(const GlowLensApp(simulateDevice: true));
    await settle(tester, 1500);
    expect(find.text('Your skin, decoded.'), findsOneWidget);
    await settle(tester, 4500);

    expect(find.text('Your Glow Today'), findsOneWidget);
    expect(find.text('Scan Your Face'), findsNothing);
    expect(find.text("Today's Routine"), findsOneWidget);

    await tester.tap(find.text('Start Face Scan'));
    await settle(tester, 2500);
    expect(find.byType(ScanScreen), findsOneWidget);
    expect(find.text('Wrinkle Detection'), findsOneWidget);
    expect(find.text('Upload Photo'), findsOneWidget);

    final before = ScanResults.instance.generation;
    await tester.tap(find.text('Scan Your Face'));
    await settle(tester, 1500);
    expect(find.textContaining('Scanning'), findsOneWidget);

    await settle(tester, 4500);
    expect(ScanResults.instance.generation, before + 1);
    expect(find.text('View Analysis'), findsOneWidget);

    await tester.tap(find.text('View Analysis'));
    await settle(tester, 3000);
    expect(find.byType(ScanScreen), findsNothing);
    expect(find.text('Detected Areas'), findsOneWidget);
    expect(find.text('Skin Health Score'), findsOneWidget);
    expect(find.text('78%'), findsOneWidget);
  });

  testWidgets('routine steps tick off on the dashboard', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(const GlowLensApp(home: AppShell()));
    await settle(tester, 2500);
    expect(find.text('1/3'), findsOneWidget);
    await tester.tap(find.text('Collagen Glow Balm'));
    await settle(tester, 800);
    expect(find.text('2/3'), findsOneWidget);
  });

  testWidgets('analytic area card opens the detail sheet', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(const GlowLensApp(home: AppShell(initialTab: 1)));
    await settle(tester, 3000);

    await tester.tap(find.text('Frown Lines'));
    await settle(tester, 1500);
    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Peptide Power Serum'), findsOneWidget);
  });

  testWidgets('products filter, add to bag and open detail', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(const GlowLensApp(home: AppShell(initialTab: 3)));
    await settle(tester, 3000);

    expect(find.text('Essentials'), findsOneWidget);
    expect(find.text('Advanced Retinol Cream'), findsOneWidget);

    await tester.tap(find.text('Evening').first);
    await settle(tester, 1500);

    await tester.tap(
      find.descendant(of: find.widgetWithText(ProductCard, 'Peptide Power Serum'), matching: glyph(Glyph.plus)),
    );
    await settle(tester, 1600);
    expect(Bag.instance.count, 1);

    await tester.tap(find.text('Peptide Power Serum'));
    await settle(tester, 1800);
    expect(find.byType(ProductDetail), findsOneWidget);
    expect(find.text('Key ingredients'), findsOneWidget);
    await settle(tester, 1000);
  });

  testWidgets('sparkle button opens the scanner from another tab', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(const GlowLensApp(home: AppShell(initialTab: 4)));
    await settle(tester, 2000);
    expect(find.text('Wilson Carter'), findsOneWidget);

    await tester.tap(find.byType(SparkleMark));
    await settle(tester, 2500);
    expect(find.byType(ScanScreen), findsOneWidget);
    expect(find.text('Scan Your Face'), findsOneWidget);
    await settle(tester, 1000);
  });

  for (final size in const [Size(360, 640), Size(360, 740), Size(412, 915)]) {
    testWidgets('every tab lays out on ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      for (final tab in const [0, 1, 3, 4]) {
        await tester.pumpWidget(
          GlowLensApp(
            key: ValueKey(tab),
            home: AppShell(initialTab: tab),
            simulateDevice: true,
          ),
        );
        await settle(tester, 3200);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
      await settle(tester, 3000);
    });
  }

  testWidgets('scanner buttons stay on screen on a short phone', (tester) async {
    tester.view.physicalSize = const Size(360, 640) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GlowLensApp(home: ScanScreen(), simulateDevice: true));
    await settle(tester, 3200);
    expect(tester.takeException(), isNull);
    final scan = tester.getRect(find.text('Scan Your Face'));
    final upload = tester.getRect(find.text('Upload Photo'));
    expect(scan.bottom, lessThan(upload.top));
    expect(upload.bottom, lessThan(640 - 20));
    await tester.pumpWidget(const SizedBox());
    await settle(tester, 3000);
  });
}
