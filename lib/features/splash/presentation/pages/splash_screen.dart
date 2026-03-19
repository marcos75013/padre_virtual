import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../home/presentation/home_screen.dart';

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

    logoScale = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: logoController, curve: Curves.easeInOut),
    );

    logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: logoController, curve: Curves.easeIn),
    );

    logoController.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
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

          /// PARTICULES
          AnimatedBuilder(
            animation: particlesController,
            builder: (context, _) {
              return CustomPaint(
                painter: ParticlePainter(particlesController.value),
                size: Size.infinite,
              );
            },
          ),

          /// HALO LUMINEUX
          Center(
            child: Container(
              width: 260,
              height: 260,
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

          /// LOGO + TEXTE
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Image.asset(
                    "assets/padre.png",
                    width: 150,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Padre",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Toujours à votre écoute",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
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