import 'package:flutter/material.dart';
import '../langue/ecran_langue_maternelle.dart';
import '../../services/audio_service.dart';

class EcranSplash extends StatefulWidget {
  const EcranSplash({super.key});

  @override
  State<EcranSplash> createState() => _EcranSplashState();
}

class _EcranSplashState extends State<EcranSplash> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(_shimmerController);

    _mainController.forward();
    AudioService.jouerSonVictoire();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const EcranLangueMaternelle(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5), Color(0xFF312E81)],
          ),
        ),
        child: Stack(
          children: [
            // Cercles décoratifs animés
            _buildAnimatedCircle(top: -50, right: -50, size: 250, opacity: 0.1),
            _buildAnimatedCircle(bottom: -80, left: -80, size: 300, opacity: 0.05),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo avec Shimmer et Glow
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withValues(alpha: 0.4),
                                  blurRadius: 50,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              'assets/images/Logo.png',
                              height: 180,
                              width: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Overlay Shimmer
                          AnimatedBuilder(
                            animation: _shimmerAnimation,
                            builder: (context, child) {
                              return ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    stops: [
                                      _shimmerAnimation.value - 0.1,
                                      _shimmerAnimation.value,
                                      _shimmerAnimation.value + 0.1
                                    ],
                                    colors: [
                                      Colors.white.withValues(alpha: 0.0),
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.srcIn,
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Nom de l'app avec effet premium
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'CODELINGO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 3,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Apprends à coder en t\'amusant',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Chargement discret
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCircle({double? top, double? right, double? bottom, double? left, required double size, required double opacity}) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
