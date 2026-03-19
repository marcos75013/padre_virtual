import 'package:flutter/material.dart';
import 'features/splash/presentation/pages/splash_screen.dart';

void main() {
  runApp(const PadreApp());
}

class PadreApp extends StatelessWidget {
  const PadreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}