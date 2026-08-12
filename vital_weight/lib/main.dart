import 'package:flutter/material.dart';
import 'package:vital_weight/screens/weight/weight_screen.dart';

void main() {
  runApp(const WeightApp());
}

class WeightApp extends StatelessWidget {
  const WeightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitalWeight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Text',
        useMaterial3: true,
      ),
      home: const CurrentWeightScreen(),
    );
  }
}
