import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../composants/index.dart';

class EcranResultat extends StatefulWidget {
  final int xpGagnes;
  final int gemmesGagnes;

  const EcranResultat({
    super.key,
    required this.xpGagnes,
    required this.gemmesGagnes,
  });

  @override
  State<EcranResultat> createState() => _EcranResultatState();
}

class _EcranResultatState extends State<EcranResultat> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Leçon terminée !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const MascotteAnimee(
                    imagePath: 'assets/images/joyeuse.png',
                    height: 220,
                    width: 220,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('XP', widget.xpGagnes.toString(), Colors.orange),
                      _buildStatCard(
                        'GEMMES',
                        widget.gemmesGagnes.toString(),
                        Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  BoutonDuo(
                    texte: 'Terminer',
                    onPressed: () {
                      Navigator.pop(context); // Retour à l'accueil
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Effet de Confettis
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
