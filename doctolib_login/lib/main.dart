import 'package:doctolib_login/screens/login/components/fade_page_route.dart';
import 'package:doctolib_login/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const DoctolibApp());
}

class DoctolibApp extends StatelessWidget {
  const DoctolibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        title: 'Doctolib Login',
        debugShowCheckedModeBanner: false,
        scrollBehavior: ScrollBehavior().copyWith(
          overscroll: false,
          physics: BouncingScrollPhysics(),
        ),
        theme: ThemeData(
          useMaterial3: true,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: SoftFadePageTransitionsBuilder(),
              TargetPlatform.iOS: SoftFadePageTransitionsBuilder(),
            },
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
