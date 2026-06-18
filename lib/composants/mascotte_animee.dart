import 'package:flutter/material.dart';

class MascotteAnimee extends StatefulWidget {
  final String imagePath;
  final double height;
  final double width;

  const MascotteAnimee({
    super.key,
    required this.imagePath,
    this.height = 150,
    this.width = 150,
  });

  @override
  State<MascotteAnimee> createState() => MascotteAnimeeState();
}

class MascotteAnimeeState extends State<MascotteAnimee> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _jumpController;
  late Animation<double> _floatAnimation;
  late Animation<double> _jumpAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation de flottement (Idle)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Animation de saut (Joy)
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -30).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: -30, end: 0).chain(CurveTween(curve: Curves.bounceOut)), weight: 50),
    ]).animate(_jumpController);
  }

  void sauter() {
    if (!_jumpController.isAnimating) {
      _jumpController.forward(from: 0);
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
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value + _jumpAnimation.value),
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
              child: Image.asset(widget.imagePath, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }
}
