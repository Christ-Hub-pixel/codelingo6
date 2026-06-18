import 'package:flutter/material.dart';
import 'dart:math' as math;

class FondInformatique extends StatefulWidget {
  final Widget child;
  const FondInformatique({super.key, required this.child});

  @override
  State<FondInformatique> createState() => _FondInformatiqueState();
}

class _FondInformatiqueState extends State<FondInformatique> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_BinaryDigit> _digits = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialiser quelques chiffres
    for (int i = 0; i < 40; i++) {
      _digits.add(_createDigit());
    }
  }

  _BinaryDigit _createDigit() {
    return _BinaryDigit(
      x: _random.nextDouble(),
      y: _random.nextDouble() * 1.5 - 0.5,
      speed: _random.nextDouble() * 0.002 + 0.001,
      value: _random.nextBool() ? "0" : "1",
      opacity: _random.nextDouble() * 0.3 + 0.05,
      size: _random.nextDouble() * 10 + 10,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            _updateDigits();
            return CustomPaint(
              painter: _MatrixPainter(digits: _digits),
              child: Container(),
            );
          },
        ),
        widget.child,
      ],
    );
  }

  void _updateDigits() {
    for (var digit in _digits) {
      digit.y += digit.speed;
      if (digit.y > 1.1) {
        digit.y = -0.1;
        digit.x = _random.nextDouble();
      }
    }
  }
}

class _BinaryDigit {
  double x;
  double y;
  double speed;
  String value;
  double opacity;
  double size;

  _BinaryDigit({
    required this.x,
    required this.y,
    required this.speed,
    required this.value,
    required this.opacity,
    required this.size,
  });
}

class _MatrixPainter extends CustomPainter {
  final List<_BinaryDigit> digits;
  _MatrixPainter({required this.digits});

  @override
  void paint(Canvas canvas, Size size) {
    for (var digit in digits) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: digit.value,
          style: TextStyle(
            color: Colors.blue.withValues(alpha: digit.opacity),
            fontSize: digit.size,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(digit.x * size.width, digit.y * size.height),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
