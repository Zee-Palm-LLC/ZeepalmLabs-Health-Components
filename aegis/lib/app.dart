import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'emergency/arrival_screen.dart';
import 'emergency/preview_data.dart';
import 'emergency/responder_tracking_screen.dart';
import 'emergency/sos_home_screen.dart';
import 'theme/aegis_theme.dart';
import 'theme/motion.dart';

abstract final class AegisRoutes {
  static const home = '/';
  static const tracking = '/tracking';
  static const arrived = '/arrived';
}

/// Opens straight onto a screen for design review, e.g.
/// `flutter run --dart-define=AEGIS_SCREEN=/arrived`.
const _initialRoute = String.fromEnvironment(
  'AEGIS_SCREEN',
  defaultValue: AegisRoutes.home,
);

class AegisApp extends StatelessWidget {
  const AegisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aegis',
      debugShowCheckedModeBanner: false,
      theme: buildAegisTheme(),
      initialRoute: _initialRoute,
      scrollBehavior: const ScrollBehavior()
          .copyWith(overscroll: false, physics: const BouncingScrollPhysics()),
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AegisColors.background,
        ),
        child: child!,
      ),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<void> _onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AegisRoutes.tracking => _slideUp(settings, _tracking),
      AegisRoutes.arrived => _popUp(settings, _arrival),
      // Anything unrecognised, including the initial route, lands on home.
      _ => _fade(
          RouteSettings(
            name: AegisRoutes.home,
            arguments: settings.arguments,
          ),
          _home,
        ),
    };
  }

  Widget _home(BuildContext context) => SosHomeScreen(
        heartRate: PreviewData.elevatedHeartRate,
        location: PreviewData.location,
        contacts: PreviewData.contacts,
        onAlertActivated: () =>
            Navigator.of(context).pushNamed(AegisRoutes.tracking),
      );

  Widget _tracking(BuildContext context) => ResponderTrackingScreen(
        dispatch: PreviewData.dispatch,
        onBack: () => Navigator.of(context).maybePop(),
        // Swaps rather than stacks: once the responder is here, there is
        // nothing to go back to.
        onArrived: () =>
            Navigator.of(context).pushReplacementNamed(AegisRoutes.arrived),
      );

  Widget _arrival(BuildContext context) => ArrivalScreen(
        heartRate: PreviewData.stableHeartRate,
        previousBpm: PreviewData.elevatedHeartRate.bpm,
        notifiedContacts: PreviewData.notifiedContacts,
        // The emergency is over, so the stack goes with it.
        onClose: () => Navigator.of(context).pushNamedAndRemoveUntil(
          AegisRoutes.home,
          (route) => false,
        ),
      );
}

/// Home: nothing to travel from, so it simply resolves.
PageRoute<void> _fade(RouteSettings settings, WidgetBuilder builder) {
  return PageRouteBuilder<void>(
    settings: settings,
    transitionDuration: AegisMotion.medium,
    reverseTransitionDuration: AegisMotion.medium,
    pageBuilder: (context, animation, secondary) => builder(context),
    transitionsBuilder: (context, animation, secondary, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// Alert sent: the tracking view comes up over the home screen, which sinks
/// back a little as it goes.
PageRoute<void> _slideUp(RouteSettings settings, WidgetBuilder builder) {
  return PageRouteBuilder<void>(
    settings: settings,
    transitionDuration: AegisMotion.slow,
    reverseTransitionDuration: AegisMotion.medium,
    pageBuilder: (context, animation, secondary) => builder(context),
    transitionsBuilder: (context, animation, secondary, child) {
      final eased = CurvedAnimation(
        parent: animation,
        curve: AegisMotion.emphasized,
        reverseCurve: AegisMotion.exit,
      );
      return SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.16),
          end: Offset.zero,
        ).animate(eased),
        child: FadeTransition(opacity: eased, child: child),
      );
    },
  );
}

/// Arrival: scales up into place, the way a confirmation should land.
PageRoute<void> _popUp(RouteSettings settings, WidgetBuilder builder) {
  return PageRouteBuilder<void>(
    settings: settings,
    transitionDuration: AegisMotion.slow,
    reverseTransitionDuration: AegisMotion.medium,
    pageBuilder: (context, animation, secondary) => builder(context),
    transitionsBuilder: (context, animation, secondary, child) {
      final eased = CurvedAnimation(
        parent: animation,
        curve: AegisMotion.emphasized,
        reverseCurve: AegisMotion.exit,
      );
      return FadeTransition(
        opacity: eased,
        child: ScaleTransition(
          scale: Tween(begin: 0.92, end: 1.0).animate(eased),
          child: child,
        ),
      );
    },
  );
}
