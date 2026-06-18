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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MascotteAnimee(
                    imagePath: 'assets/images/joyeuse.png',
                    height: 180,
                    width: 180,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    TraductionService.t('lecon_terminee'),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF58CC02)),
                  ),
                  const SizedBox(height: 40),
                  
                  // Cartes de score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRewardCard('⚡', widget.xpGagnee.toString(), 'TOTAL XP', Colors.orange),
                      _buildRewardCard('💎', widget.gemmesGagnees.toString(), 'GEMS', Colors.blue),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                  
                  BoutonDuo(
                    texte: TraductionService.t('continuer'),
                    couleur: const Color(0xFF58CC02),
                    onPressed: () => Navigator.pop(context),
                  ),
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
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
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
