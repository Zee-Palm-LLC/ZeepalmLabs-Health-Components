import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_quest/core/palette.dart';
import 'package:health_quest/core/shaders.dart';
import 'package:health_quest/core/type.dart';
import 'package:health_quest/data/quests.dart';
import 'package:health_quest/features/auth/main_quest_screen.dart';
import 'package:health_quest/features/leaderboard/leaderboard_screen.dart';
import 'package:health_quest/features/onboarding/onboarding_screen.dart';
import 'package:health_quest/features/quest/quest_screen.dart';
import 'package:health_quest/features/shell/app_shell.dart';
import 'package:health_quest/widgets/hud.dart';
import 'package:health_quest/widgets/nav_bar.dart';
import 'package:health_quest/widgets/painters/quest_icons.dart';

const Size canvas = Size(430, 932);
const double pixelRatio = 3;
const Size device = Size(393, 852);
const String outputDir = 'store/app_store/iphone_6_9';
const String emojiFont = 'C:/Windows/Fonts/seguiemj.ttf';

class Badge {
  const Badge({
    required this.label,
    required this.glyph,
    required this.tone,
    required this.top,
    this.left,
    this.right,
    this.tilt = -0.06,
  });

  final String label;
  final QuestGlyph glyph;
  final Color tone;
  final double top;
  final double? left;
  final double? right;
  final double tilt;
}

class Shot {
  const Shot({
    required this.file,
    required this.kicker,
    required this.lineOne,
    required this.lineTwo,
    required this.subtitle,
    required this.tone,
    required this.screen,
    required this.badges,
    this.prepare,
    this.spendsXp = false,
  });

  final String file;
  final String kicker;
  final String lineOne;
  final String lineTwo;
  final String subtitle;
  final Color tone;
  final Widget screen;
  final List<Badge> badges;
  final Future<void> Function(WidgetTester tester)? prepare;
  final bool spendsXp;
}

final List<Shot> shots = <Shot>[
  const Shot(
    file: '01_level_up',
    kicker: 'HEALTH QUEST',
    lineOne: 'YOUR HEALTH IS',
    lineTwo: 'NOW AN RPG',
    subtitle: 'Every healthy choice earns you XP.',
    tone: Quests.purple,
    screen: OnboardingScreen(playIntro: false),
    badges: <Badge>[
      Badge(label: '+100 XP', glyph: QuestGlyph.shield, tone: Quests.gold, top: 470, right: 14, tilt: 0.07),
    ],
  ),
  const Shot(
    file: '02_daily_quests',
    kicker: 'DAILY QUESTS',
    lineOne: 'TURN HABITS',
    lineTwo: 'INTO QUESTS',
    subtitle: 'Water, steps and calm. All worth XP.',
    tone: Quests.green,
    screen: AppShell(),
    badges: <Badge>[
      Badge(label: '7 DAY STREAK', glyph: QuestGlyph.flame, tone: Quests.gold, top: 448, right: 8, tilt: 0.06),
      Badge(label: '+75 XP', glyph: QuestGlyph.footprints, tone: Quests.green, top: 676, left: 12),
    ],
  ),
  Shot(
    file: '03_victory',
    kicker: 'EARN REWARDS',
    lineOne: 'CLAIM',
    lineTwo: 'EVERY VICTORY',
    subtitle: 'Finish a quest. Cash in the XP.',
    tone: Quests.gold,
    screen: QuestScreen(quest: Quest.today.last),
    spendsXp: true,
    badges: const <Badge>[
      Badge(label: 'X2 STREAK BONUS', glyph: QuestGlyph.flame, tone: Quests.blueBright, top: 300, right: 10, tilt: 0.06),
    ],
    prepare: (WidgetTester t) async {
      final claim = find.text('CLAIM +60 XP');
      await t.scrollUntilVisible(claim, 200, scrollable: find.byType(Scrollable).first);
      await t.pump(const Duration(milliseconds: 300));
      await t.tap(claim);
      await t.pump();
      await t.pump(const Duration(milliseconds: 2600));
    },
  ),
  const Shot(
    file: '04_stats',
    kicker: 'CHARACTER SHEET',
    lineOne: 'LEVEL UP',
    lineTwo: 'FOUR STATS',
    subtitle: 'Physical, mental, energy and hydration.',
    tone: Quests.blue,
    screen: AppShell(initialTab: NavTab.stats),
    badges: <Badge>[
      Badge(label: 'POWER 50', glyph: QuestGlyph.bars, tone: Quests.blueBright, top: 482, left: 10),
      Badge(label: 'HYDRATION LV 16', glyph: QuestGlyph.drop, tone: Quests.blue, top: 772, right: 10, tilt: 0.05),
    ],
  ),
  const Shot(
    file: '05_rewards',
    kicker: 'REWARDS VAULT',
    lineOne: 'UNLOCK',
    lineTwo: 'LEGENDARY BADGES',
    subtitle: 'Spend your XP on badges that stay with you.',
    tone: Quests.gold,
    screen: AppShell(initialTab: NavTab.rewards),
    badges: <Badge>[
      Badge(label: 'BADGE UNLOCKED', glyph: QuestGlyph.trophy, tone: Quests.gold, top: 748, left: 10),
    ],
  ),
  const Shot(
    file: '06_leaderboard',
    kicker: 'WEEKLY LEAGUE',
    lineOne: 'OUTRANK',
    lineTwo: 'YOUR FRIENDS',
    subtitle: 'Climb the board. Challenge your crew.',
    tone: Quests.rose,
    screen: LeaderboardScreen(),
    badges: <Badge>[
      Badge(label: 'CHALLENGE SENT', glyph: QuestGlyph.swords, tone: Quests.rose, top: 782, left: 10),
      Badge(label: '#1 NOVA', glyph: QuestGlyph.crown, tone: Quests.gold, top: 360, right: 12, tilt: 0.07),
    ],
  ),
  Shot(
    file: '07_choose_path',
    kicker: 'START YOUR JOURNEY',
    lineOne: 'CHOOSE',
    lineTwo: 'YOUR PATH',
    subtitle: 'Move, hydrate, calm or sleep. You set the pace.',
    tone: Quests.blueBright,
    screen: const MainQuestScreen(),
    badges: const <Badge>[
      Badge(label: 'STARTER QUEST', glyph: QuestGlyph.swords, tone: Quests.blueBright, top: 318, right: 10, tilt: 0.06),
    ],
    prepare: (WidgetTester t) async {
      await t.tap(find.text('HYDRATE'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 800));
    },
  ),
  const Shot(
    file: '08_player_card',
    kicker: 'PLAYER CARD',
    lineOne: 'SHOW OFF',
    lineTwo: 'YOUR PROGRESS',
    subtitle: 'Badges, achievements and your streak.',
    tone: Quests.green,
    screen: AppShell(initialTab: NavTab.profile),
    badges: <Badge>[
      Badge(label: '148 QUESTS', glyph: QuestGlyph.swords, tone: Quests.green, top: 700, right: 10, tilt: 0.06),
    ],
  ),
];

Future<void> loadFont(String family, List<Future<ByteData>> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    loader.addFont(file);
  }
  await loader.load();
}

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: T.body,
  fontFamilyFallback: const <String>['Emoji'],
  scaffoldBackgroundColor: Night.voidBlack,
  colorScheme: const ColorScheme.dark(
    primary: Spectrum.violet,
    secondary: Spectrum.blue,
    surface: Night.deep,
  ),
  splashFactory: NoSplash.splashFactory,
  highlightColor: Colors.transparent,
);

void main() {
  testWidgets('App Store screenshots', (WidgetTester t) async {
    t.view.physicalSize = canvas * pixelRatio;
    t.view.devicePixelRatio = pixelRatio;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    await t.runAsync(() async {
      await loadFont('Saira', <Future<ByteData>>[
        rootBundle.load('assets/fonts/Saira-Variable.ttf'),
        rootBundle.load('assets/fonts/Saira-Italic-Variable.ttf'),
      ]);
      await loadFont('Inter', <Future<ByteData>>[
        rootBundle.load('assets/fonts/Inter-Variable.ttf'),
      ]);
      final emoji = File(emojiFont);
      if (emoji.existsSync()) {
        await loadFont('Emoji', <Future<ByteData>>[
          Future<ByteData>.value(ByteData.sublistView(emoji.readAsBytesSync())),
        ]);
      }
      await Shaders.warmUp();
    });

    Directory(outputDir).createSync(recursive: true);
    final frame = GlobalKey();

    final order = <Shot>[
      ...shots.where((Shot s) => !s.spendsXp),
      ...shots.where((Shot s) => s.spendsXp),
    ];
    for (final shot in order) {
      await t.pumpWidget(const SizedBox.shrink());
      await t.pumpWidget(
        RepaintBoundary(
          key: frame,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: StoreShot(shot: shot),
          ),
        ),
      );
      await t.runAsync(() async {
        for (final asset in <String>[
          'assets/hero/face.png',
          'assets/hero/hero.png',
          'assets/hero/plate.png',
        ]) {
          await precacheImage(AssetImage(asset), frame.currentContext!);
        }
      });
      await t.pump();
      await t.pump(const Duration(milliseconds: 3000));
      await shot.prepare?.call(t);
      await t.pump(const Duration(milliseconds: 16));

      await t.runAsync(() async {
        final boundary =
            frame.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$outputDir/${shot.file}.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      expect(t.takeException(), isNull, reason: shot.file);
    }
  });
}

class StoreShot extends StatelessWidget {
  const StoreShot({super.key, required this.shot});

  final Shot shot;

  static const double phoneWidth = 326;
  static const double phoneTop = 222;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: const MediaQueryData(size: canvas, devicePixelRatio: pixelRatio),
      child: SizedBox.fromSize(
        size: canvas,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(painter: BackdropPainter(shot.tone)),
            ),
            Positioned(
              top: 44,
              left: 24,
              right: 24,
              child: Headline(shot: shot),
            ),
            Positioned(
              top: phoneTop,
              left: (canvas.width - phoneWidth) / 2,
              child: PhoneFrame(
                width: phoneWidth,
                glow: shot.tone,
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: appTheme(),
                  builder: (BuildContext context, Widget? child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: device,
                      padding: const EdgeInsets.only(top: 54, bottom: 30),
                      viewPadding: const EdgeInsets.only(top: 54, bottom: 30),
                      textScaler: TextScaler.noScaling,
                    ),
                    child: child!,
                  ),
                  home: shot.screen,
                ),
              ),
            ),
            for (final badge in shot.badges)
              Positioned(
                top: badge.top,
                left: badge.left,
                right: badge.right,
                child: FloatingBadge(badge: badge),
              ),
          ],
        ),
      ),
    );
  }
}

class Headline extends StatelessWidget {
  const Headline({super.key, required this.shot});

  final Shot shot;

  @override
  Widget build(BuildContext context) {
    final accent = Color.lerp(shot.tone, Ink2.bright, 0.25)!;
    return Column(
      children: <Widget>[
        SizedBox(
          height: 26,
          child: HudPanel(
            cut: 8,
            fill: shot.tone.withValues(alpha: 0.16),
            edge: shot.tone.withValues(alpha: 0.6),
            accent: shot.tone,
            brackets: false,
            glow: 0.35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              widthFactor: 1,
              child: Text(
                shot.kicker,
                style: T.questKicker.copyWith(color: accent, fontSize: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            shot.lineOne,
            style: T.disp(36, weight: 900, letterSpacing: 1.2),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: LinearGradient(
              colors: <Color>[
                Color.lerp(shot.tone, Ink2.bright, 0.35)!,
                shot.tone,
                Spectrum.blue,
              ],
              stops: const <double>[0, 0.55, 1],
            ).createShader,
            child: Text(
              shot.lineTwo,
              style: T.disp(46, weight: 900, letterSpacing: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          shot.subtitle,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: T.text(15, weight: 450, color: Ink2.secondary),
        ),
      ],
    );
  }
}

class PhoneFrame extends StatelessWidget {
  const PhoneFrame({
    super.key,
    required this.width,
    required this.glow,
    required this.child,
  });

  final double width;
  final Color glow;
  final Widget child;

  static const double bezel = 10;

  @override
  Widget build(BuildContext context) {
    final scale = (width - bezel * 2) / device.width;
    final height = device.height * scale + bezel * 2;
    final screenRadius = 55 * scale;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenRadius + bezel),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: glow.withValues(alpha: 0.45),
                    blurRadius: 60,
                    spreadRadius: 2,
                  ),
                  const BoxShadow(
                    color: Color(0xCC000000),
                    blurRadius: 30,
                    offset: Offset(0, 18),
                  ),
                ],
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF4A4E5E),
                    Color(0xFF15161E),
                    Color(0xFF2C2F3B),
                  ],
                ),
                border: Border.all(color: const Color(0x66FFFFFF), width: 1.2),
              ),
            ),
          ),
          Positioned(
            left: 3,
            right: 3,
            top: 3,
            bottom: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(screenRadius + bezel - 3),
              ),
            ),
          ),
          Positioned(
            left: bezel,
            top: bezel,
            right: bezel,
            bottom: bezel,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenRadius),
              child: FittedBox(
                child: SizedBox.fromSize(
                  size: device,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(child: child),
                      const Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: 54,
                        child: IgnorePointer(child: StatusBar()),
                      ),
                      Positioned(
                        bottom: 8,
                        left: (device.width - 140) / 2,
                        child: Container(
                          width: 140,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xE6FFFFFF),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: 52,
          top: 17,
          child: Text(
            '9:41',
            style: T.text(17, weight: 650, color: Colors.white, height: 1),
          ),
        ),
        Positioned(
          top: 11,
          left: (device.width - 124) / 2,
          child: Container(
            width: 124,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        const Positioned(
          right: 30,
          top: 18,
          child: CustomPaint(size: Size(78, 14), painter: StatusIconsPainter()),
        ),
      ],
    );
  }
}

class StatusIconsPainter extends CustomPainter {
  const StatusIconsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white;
    for (var i = 0; i < 4; i++) {
      final h = 4.0 + i * 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * 5.0, size.height - h - 1, 3.2, h),
          const Radius.circular(1),
        ),
        white,
      );
    }
    final wifi = Offset(31, size.height - 1.5);
    for (var i = 0; i < 3; i++) {
      final r = 4.0 + i * 4;
      canvas.drawArc(
        Rect.fromCircle(center: wifi, radius: r),
        -math.pi * 0.75,
        math.pi * 0.5,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..color = Colors.white,
      );
    }
    const body = Rect.fromLTWH(48, 1, 25, 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(3.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x99FFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body.deflate(2), const Radius.circular(2)),
      white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(74.5, 5, 1.8, 4),
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0x99FFFFFF),
    );
  }

  @override
  bool shouldRepaint(StatusIconsPainter oldDelegate) => false;
}

class FloatingBadge extends StatelessWidget {
  const FloatingBadge({super.key, required this.badge});

  final Badge badge;

  @override
  Widget build(BuildContext context) {
    final tone = badge.tone;
    return Transform.rotate(
      angle: badge.tilt,
      child: SizedBox(
        height: 44,
        child: HudPanel(
          cut: 11,
          fill: const Color(0xF20D1020),
          gradient: LinearGradient(
            colors: <Color>[
              tone.withValues(alpha: 0.28),
              tone.withValues(alpha: 0.06),
            ],
          ),
          edge: tone.withValues(alpha: 0.85),
          accent: tone,
          glow: 0.9,
          rail: true,
          bracketLength: 10,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              QuestIcon(
                glyph: badge.glyph,
                size: 20,
                color: tone,
                highlight: Color.lerp(tone, Ink2.bright, 0.55),
              ),
              const SizedBox(width: 9),
              Text(
                badge.label,
                style: T.disp(16, weight: 900, letterSpacing: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackdropPainter extends CustomPainter {
  const BackdropPainter(this.tone);

  final Color tone;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF0B0718), Color(0xFF05060C), Color(0xFF070A18)],
        ).createShader(rect),
    );

    void glow(Offset centre, double radius, Color color, double alpha) {
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: centre, radius: radius)),
      );
    }

    glow(Offset(size.width * 0.5, size.height * 0.52), size.width * 0.95, tone, 0.30);
    glow(Offset(size.width * 0.08, size.height * 0.04), size.width * 0.8, Quests.purple, 0.28);
    glow(Offset(size.width * 0.98, size.height * 0.92), size.width * 0.7, Quests.blue, 0.20);

    final horizon = size.height * 0.64;
    final vanishing = Offset(size.width / 2, horizon);
    final grid = Paint()
      ..strokeWidth = 0.8
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[tone.withValues(alpha: 0), tone.withValues(alpha: 0.22)],
      ).createShader(Rect.fromLTWH(0, horizon, size.width, size.height - horizon));
    for (var i = -10; i <= 10; i++) {
      canvas.drawLine(vanishing, Offset(size.width / 2 + i * 70, size.height), grid);
    }
    for (var k = 1; k < 12; k++) {
      final y = horizon + (size.height - horizon) * math.pow(k / 11, 1.8);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    var seed = 20260916;
    double next() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed / 0x7fffffff;
    }

    for (var i = 0; i < 120; i++) {
      final p = Offset(next() * size.width, next() * size.height);
      final r = 0.4 + next() * 1.2;
      final a = 0.15 + next() * 0.65;
      canvas.drawCircle(p, r, Paint()..color = Colors.white.withValues(alpha: a));
    }
  }

  @override
  bool shouldRepaint(BackdropPainter oldDelegate) => oldDelegate.tone != tone;
}
