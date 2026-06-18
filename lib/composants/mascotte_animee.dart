import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fournisseurs/progression_fournisseur.dart';
import '../services/audio_service.dart';

class MascotteAnimee extends StatefulWidget {
  final String imagePath;
  final double height;
  final double width;

  const MascotteAnimee({
    super.key,
    required this.imagePath,
    this.height = 120,
    this.width = 120,
  });

  @override
  State<MascotteAnimee> createState() => MascotteAnimeeState();
}

class MascotteAnimeeState extends State<MascotteAnimee> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _jumpController;
  late Animation<double> _jumpAnimation;

  @override
  void initState() {
    super.initState();
    // Animation de flottement continue
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Animation de saut (déclenchée occasionnellement)
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -30), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -30, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _jumpController, curve: Curves.easeInOut));

    _lancerSautsAleatoires();
  }

  void sauter() {
    if (!_jumpController.isAnimating) {
      _jumpController.forward(from: 0);
    }
  }

  void _lancerSautsAleatoires() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: 5 + (5 * (DateTime.now().second % 3)))); // Aléatoire
      if (mounted) {
        _jumpController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _jumpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnimation, _jumpAnimation]),
      builder: (context, child) {
        // Appliquer la tenue si une est équipée
        String currentImagePath = widget.imagePath;
        String? base64Image;
        
        try {
          final progression = context.watch<ProgressionFournisseur>();
          if (progression.tenueActuelle != 'Defaut') {
            currentImagePath = progression.avatarPath;
          } else if (progression.avatarBase64 != null) {
            base64Image = progression.avatarBase64;
          }
        } catch (_) {
          // Si on n'est pas dans le contexte du provider (rare, mais prudent)
        }

        return Transform.translate(
          offset: Offset(0, _floatAnimation.value + _jumpAnimation.value),
          child: GestureDetector(
            onTap: () {
              sauter();
              AudioService.jouerSonMessage();
            },
            child: Container(
              height: widget.height,
              width: widget.width,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: Offset(0, 10 - _floatAnimation.value),
                )
              ],
            ),
            child: ClipOval(
              child: base64Image != null 
                ? Image.memory(
                    base64Decode(base64Image),
                    fit: BoxFit.cover,
                  )
                : Image.asset(currentImagePath, fit: BoxFit.cover),
            ),
          ),
        ),
      );
      },
    );
  }
}
