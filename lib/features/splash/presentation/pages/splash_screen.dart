import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../home/presentation/home_screen.dart';
import '../../../home/presentation/pages/conversation_mode_screen.dart';
import '../../../language/presentation/pages/language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController logoController;
  late AnimationController particlesController;

  late Animation<double> logoScale;
  late Animation<double> logoOpacity;

  @override
  void initState() {
    super.initState();

    logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    logoScale = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: logoController, curve: Curves.easeInOut),
    );

    logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: logoController, curve: Curves.easeIn),
    );

    logoController.forward();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();

    final savedLang = prefs.getString("lang");
    final savedName = prefs.getString("name");
    final savedGender = prefs.getString("gender");
    final savedAge = prefs.getInt("age");

    /// 🧠 1. PAS DE LANGUE → écran langue
    if (savedLang == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LanguageSelectionScreen(),
        ),
      );
      return;
    }

    /// 🧠 2. LANGUE OK MAIS PAS DE PROFIL → Home
    if (savedName == null || savedGender == null || savedAge == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
      return;
    }

    /// 🧠 3. TOUT EST OK → DIRECT MODE SCREEN 🚀
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationModeScreen(
          language: savedLang,
          name: savedName,
          gender: savedGender,
          age: savedAge,
        ),
      ),
    );
  }

  @override
  void dispose() {
    logoController.dispose();
    particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1C3D),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: particlesController,
            builder: (context, _) {
              return CustomPaint(
                painter: ParticlePainter(particlesController.value),
                size: Size.infinite,
              );
            },
          ),
          Center(
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 120,
                    spreadRadius: 40,
                  )
                ],
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: logoOpacity.value,
                  child: Transform.scale(
                    scale: logoScale.value,
                    child: child,
                  ),
                );
              },
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 80,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/images/logo1_splash.png",
                    fit: BoxFit.contain,
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

class ParticlePainter extends CustomPainter {

  final double progress;
  final Random random = Random();

  ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15);

    for (int i = 0; i < 40; i++) {

      final dx = random.nextDouble() * size.width;
      final dy = (random.nextDouble() * size.height + progress * 200) % size.height;

      canvas.drawCircle(
        Offset(dx, dy),
        random.nextDouble() * 2 + 1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}