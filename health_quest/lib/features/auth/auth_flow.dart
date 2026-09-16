import 'package:flutter/widgets.dart';

import '../../core/design.dart';
import '../shell/app_shell.dart';

PageRouteBuilder<void> authRoute(Widget page) => PageRouteBuilder<void>(
  transitionDuration: const Duration(milliseconds: 560),
  reverseTransitionDuration: const Duration(milliseconds: 360),
  pageBuilder: (BuildContext context, Animation<double> a1, Animation<double> a2) =>
      page,
  transitionsBuilder:
      (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondary,
        Widget child,
      ) {
        final a = CurvedAnimation(parent: animation, curve: D.emphasized);
        return FadeTransition(
          opacity: a,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.03, end: 1).animate(a),
            child: child,
          ),
        );
      },
);

void swapAuthPage(BuildContext context, Widget page) =>
    Navigator.of(context).pushReplacement<void, void>(authRoute(page));

void enterGame(BuildContext context) => Navigator.of(context)
    .pushAndRemoveUntil<void>(authRoute(const AppShell()), (Route<dynamic> r) => false);

final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
final RegExp _heroName = RegExp(r'^[A-Za-z0-9 _]+$');

String? validateEmail(String value) {
  final v = value.trim();
  if (v.isEmpty) return 'Enter your email.';
  if (!_email.hasMatch(v)) return 'That email does not look right.';
  return null;
}

String? validateHeroName(String value) {
  final v = value.trim();
  if (v.isEmpty) return 'Your hero needs a name.';
  if (v.length < 3) return 'At least 3 characters.';
  if (v.length > 16) return 'Keep it to 16 characters.';
  if (!_heroName.hasMatch(v)) return 'Letters, numbers and spaces only.';
  return null;
}

String? validateNewPassword(String value) {
  if (value.isEmpty) return 'Choose a password.';
  if (value.length < 8) return 'At least 8 characters.';
  return null;
}

String? validatePassword(String value) =>
    value.isEmpty ? 'Enter your password.' : null;
