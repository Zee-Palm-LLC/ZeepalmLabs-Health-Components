import 'package:flutter/material.dart';

import 'chat/chat_screen.dart';
import 'core/canvas.dart';
import 'core/diary.dart';
import 'core/motion.dart';
import 'core/palette.dart';

class MomoApp extends StatefulWidget {
  const MomoApp({super.key, this.home, this.diary});

  final Widget? home;
  final Diary? diary;

  @override
  State<MomoApp> createState() => _MomoAppState();
}

class _MomoAppState extends State<MomoApp> {
  late final Diary _diary = widget.diary ?? Diary();

  @override
  void dispose() {
    if (widget.diary == null) _diary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DiaryScope(
      diary: _diary,
      child: MaterialApp(
        title: 'Momo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Shade.ground,
          fontFamily: 'Inter',
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Shade.coral,
            selectionColor: Shade.peach.withValues(alpha: 0.3),
            selectionHandleColor: Shade.coral,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Shade.coral, surface: Shade.ground),
        ),
        builder: (context, child) => ClockHost(child: DesignCanvas(child: child!)),
        home: widget.home ?? const ChatScreen(),
      ),
    );
  }
}
