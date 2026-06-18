import 'dart:math';
import 'package:flutter/material.dart';

class FondAnimeCode extends StatefulWidget {
  final Widget child;
  const FondAnimeCode({super.key, required this.child});

  @override
  State<FondAnimeCode> createState() => _FondAnimeCodeState();
}

class _FondAnimeCodeState extends State<FondAnimeCode> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _colorController;
  final List<CodeSnippet> _snippets = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    for (int i = 0; i < 25; i++) {
      _snippets.add(_createSnippet());
    }
  }

  CodeSnippet _createSnippet() {
    final texts = ['print()', 'if:', 'for:', 'class', 'while', 'def', 'import', 'return'];
    return CodeSnippet(
      text: texts[_random.nextInt(texts.length)],
      position: Offset(_random.nextDouble(), _random.nextDouble()),
      speed: _random.nextDouble() * 0.05 + 0.02,
      opacity: _random.nextDouble() * 0.05 + 0.02,
      size: _random.nextDouble() * 10 + 10,
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dégradé de fond animé
        AnimatedBuilder(
          animation: _colorController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(_random.nextDouble() - 0.5, _random.nextDouble() - 0.5),
                  radius: 1.5,
                  colors: [
                    Color.lerp(const Color(0xFF1E1B4B), const Color(0xFF312E81), _colorController.value)!,
                    const Color(0xFF0F172A),
                  ],
                ),
              ),
            );
          },
        ),
        
        // Particules de code
        AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            return CustomPaint(
              painter: _CodePainter(_snippets, _mainController.value),
              child: Container(),
            );
          },
        ),
        
        // Effet de halo lumineux
        _buildGlow(Alignment.topLeft, Colors.blueAccent.withValues(alpha: 0.1)),
        _buildGlow(Alignment.bottomRight, Colors.indigoAccent.withValues(alpha: 0.1)),
        
        widget.child,
      ],
    );
  }

  Widget _buildGlow(Alignment alignment, Color color) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: alignment,
            radius: 1.0,
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class CodeSnippet {
  final String text;
  final Offset position;
  final double speed;
  final double opacity;
  final double size;

  CodeSnippet({
    required this.text,
    required this.position,
    required this.speed,
    required this.opacity,
    required this.size,
  });
}

class _CodePainter extends CustomPainter {
  final List<CodeSnippet> snippets;
  final double animationValue;

  _CodePainter(this.snippets, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var snippet in snippets) {
      final double yPos = ((snippet.position.dy + (animationValue * snippet.speed)) % 1.0) * size.height;
      final double xPos = snippet.position.dx * size.width;
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: snippet.text,
          style: TextStyle(
            color: Colors.blue.withValues(alpha: snippet.opacity),
            fontSize: snippet.size,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(xPos, yPos));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
