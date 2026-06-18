import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../../fournisseurs/progression_fournisseur.dart';
import '../../composants/index.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../utils/theme.dart';

class EcranRecompense extends StatefulWidget {
  final int gemmesGagnees;
  final String titre;

  const EcranRecompense({
    super.key, 
    required this.gemmesGagnees, 
    required this.titre
  });

  @override
  State<EcranRecompense> createState() => _EcranRecompenseState();
}

class _EcranRecompenseState extends State<EcranRecompense> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late AnimationController _appearController;
  bool _estOuvert = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _appearController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    _appearController.dispose();
    super.dispose();
  }

  Future<void> _ouvrirCoffre() async {
    if (_estOuvert) return;

    final progression = Provider.of<ProgressionFournisseur>(context, listen: false);

    // Animation de secousse avant l'ouverture
    for (int i = 0; i < 3; i++) {
      HapticService.click();
      await _shakeController.forward();
      await _shakeController.reverse();
    }

    if (!mounted) return;

    setState(() => _estOuvert = true);
    
    HapticService.success();
    AudioService.jouerSonVictoire();
    Future.delayed(const Duration(milliseconds: 500), () => AudioService.jouerSonGemmes());
    _confettiController.play();

    progression.ajouterGemmes(widget.gemmesGagnees);
    progression.ajouterXP(50); // Bonus de fin de leçon
    progression.debloquerSucces('Premier Pas');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.backgroundDark],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.amber, Colors.orange, Colors.yellow, Colors.white],
            ),
            
            FadeTransition(
              opacity: _appearController,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.titre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 32, 
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: Colors.blueAccent, blurRadius: 20)],
                      ),
                    ),
                    const SizedBox(height: 80),
                    
                    GestureDetector(
                      onTap: _ouvrirCoffre,
                      child: AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) {
                          double offset = _shakeController.value * 10;
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: _buildTreasureChest(),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    if (!_estOuvert)
                      const Text(
                        'TOUCHE LE COFFRE !',
                        style: TextStyle(
                          color: Colors.amber, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 2,
                        ),
                      ),
                    
                    if (_estOuvert) ...[
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('💎', style: TextStyle(fontSize: 40)),
                                    const SizedBox(width: 12),
                                    Text(
                                      '+${widget.gemmesGagnees}',
                                      style: const TextStyle(
                                        color: Colors.white, 
                                        fontSize: 48, 
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                BoutonDuo(
                                  texte: 'TERMINER',
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreasureChest() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _estOuvert ? Colors.amber.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
        boxShadow: [
          if (_estOuvert)
            BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 50, spreadRadius: 20),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: _estOuvert 
              ? Image.asset('assets/images/joyeuse.png', key: const ValueKey('open'), height: 150)
              : const Icon(Icons.redeem_rounded, key: ValueKey('closed'), size: 120, color: Colors.amber),
        ),
      ),
    );
  }
}
