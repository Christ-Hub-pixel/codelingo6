import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../composants/index.dart';
import '../../services/traduction_service.dart';
import '../../services/audio_service.dart';

class EcranSuccesLecon extends StatefulWidget {
  final int xpGagnee;
  final int gemmesGagnees;

  const EcranSuccesLecon({
    super.key,
    required this.xpGagnee,
    required this.gemmesGagnees,
  });

  @override
  State<EcranSuccesLecon> createState() => _EcranSuccesLeconState();
}

class _EcranSuccesLeconState extends State<EcranSuccesLecon> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    AudioService.jouerSonSucces();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B), // Fond sombre plus élégant pour faire ressortir la lumière
      body: Stack(
        children: [
          // Effet de lumière de fond
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amberAccent.withValues(alpha: 0.5),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          'assets/images/recompense.png',
                          height: 220,
                          width: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, opacity, child) {
                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - opacity)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          TraductionService.t('lecon_terminee').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.amberAccent,
                            letterSpacing: 2,
                            shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Super travail ! Voici tes récompenses :",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Cartes de score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRewardCard('⚡', widget.xpGagnee.toString(), 'XP GAGNÉE', Colors.orangeAccent),
                      _buildRewardCard('💎', widget.gemmesGagnees.toString(), 'GEMMES', Colors.cyanAccent),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  BoutonDuo(
                    texte: TraductionService.t('continuer').toUpperCase(),
                    couleur: const Color(0xFF58CC02),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Confettis
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              maxBlastForce: 100,
              minBlastForce: 80,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.yellow, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(String icon, String value, String label, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}
