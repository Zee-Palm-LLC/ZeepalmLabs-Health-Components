import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/motion.dart';
import 'core/nav_bar.dart';
import 'core/sheet.dart';
import 'core/status_bar.dart';
import 'core/widgets.dart';
import 'data/visit.dart';
import 'features/home_screen.dart';
import 'features/leave_screen.dart';
import 'features/profile_screen.dart';
import 'features/queue_screen.dart';
import 'features/sheets.dart';
import 'features/turn_screen.dart';

enum Sheet { token, swap, visit }

class QueueFlow extends StatefulWidget {
  const QueueFlow({super.key, this.initial = 0});

  final int initial;

  @override
  State<QueueFlow> createState() => FlowState();
}

class FlowState extends State<QueueFlow> {
  static const home = 0;
  static const queue = 1;
  static const route = 2;
  static const turn = 3;
  static const profile = 4;

  final visit = Visit();
  late int step = widget.initial;
  late int tab = _tabOf(widget.initial);
  Sheet? sheet;
  String? _toast;
  int _toastSerial = 0;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initial != home) visit.take();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    visit.dispose();
    super.dispose();
  }

  static int _tabOf(int step) {
    return switch (step) {
      queue => 1,
      route => 2,
      profile => 3,
      _ => 0,
    };
  }

  void go(int to) {
    if (!mounted) return;
    if ((to == queue || to == route) && !visit.hasToken) {
      open(Sheet.token);
      setState(() => tab = _tabOf(step));
      return;
    }
    if (to == step) return;
    darkChrome.value = to == turn;
    setState(() {
      step = to;
      tab = _tabOf(to);
      sheet = null;
    });
  }

  void open(Sheet value) => setState(() => sheet = value);

  void close() {
    if (sheet == null) return;
    setState(() => sheet = null);
  }

  void toast(String message) {
    _toastTimer?.cancel();
    setState(() {
      _toast = message;
      _toastSerial++;
    });
    _toastTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  void back() {
    if (sheet != null) {
      close();
      return;
    }
    go(switch (step) {
      turn || route => queue,
      _ => home,
    });
  }

  void _tab(int index) {
    if (index == tab) return;
    final target = [home, queue, route, profile][index];
    if ((target == queue || target == route) && !visit.hasToken) {
      open(Sheet.token);
      return;
    }
    setState(() => tab = index);
    Future.delayed(const Duration(milliseconds: 260), () => go(target));
  }

  void _issued() {
    visit.take();
    close();
    Future.delayed(const Duration(milliseconds: 200), () => go(queue));
  }

  void _swapped(int places) {
    visit.sim.moveBack(places);
    close();
    toast(places == 1 ? 'You let 1 person go ahead' : 'You let $places people go ahead');
  }

  void _cancelled() {
    visit.finish();
    close();
    go(home);
    toast('Token cancelled');
  }

  void _checkedIn() {
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      visit.finish();
      go(home);
      toast('Checked in · Room 3 at 10:41 AM');
    });
  }

  Widget? _sheet() {
    return switch (sheet) {
      Sheet.token => TokenSheet(key: const ValueKey('token'), visit: visit, onIssued: _issued),
      Sheet.swap => SwapSheet(key: const ValueKey('swap'), visit: visit, onSwapped: _swapped),
      Sheet.visit => VisitSheet(key: const ValueKey('visit'), visit: visit, onCancel: _cancelled),
      null => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dark = step == turn;
    final screen = switch (step) {
      home => HomeScreen(
        key: const ValueKey(home),
        visit: visit,
        onToken: () => open(Sheet.token),
        onQueue: () => go(queue),
      ),
      queue => QueueScreen(key: const ValueKey(queue), visit: visit, onRoute: () => go(route)),
      route => LeaveScreen(
        key: const ValueKey(route),
        onBack: () => go(queue),
        onArrive: () => go(turn),
        onSwap: () => open(Sheet.swap),
        onInfo: () => open(Sheet.visit),
        onLeave: visit.leave,
      ),
      profile => ProfileScreen(
        key: const ValueKey(profile),
        visit: visit,
        onQueue: () => go(queue),
        onToken: () => open(Sheet.token),
      ),
      _ => TurnScreen(key: const ValueKey(turn), onDone: _checkedIn),
    };
    return PopScope(
      canPop: step == home && sheet == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: DesignCanvas(
            background: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
              child: dark ? const TurnBackdrop(key: ValueKey('dark')) : const HomeBackdrop(key: ValueKey('light')),
            ),
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                TweenAnimationBuilder<double>(
                  key: ValueKey(step),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  child: SizedBox.expand(child: screen),
                  builder: (context, t, child) => Opacity(opacity: t, child: child),
                ),
                _NavLayer(visible: step == home || step == queue || step == profile, index: tab, onSelect: _tab),
                SheetLayer(sheet: _sheet(), onDismiss: close),
                ToastLayer(message: _toast, serial: _toastSerial),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLayer extends StatelessWidget {
  const _NavLayer({required this.visible, required this.index, required this.onSelect});

  final bool visible;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scope = CanvasScope.of(context);
    return Positioned(
      left: -scope.bleed,
      right: -scope.bleed,
      top: scope.barTop,
      bottom: 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: visible ? 1 : 0),
          duration: const Duration(milliseconds: 460),
          curve: visible ? Curves.easeOutCubic : Curves.easeInCubic,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              border: Border(top: BorderSide(color: Color(0xFFE6F0ED))),
              boxShadow: [BoxShadow(color: Color(0x140F3B3A), blurRadius: 24, offset: Offset(0, -6))],
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: QueueNavBar(index: index, onSelect: onSelect),
            ),
          ),
          builder: (context, t, child) {
            return Transform.translate(
              offset: Offset(0, lerp(DesignCanvas.barHeight + scope.barInset + 30, 0, t)),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
