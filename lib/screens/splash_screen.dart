import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../graph/graph_controller.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  late Animation<double> _pulseGlow;

  @override
  void initState() {
    super.initState();

    // 1. Fade-in animation for title and subtitle
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // 2. Scale-in animation for the logo
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleIn = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // 3. Pulsating animation for the glow effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseGlow = Tween<double>(begin: 8.0, end: 24.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _scaleController.forward();
    Timer(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });

    // Navigate to HomeScreen after delay
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GraphController>(context);
    final bool isDark = controller.isDarkMode;

    final primaryColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1);
    final secondaryColor = isDark ? const Color(0xFFBD00FF) : const Color(0xFF7B1FA2);
    final backgroundColor = isDark ? const Color(0xFF0A0D14) : const Color(0xFFF3F5F9);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Cyberpunk Grid Background
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.04 : 0.02,
              child: GridPaper(
                color: isDark ? Colors.blueGrey : Colors.indigo,
                interval: 80,
                divisions: 2,
                subdivisions: 4,
              ),
            ),
          ),
          
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withOpacity(0.08),
              ),
            ),
          ),

          // Central Logo and Text Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Glowing Logo
                AnimatedBuilder(
                  animation: _pulseGlow,
                  builder: (context, child) {
                    return ScaleTransition(
                      scale: _scaleIn,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF111422) : Colors.white,
                          border: Border.all(
                            color: primaryColor.withOpacity(0.8),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(isDark ? 0.4 : 0.25),
                              blurRadius: _pulseGlow.value,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: secondaryColor.withOpacity(isDark ? 0.2 : 0.12),
                              blurRadius: _pulseGlow.value * 1.5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.hub_outlined,
                            size: 64,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Animated App Title & Subtitle
                FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          'MusicGraph AI',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Explora la Ciencia de las Conexiones Musicales',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                // Tiny aesthetic loading indicator
                FadeTransition(
                  opacity: _fadeIn,
                  child: SizedBox(
                    width: 160,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            color: primaryColor,
                            backgroundColor: isDark 
                                ? Colors.white.withOpacity(0.08) 
                                : Colors.black.withOpacity(0.06),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Cargando base de datos...',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: subtitleColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Footer
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeIn,
              child: Center(
                child: Text(
                  'MusicGraph AI • Proyecto Académico',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: subtitleColor.withOpacity(0.5),
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
