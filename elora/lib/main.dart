import 'package:elora/screens/welcome/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF8FAFC),
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const Elora());
}

class Elora extends StatelessWidget {
  const Elora({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elora',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      scrollBehavior: ScrollBehavior().copyWith(
        overscroll: false,
        physics: const BouncingScrollPhysics(),
      ),
      home: WelcomeScreen(),
    );
  }
}
